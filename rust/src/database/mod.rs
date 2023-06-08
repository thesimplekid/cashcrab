use anyhow::Result;
use lazy_static::lazy_static;
use redb::{Database, MultimapTableDefinition, TableDefinition};
use std::sync::Arc;
use tokio::sync::Mutex;

pub(crate) mod cashu;
pub(crate) mod contacts;
pub(crate) mod message;
pub(crate) mod nostr;
pub(crate) mod transactions;

const CONFIG: TableDefinition<&str, &str> = TableDefinition::new("config");

// Mint Info
// Key: Mint Url
// Value: Serialized Mint
const MINT_INFO: TableDefinition<&str, &str> = TableDefinition::new("mint_info");

// Mint Keysets
// Key: Mint url
// Value: (keyset id, unix_time)
const MINT_KEYSETS: MultimapTableDefinition<&str, (&str, u64)> =
    MultimapTableDefinition::new("mint_keysets");

// Keysets
// Key: Keyset ID
// Value: Serialized hashmap of mint public keys
const KEYSETS: TableDefinition<&str, &str> = TableDefinition::new("keysets");

// Transactions
// Key: Transaction Id
// Value: Serialized transaction info
const PENDING_TRANSACTIONS: TableDefinition<&str, &str> =
    TableDefinition::new("pending_transactions");

// Transactions
// Key: Transaction Id
// Value: Serialized transaction info
const TRANSACTIONS: TableDefinition<&str, &str> = TableDefinition::new("transactions");

// Proofs
// Multimap Table
// Key: MintUrl
// Value: Serialized proof
const PROOFS: MultimapTableDefinition<&str, &str> = MultimapTableDefinition::new("proofs");

// Messages
// Multimap Table
// Key: Peer Hex pubkey
// Value: Serialized Message
const MESSAGES: MultimapTableDefinition<&str, &str> = MultimapTableDefinition::new("messages");

// Contacts
// Table
// Key: Nostr hex pubkey
// Value: Serialized Contact Info
const CONTACTS: TableDefinition<&str, &str> = TableDefinition::new("constacts");

lazy_static! {
    static ref DB: Arc<Mutex<Option<Database>>> = Arc::new(Mutex::new(None));
}

/// Init Database
pub(crate) async fn init_db(path: &str) -> Result<()> {
    let db = Database::create(format!("{path}/cashu.redb"))?;
    let mut database = DB.lock().await;
    *database = Some(db);

    if let Some(database) = database.as_ref() {
        let write_txn = database.begin_write()?;
        {
            let _ = write_txn.open_table(CONFIG)?;
            let _ = write_txn.open_table(MINT_INFO)?;
            let _ = write_txn.open_table(KEYSETS)?;
            let _ = write_txn.open_table(TRANSACTIONS)?;
            let _ = write_txn.open_table(PENDING_TRANSACTIONS)?;
            let _ = write_txn.open_table(CONTACTS)?;
            let _ = write_txn.open_multimap_table(PROOFS)?;
            let _ = write_txn.open_multimap_table(MESSAGES)?;
            let _ = write_txn.open_multimap_table(MINT_KEYSETS)?;
        }
        write_txn.commit()?;
    }

    Ok(())
}
