use std::sync::Mutex as StdMutex;

use allo_isolate::ffi::*;
use anyhow::{anyhow, bail, Error, Result};
use bitcoin::Amount;
use cashu_crab::{
    cashu_wallet::CashuWallet,
    client::Client,
    error::Error as CashuCrabError,
    types::{Proofs, Token},
};
use flutter_rust_bridge::StreamSink;
use lazy_static::lazy_static;
use lightning_invoice::{Invoice, InvoiceDescription};
use std::{collections::HashMap, ffi::CString, fmt, io, str::FromStr, sync::Arc};
use tokio::runtime::{Builder, Runtime};
use tokio::sync::Mutex;

use crate::database;

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
    // static ref PROOFS: Arc<Mutex<HashMap<String, Proofs>>> = Arc::new(Mutex::new(HashMap::new()));
    static ref PENDING_PROOFS: Arc<Mutex<HashMap<String, Proofs>>> =
        Arc::new(Mutex::new(HashMap::new()));
    static ref RUNTIME: Arc<StdMutex<Runtime>> = Arc::new(StdMutex::new(Runtime::new().unwrap()));
}

macro_rules! lock_runtime {
    () => {
        match RUNTIME.lock() {
            Ok(lock) => lock,
            Err(_) => {
                let err: anyhow::Error = anyhow!("Failed to lock the runtime mutex");
                return Err(err.into());
            }
        }
    };
}

pub fn init_db(path: String) -> Result<()> {
    let rt = lock_runtime!();
    rt.block_on(async {
        database::init_db(&path).await?;
        Ok(())
    })
}
pub fn get_balances() -> Result<String> {
    let rt = lock_runtime!();
    rt.block_on(async {
        let proofs = database::get_all_proofs().await?;

        let balances = proofs
            .iter()
            .map(|(mint, proofs)| {
                let balance = proofs
                    .iter()
                    .fold(0, |acc, proof| acc + proof.amount.to_sat());
                (mint.to_owned(), balance)
            })
            .collect::<HashMap<_, _>>();

        Ok(serde_json::to_string(&balances)?)
    })
}

/// Create Wallet
pub fn create_wallet(url: String) -> Result<String> {
    let rt = lock_runtime!();

    rt.block_on(async {
        let client = Client::new(&url)?;
        let wallet = match client.get_keys().await {
            Ok(keys) => Some(CashuWallet::new(client.clone(), keys)),
            Err(_err) => None,
        };

        WALLETS.lock().await.insert(url.to_string(), wallet.clone());

        Ok("".to_string())
    })
}

pub fn get_wallets() -> Result<Vec<String>> {
    let rt = lock_runtime!();
    rt.block_on(async {
        Ok(WALLETS
            .lock()
            .await
            .iter()
            .map(|(k, _v)| k.to_owned())
            .collect())
    })
}

pub fn remove_wallet(url: String) -> Result<String> {
    let rt = lock_runtime!();
    rt.block_on(async {
        WALLETS.lock().await.remove(&url);
        Ok("".to_string())
    })
}

/// Check proofs for mints that should be added
pub fn add_new_wallets(_mints: Vec<String>) -> Result<()> {
    /*
    let mut wallets = WALLETS.lock().await;
    for mint in mints {
        if let Ok(client) = Client::new(&mint) {
            if let Ok(mint_keys) = client.get_keys().await {
                let wallet = CashuWallet::new(client, mint_keys);
                wallets.insert(mint, Some(wallet));
            }
        }
    }
    */

    Ok(())
}

/*
/// Load Proofs
pub async fn set_proofs(proofs: &str) -> Result<String, CashuError> {
    let proofs: HashMap<String, Proofs> = serde_json::from_str(proofs)?;

    let mut c_proofs = PROOFS.lock().await;

    *c_proofs = proofs;
    Ok(serde_json::to_string(&*c_proofs)?)
}

/// Get Proofs
pub async fn get_proofs() -> Result<String, CashuError> {
    let c_proofs = PROOFS.lock().await;

    Ok(serde_json::to_string(&*c_proofs)?)
}
*/

pub fn set_mints(mints: Vec<String>) -> Result<Vec<String>> {
    let rt = lock_runtime!();

    rt.block_on(async {
        add_new_wallets(mints)?;

        let m: Vec<String> = WALLETS.lock().await.keys().cloned().collect();

        Ok(m)
    })
}

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

pub fn check_spendable(encoded_token: String) -> Result<bool> {
    let rt = lock_runtime!();
    let token = Token::from_str(&encoded_token)?;
    rt.block_on(async {
        let wallet = wallet_for_url(&token.token_info().1).await?;

        let check_spent = wallet
            .check_proofs_spent(token.token[0].clone().proofs)
            .await?;

        // REVIEW: This is a fairly naive check on if a token is spendable
        if check_spent.spendable.is_empty() {
            return Ok(false);
        } else {
            return Ok(true);
        }
    })
}

pub fn receive_token(encoded_token: String) -> Result<String> {
    let rt = lock_runtime!();
    let token = Token::from_str(&encoded_token)?;
    rt.block_on(async {
        let wallet = wallet_for_url(&token.token_info().1).await?;
        let mint_url = wallet.client.mint_url.to_string();
        let received_proofs = wallet.receive(&encoded_token).await?;

        database::add_proofs(&mint_url, received_proofs.clone()).await?;

        // let got = database::get_proofs(&mint_url).await?;
        Ok(serde_json::to_string(&received_proofs)?)
    })
}

// REVIEW: Naive coin selection
fn select_send_proofs(amount: u64, proofs: &Proofs) -> (Proofs, Proofs) {
    let mut send_proofs = vec![];
    let mut keep_proofs = vec![];

    let mut a = 0;

    for proof in proofs {
        if a < amount {
            send_proofs.push(proof.clone());
        } else {
            keep_proofs.push(proof.clone());
        }
        a += proof.amount.to_sat();
    }

    (send_proofs, keep_proofs)
}

pub fn send(amount: u64, active_mint: String) -> Result<String> {
    let rt = lock_runtime!();
    rt.block_on(async {
        let wallet = wallet_for_url(&active_mint).await?;

        let proofs = database::get_proofs(&active_mint).await?;

        let (send_proofs, mut keep_proofs) = select_send_proofs(amount, &proofs);
        let r = wallet.send(Amount::from_sat(amount), send_proofs).await?;
        keep_proofs.extend(r.change_proofs.clone());

        // Set wallet proofs to change
        database::add_proofs(&active_mint, keep_proofs).await?;

        // Add pending proofs
        // TODO: Remove this
        PENDING_PROOFS
            .lock()
            .await
            .insert(active_mint.to_owned(), r.send_proofs.clone());

        let token = wallet.proofs_to_token(r.send_proofs, None);

        return Ok(token);
    })
}

// TODO: Need to make sure wallet is in wallets
pub fn request_mint(amount: u64, mint_url: String) -> Result<RequestMintInfo> {
    let rt = lock_runtime!();
    rt.block_on(async {
        let wallet = wallet_for_url(&mint_url).await?;
        let invoice = wallet.request_mint(Amount::from_sat(amount)).await?;
        Ok(RequestMintInfo {
            pr: invoice.pr.to_string(),
            hash: invoice.hash,
        })
    })
}

pub fn mint_token(amount: u64, hash: String, mint: String) -> Result<()> {
    let rt = lock_runtime!();
    rt.block_on(async {
        let wallets = WALLETS.lock().await;
        if let Some(Some(wallet)) = wallets.get(&mint) {
            let proofs = wallet.mint_token(Amount::from_sat(amount), &hash).await?;

            database::add_proofs(&mint, proofs).await?;

            return Ok(());
        }
        bail!("Could not get invoice".to_string())
    })
}

// TODO: Melt, untested as legend.lnbits has LN issues
pub fn melt(amount: u64, invoice: String, mint: String) -> Result<()> {
    let rt = lock_runtime!();
    rt.block_on(async {
        let wallet = wallet_for_url(&mint).await?;

        let invoice = str::parse::<Invoice>(&invoice)?;
        let proofs = database::get_proofs(&mint).await?;

        let (send_proofs, mut keep_proofs) = select_send_proofs(amount, &proofs);
        let change = wallet.melt(invoice, send_proofs.clone()).await?;
        if let Some(change) = change.change {
            keep_proofs.extend(change);
        }

        // Remove proofs to be sent
        database::remove_proofs(&mint, send_proofs).await?;

        Ok(())
    })
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

pub struct InvoiceInfo {
    pub amount: u64,
    pub hash: String,
    pub memo: Option<String>,
}

// REVIEW: Have to define this twice since its from another crate
pub struct RequestMintInfo {
    pub pr: String,
    pub hash: String,
}

pub struct TokenData {
    pub encoded_token: String,
    pub mint: String,
    pub amount: u64,
    pub memo: Option<String>, // spendable: Option<bool>,
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

/*
pub async fn create_client(url: &str) -> Result<String, CashuError> {
    let client = Client::new(url)?;

    let client = Cashu { mints: vec![] };
    Ok(url.to_string())
}
*/
