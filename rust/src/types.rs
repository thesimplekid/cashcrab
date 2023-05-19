use bitcoin_hashes::sha256;
use bitcoin_hashes::Hash;
pub use cashu_crab::types::MintInfo;
use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};
use std::time::SystemTime;

#[derive(Debug, Copy, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum TransactionStatus {
    Sent,
    Received,
    Pending,
    Failed,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Transaction {
    CashuTransaction(CashuTransaction),
    LNTransaction(LNTransaction),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum TransactionKind {
    CashuTransaction,
    LNTransaction,
}

impl TransactionKind {
    pub fn as_json(&self) -> String {
        serde_json::json!(self).to_string()
    }
}

impl Transaction {
    pub fn id(&self) -> String {
        match self {
            Transaction::CashuTransaction(transaction) => {
                sha256::Hash::hash(transaction.token.as_bytes()).to_string()
            }
            Transaction::LNTransaction(transaction) => {
                sha256::Hash::hash(transaction.bolt11.as_bytes()).to_string()
            }
        }
    }

    pub fn status(&self) -> TransactionStatus {
        match self {
            Transaction::CashuTransaction(transaction) => transaction.status,
            Transaction::LNTransaction(transaction) => transaction.status,
        }
    }

    /// Get transaction as json string
    pub fn as_json(&self) -> String {
        serde_json::json!(self).to_string()
    }

    /// Get Transaction Kind
    pub fn kind(&self) -> TransactionKind {
        match self {
            Transaction::CashuTransaction(_transaction) => TransactionKind::CashuTransaction,
            Transaction::LNTransaction(_transaction) => TransactionKind::LNTransaction,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CashuTransaction {
    pub id: Option<String>,
    pub status: TransactionStatus,
    pub time: u64,
    pub amount: u64,
    pub mint: String,
    pub token: String,
}

impl CashuTransaction {
    pub fn new(status: Option<TransactionStatus>, amount: u64, mint: &str, token: &str) -> Self {
        let id = sha256::Hash::hash(token.as_bytes()).to_string();
        let status = match status {
            Some(status) => status,
            None => TransactionStatus::Pending,
        };
        Self {
            id: Some(id),
            status,
            time: unix_time(),
            amount,
            mint: mint.to_string(),
            token: token.to_string(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LNTransaction {
    pub id: Option<String>,
    pub status: TransactionStatus,
    pub time: u64,
    pub amount: u64,
    pub mint: String,
    pub bolt11: String,
}

pub fn unix_time() -> u64 {
    SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .map(|x| x.as_secs())
        .unwrap_or(0)
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Mint {
    pub url: String,
    pub active_keyset: String,
    pub keysets: Vec<String>,
}

impl Mint {
    /// Get transaction as json string
    pub fn as_json(&self) -> String {
        serde_json::json!(self).to_string()
    }
}
