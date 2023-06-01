use std::time::Duration;
use std::{str::FromStr, sync::Arc};

use anyhow::{bail, Result};
use cashu_crab::types::Token;
use lazy_static::lazy_static;
use nostr_sdk::prelude::*;
use tokio::{sync::Mutex, task::JoinHandle};

use crate::{
    database,
    types::{self, CashuTransaction, Conversation, Direction, Message, Picture, Transaction},
    utils::unix_time,
};

lazy_static! {
    static ref LISTEN_CLIENT: Arc<Mutex<Option<Client>>> = Arc::new(Mutex::new(None));
    static ref SEND_CLIENT: Arc<Mutex<Option<Client>>> = Arc::new(Mutex::new(None));
}

#[derive(Clone)]
pub enum NostrMessage {}

/// Convert string key to nostr keys
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
pub(crate) async fn init_client(private_key: &Option<String>) -> Result<()> {
    let keys = handle_keys(private_key)?;

    if private_key.is_none() {
        if let Ok(secret_key) = keys.secret_key() {
            database::nostr::save_key(&secret_key.display_secret().to_string()).await?;
        }
    }

    let mut relays = database::nostr::get_relays().await?;

    if relays.is_empty() {
        // FIXME: Don't just default to this fine for dev
        relays.push("wss://thesimplekid.space".to_string());
        database::nostr::save_relays(&relays).await?;
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
    let mut g_client = LISTEN_CLIENT.lock().await;
    *g_client = Some(client);

    let mut s_client = SEND_CLIENT.lock().await;
    *s_client = Some(send_client);

    drop(s_client);
    drop(g_client);

    if let Err(err) = get_events_since_last(&keys.public_key()).await {
        bail!(err);
    }

    if let Ok(contacts) = get_contacts(&keys.public_key()).await {
        get_metadata(contacts).await?;
    }

    if let Err(err) = handle_notifications().await {
        log::error!("Error in handle_notifications: {:?}", err);
    }

    // REVIEW: This breaks it, likely cant get a lock on something
    // Not sure I want to refresh all the contacts on start up anyway
    // if let Err(err) = refresh_contacts().await {
    //     bail!(err);
    // }

    Ok(())
}

/// Msats to sats
fn invoice_amount(amount_msat: Option<u64>) -> Option<u64> {
    amount_msat.map(|amount_msat| amount_msat / 1000)
}

/// Handle Direct message
/// Invoice, cahsu token, invoice
async fn handle_message(msg: &str, author: XOnlyPublicKey, created_at: Timestamp) -> Result<()> {
    if msg.to_lowercase().as_str().starts_with("lnbc") {
        // Invoice message
        let invoice = lightning_invoice::Invoice::from_str(msg)?;

        let transaction = Transaction::LNTransaction(types::LNTransaction::new(
            None,
            invoice_amount(invoice.amount_milli_satoshis()).unwrap_or(0),
            None,
            msg,
            "",
        ));

        database::transactions::add_transaction(&transaction).await?;

        let message = Message::Token {
            direction: Direction::Received,
            time: unix_time(),
            transaction_id: transaction.id(),
        };
        database::message::add_message(author, &message).await?;
    }
    // cashu token
    else if msg.to_lowercase().as_str().starts_with("cashu") {
        let token = Token::from_str(msg)?;
        let token_info = token.token_info();

        let transaction = Transaction::CashuTransaction(CashuTransaction::new(
            None,
            token_info.0,
            &token_info.1,
            msg,
        ));

        database::transactions::add_transaction(&transaction).await?;

        let message = Message::Token {
            direction: Direction::Received,
            time: unix_time(),
            transaction_id: transaction.id(),
        };

        database::message::add_message(author, &message).await?;
    } else {
        // Text Message
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

/// Handle metadata event
async fn handle_metadata(event: Event) -> Result<Option<types::Contact>> {
    if let Ok(info) = Metadata::from_json(&event.clone().content) {
        let picture = match info.picture {
            Some(picture_url) => Some(Picture::new(&picture_url)),
            None => None,
        };

        let contact = types::Contact {
            pubkey: event.pubkey.to_string(),
            npub: event
                .clone()
                .pubkey
                .to_bech32()
                .unwrap_or(event.pubkey.to_string()),
            name: info.name,
            picture,
            lud16: info.lud16,
            created_at: Some(event.created_at.as_u64()),
        };

        Ok(Some(contact))
    } else {
        bail!("Could not decode contact: {:?}", event);
    }
}

/// Handle nostr event
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
        Kind::Metadata => if let Err(_err) = handle_metadata(event).await {},
        _ => (),
    }
    Ok(())
}

/// Add Relay
pub(crate) async fn add_relay(relay: String) -> Result<()> {
    let client = SEND_CLIENT.clone();

    let _result: JoinHandle<Result<()>> = tokio::spawn(async move {
        let mut client_guard = client.lock().await;
        if let Some(client) = client_guard.as_mut() {
            client.add_relay(relay, None).await?;

            let relays: Vec<String> = client
                .relays()
                .await
                .keys()
                .map(|u| u.to_string())
                .collect();

            database::nostr::save_relays(&relays).await?;
        }

        Ok(())
    });

    Ok(())
}

/// Remove relay
pub(crate) async fn remove_relay(relay: String) -> Result<()> {
    let client = SEND_CLIENT.clone();

    let _result: JoinHandle<Result<()>> = tokio::spawn(async move {
        let mut client_guard = client.lock().await;
        if let Some(client) = client_guard.as_mut() {
            client.remove_relay(relay).await?;

            let relays: Vec<String> = client
                .relays()
                .await
                .keys()
                .map(|u| u.to_string())
                .collect();

            database::nostr::save_relays(&relays).await?;
        }

        Ok(())
    });

    Ok(())
}

/// Get relays
pub(crate) async fn get_relays() -> Result<Vec<String>> {
    let client = SEND_CLIENT.clone();

    let mut client_guard = client.lock().await;

    let mut relays = vec![];
    if let Some(client) = client_guard.as_mut() {
        let client_relays = client.relays().await;
        let client_relays_string: Vec<String> =
            client_relays.keys().map(|k| k.to_string()).collect();
        relays = client_relays_string;
    }

    Ok(relays)
}

pub(crate) async fn handle_notifications() -> Result<()> {
    let client = LISTEN_CLIENT.clone();

    let _result: JoinHandle<Result<()>> = tokio::spawn(async move {
        let mut client_guard = client.lock().await;

        if let Some(client) = client_guard.as_mut() {
            client
                .handle_notifications(|notification| async {
                    if let RelayPoolNotification::Event(_url, event) = notification {
                        if let Err(_err) = handle_event(event, &client.keys()).await {
                            // bail!(err);
                        }
                    }
                    Ok(())
                })
                .await?;
        }
        Ok(())
    });

    Ok(())
}

pub(crate) async fn get_events_since_last(pubkey: &XOnlyPublicKey) -> Result<()> {
    let mut client = SEND_CLIENT.lock().await;

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
pub(crate) async fn get_metadata(pubkeys: Vec<XOnlyPublicKey>) -> Result<Vec<types::Contact>> {
    let mut client = SEND_CLIENT.lock().await;

    let mut contacts = vec![];
    if let Some(client) = client.as_mut() {
        client.connect().await;
        let pubkeys: Vec<String> = pubkeys.iter().map(|x| x.to_string()).collect();
        let subscription = Filter::new().authors(pubkeys.clone()).kind(Kind::Metadata);
        let timeout = Duration::from_secs(30);
        let events = client
            .get_events_of(vec![subscription.clone()], Some(timeout))
            .await?;

        for event in events {
            if let Some(contact) = handle_metadata(event).await? {
                contacts.push(contact);
            }
        }
    }

    Ok(contacts)
}

pub(crate) async fn _refresh_contacts() -> Result<()> {
    let mut client = SEND_CLIENT.try_lock()?;

    if let Some(client) = client.as_mut() {
        let x_pubkey = client.keys().public_key();
        let contacts = get_contacts(&x_pubkey).await?;
        get_metadata(contacts).await?;
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

/// Set contact list
pub(crate) async fn set_contact_list() -> Result<()> {
    let mut client = SEND_CLIENT.lock().await;

    if let Some(client) = client.as_mut() {
        let contacts = database::contacts::get_contacts().await?;

        let contacts: Vec<nostr_sdk::Contact> = contacts
            .iter()
            .map(|x| {
                nostr_sdk::Contact::new::<String>(
                    XOnlyPublicKey::from_str(&x.pubkey).unwrap(),
                    None,
                    None,
                )
            })
            .collect();

        client.set_contact_list(contacts).await?;
    };

    Ok(())
}

/// Send message
pub async fn send_message(receiver: XOnlyPublicKey, message: &Message) -> Result<Conversation> {
    let mut client = SEND_CLIENT.lock().await;

    if let Some(client) = client.as_mut() {
        if let Ok(Some(msg)) = message.content().await {
            client.send_direct_msg(receiver, msg).await?;
            if let Some(transaction_id) = message.id() {
                if let Ok(Some(transaction)) =
                    database::transactions::get_transaction(&transaction_id).await
                {
                    return Ok(Conversation::new(vec![message.clone()], vec![transaction]));
                }
            }
        }
    }

    Ok(Conversation::new(vec![message.clone()], vec![]))
}
