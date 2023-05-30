use std::sync::Mutex as StdMutex;
use std::{collections::HashMap, fmt, io, str::FromStr, sync::Arc};

use anyhow::{anyhow, bail, Error, Result};
use bitcoin::{secp256k1::XOnlyPublicKey, Amount};
use cashu_crab::{
    cashu_wallet::CashuWallet,
    client::Client,
    error::Error as CashuCrabError,
    types::{Proofs, Token},
};
use lazy_static::lazy_static;
use lightning_invoice::{Invoice, InvoiceDescription};
use nostr_sdk::prelude::{FromBech32, PREFIX_BECH32_PUBLIC_KEY};
use tokio::runtime::Runtime;
use tokio::sync::Mutex;

use super::types::{InvoiceInfo, TokenData};
use crate::{
    database,
    nostr::{self, init_client},
    types::{
        self, CashuTransaction, Conversation, LNTransaction, Message, Mint, Transaction,
        TransactionStatus,
    },
};

impl From<CashuError> for Error {
    fn from(err: CashuError) -> Self {
        Self::msg(err.to_string())
    }
}

#[derive(Clone, Debug)]
pub struct CashuError(pub String);

impl fmt::Display for CashuError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let msg = format!("Error in Rust: {:?}", self.0);
        write!(f, "{}", &msg)
    }
}

impl From<minreq::Error> for CashuError {
    fn from(err: minreq::Error) -> Self {
        Self(err.to_string())
    }
}

impl From<io::Error> for CashuError {
    fn from(err: io::Error) -> Self {
        Self(err.to_string())
    }
}

impl From<serde_json::Error> for CashuError {
    fn from(err: serde_json::Error) -> Self {
        Self(err.to_string())
    }
}

impl From<CashuCrabError> for CashuError {
    fn from(err: CashuCrabError) -> Self {
        Self(err.to_string())
    }
}

impl From<tokio::sync::TryLockError> for CashuError {
    fn from(err: tokio::sync::TryLockError) -> Self {
        Self(err.to_string())
    }
}

impl From<redb::Error> for CashuError {
    fn from(err: redb::Error) -> Self {
        Self(err.to_string())
    }
}

impl From<lightning_invoice::ParseOrSemanticError> for CashuError {
    fn from(err: lightning_invoice::ParseOrSemanticError) -> Self {
        Self(err.to_string())
    }
}

lazy_static! {
    static ref WALLETS: Arc<Mutex<HashMap<String, Option<CashuWallet>>>> =
        Arc::new(Mutex::new(HashMap::new()));
    static ref RUNTIME: Arc<StdMutex<Runtime>> = Arc::new(StdMutex::new(Runtime::new().unwrap()));
}

macro_rules! lock_runtime {
    () => {
        match RUNTIME.lock() {
            Ok(lock) => lock,
            Err(err) => {
                let err: anyhow::Error = anyhow!("Failed to lock the runtime mutex: {}", err);
                return Err(err.into());
            }
        }
    };
}

pub fn init_db(path: String) -> Result<()> {
    let rt = lock_runtime!();
    let result = rt.block_on(async {
        database::init_db(&path).await?;
        Ok(())
    });

    drop(rt);
    result
}

pub fn init_nostr() -> Result<String> {
    let rt = lock_runtime!();
    let result = rt.block_on(async {
        let key = database::nostr::get_key().await?;
        // TODO: get relays
        init_client(&key).await?;

        Ok("".to_string())
    });

    drop(rt);
    result
}

pub fn get_relays() -> Result<Vec<String>> {
    let rt = lock_runtime!();
    let result = rt.block_on(async { nostr::get_relays().await });
    drop(rt);

    result
}

pub fn add_relay(relay: String) -> Result<()> {
    let rt = lock_runtime!();
    let result = rt.block_on(async { nostr::add_relay(relay).await });
    drop(rt);

    result
}

pub fn remove_relay(relay: String) -> Result<()> {
    let rt = lock_runtime!();
    let result = rt.block_on(async { nostr::remove_relay(relay).await });
    drop(rt);

    result
}

/// Fetch contacts from relay for a given pubkey
pub fn fetch_contacts(pubkey: String) -> Result<Vec<types::Contact>> {
    let rt = lock_runtime!();
    let result = rt.block_on(async {
        let x_pubkey = match pubkey.starts_with(PREFIX_BECH32_PUBLIC_KEY) {
            true => XOnlyPublicKey::from_bech32(&pubkey)?,
            false => XOnlyPublicKey::from_str(&pubkey)?,
        };
        let contacts = nostr::get_contacts(&x_pubkey).await?;
        let contacts = nostr::get_metadata(contacts).await?;

        // Publish contact list
        nostr::set_contact_list().await?;

        Ok(contacts)
    });
    drop(rt);

    result
}

pub fn add_contact(pubkey: String) -> Result<()> {
    let rt = lock_runtime!();
    let result = rt.block_on(async {
        let x_pubkey = match pubkey.starts_with(PREFIX_BECH32_PUBLIC_KEY) {
            true => XOnlyPublicKey::from_bech32(&pubkey)?,
            false => XOnlyPublicKey::from_str(&pubkey)?,
        };
        let contacts = nostr::get_metadata(vec![x_pubkey]).await?;
        database::message::add_contacts(contacts).await?;
        nostr::set_contact_list().await?;
        Ok(())
    });

    drop(rt);
    result
}

pub fn remove_contact(pubkey: String) -> Result<()> {
    let rt = lock_runtime!();
    let result = rt.block_on(async {
        let x_pubkey = match pubkey.starts_with(PREFIX_BECH32_PUBLIC_KEY) {
            true => XOnlyPublicKey::from_bech32(&pubkey)?,
            false => XOnlyPublicKey::from_str(&pubkey)?,
        };
        database::message::remove_contact(&x_pubkey).await?;
        nostr::set_contact_list().await?;
        Ok(())
    });

    drop(rt);
    result
}

pub fn get_contacts() -> Result<Vec<types::Contact>> {
    let rt = lock_runtime!();
    let result = rt.block_on(async {
        let contacts = database::message::get_contacts().await?;
        Ok(contacts)
    });

    drop(rt);
    result
}

pub fn send_message(pubkey: String, message: Message) -> Result<Conversation> {
    let rt = lock_runtime!();
    let result = rt.block_on(async {
        let x_pubkey = match pubkey.starts_with(PREFIX_BECH32_PUBLIC_KEY) {
            true => XOnlyPublicKey::from_bech32(&pubkey)?,
            false => XOnlyPublicKey::from_str(&pubkey)?,
        };

        database::message::add_message(x_pubkey, &message).await?;
        let conversation = nostr::send_message(x_pubkey, &message).await?;
        Ok(conversation)
    });

    drop(rt);
    result
}

pub fn get_conversation(pubkey: String) -> Result<Conversation> {
    let rt = lock_runtime!();
    let result: Result<Conversation> = rt.block_on(async {
        let x_pubkey = match pubkey.starts_with(PREFIX_BECH32_PUBLIC_KEY) {
            true => XOnlyPublicKey::from_bech32(&pubkey)?,
            false => XOnlyPublicKey::from_str(&pubkey)?,
        };
        let messages = database::message::get_messages(&x_pubkey).await?;

        let transaction_messages: &Vec<String> = &messages
            .iter()
            .filter(|enum_value| {
                matches!(enum_value, Message::Invoice { .. } | Message::Token { .. })
            })
            .map(|x| x.id())
            .flatten()
            .collect();

        let transactions = database::transactions::get_transactions(transaction_messages).await?;
        Ok(Conversation {
            messages,
            transactions,
        })
    });

    drop(rt);
    result
}

pub fn get_balances() -> Result<String> {
    let rt = lock_runtime!();
    let result = rt.block_on(async {
        let proofs = database::cashu::get_all_proofs().await?;

        let balances = proofs
            .iter()
            .map(|(mint, proofs)| {
                let balance = proofs
                    .iter()
                    .fold(0, |acc, proof| acc + proof.amount.to_sat() as i64);
                (mint.to_owned(), balance)
            })
            .collect::<HashMap<_, _>>();

        Ok(serde_json::to_string(&balances)?)
    });

    drop(rt);
    result
}

/// Add Mint
pub fn add_mint(url: String) -> Result<()> {
    let rt = lock_runtime!();

    let result = rt.block_on(async {
        let mut active_keyset = None;
        let mut keysets = vec![];

        let client = Client::new(&url)?;
        let wallet = match client.get_keys().await {
            Ok(keys) => {
                let keyset_id = keys.id();

                active_keyset = Some(keyset_id.clone());
                keysets.push(keyset_id.clone());

                database::cashu::add_keyset(&url, &keys).await?;

                Some(CashuWallet::new(client.clone(), keys))
            }
            Err(_err) => None,
        };

        WALLETS.lock().await.insert(url.to_string(), wallet.clone());

        let mint = Mint {
            url,
            active_keyset,
            keysets,
        };

        database::cashu::add_mint(mint).await?;

        Ok(())
    });

    drop(rt);
    result
}

pub fn get_wallets() -> Result<Vec<String>> {
    let rt = lock_runtime!();
    let result = rt.block_on(async {
        Ok(WALLETS
            .lock()
            .await
            .iter()
            .map(|(k, _v)| k.to_owned())
            .collect())
    });

    drop(rt);
    result
}

/// Remove wallet (mint)
pub fn remove_wallet(url: String) -> Result<String> {
    let rt = lock_runtime!();
    let result = rt.block_on(async {
        WALLETS.lock().await.remove(&url);
        Ok("".to_string())
    });

    drop(rt);

    result
}

/// Get wallet for uri
async fn wallet_for_url(mint_url: &str) -> Result<CashuWallet> {
    let mut wallets = WALLETS.lock().await;
    let cashu_wallet = match wallets.get(mint_url) {
        Some(Some(wallet)) => wallet.clone(),
        _ => {
            let client = Client::new(mint_url)?;
            let keys = client.get_keys().await?;
            let wallet = CashuWallet::new(client, keys);
            wallets.insert(mint_url.to_string(), Some(wallet.clone()));

            wallet
        }
    };

    Ok(cashu_wallet)
}

/// Check spendable for messages
pub fn check_spendable(transaction: Transaction) -> Result<TransactionStatus> {
    let rt = lock_runtime!();
    let result = rt.block_on(async {
        match &transaction {
            Transaction::CashuTransaction(cashu_trans) => {
                let token = Token::from_str(&cashu_trans.token)?;
                let wallet = wallet_for_url(&cashu_trans.mint).await?;

                let check_spent = wallet
                    .check_proofs_spent(token.token[0].clone().proofs)
                    .await?;

                // REVIEW: This is a fairly naive check on if a token is spendable
                // this works in the way `check_spendable` is called now but is not techically correct
                // As a spendable proof can be from a completed transaction
                if check_spent.spendable.is_empty() {
                    let transaction = Transaction::CashuTransaction(CashuTransaction {
                        id: Some(transaction.id()),
                        status: TransactionStatus::Sent,
                        time: cashu_trans.time,
                        amount: cashu_trans.amount,
                        mint: cashu_trans.mint.clone(),
                        token: cashu_trans.token.clone(),
                    });

                    database::transactions::update_transaction_status(&transaction).await?;

                    // Update Status
                    Ok(TransactionStatus::Sent)
                } else {
                    Ok(TransactionStatus::Pending)
                }
            }
            Transaction::LNTransaction(ln_trans) => {
                if let Some(mint) = &ln_trans.mint {
                    let wallet = wallet_for_url(&mint).await?;
                    let invoice = Invoice::from_str(&ln_trans.bolt11)?;

                    let proofs = wallet
                        .mint_token(Amount::from_sat(ln_trans.amount), &ln_trans.hash)
                        .await
                        .unwrap_or_default();

                    if !proofs.is_empty() {
                        database::cashu::add_proofs(&mint, &proofs).await?;
                        database::transactions::update_transaction_status(
                            &Transaction::LNTransaction(LNTransaction::new(
                                Some(TransactionStatus::Received),
                                ln_trans.amount,
                                ln_trans.mint.clone(),
                                &ln_trans.bolt11,
                                &ln_trans.hash,
                            )),
                        )
                        .await?;
                        return Ok(TransactionStatus::Received);
                    } else if invoice.is_expired() {
                        database::transactions::update_transaction_status(
                            &Transaction::LNTransaction(LNTransaction::new(
                                Some(TransactionStatus::Expired),
                                ln_trans.amount,
                                ln_trans.mint.clone(),
                                &ln_trans.bolt11,
                                &ln_trans.hash,
                            )),
                        )
                        .await?;
                        return Ok(TransactionStatus::Expired);
                    }
                }

                Ok(TransactionStatus::Pending)
            }
        }
    });

    drop(rt);
    result
}

/// Receive
pub fn receive_token(encoded_token: String) -> Result<Transaction> {
    let rt = lock_runtime!();
    let token = Token::from_str(&encoded_token)?;
    let result = rt.block_on(async {
        let wallet = wallet_for_url(&token.token_info().1).await?;
        let mint_url = wallet.client.mint_url.to_string();
        let received_proofs = wallet.receive(&encoded_token).await?;

        database::cashu::add_proofs(&mint_url, &received_proofs).await?;

        let transaction = Transaction::CashuTransaction(CashuTransaction::new(
            Some(TransactionStatus::Received),
            token.token_info().0,
            &mint_url,
            &encoded_token,
        ));

        database::transactions::add_transaction(&transaction).await?;

        Ok(transaction)
    });

    drop(rt);
    result
}

// REVIEW: Naive coin selection
async fn select_send_proofs(mint: &str, amount: u64, proofs: &Proofs) -> Result<(Proofs, Proofs)> {
    let mut send_proofs = vec![];
    let mut keep_proofs = vec![];

    let mut a = 0;

    let keysets = database::cashu::get_keyset(mint).await?;

    let mut sorted_vec_of_proofs = proofs.clone();

    // Sort proofs so oldest ming keyset is first
    sorted_vec_of_proofs.sort_by_key(|s| {
        keysets
            .iter()
            .find(|(field, _)| field == &&s.id.clone().unwrap_or_default())
            .map(|(_, key)| *key)
            .unwrap_or(u64::MAX)
    });

    for proof in proofs {
        if a < amount {
            send_proofs.push(proof.clone());
        } else {
            keep_proofs.push(proof.clone());
        }
        a += proof.amount.to_sat();
    }

    Ok((send_proofs, keep_proofs))
}

pub fn send(amount: u64, active_mint: String) -> Result<Transaction> {
    let rt = lock_runtime!();
    let result = rt.block_on(async {
        let wallet = wallet_for_url(&active_mint).await?;

        let proofs = database::cashu::get_proofs(&active_mint).await?;

        let (send_proofs, mut keep_proofs) =
            select_send_proofs(&active_mint, amount, &proofs).await?;
        let r = wallet
            .send(Amount::from_sat(amount), send_proofs.clone())
            .await?;
        keep_proofs.extend(r.change_proofs.clone());

        // Set wallet proofs to change
        database::cashu::add_proofs(&active_mint, &keep_proofs).await?;

        // Remove sent proofs
        database::cashu::remove_proofs(&active_mint, send_proofs).await?;

        let token = wallet.proofs_to_token(r.send_proofs, None)?;
        let transaction = CashuTransaction::new(
            Some(TransactionStatus::Pending),
            amount,
            &active_mint,
            &token,
        );
        let transaction = Transaction::CashuTransaction(transaction);

        database::transactions::add_transaction(&transaction).await?;
        Ok(transaction)
    });

    drop(rt);

    result
}

// TODO: Need to make sure wallet is in wallets
pub fn request_mint(amount: u64, mint_url: String) -> Result<Transaction> {
    let rt = lock_runtime!();
    let result = rt.block_on(async {
        let wallet = wallet_for_url(&mint_url).await?;
        let invoice = wallet.request_mint(Amount::from_sat(amount)).await?;

        let transaction = LNTransaction::new(
            None,
            amount,
            Some(mint_url),
            &invoice.pr.to_string(),
            &invoice.hash,
        );
        let transaction = Transaction::LNTransaction(transaction);

        database::transactions::add_transaction(&transaction).await?;

        Ok(transaction)
    });

    drop(rt);
    result
}

pub fn mint_token(amount: u64, hash: String, mint: String) -> Result<()> {
    let rt = lock_runtime!();
    let result = rt.block_on(async {
        let wallets = WALLETS.lock().await;
        if let Some(Some(wallet)) = wallets.get(&mint) {
            let proofs = wallet.mint_token(Amount::from_sat(amount), &hash).await?;

            database::cashu::add_proofs(&mint, &proofs).await?;

            return Ok(());
        }
        bail!("Could not get invoice".to_string())
    });

    drop(rt);

    result
}

// TODO: Melt, untested as legend.lnbits has LN issues
pub fn melt(amount: u64, invoice: String, mint: String) -> Result<()> {
    let rt = lock_runtime!();
    let result = rt.block_on(async {
        let wallet = wallet_for_url(&mint).await?;

        let invoice = str::parse::<Invoice>(&invoice)?;
        let proofs = database::cashu::get_proofs(&mint).await?;

        let (send_proofs, mut keep_proofs) = select_send_proofs(&mint, amount, &proofs).await?;
        let change = wallet.melt(invoice, send_proofs.clone()).await?;
        if let Some(change) = change.change {
            keep_proofs.extend(change);
        }

        // Remove proofs to be sent
        database::cashu::remove_proofs(&mint, send_proofs).await?;

        Ok(())
    });

    drop(rt);
    result
}

/// Decode invoice
pub fn decode_invoice(invoice: String) -> Result<InvoiceInfo> {
    let invoice = str::parse::<Invoice>(&invoice)?;

    let memo = match invoice.description() {
        lightning_invoice::InvoiceDescription::Direct(memo) => Some(memo.clone().into_inner()),
        InvoiceDescription::Hash(_) => None,
    };

    Ok(InvoiceInfo {
        // FIXME: Convert this conrrectlly
        amount: invoice.amount_milli_satoshis().unwrap() / 1000,
        hash: invoice.payment_hash().to_string(),
        memo,
    })
}

pub fn get_transactions() -> Result<Vec<Transaction>> {
    let rt = lock_runtime!();
    let result = rt.block_on(async { Ok(database::transactions::get_all_transactions().await?) });

    drop(rt);

    result
}

pub fn get_transaction(tid: String) -> Result<Option<Transaction>> {
    let rt = lock_runtime!();
    let result = rt.block_on(async { Ok(database::transactions::get_transaction(&tid).await?) });

    drop(rt);

    result
}

pub fn get_mints() -> Result<Vec<Mint>> {
    let rt = lock_runtime!();
    let result = rt.block_on(async { Ok(database::cashu::get_all_mints().await?) });

    drop(rt);

    result
}

pub fn get_active_mint() -> Result<Option<Mint>> {
    let rt = lock_runtime!();

    let result = rt.block_on(async { database::cashu::get_active_mint().await })?;

    drop(rt);

    Ok(result)
}

pub fn set_active_mint(mint_url: Option<String>) -> Result<()> {
    let rt = lock_runtime!();

    let result = rt.block_on(async { database::cashu::set_active_mint(mint_url).await });

    drop(rt);

    result?;

    Ok(())
}

pub fn decode_token(encoded_token: String) -> Result<TokenData> {
    let token = Token::from_str(&encoded_token)?;

    let token_info = token.token_info();

    Ok(TokenData {
        encoded_token,
        mint: token_info.1,
        amount: token_info.0,
        memo: token.memo,
    })
}
