use std::{str::FromStr, sync::Arc};

use anyhow::{bail, Result};
use cashu_crab::types::Token;
use nostr_sdk::prelude::*;
use tokio::sync::{broadcast, mpsc, Mutex};
use tokio::time::{timeout, Duration};

use crate::types::ChannelMessage;
use crate::{
    database,
    types::{
        self, CashuTransaction, Conversation, Direction, KeyData, Message, Picture, Transaction,
    },
    utils::unix_time,
};

#[derive(Clone, Debug)]
pub struct Nostr {
    client: Arc<Mutex<Option<Client>>>,
    nostr_rx: Arc<Mutex<mpsc::Receiver<ChannelMessage>>>,
    nostr_tx: mpsc::Sender<ChannelMessage>,
    nostr_res_rx: Arc<Mutex<broadcast::Receiver<ChannelMessage>>>,
    nostr_res_tx: broadcast::Sender<ChannelMessage>,
}

impl Nostr {
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

    /// Msats to sats
    fn invoice_amount(amount_msat: Option<u64>) -> Option<u64> {
        amount_msat.map(|amount_msat| amount_msat / 1000)
    }

    /// Init Nostr Client
    pub(crate) async fn new(private_key: &Option<String>) -> Result<Self> {
        let (nostr_tx, nostr_rx) = mpsc::channel::<ChannelMessage>(100);

        let (nostr_res_tx, nostr_res_rx) = broadcast::channel::<ChannelMessage>(100);
        let keys = Self::handle_keys(private_key)?;

        let mut relays = database::nostr::get_relays().await?;

        if relays.is_empty() {
            // FIXME: Don't just default to this fine for dev
            relays.push("wss://relay.damus.io".to_string());
            database::nostr::save_relays(&relays).await?;
        }

        let client = Client::new(&keys);
        let relays = relays.iter().map(|url| (url, None)).collect();
        client.add_relays(relays).await?;
        client.connect().await;

        let subscription = Filter::new()
            .pubkey(keys.public_key())
            .kind(Kind::EncryptedDirectMessage)
            .since(Timestamp::now());

        client.subscribe(vec![subscription]).await;

        // if let Err(err) = Self::get_events_since_last(&keys.public_key()).await {
        //    bail!(err);
        // }

        /*
        if let Ok(contacts) = Self::get_contacts(&keys.public_key()).await {
             get_metadata(contacts).await?;
        }
                */

        // REVIEW: This breaks it, likely cant get a lock on something
        // Not sure I want to refresh all the contacts on start up anyway
        // if let Err(err) = refresh_contacts().await {
        //     bail!(err);
        // }

        Ok(Self {
            client: Arc::new(Mutex::new(Some(client))),
            nostr_rx: Arc::new(Mutex::new(nostr_rx)),
            nostr_tx,
            nostr_res_rx: Arc::new(Mutex::new(nostr_res_rx)),
            nostr_res_tx,
        })
    }

    /// Perform Nostr tasks
    pub async fn run(&mut self) -> Result<()> {
        loop {
            let res = self.run_internal().await;
            if let Err(e) = res {
                bail!("Run error: {:?}", e);
            }
        }
    }

    /// Internal select loop for preforming nostr operations
    async fn run_internal(&mut self) -> Result<()> {
        let mut client_guard = self.client.lock().await;
        let mut nostr_rx = self.nostr_rx.lock().await;
        if let Some(client) = client_guard.as_mut() {
            let mut stop_listen = false;
            loop {
                tokio::select! {
                    m = nostr_rx.recv() => {
                        match m {
                            // TODO: Change this to log out
                            Some(ChannelMessage::Shutdown) => {
                                client.disconnect().await?;
                                stop_listen = true;
                                // client = None;
                                break;
                            },
                            Some(ChannelMessage::GetKeys) => {
                                let npub = client.keys().public_key().to_bech32()?;

                                let nsec = match client.keys().secret_key() {
                                    Ok(sec) => Some(sec.to_bech32()?),
                                    Err(_) => None,
                                };
                                let keydata = KeyData {
                                    npub,
                                    nsec
                                };
                                self.nostr_res_tx.send(ChannelMessage::KeyData(Some(keydata))).unwrap();
                            },
                            Some(ChannelMessage::AddRelay(relay)) => {
                                client.add_relay(relay, None).await?;

                                let relays: Vec<String> = client.relays()
                                .await
                                .keys()
                                .map(|u| u.to_string())
                                .collect();

                                database::nostr::save_relays(&relays).await?;
                            },
                            Some(ChannelMessage::RemoveRelay(relay)) => {
                                client.remove_relay(relay).await?;

                                let relays: Vec<String> = client
                                .relays()
                                .await
                                .keys()
                                .map(|u| u.to_string())
                                .collect();

                                database::nostr::save_relays(&relays).await?;
                            },
                            Some(ChannelMessage::GetRelays) => {
                                let client_relays = client.relays().await;
                                let client_relays_string: Vec<String> =
                                        client_relays.keys().map(|k| k.to_string()).collect();
                                self.nostr_res_tx.send(ChannelMessage::Relays(client_relays_string))?;
                            },
                            Some(ChannelMessage::SetContacts(contacts)) => {
                                client.set_contact_list(contacts).await?;
                            },
                            Some(ChannelMessage::GetMetadata(pubkeys)) => {
                                let mut contacts = vec![];
                                let pubkeys: Vec<String> = pubkeys.iter().map(|x| x.to_string()).collect();
                                let subscription = Filter::new().authors(pubkeys.clone()).kind(Kind::Metadata);
                                let timeout = Duration::from_secs(30);
                                let events = client
                                    .get_events_of(vec![subscription.clone()], Some(timeout))
                                    .await?;

                                for event in events {
                                    if let Some(contact) = Self::handle_metadata(event).await? {
                                        contacts.push(contact);
                                    }
                                }
                                self.nostr_res_tx.send(ChannelMessage::Contacts(contacts))?;
                            },
                            Some(ChannelMessage::SendDirectMessage(receiver, msg)) => {
                                client.send_direct_msg(receiver, msg).await?;
                            },
                            Some(ChannelMessage::GetContacts(pubkey)) => {
                                let mut pubkeys = vec![];
                                let subscription = Filter::new().author(pubkey.to_string()).kind(Kind::ContactList);

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
                                self.nostr_res_tx.send(ChannelMessage::ContactPubkeys(pubkeys))?;

                            },
                            Some(_) => {},
                            None => {},
                        }
                    }
                    _ = async {
                        client.handle_notifications(|notification| async {
                        if let RelayPoolNotification::Event(_url, event) = notification {
                            if let Err(_err) = Self::handle_event(event, &client.keys()).await {
                                                        // Handle the error if needed
                            }
                        }
                        Ok(stop_listen)
                        }).await
                    } => {}
                }
            }
            if stop_listen {
                *client_guard = None;
            }
        }

        Ok(())
    }

    pub(crate) async fn get_keys(&self) -> Result<Option<KeyData>> {
        self.nostr_tx.send(ChannelMessage::GetKeys).await?;
        let timeout_duration = Duration::from_secs(5);

        let mut nostr_rx = self.nostr_res_rx.lock().await;

        match timeout(timeout_duration, nostr_rx.recv()).await {
            Ok(Ok(msg)) => {
                if let ChannelMessage::KeyData(keydata) = msg {
                    return Ok(keydata);
                }
            }
            Ok(Err(_)) => (),
            Err(_) => (),
        }

        Ok(None)
    }

    /// Handle Direct message
    /// Invoice, cahsu token, invoice
    async fn handle_message(
        msg: &str,
        author: XOnlyPublicKey,
        created_at: Timestamp,
    ) -> Result<()> {
        if msg.to_lowercase().as_str().starts_with("lnbc") {
            // Invoice message
            let invoice = lightning_invoice::Invoice::from_str(msg)?;

            let transaction = Transaction::LNTransaction(types::LNTransaction::new(
                types::TransactionStatus::Sent,
                Self::invoice_amount(invoice.amount_milli_satoshis()).unwrap_or(0),
                None,
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
                types::TransactionStatus::Pending(types::Pending::Receive),
                token_info.0,
                &token_info.1,
                msg,
                Some(author.to_string()),
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
        if let Ok(info) = Metadata::from_json(&event.content) {
            let picture = info.picture.map(|picture_url| Picture::new(&picture_url));

            let contact = types::Contact {
                pubkey: event.pubkey.to_string(),
                npub: event.pubkey.to_bech32().unwrap_or(event.pubkey.to_string()),
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
                        if let Err(err) =
                            Self::handle_message(&msg, event.pubkey, event.created_at).await
                        {
                            bail!(err);
                        }
                    }
                    Err(e) => {
                        log::error!("Impossible to decrypt direct message: {e}")
                    }
                }
            }
            Kind::Metadata => if let Err(_err) = Self::handle_metadata(event).await {},
            _ => (),
        }
        Ok(())
    }

    /// Log Out
    pub(crate) async fn log_out(&self) -> Result<()> {
        self.nostr_tx.send(ChannelMessage::Shutdown).await?;
        Ok(())
    }

    /// Add Relay
    pub(crate) async fn add_relay(&self, relay: String) -> Result<()> {
        self.nostr_tx.send(ChannelMessage::AddRelay(relay)).await?;

        Ok(())
    }

    /// Remove relay
    pub(crate) async fn remove_relay(&self, relay: String) -> Result<()> {
        self.nostr_tx
            .send(ChannelMessage::RemoveRelay(relay))
            .await?;
        Ok(())
    }

    /// Get relays
    pub(crate) async fn get_relays(&mut self) -> Result<Vec<String>> {
        let timeout_duration = Duration::from_secs(5);
        self.nostr_tx.send(ChannelMessage::GetRelays).await?;

        let mut nostr_res_rx = self.nostr_res_rx.lock().await;
        loop {
            match timeout(timeout_duration, nostr_res_rx.recv()).await {
                Ok(Ok(msg)) => {
                    if let ChannelMessage::Relays(relays) = msg {
                        return Ok(relays);
                    }
                }
                Ok(Err(_)) => (),
                Err(_) => break,
            }
        }

        Ok(vec![])
    }

    /*
    pub(crate) async fn _get_events_since_last(_pubkey: &XOnlyPublicKey) -> Result<()> {
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
                Self::handle_event(event, &client.keys()).await?;
            }
        }

        Ok(())
    }
        */

    /// Get metadata for pubkeys
    pub(crate) async fn get_metadata(
        &mut self,
        pubkeys: Vec<XOnlyPublicKey>,
    ) -> Result<Vec<types::Contact>> {
        self.nostr_tx
            .send(ChannelMessage::GetMetadata(pubkeys))
            .await?;
        let timeout_duration = Duration::from_secs(5);

        let mut nostr_res_rx = self.nostr_res_rx.lock().await;
        loop {
            match timeout(timeout_duration, nostr_res_rx.recv()).await {
                Ok(Ok(msg)) => {
                    if let ChannelMessage::Contacts(contacts) = msg {
                        return Ok(contacts);
                    }
                }
                Ok(Err(_)) => (),
                Err(_) => break,
            };
        }

        Ok(vec![])
    }

    pub(crate) async fn _refresh_contacts() -> Result<()> {
        /*
        let mut client = SEND_CLIENT.try_lock()?;

        if let Some(client) = client.as_mut() {
            let x_pubkey = client.keys().public_key();
            let contacts = Self::get_contacts(&x_pubkey).await?;
            Self::get_metadata(contacts).await?;
        }
        */
        Ok(())
    }

    /// Get contacts for a given pubkey
    pub(crate) async fn get_contacts(
        &mut self,
        pubkey: &XOnlyPublicKey,
    ) -> Result<Vec<XOnlyPublicKey>> {
        self.nostr_tx
            .send(ChannelMessage::GetContacts(pubkey.to_owned()))
            .await?;
        let timeout_duration = Duration::from_secs(5);

        let mut nostr_res_rx = self.nostr_res_rx.lock().await;
        loop {
            match timeout(timeout_duration, nostr_res_rx.recv()).await {
                Ok(Ok(msg)) => {
                    if let ChannelMessage::ContactPubkeys(contacts) = msg {
                        return Ok(contacts);
                    }
                }
                Ok(Err(_)) => (),
                Err(_) => break,
            };
        }

        Ok(vec![])
    }

    /// Set contact list
    pub(crate) async fn set_contact_list(&mut self) -> Result<()> {
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

        self.nostr_tx
            .send(ChannelMessage::SetContacts(contacts))
            .await?;

        Ok(())
    }

    /// Send message
    pub async fn send_message(
        &mut self,
        receiver: XOnlyPublicKey,
        message: &Message,
    ) -> Result<Conversation> {
        if let Ok(Some(msg)) = message.content().await {
            self.nostr_tx
                .send(ChannelMessage::SendDirectMessage(receiver, msg))
                .await?;
            if let Some(transaction_id) = message.id() {
                if let Ok(Some(transaction)) =
                    database::transactions::get_transaction(&transaction_id).await
                {
                    return Ok(Conversation::new(vec![message.clone()], vec![transaction]));
                }
            }
        }
        Ok(Conversation::new(vec![message.clone()], vec![]))
    }
}
