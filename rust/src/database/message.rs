use anyhow::{anyhow, Result};
use bitcoin::secp256k1::XOnlyPublicKey;
use nostr_sdk::Timestamp;
use redb::{ReadableMultimapTable, ReadableTable};

use super::{CONFIG, DB, MESSAGES};
use crate::types::Message;
use crate::utils;

pub(crate) async fn most_recent_event_time() -> Result<()> {
    let db = DB.try_lock().unwrap();
    let db = db
        .as_ref()
        .ok_or_else(|| anyhow!("DB not set".to_string()))?;

    let write_txn = db.begin_write()?;
    {
        let mut settings_table = write_txn.open_table(CONFIG)?;

        settings_table.insert("most_recent_event", Timestamp::now().to_string().as_str())?;
    }
    write_txn.commit()?;

    Ok(())
}

pub(crate) async fn _get_most_recent_event_time() -> Result<Option<String>> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| anyhow!("DB not set".to_string()))?;

    let read_txn = db.begin_read()?;
    let settings_table = read_txn.open_table(CONFIG)?;

    let key = settings_table.get("most_recent_event")?;

    match key {
        Some(key) => Ok(Some(key.value().to_string())),
        None => Ok(None),
    }
}

pub(crate) async fn add_message(author: XOnlyPublicKey, message: &Message) -> Result<()> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| anyhow!("DB not set".to_string()))?;

    let write_txn = db.begin_write()?;
    {
        let mut message_table = write_txn.open_multimap_table(MESSAGES)?;

        message_table.insert(
            utils::encode_pubkey(&author).as_str(),
            serde_json::to_string(&message)?.as_str(),
        )?;
    }
    write_txn.commit()?;

    Ok(())
}

pub(crate) async fn get_messages(pubkey: &XOnlyPublicKey) -> Result<Vec<Message>> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| anyhow!("DB not set".to_string()))?;
    let read_txn = db.begin_read()?;
    let table = read_txn.open_multimap_table(MESSAGES)?;

    let messages = table.get(utils::encode_pubkey(pubkey).as_str())?;

    let mut messages: Vec<Message> = messages
        .into_iter()
        .filter_map(|item| {
            if let Ok(value) = item {
                serde_json::from_str(value.value()).ok()
            } else {
                None
            }
        })
        .collect();

    // Sort in ascending order
    messages.sort_by_key(|message| match message {
        Message::Text { time, .. } => *time,
        Message::Invoice { time, .. } => *time,
        Message::Token { time, .. } => *time,
    });

    Ok(messages)
}
