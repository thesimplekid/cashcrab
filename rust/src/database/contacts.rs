use anyhow::{anyhow, Result};
use bitcoin::secp256k1::XOnlyPublicKey;
use redb::ReadableTable;

use super::{CONTACTS, DB, MESSAGES};
use crate::types;

pub(crate) async fn add_contacts(contacts: Vec<types::Contact>) -> Result<()> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| anyhow!("DB not set".to_string()))?;

    let write_txn = db.begin_write()?;
    {
        let mut contacts_table = write_txn.open_table(CONTACTS)?;

        for contact in contacts {
            contacts_table.insert(contact.pubkey.as_str(), contact.as_json().as_str())?;
        }
    }
    write_txn.commit()?;

    Ok(())
}

/// Delete contact and messages from db
pub(crate) async fn remove_contact(pubkey: &XOnlyPublicKey) -> Result<()> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| anyhow!("DB not set".to_string()))?;

    let write_txn = db.begin_write()?;
    {
        let mut contacts_table = write_txn.open_table(CONTACTS)?;

        contacts_table.remove(pubkey.to_string().as_str())?;
        let mut messages_table = write_txn.open_multimap_table(MESSAGES)?;

        messages_table.remove_all(pubkey.to_string().as_str())?;
    }
    write_txn.commit()?;

    Ok(())
}

pub(crate) async fn get_contacts() -> Result<Vec<types::Contact>> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| anyhow!("DB not set".to_string()))?;
    let read_txn = db.begin_read()?;
    let contacts_table = read_txn.open_table(CONTACTS)?;

    let contacts: Vec<types::Contact> = contacts_table.iter()?.fold(Vec::new(), |mut vec, item| {
        if let Ok((_key, value)) = item {
            if let Ok(contact) = serde_json::from_str(value.value()) {
                vec.push(contact)
            }
        }
        vec
    });

    Ok(contacts)
}

pub(crate) async fn get_contact(pubkey: &XOnlyPublicKey) -> Result<Option<types::Contact>> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| anyhow!("DB not set".to_string()))?;
    let read_txn = db.begin_read()?;
    let contacts_table = read_txn.open_table(CONTACTS)?;

    let contact = match contacts_table.get(pubkey.to_string().as_str())? {
        Some(contact) => Some(serde_json::from_str(contact.value())?),
        None => None,
    };

    Ok(contact)
}
