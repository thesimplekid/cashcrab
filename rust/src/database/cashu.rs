use std::collections::HashMap;

use anyhow::Result;
use cashu_crab::nuts::{nut00::Proofs, nut01::Keys};
use redb::{ReadableMultimapTable, ReadableTable};

use super::{CONFIG, DB, KEYSETS, MINT_INFO, MINT_KEYSETS, PROOFS};
use crate::{
    api::CashuError,
    types::{Mint, MintInformation},
    utils::unix_time,
};

/// Add proofs
pub(crate) async fn add_proofs(mint: &str, proofs: &Proofs) -> Result<(), CashuError> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;

    let write_txn = db.begin_write()?;
    {
        let mut proof_table = write_txn.open_multimap_table(PROOFS)?;

        for proof in proofs {
            proof_table.insert(mint, serde_json::to_string(&proof)?.as_str())?;
        }
    }
    write_txn.commit()?;

    Ok(())
}

/// Get Proofs
pub(crate) async fn get_proofs(mint: &str) -> Result<Proofs, CashuError> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;
    let read_txn = db.begin_read()?;
    let table = read_txn.open_multimap_table(PROOFS)?;

    let proofs = table.get(mint)?;

    let mut result: Proofs = vec![];

    for p in proofs.flatten() {
        let p = p.value();

        if let Ok(p) = serde_json::from_str(p) {
            result.push(p);
        }
    }

    Ok(result)
}

/// Get all proofs
pub(crate) async fn get_all_proofs() -> Result<HashMap<String, Proofs>, CashuError> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;
    let read_txn = db.begin_read()?;
    let table = read_txn.open_multimap_table(PROOFS)?;

    let proofs = table.iter()?;

    let proof_by_mint = proofs.into_iter().fold(HashMap::new(), |mut map, item| {
        if let Ok((key, value)) = item {
            let values: Proofs = value
                .map(|v| serde_json::from_str(v.unwrap().value()).unwrap())
                .collect();

            map.insert(key.value().to_string(), values);
        }
        map
    });

    Ok(proof_by_mint)
}

/// Remove proofs
pub(crate) async fn remove_proofs(mint: &str, proofs: &Proofs) -> Result<()> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;
    let write_txn = db.begin_write()?;
    {
        let mut proof_table = write_txn.open_multimap_table(PROOFS)?;

        for proof in proofs {
            proof_table.remove(mint, serde_json::to_string(&proof)?.as_str())?;
        }
    }
    write_txn.commit()?;

    Ok(())
}

/// Add Keyset
pub(crate) async fn add_keyset(mint: &str, keys: &Keys) -> Result<()> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;

    let write_txn = db.begin_write()?;
    {
        let keyset_id = keys.id();

        let time = unix_time();

        let mut mint_keysets_table = write_txn.open_multimap_table(MINT_KEYSETS)?;
        mint_keysets_table.insert(mint, (keyset_id.as_str(), time))?;

        let mut keysets_table = write_txn.open_table(KEYSETS)?;

        keysets_table.insert(keyset_id.as_str(), serde_json::to_string(&keys)?.as_str())?;
    }
    write_txn.commit()?;

    Ok(())
}

/// Get keysets
pub(crate) async fn get_keyset(mint: &str) -> Result<HashMap<String, u64>> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;

    let read_txn = db.begin_read()?;
    let mint_keysets_table = read_txn.open_multimap_table(MINT_KEYSETS)?;
    let keysets = mint_keysets_table.get(mint)?;

    let mut keyset_map = HashMap::new();

    for k in keysets.flatten() {
        let (key, value) = k.value();
        keyset_map.insert(key.to_string(), value);
    }

    Ok(keyset_map)
}

/// Add Mint
pub(crate) async fn add_mint(mint: Mint) -> Result<()> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;

    let write_txn = db.begin_write()?;
    {
        let mut mint_table = write_txn.open_table(MINT_INFO)?;
        mint_table.insert(mint.url.as_str(), mint.as_json().as_str())?;
    }
    write_txn.commit()?;

    Ok(())
}

/// Update Mint Info
pub(crate) async fn update_mint_info(url: &str, mint_info: MintInformation) -> Result<()> {
    let current_mint = get_mint(url).await?;

    let new_mint = match current_mint {
        Some(info) => Mint {
            url: info.url,
            active_keyset: info.active_keyset,
            keysets: info.keysets,
            info: Some(mint_info),
        },
        None => Mint {
            url: url.to_string(),
            active_keyset: None,
            keysets: vec![],
            info: Some(mint_info),
        },
    };

    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;

    let write_txn = db.begin_write()?;
    {
        let mut mint_table = write_txn.open_table(MINT_INFO)?;
        mint_table.insert(url, new_mint.as_json().as_str())?;
    }
    write_txn.commit()?;

    Ok(())
}

/// Get all mints
pub(crate) async fn get_all_mints() -> Result<Vec<Mint>, CashuError> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;
    let read_txn = db.begin_read()?;
    let table = read_txn.open_table(MINT_INFO)?;

    let mints: Vec<Mint> = table.iter()?.fold(Vec::new(), |mut vec, item| {
        if let Ok((_key, value)) = item {
            if let Ok(transaction) = serde_json::from_str(value.value()) {
                vec.push(transaction)
            }
        }
        vec
    });

    Ok(mints)
}

pub(crate) async fn get_mint(mint_url: &str) -> Result<Option<Mint>, CashuError> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;
    let read_txn = db.begin_read()?;
    let table = read_txn.open_table(MINT_INFO)?;

    if let Some(mint_info) = table.get(mint_url)? {
        return Ok(Some(serde_json::from_str(mint_info.value())?));
    }

    Ok(None)
}

pub(crate) async fn set_active_mint(mint_url: Option<String>) -> Result<(), CashuError> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;

    let write_txn = db.begin_write()?;
    {
        let mut config_table = write_txn.open_table(CONFIG)?;
        match mint_url {
            Some(url) => {
                config_table.insert("active_mint", url.as_str())?;
            }
            None => {
                config_table.remove("active_mint")?;
            }
        }
    }
    write_txn.commit()?;

    Ok(())
}

pub(crate) async fn get_active_mint() -> Result<Option<Mint>, CashuError> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;
    let read_txn = db.begin_read()?;
    let table = read_txn.open_table(CONFIG)?;

    if let Some(active_mint) = table.get("active_mint")? {
        let active_mint = active_mint.value();
        let mint_info_table = read_txn.open_table(MINT_INFO)?;
        // TODO: Refactor this without the returns
        let mint = mint_info_table.get(active_mint)?;
        match mint {
            Some(mint) => return Ok(Some(serde_json::from_str(mint.value())?)),
            None => {
                return Ok(Some(Mint {
                    url: active_mint.to_string(),
                    active_keyset: None,
                    keysets: vec![],
                    info: None,
                }))
            }
        }
    };

    Ok(None)
}
