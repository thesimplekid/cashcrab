use anyhow::Result;
use cashu_crab::types::Proofs;
use lazy_static::lazy_static;
use redb::{Database, MultimapTableDefinition, ReadableMultimapTable, TableDefinition};
use std::{collections::HashMap, sync::Arc};
use tokio::sync::Mutex;

use crate::api::CashuError;

// Mint Info
// Key: Mint Url
// Value: Serialized Mint info
const MINT_INFO: TableDefinition<&str, &str> = TableDefinition::new("mint_info");

// Mint Keysets
// Key: Mint url
// Value: keyset id
const MINT_KEYSETS: TableDefinition<&str, &str> = TableDefinition::new("mint_keysets");

// Keysets
// Key: Keyset ID
/// Value: Serialized hashmap of mint public keys
const KEYSETS: TableDefinition<&str, &str> = TableDefinition::new("keysets");

// Cashu Transactions
// Key: Transaction Id
// Value: Serialized transaction info
const CASHU_TRANSACTIONS: TableDefinition<&str, &str> = TableDefinition::new("cashu_transactions");

// Proofs
// Multimap Table
// Key: MintUrl
// Value: Serialized proof
const PROOFS: MultimapTableDefinition<&str, &str> = MultimapTableDefinition::new("proofs");

// Lightning Invoice
// Key: payment hash
// value: Serialized invoice info
const LIGHTNING_INVOICES: TableDefinition<&str, &str> = TableDefinition::new("lightning_invoice");

lazy_static! {
    static ref DB: Arc<Mutex<Option<Database>>> = Arc::new(Mutex::new(None));
}

/// Init Database
pub(crate) async fn init_db(path: &str) -> Result<String, CashuError> {
    let db = Database::create(format!("{path}/cashu.redb"))?;
    let mut database = DB.lock().await;
    *database = Some(db);

    if let Some(database) = database.as_ref() {
        let write_txn = database.begin_write()?;
        {
            let _ = write_txn.open_table(MINT_INFO)?;
            let _ = write_txn.open_table(MINT_KEYSETS)?;
            let _ = write_txn.open_table(KEYSETS)?;
            let _ = write_txn.open_table(CASHU_TRANSACTIONS)?;
            let _ = write_txn.open_multimap_table(PROOFS)?;
            let _ = write_txn.open_table(LIGHTNING_INVOICES)?;
        }
        write_txn.commit()?;
    }

    Ok("".to_string())
}

/// Add proofs
pub(crate) async fn add_proofs(mint: &str, proofs: Proofs) -> Result<(), CashuError> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;

    let write_txn = db.begin_write()?;
    {
        let mut proof_table = write_txn.open_multimap_table(PROOFS)?;

        for proof in &proofs {
            proof_table.insert(mint, serde_json::to_string(&proof)?.as_str())?;
        }
    }
    write_txn.commit()?;

    //Err(CashuError(format!("added Proofs: {:?}", proofs)))
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

    for p in proofs {
        if let Ok(p) = p {
            let p = p.value();

            if let Ok(p) = serde_json::from_str(p) {
                result.push(p);
            }
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
pub(crate) async fn remove_proofs(mint: &str, proofs: Proofs) -> Result<(), CashuError> {
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
