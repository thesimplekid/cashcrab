use anyhow::Result;
use bitcoin::secp256k1::XOnlyPublicKey;
use bitcoin_hashes::sha256;
use bitcoin_hashes::Hash;
use cashu_crab::nuts::nut09::MintInfo;
use cashu_crab::nuts::nut09::MintVersion;
use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};

use crate::database;
use crate::utils::unix_time;

#[derive(Debug, Copy, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum Pending {
    Send,
    Receive,
}

#[derive(Debug, Copy, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum TransactionStatus {
    Sent,
    Received,
    Pending(Pending),
    Failed,
    Expired,
}

impl TransactionStatus {
    pub fn is_pending(&self) -> bool {
        matches!(self, TransactionStatus::Pending(_))
    }
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
    pub fn is_pending(&self) -> bool {
        matches!(self.status(), TransactionStatus::Pending(_))
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
    pub from: Option<String>,
}

impl CashuTransaction {
    pub fn new(
        status: TransactionStatus,
        amount: u64,
        mint: &str,
        token: &str,
        from: Option<String>,
    ) -> Self {
        let id = sha256::Hash::hash(token.as_bytes()).to_string();
        Self {
            id: Some(id),
            status,
            time: unix_time(),
            amount,
            mint: mint.to_string(),
            token: token.to_string(),
            from,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LNTransaction {
    pub id: Option<String>,
    pub status: TransactionStatus,
    pub time: u64,
    pub amount: u64,
    pub fee: Option<u64>,
    pub mint: Option<String>,
    pub bolt11: String,
    pub hash: String,
}

impl LNTransaction {
    pub fn new(
        status: TransactionStatus,
        amount: u64,
        fee: Option<u64>,
        mint: Option<String>,
        bolt11: &str,
        hash: &str,
    ) -> Self {
        let id = sha256::Hash::hash(bolt11.as_bytes()).to_string();
        Self {
            id: Some(id),
            status,
            time: unix_time(),
            amount,
            fee,
            mint,
            bolt11: bolt11.to_string(),
            hash: hash.to_string(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Mint {
    /// Mint Url
    pub url: String,
    /// Active Keyset Id
    pub active_keyset: Option<String>,
    /// Key Set Ids
    pub keysets: Vec<String>,
    /// Mint Information
    pub info: Option<MintInformation>,
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
                match database::transactions::get_transaction(transaction_id).await? {
                    Some(transaction) => Ok(Some(transaction.content())),
                    None => Ok(None),
                }
            }
            Self::Token { transaction_id, .. } => {
                match database::transactions::get_transaction(transaction_id).await? {
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

/// Profile Picture Info
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Picture {
    pub url: String,
    pub hash: Option<String>,
    pub updated: u64,
}

impl Picture {
    pub fn new(url: &str) -> Self {
        Self {
            url: url.to_string(),
            hash: None,
            updated: unix_time(),
        }
    }
}

/// Contact info
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Contact {
    /// Nostr Hex Pubkey
    pub pubkey: String,
    /// Nostr NPub
    pub npub: String,
    /// Username
    pub name: Option<String>,
    /// Picture Info
    pub picture: Option<Picture>,
    /// Lud16
    pub lud16: Option<String>,
    /// create_at
    pub created_at: Option<u64>,
}

impl Contact {
    /// Get contact as json string
    pub fn as_json(&self) -> String {
        serde_json::json!(self).to_string()
    }
}

pub struct InvoiceInfo {
    pub bolt11: String,
    pub amount: u64,
    pub hash: String,
    pub memo: Option<String>,
    pub mint: Option<String>,
    pub status: InvoiceStatus,
}

pub struct TokenData {
    pub encoded_token: String,
    pub mint: String,
    pub amount: u64,
    pub memo: Option<String>, // spendable: Option<bool>,
}

#[derive(Debug, Clone)]
pub struct KeyData {
    pub npub: String,
    pub nsec: Option<String>,
}

#[derive(Debug, Clone)]
pub(crate) enum ChannelMessage {
    Shutdown,
    GetKeys,
    KeyData(Option<KeyData>),
    AddRelay(String),
    RemoveRelay(String),
    GetRelays,
    Relays(Vec<String>),
    BackupTokens(Vec<String>),
    RestoreTokens,
    TokensRestored,
    SetContacts(Vec<nostr_sdk::Contact>),
    GetMetadata(Vec<XOnlyPublicKey>),
    Contacts(Vec<Contact>),
    SendDirectMessage(XOnlyPublicKey, String),
    GetContacts(XOnlyPublicKey),
    ContactPubkeys(Vec<XOnlyPublicKey>),
    Custom(String),
}

#[frb(mirror(MintVersion))]
pub struct _MintVersion {
    pub name: String,
    pub version: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MintInformation {
    /// name of the mint and should be recognizable
    pub name: Option<String>,
    /// hex pubkey of the mint
    pub pubkey: Option<String>,
    /// implementation name and the version running
    pub version: Option<String>,
    /// short description of the mint
    pub description: Option<String>,
    /// long description
    pub description_long: Option<String>,
    /// contact methods to reach the mint operator
    pub contact: Vec<Vec<String>>,
    /// shows which NUTs the mint supports
    pub nuts: Vec<String>,
    /// message of the day that the wallet must display to the user
    pub motd: Option<String>,
}

impl From<MintInfo> for MintInformation {
    fn from(mint_info: MintInfo) -> Self {
        Self {
            name: mint_info.name,
            pubkey: None,
            version: mint_info
                .version
                .map(|v| format!("{}/{}", v.name, v.version)),
            description: mint_info.description,
            description_long: mint_info.description_long,
            contact: mint_info.contact,
            nuts: mint_info.nuts,
            motd: mint_info.motd,
        }
    }
}
