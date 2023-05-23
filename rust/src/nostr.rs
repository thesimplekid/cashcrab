use std::time::Duration;

use anyhow::{bail, Result};
use cashu_crab::types::Token;
use lazy_static::lazy_static;
use nostr_sdk::prelude::*;
use std::{str::FromStr, sync::Arc};
use tokio::sync::Mutex;

use crate::{
    database,
    types::{Contact, Direction, InvoiceStatus, Message},
};

lazy_static! {
    static ref CLIENT: Arc<Mutex<Option<Client>>> = Arc::new(Mutex::new(None));
}

fn handle_keys(private_key: Option<String>) -> Result<Keys> {
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
    let keys = handle_keys(private_key)?;

    let client = Client::new(&keys);
    let relays = relays.iter().map(|url| (url, None)).collect();
    client.add_relays(relays).await?;
    client.connect().await;

    let subscription = Filter::new()
        .pubkey(keys.public_key())
        .kind(Kind::EncryptedDirectMessage)
        .since(Timestamp::now());

    client.subscribe(vec![subscription]).await;

    // handle_notifications().await?;

    let mut g_client = CLIENT.lock().await;
    *g_client = Some(client);

    Ok(())
}

fn invoice_amount(amount_msat: Option<u64>) -> Option<u64> {
    match amount_msat {
        Some(amount_msat) => Some(amount_msat / 1000),
        None => None,
    }
}

async fn handle_message(event: Event, msg: &str) -> Result<()> {
    match msg.to_lowercase().as_str() {
        // Invoice message
        "lnbc" => {
            let invoice = lightning_invoice::Invoice::from_str(msg)?;
            let message = Message::Invoice {
                direction: Direction::Received,
                time: event.created_at.as_u64(),
                bolt11: msg.to_string(),
                amount: invoice_amount(invoice.amount_milli_satoshis()),
                // Check if its paid
                status: InvoiceStatus::Unpaid,
            };

            database::message::add_message(event.pubkey, &message).await?;
        }
        // cashu token
        "cashua" => {
            let token = Token::from_str(msg)?;
            let token_info = token.token_info();
            let message = Message::Token {
                direction: Direction::Received,
                time: event.created_at.as_u64(),
                token: msg.to_string(),
                amount: Some(token_info.0),
                mint: token_info.1,
                status: crate::types::TokenStatus::Spendable,
            };

            database::message::add_message(event.pubkey, &message).await?;
        }
        // Text message
        _ => {
            database::message::add_message(
                event.pubkey,
                &Message::Text {
                    direction: Direction::Received,
                    time: event.created_at.as_u64(),
                    content: msg.to_string(),
                },
            )
            .await?
        }
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

pub(crate) async fn handle_notifications() -> Result<()> {
    let client = CLIENT.clone();
    let _task: tokio::task::JoinHandle<Result<()>> = tokio::spawn(async move {
        let mut client = client.lock().await;

        if let Some(client) = client.as_mut() {
            client
                .handle_notifications(|notification| async {
                    if let RelayPoolNotification::Event(_url, event) = notification {
                        match event.kind {
                            Kind::EncryptedDirectMessage => {
                                match decrypt(
                                    &client.keys().secret_key()?,
                                    &event.pubkey,
                                    &event.content,
                                ) {
                                    Ok(msg) => {
                                        if let Err(_err) = handle_message(event, &msg).await {
                                            ()
                                            // TODO: figure out logging
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
                    }
                    Ok(())
                })
                .await?;
        }

        Ok(())
    });
    Ok(())
}

pub(crate) async fn get_metadata(pubkey: &XOnlyPublicKey) -> Result<()> {
    let mut client = CLIENT.lock().await;

    // bail!("X: {}", x_pubkey);
    if let Some(client) = client.as_mut() {
        client.connect().await;
        let subscription = Filter::new()
            .author(pubkey.to_string())
            .kind(Kind::Metadata);
        /*
                bail!(
                    "{:?}, Relays: {:?}",
                    subscription.as_json(),
                    client.relays().await
                );
        */
        let timeout = Duration::from_secs(30);
        let events = client
            .get_events_of(vec![subscription.clone()], Some(timeout))
            .await?;

        if !events.is_empty() {
            handle_metadata(events[0].clone()).await?;
        }
        // bail!("Filter: {:?}, Events: {:?}", subscription, events);
    }

    Ok(())
}

pub async fn send_message(receiver: XOnlyPublicKey, message: &Message) -> Result<()> {
    let mut client = CLIENT.lock().await;

    if let Some(client) = client.as_mut() {
        client.send_direct_msg(receiver, message.content()).await?;
    }

    Ok(())
}
