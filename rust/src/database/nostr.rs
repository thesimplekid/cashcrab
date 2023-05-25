use anyhow::{anyhow, Result};
use redb::ReadableTable;

use super::{CONFIG, DB};

pub(crate) async fn save_key(key: &str) -> Result<()> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| anyhow!("DB not set".to_string()))?;

    let write_txn = db.begin_write()?;
    {
        let mut settings_table = write_txn.open_table(CONFIG)?;

        settings_table.insert("private_key", key)?;
    }
    write_txn.commit()?;

    Ok(())
}

pub(crate) async fn get_key() -> Result<Option<String>> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| anyhow!("DB not set".to_string()))?;

    let read_txn = db.begin_read()?;
    let settings_table = read_txn.open_table(CONFIG)?;

    let key = settings_table.get("private_key")?;

    match key {
        Some(key) => Ok(Some(key.value().to_string())),
        None => Ok(None),
    }
}

pub(crate) async fn save_relays(relays: &Vec<String>) -> Result<()> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| anyhow!("DB not set".to_string()))?;

    let write_txn = db.begin_write()?;
    {
        let mut settings_table = write_txn.open_table(CONFIG)?;

        settings_table.insert("relays", serde_json::to_string(&relays)?.as_str())?;
    }
    write_txn.commit()?;

    Ok(())
}

pub(crate) async fn get_relays() -> Result<Vec<String>> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| anyhow!("DB not set".to_string()))?;

    let read_txn = db.begin_read()?;
    let settings_table = read_txn.open_table(CONFIG)?;

    let relays = settings_table.get("relays")?;

    match relays {
        Some(relays) => Ok(serde_json::from_str(relays.value())?),
        None => Ok(vec![]),
    }
}
