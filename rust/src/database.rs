use anyhow::Result;
use cashu_crab::types::{MintInfo, Proofs};
use lazy_static::lazy_static;
use redb::{
    Database, MultimapTableDefinition, ReadableMultimapTable, ReadableTable, TableDefinition,
};
use std::{collections::HashMap, sync::Arc};
use tokio::sync::Mutex;

use crate::{
    api::CashuError,
    types::{Mint, Transaction, TransactionStatus},
};

const CONFIG: TableDefinition<&str, &str> = TableDefinition::new("config");

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

// Transactions
// Key: Transaction Id
// Value: Serialized transaction info
const PENDING_TRANSACTIONS: TableDefinition<&str, &str> =
    TableDefinition::new("pendingtransactions");

// Transactions
// Key: Transaction Id
// Value: Serialized transaction info
const TRANSACTIONS: TableDefinition<&str, &str> = TableDefinition::new("transactions");

// Proofs
// Multimap Table
// Key: MintUrl
// Value: Serialized proof
const PROOFS: MultimapTableDefinition<&str, &str> = MultimapTableDefinition::new("proofs");

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
            let _ = write_txn.open_table(CONFIG)?;
            let _ = write_txn.open_table(MINT_INFO)?;
            let _ = write_txn.open_table(MINT_KEYSETS)?;
            let _ = write_txn.open_table(KEYSETS)?;
            let _ = write_txn.open_table(TRANSACTIONS)?;
            let _ = write_txn.open_table(PENDING_TRANSACTIONS)?;
            let _ = write_txn.open_multimap_table(PROOFS)?;
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

/// Add Transaction
pub(crate) async fn add_transaction(transaction: &Transaction) -> Result<(), CashuError> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;

    let write_txn = db.begin_write()?;
    {
        if transaction.status().eq(&TransactionStatus::Pending) {
            let mut pending_transaction_table = write_txn.open_table(PENDING_TRANSACTIONS)?;

            pending_transaction_table
                .insert(transaction.id().as_str(), transaction.as_json().as_str())?;
        } else {
            let mut transaction_table = write_txn.open_table(TRANSACTIONS)?;

            transaction_table.insert(transaction.id().as_str(), transaction.as_json().as_str())?;
        }
    }
    write_txn.commit()?;

    //Err(CashuError(format!("added Proofs: {:?}", proofs)))
    Ok(())
}

/// Get all transactions
pub(crate) async fn get_all_transactions() -> Result<Vec<Transaction>, CashuError> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;
    let read_txn = db.begin_read()?;
    let table = read_txn.open_table(TRANSACTIONS)?;

    let transactions: Vec<Transaction> = table.iter()?.fold(Vec::new(), |mut vec, item| {
        if let Ok((_key, value)) = item {
            if let Ok(transaction) = serde_json::from_str(value.value()) {
                vec.push(transaction)
            }
        }
        vec
    });

    // return Err(CashuError(format!("Transactions: {:?}", transactions)));

    Ok(transactions)
}

pub(crate) async fn update_transaction_status(transaction: &Transaction) -> Result<(), CashuError> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;

    let write_txn = db.begin_write()?;

    {
        if transaction.status().ne(&TransactionStatus::Pending) {
            let mut pending_transaction_table = write_txn.open_table(PENDING_TRANSACTIONS)?;
            pending_transaction_table.remove(transaction.id().as_str())?;
        }
        let mut transactions_table = write_txn.open_table(TRANSACTIONS)?;
        transactions_table.insert(transaction.id().as_str(), transaction.as_json().as_str())?;
    }

    write_txn.commit()?;
    Ok(())
}

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

    // return Err(CashuError(format!("Transactions: {:?}", transactions)));

    Ok(mints)
}

pub(crate) async fn get_mint(mint_url: &str) -> Result<Option<MintInfo>, CashuError> {
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
        // TODO: Reafctor this without the returns
        if let Some(mint_info) = mint_info_table.get(active_mint)? {
            return Ok(Some(serde_json::from_str(mint_info.value())?));
        };

        return Ok(Some(Mint {
            url: active_mint.to_string(),
            active_keyset: None,
            keysets: vec![],
        }));
    };

    Ok(None)
}
