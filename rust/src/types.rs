use anyhow::Result;
use bitcoin_hashes::sha256;
use bitcoin_hashes::Hash;
pub use cashu_crab::types::MintInfo;
use serde::{Deserialize, Serialize};
use std::time::SystemTime;

use crate::database;

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

    pub fn content(&self) -> String {
        match self {
            Transaction::CashuTransaction(transaction) => transaction.token.clone(),
            Transaction::LNTransaction(transaction) => transaction.bolt11.clone(),
        }
    }

    /// Get transaction as json string
    pub fn as_json(&self) -> String {
        serde_json::json!(self).to_string()
    }

    /// Get Transaction Kind
    pub fn _kind(&self) -> TransactionKind {
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
    pub mint: Option<String>,
    pub bolt11: String,
    pub hash: String,
}

impl LNTransaction {
    pub fn new(
        status: Option<TransactionStatus>,
        amount: u64,
        mint: Option<String>,
        bolt11: &str,
        hash: &str,
    ) -> Self {
        let id = sha256::Hash::hash(bolt11.as_bytes()).to_string();
        let status = match status {
            Some(status) => status,
            None => TransactionStatus::Pending,
        };
        Self {
            id: Some(id),
            status,
            time: unix_time(),
            amount,
            mint,
            bolt11: bolt11.to_string(),
            hash: hash.to_string(),
        }
    }
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
    pub active_keyset: Option<String>,
    pub keysets: Vec<String>,
}

impl Mint {
    /// Get transaction as json string
    pub fn as_json(&self) -> String {
        serde_json::json!(self).to_string()
    }
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum TokenStatus {
    Spendable,
    Claimed,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum InvoiceStatus {
    Paid,
    Unpaid,
    Expired,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum Direction {
    Sent,
    Received,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Message {
    Text {
        direction: Direction,
        time: u64,
        content: String,
    },
    Invoice {
        direction: Direction,
        time: u64,
        transaction_id: String,
    },
    Token {
        direction: Direction,
        time: u64,
        transaction_id: String,
    },
}

impl Message {
    /// Get contact as json string
    pub fn _as_json(&self) -> String {
        serde_json::json!(self).to_string()
    }

    pub fn id(&self) -> Option<String> {
        match self {
            Message::Invoice { transaction_id, .. } => Some(transaction_id.to_string()),
            Message::Token { transaction_id, .. } => Some(transaction_id.to_string()),
            Message::Text { .. } => None,
        }
    }

    /// Content of message
    pub async fn content(&self) -> Result<Option<String>> {
        match self {
            Self::Text { content, .. } => Ok(Some(content.to_owned())),
            Self::Invoice { transaction_id, .. } => {
                match database::transactions::get_transaction(&transaction_id).await? {
                    Some(transaction) => Ok(Some(transaction.content())),
                    None => Ok(None),
                }
            }
            Self::Token { transaction_id, .. } => {
                match database::transactions::get_transaction(&transaction_id).await? {
                    Some(transaction) => Ok(Some(transaction.content())),
                    None => Ok(None),
                }
            }
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Conversation {
    pub messages: Vec<Message>,
    pub transactions: Vec<Transaction>,
}

impl Conversation {
    pub fn new(messages: Vec<Message>, transactions: Vec<Transaction>) -> Self {
        Self {
            messages,
            transactions,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Contact {
    pub pubkey: String,
    pub npub: String,
    pub name: Option<String>,
    pub picture: Option<String>,
    pub lud16: Option<String>,
}

impl Contact {
    /// Get contact as json string
    pub fn as_json(&self) -> String {
        serde_json::json!(self).to_string()
    }
}
