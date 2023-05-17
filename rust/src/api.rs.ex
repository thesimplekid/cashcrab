use std::{collections::HashMap, io, str::FromStr, sync::Arc};

use anyhow::{anyhow, bail, Result};
use bitcoin::Amount;
use cashu_crab::{
    cashu_wallet::CashuWallet,
    client::Client,
    // error::Error as CashuCrabError,
    types::{Proofs, Token},
};
use lazy_static::lazy_static;
use lightning_invoice::{Invoice, InvoiceDescription};
use std::sync::Mutex as StdMutex;
use tokio::runtime::{Builder, Runtime};
use tokio::sync::Mutex;

lazy_static! {
    static ref WALLETS: Arc<Mutex<HashMap<String, Option<CashuWallet>>>> =
        Arc::new(Mutex::new(HashMap::new()));
    static ref PROOFS: Arc<Mutex<HashMap<String, Proofs>>> = Arc::new(Mutex::new(HashMap::new()));
    static ref PENDING_PROOFS: Arc<Mutex<HashMap<String, Proofs>>> =
        Arc::new(Mutex::new(HashMap::new()));
    static ref RUNTIME: Arc<StdMutex<Runtime>> = Arc::new(StdMutex::new(Runtime::new().unwrap()));
}

pub fn get_balances() -> Result<String> {
    let rt = RUNTIME.lock().map_err(|_| {
        let err: anyhow::Error = anyhow!("Failed to lock the runtime mutex");
        <anyhow::Error as Into<anyhow::Error>>::into(err)
    })?;
    rt.block_on(async {
        let proofs = PROOFS.lock().await;

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
    let rt = RUNTIME.lock().map_err(|_| {
        let err: anyhow::Error = anyhow!("Failed to lock the runtime mutex");
        <anyhow::Error as Into<anyhow::Error>>::into(err)
    })?;
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
    let rt = RUNTIME.lock().map_err(|_| {
        let err: anyhow::Error = anyhow!("Failed to lock the runtime mutex");
        <anyhow::Error as Into<anyhow::Error>>::into(err)
    })?;
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
    let rt = RUNTIME.lock().map_err(|_| {
        let err: anyhow::Error = anyhow!("Failed to lock the runtime mutex");
        <anyhow::Error as Into<anyhow::Error>>::into(err)
    })?;
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

/// Load Proofs
pub fn set_proofs(proofs: String) -> Result<String> {
    let rt = RUNTIME.lock().map_err(|_| {
        let err: anyhow::Error = anyhow!("Failed to lock the runtime mutex");
        <anyhow::Error as Into<anyhow::Error>>::into(err)
    })?;
    rt.block_on(async {
        let proofs: HashMap<String, Proofs> = serde_json::from_str(&proofs)?;

        let mut c_proofs = PROOFS.lock().await;

        *c_proofs = proofs;
        Ok(serde_json::to_string(&*c_proofs)?)
    })
}

/// Get Proofs
pub fn get_proofs() -> Result<String> {
    // bail!("got proof call");
    let rt = RUNTIME.lock().map_err(|_| {
        let err: anyhow::Error = anyhow!("Failed to lock the runtime mutex");
        <anyhow::Error as Into<anyhow::Error>>::into(err)
    })?;
    rt.block_on(async {
        let c_proofs = PROOFS.lock().await;

        Ok(serde_json::to_string(&*c_proofs)?)
    })
}
/// Get Proofs
async fn async_get_proofs() -> Result<String> {
    // bail!("got proof call");
    let c_proofs = PROOFS.lock().await;

    Ok(serde_json::to_string(&*c_proofs)?)
}

pub fn set_mints(mints: Vec<String>) -> Result<String> {
    let rt = RUNTIME.lock().map_err(|_| {
        let err: anyhow::Error = anyhow!("Failed to lock the runtime mutex");
        <anyhow::Error as Into<anyhow::Error>>::into(err)
    })?;
    rt.block_on(async {
        // bail!(format!("mints: {:?}", mints));
        //add_new_wallets(mints)?;

        // let m: Vec<String> = WALLETS.lock().await.keys().cloned().collect();
        let m = serde_json::to_string(&mints)?;

        Ok(m)
    })
}

async fn wallet_for_url(mint_url: String) -> Result<CashuWallet> {
    // rt.block_on(async {
    let mut wallets = WALLETS.lock().await;
    let cashu_wallet = match wallets.get(&mint_url) {
        Some(Some(wallet)) => wallet.clone(),
        _ => {
            let client = Client::new(&mint_url)?;
            let keys = client.get_keys().await?;
            let wallet = CashuWallet::new(client, keys);
            wallets.insert(mint_url.to_string(), Some(wallet.clone()));

            wallet
        }
    };

    Ok(cashu_wallet)
    // })
}

pub fn check_spendable(encoded_token: String) -> Result<bool> {
    let rt = RUNTIME.lock().map_err(|_| {
        let err: anyhow::Error = anyhow!("Failed to lock the runtime mutex");
        <anyhow::Error as Into<anyhow::Error>>::into(err)
    })?;
    rt.block_on(async {
        let token = Token::from_str(&encoded_token)?;
        let wallet = wallet_for_url(token.token_info().1).await?;

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

async fn insert_proofs(mint_url: String, proofs: Proofs) {
    let mut mint_proofs = PROOFS.lock().await;

    let current_proofs = mint_proofs.get(&mint_url);

    let proofs = match current_proofs {
        Some(c_proofs) => {
            let mut c_proofs = c_proofs.clone();
            c_proofs.extend(proofs);

            c_proofs
        }
        None => proofs,
    };

    mint_proofs.insert(mint_url.to_string(), proofs);
}

pub fn receive_token(encoded_token: String) -> Result<String> {
    let rt = RUNTIME.lock().map_err(|_| {
        let err: anyhow::Error = anyhow!("Failed to lock the runtime mutex");
        <anyhow::Error as Into<anyhow::Error>>::into(err)
    })?;
    // bail!(format!("got lock"));

    rt.block_on(async {
        let token = Token::from_str(&encoded_token)?;
        let wallet = wallet_for_url(token.token_info().1).await?;
        let mint_url = wallet.client.mint_url.to_string();
        let received_proofs = wallet.receive(&encoded_token).await?;

        insert_proofs(mint_url, received_proofs).await;
        let proofs = async_get_proofs().await?;
        return Ok(proofs);
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
    let rt = RUNTIME.lock().map_err(|_| {
        let err: anyhow::Error = anyhow!("Failed to lock the runtime mutex");
        <anyhow::Error as Into<anyhow::Error>>::into(err)
    })?;
    rt.block_on(async {
        let wallet = wallet_for_url(active_mint.clone()).await?;

        let mut proofs = PROOFS.lock().await;
        let active_proofs = proofs.get(&active_mint);

        if let Some(proofs_l) = active_proofs {
            let (send_proofs, mut keep_proofs) = select_send_proofs(amount, proofs_l);
            let r = wallet.send(Amount::from_sat(amount), send_proofs).await?;
            keep_proofs.extend(r.change_proofs.clone());

            // Sent wallet proofs to change
            proofs.insert(active_mint.to_owned(), keep_proofs);

            // Add pending proofs
            PENDING_PROOFS
                .lock()
                .await
                .insert(active_mint.to_owned(), r.send_proofs.clone());

            let token = wallet.proofs_to_token(r.send_proofs, None);

            return Ok(token);
        }
        bail!("Error sending");
    })
}

// TODO: Need to make sure wallet is in wallets
pub fn request_mint(amount: u64, mint_url: String) -> Result<RequestMintInfo> {
    let rt = RUNTIME.lock().map_err(|_| {
        let err: anyhow::Error = anyhow!("Failed to lock the runtime mutex");
        <anyhow::Error as Into<anyhow::Error>>::into(err)
    })?;
    rt.block_on(async {
        let wallet = wallet_for_url(mint_url).await?;
        let invoice = wallet.request_mint(Amount::from_sat(amount)).await?;
        Ok(RequestMintInfo {
            pr: invoice.pr.to_string(),
            hash: invoice.hash,
        })
    })
}

pub fn mint_token(amount: u64, hash: String, mint: String) -> Result<String> {
    let rt = RUNTIME.lock().map_err(|_| {
        let err: anyhow::Error = anyhow!("Failed to lock the runtime mutex");
        <anyhow::Error as Into<anyhow::Error>>::into(err)
    })?;
    rt.block_on(async {
        let wallets = WALLETS.lock().await;
        if let Some(Some(wallet)) = wallets.get(&mint) {
            let proofs = wallet.mint_token(Amount::from_sat(amount), &hash).await?;

            insert_proofs(mint, proofs).await;

            return get_proofs();
        }
        bail!("Mint error");
    })
}

// TODO: Melt, untested as legend.lnbits has LN issues
pub fn melt(amount: u64, invoice: String, mint: String) -> Result<String> {
    let rt = RUNTIME.lock().map_err(|_| {
        let err: anyhow::Error = anyhow!("Failed to lock the runtime mutex");
        <anyhow::Error as Into<anyhow::Error>>::into(err)
    })?;
    rt.block_on(async {
        let wallet = wallet_for_url(mint.clone()).await?;

        let invoice = str::parse::<Invoice>(&invoice).unwrap();
        let mut proofs = PROOFS.lock().await;
        let active_proofs = proofs.get(&mint);

        if let Some(proofs_l) = active_proofs {
            let (send_proofs, mut keep_proofs) = select_send_proofs(amount, proofs_l);
            let change = wallet.melt(invoice, send_proofs).await?;
            keep_proofs.extend(change.change.unwrap());

            // Sent wallet proofs to change
            proofs.insert(mint.to_owned(), keep_proofs);
        }

        get_proofs()
    })
}

/// Decode invoice
pub fn decode_invoice(invoice: String) -> Result<InvoiceInfo> {
    let invoice = str::parse::<Invoice>(&invoice).unwrap();

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
