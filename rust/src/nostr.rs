use std::time::Duration;

use anyhow::{bail, Result};
use cashu_crab::types::Token;
use lazy_static::lazy_static;
use nostr_sdk::prelude::*;
use std::{str::FromStr, sync::Arc};
use tokio::{sync::Mutex, task::JoinHandle};

use crate::{
    database,
    types::{Contact, Direction, InvoiceStatus, Message},
};

lazy_static! {
    static ref CLIENT: Arc<Mutex<Option<Client>>> = Arc::new(Mutex::new(None));
    static ref SEND_CLIENT: Arc<Mutex<Option<Client>>> = Arc::new(Mutex::new(None));
}

#[derive(Clone)]
pub enum NostrMessage {}

fn handle_keys(private_key: &Option<String>) -> Result<Keys> {
    // Parse and validate private key
    let keys = match private_key {
        Some(pk) => {
            // create a new identity using the provided private key
            Keys::from_sk_str(pk.as_str())?
        }
        None => Keys::generate(),
    };

    Ok(keys)
}

/// Init Nostr Client
pub(crate) async fn init_client(private_key: Option<String>, relays: Vec<String>) -> Result<()> {
    let keys = handle_keys(&private_key)?;

    if private_key.is_none() {
        if let Ok(secret_key) = keys.secret_key() {
            database::message::save_key(&secret_key.display_secret().to_string()).await?;
        }
    }

    let client = Client::new(&keys);
    let relays = relays.iter().map(|url| (url, None)).collect();
    client.add_relays(relays).await?;
    client.connect().await;

    let send_client = client.clone();

    let subscription = Filter::new()
        .pubkey(keys.public_key())
        .kind(Kind::EncryptedDirectMessage)
        .since(Timestamp::now());

    client.subscribe(vec![subscription]).await;
    let mut g_client = CLIENT.lock().await;
    *g_client = Some(client);

    let mut s_client = SEND_CLIENT.lock().await;
    *s_client = Some(send_client);

    //if let Err(err) = get_events_since_last(&keys.public_key()).await {
    //  bail!(err);
    //}

    if let Err(err) = handle_notifications().await {
        log::error!("Error in handle_notifications: {:?}", err);
    }

    Ok(())
}

fn invoice_amount(amount_msat: Option<u64>) -> Option<u64> {
    match amount_msat {
        Some(amount_msat) => Some(amount_msat / 1000),
        None => None,
    }
}

async fn handle_message(msg: &str, author: XOnlyPublicKey, created_at: Timestamp) -> Result<()> {
    if msg.to_lowercase().as_str().starts_with("lnbc") {
        // Invoice message
        let invoice = lightning_invoice::Invoice::from_str(msg)?;
        let message = Message::Invoice {
            direction: Direction::Received,
            time: created_at.as_u64(),
            bolt11: msg.to_string(),
            amount: invoice_amount(invoice.amount_milli_satoshis()),
            // Check if its paid
            status: InvoiceStatus::Unpaid,
        };

        database::message::add_message(author, &message).await?;
    }
    // cashu token
    else if msg.to_lowercase().as_str().starts_with("cashu") {
        let token = Token::from_str(msg)?;
        let token_info = token.token_info();
        let message = Message::Token {
            direction: Direction::Received,
            time: created_at.as_u64(),
            token: msg.to_string(),
            amount: Some(token_info.0),
            mint: token_info.1,
            status: crate::types::TokenStatus::Spendable,
        };

        database::message::add_message(author, &message).await?;
    } else {
        database::message::add_message(
            author,
            &Message::Text {
                direction: Direction::Received,
                time: created_at.as_u64(),
                content: msg.to_string(),
            },
        )
        .await?
    }

    Ok(())
}

fn from_value(value: Option<&serde_json::Value>) -> Option<String> {
    value.and_then(|v| serde_json::to_string(v).ok().map(|s| s.replace("\"", "")))
}

async fn handle_metadata(event: Event) -> Result<()> {
    // TODO: Use `Metadat::from_str`
    // https://github.com/rust-nostr/nostr/issues/109
    if let Ok(info) = serde_json::from_str::<Value>(&event.clone().content) {
        let contact = Contact {
            npub: event
                .clone()
                .pubkey
                .to_bech32()
                .unwrap_or(event.pubkey.to_string()),
            name: from_value(info.get("name")),
            picture: from_value(info.get("picture")),
            lud16: from_value(info.get("lud16")),
        };

        if let Err(_err) =
            database::message::add_contact(&event.pubkey.to_string(), contact.clone()).await
        {
            bail!("Could not add Contact");
        }

        Ok(())

        // bail!("{:?}", contact);
    } else {
        bail!("Could not decode contact: {:?}", event);
    }
}

async fn handle_event(event: Event, keys: &Keys) -> Result<()> {
    database::message::most_recent_event_time().await?;
    match event.kind {
        Kind::EncryptedDirectMessage => {
            match decrypt(&keys.secret_key()?, &event.pubkey, &event.content) {
                Ok(msg) => {
                    if let Err(err) = handle_message(&msg, event.pubkey, event.created_at).await {
                        bail!(err);
                    }
                }
                Err(e) => {
                    log::error!("Impossible to decrypt direct message: {e}")
                }
            }
        }
        Kind::Metadata => {
            if let Err(_err) = handle_metadata(event).await {
                ()
            }
        }
        _ => (),
    }
    Ok(())
}

pub(crate) async fn handle_notifications() -> Result<()> {
    let client = CLIENT.clone();

    let _result: JoinHandle<Result<()>> = tokio::spawn(async move {
        let mut client_guard = client.lock().await;

        if let Some(client) = client_guard.as_mut() {
            client
                .handle_notifications(|notification| async {
                    if let RelayPoolNotification::Event(_url, event) = notification {
                        if let Err(_err) = handle_event(event, &client.keys()).await {
                            // bail!(err);
                            ()
                        }
                    }
                    Ok(())
                })
                .await?;
        }
        Ok(())
    });

    // if let Err(err) = result.await {
    //    print!("{:?}", err);
    // }

    Ok(())
}

pub(crate) async fn get_events_since_last(pubkey: &XOnlyPublicKey) -> Result<()> {
    let mut client = SEND_CLIENT.lock().await;

    // bail!("X: {}", pubkey);

    if let Some(client) = client.as_mut() {
        let time = database::message::get_most_recent_event_time().await?;

        client.connect().await;
        let subscription = match time {
            Some(time) => Filter::new()
                .pubkey(pubkey.to_owned())
                .kind(Kind::EncryptedDirectMessage)
                .since(Timestamp::from_str(&time)?),
            None => Filter::new()
                .pubkey(pubkey.to_owned())
                .kind(Kind::EncryptedDirectMessage),
        };
        let timeout = Duration::from_secs(30);
        let events = client
            .get_events_of(vec![subscription.clone()], Some(timeout))
            .await?;

        for event in events {
            handle_event(event, &client.keys()).await?;
        }
    }

    Ok(())
}

/// Get metadata for pubkeys
pub(crate) async fn get_metadata(pubkeys: Vec<XOnlyPublicKey>) -> Result<()> {
    let mut client = SEND_CLIENT.lock().await;

    if let Some(client) = client.as_mut() {
        client.connect().await;
        let pubkeys: Vec<String> = pubkeys.iter().map(|x| x.to_string()).collect();
        let subscription = Filter::new().authors(pubkeys.clone()).kind(Kind::Metadata);
        let timeout = Duration::from_secs(30);
        let events = client
            .get_events_of(vec![subscription.clone()], Some(timeout))
            .await?;

        for event in events {
            handle_metadata(event).await?;
        }
    }

    Ok(())
}

/// Get contacts for a given pubkey
pub(crate) async fn get_contacts(pubkey: &XOnlyPublicKey) -> Result<Vec<XOnlyPublicKey>> {
    let mut client = SEND_CLIENT.lock().await;

    let mut pubkeys: Vec<XOnlyPublicKey> = Vec::new();
    if let Some(client) = client.as_mut() {
        client.connect().await;
        let subscription = Filter::new()
            .author(pubkey.to_string())
            .kind(Kind::ContactList);

        let timeout = Duration::from_secs(30);
        let events = client
            .get_events_of(vec![subscription.clone()], Some(timeout))
            .await?;

        for event in events.into_iter() {
            for tag in event.tags.into_iter() {
                match tag {
                    Tag::PubKey(pk, _) => pubkeys.push(pk),
                    Tag::ContactList { pk, .. } => pubkeys.push(pk),
                    _ => (),
                }
            }
        }
    }

    Ok(pubkeys)
}

pub async fn send_message(receiver: XOnlyPublicKey, message: &Message) -> Result<()> {
    let mut client = SEND_CLIENT.lock().await;

    if let Some(client) = client.as_mut() {
        client.send_direct_msg(receiver, message.content()).await?;
    }

    Ok(())
}
