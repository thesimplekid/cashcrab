use anyhow::Result;
use redb::ReadableTable;

use crate::{
    api::CashuError,
    types::{Transaction, TransactionStatus},
};

use super::{DB, PENDING_TRANSACTIONS, TRANSACTIONS};

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

    let mut transactions: Vec<Transaction> = table.iter()?.fold(Vec::new(), |mut vec, item| {
        if let Ok((_key, value)) = item {
            if let Ok(transaction) = serde_json::from_str(value.value()) {
                vec.push(transaction)
            }
        }
        vec
    });

    // Get Pending Transactions
    let table = read_txn.open_table(PENDING_TRANSACTIONS)?;
    let pending_transactions: Vec<Transaction> = table.iter()?.fold(Vec::new(), |mut vec, item| {
        if let Ok((_key, value)) = item {
            if let Ok(transaction) = serde_json::from_str(value.value()) {
                vec.push(transaction)
            }
        }
        vec
    });

    transactions.extend(pending_transactions);

    // return Err(CashuError(format!("Transactions: {:?}", transactions)));

    Ok(transactions)
}

/// Get transaction
pub(crate) async fn get_transaction(id: &str) -> Result<Option<Transaction>, CashuError> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;
    let read_txn = db.begin_read()?;
    let table = read_txn.open_table(TRANSACTIONS)?;
    let pending_table = read_txn.open_table(PENDING_TRANSACTIONS)?;

    let transaction = match table.get(id)? {
        Some(t) => Some(serde_json::from_str(t.value())?),
        None => match pending_table.get(id)? {
            Some(t) => Some(serde_json::from_str(t.value())?),
            None => None,
        },
    };

    Ok(transaction)
}

/// Get transactions
pub(crate) async fn get_transactions(ids: &Vec<String>) -> Result<Vec<Transaction>, CashuError> {
    let db = DB.lock().await;
    let db = db
        .as_ref()
        .ok_or_else(|| CashuError("DB not set".to_string()))?;
    let read_txn = db.begin_read()?;
    let table = read_txn.open_table(TRANSACTIONS)?;
    let pending_table = read_txn.open_table(PENDING_TRANSACTIONS)?;

    let mut transactions = vec![];

    for id in ids {
        if let Ok(Some(t)) = table.get(id.as_str()) {
            transactions.push(serde_json::from_str(t.value())?);
        } else if let Ok(Some(t)) = pending_table.get(id.as_str()) {
            transactions.push(serde_json::from_str(t.value())?);
        }
    }

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
