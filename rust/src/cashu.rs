use std::{collections::HashMap, str::FromStr};

use anyhow::Result;
use cashu_crab::nuts::nut00::{mint_proofs_from_proofs, Token};
use cashu_crab::Amount;
use lightning_invoice::Invoice;

use crate::{
    api::wallet_for_url,
    database,
    types::{CashuTransaction, LNTransaction, Transaction, TransactionStatus},
};

pub(crate) async fn init_cashu() -> Result<()> {
    let mints = database::cashu::get_all_mints().await?;

    for mint in mints {
        wallet_for_url(&mint.url).await?;
    }

    let pending = database::transactions::get_pending_transactions().await?;
    // bail!("{:?}", pending);

    for transaction in pending {
        check_transaction_status(&transaction).await?;
    }

    Ok(())
}

/// Fetch Mint into
pub(crate) async fn fetch_mint_info(url: &str) -> Result<()> {
    let wallet = wallet_for_url(url).await?;
    let mint_info = wallet.client.get_info().await?;

    database::cashu::update_mint_info(url, mint_info.into()).await?;
    Ok(())
}

pub(crate) async fn get_mint_balances(mints: Vec<String>) -> Result<HashMap<String, i64>> {
    let proofs = database::cashu::get_all_proofs().await?;

    let mut balances = proofs
        .iter()
        .map(|(mint, proofs)| {
            let balance = proofs
                .iter()
                .fold(0, |acc, proof| acc + proof.amount.to_sat() as i64);
            (mint.to_owned(), balance)
        })
        .collect::<HashMap<_, _>>();

    for mint in mints {
        balances.entry(mint).or_insert(0);
    }

    Ok(balances)
}

pub(crate) async fn receive_token(encoded_token: &str) -> Result<Transaction> {
    let token = Token::from_str(encoded_token)?;
    let wallet = wallet_for_url(&token.token_info().1).await?;
    let mint_url = wallet.client.mint_url.to_string();
    let received_proofs = wallet.receive(encoded_token).await?;

    database::cashu::add_proofs(&mint_url, &received_proofs).await?;

    let transaction = Transaction::CashuTransaction(CashuTransaction::new(
        TransactionStatus::Received,
        token.token_info().0,
        &mint_url,
        encoded_token,
        None,
    ));

    database::transactions::add_transaction(&transaction).await?;

    Ok(transaction)
}

/// Checks if all proofs for a mint are spent
pub(crate) async fn remove_spent_proofs(mint_url: &str) -> Result<()> {
    let wallet = wallet_for_url(mint_url).await?;

    let proofs = database::cashu::get_proofs(mint_url).await?;

    let check_proofs = wallet
        .check_proofs_spent(&mint_proofs_from_proofs(proofs.clone()))
        .await?;

    let spent: Vec<String> = check_proofs
        .spent
        .iter()
        .map(|p| p.secret.clone())
        .collect();

    let spent_proofs = proofs
        .iter()
        .filter(|p| spent.contains(&p.secret))
        .cloned()
        .collect();

    database::cashu::remove_proofs(mint_url, &spent_proofs).await?;

    Ok(())
}

pub(crate) async fn check_transaction_status(
    transaction: &Transaction,
) -> Result<TransactionStatus> {
    match &transaction {
        Transaction::CashuTransaction(cashu_trans) => {
            let token = Token::from_str(&cashu_trans.token)?;
            let wallet = wallet_for_url(&cashu_trans.mint).await?;

            let proofs = token.token[0].clone().proofs;
            let check_spent = wallet
                .check_proofs_spent(&mint_proofs_from_proofs(proofs.clone()))
                .await?;

            // REVIEW: This is a fairly naive check on if a token is spendable
            // this works in the way `check_spendable` is called now but is not techically correct
            // As a spendable proof can be from a completed transaction
            // bail!("{:?}", check_spent);
            if check_spent.spendable.is_empty() {
                // bail!("{:?}", transaction);
                let transaction = Transaction::CashuTransaction(CashuTransaction {
                    id: Some(transaction.id()),
                    status: TransactionStatus::Sent,
                    time: cashu_trans.time,
                    amount: cashu_trans.amount,
                    mint: cashu_trans.mint.clone(),
                    token: cashu_trans.token.clone(),
                    from: cashu_trans.from.clone(),
                });

                database::transactions::update_transaction_status(&transaction).await?;

                // Update Status
                Ok(TransactionStatus::Sent)
            } else if check_spent.spendable.len().ne(&proofs.len()) {
                // Tokens can have multiple proofs
                // In the case that some of the proofs of a token are spendable
                // Claim them in a new transaction

                let transaction = Transaction::CashuTransaction(CashuTransaction {
                    id: Some(transaction.id()),
                    status: TransactionStatus::Sent,
                    time: cashu_trans.time,
                    amount: cashu_trans.amount,
                    mint: cashu_trans.mint.clone(),
                    token: cashu_trans.token.clone(),
                    from: cashu_trans.from.clone(),
                });

                database::transactions::update_transaction_status(&transaction).await?;

                let spendable_secrets: Vec<String> = check_spent
                    .spendable
                    .iter()
                    .map(|p| p.secret.clone())
                    .collect();

                let spendable_proofs = proofs
                    .iter()
                    .filter(|p| spendable_secrets.contains(&p.secret))
                    .cloned()
                    .collect();

                let token = wallet.proofs_to_token(spendable_proofs, None)?;
                let _transaction = receive_token(&token).await?;

                Ok(TransactionStatus::Sent)
            } else {
                Ok(cashu_trans.status)
            }
        }
        Transaction::LNTransaction(ln_trans) => {
            if let Some(mint) = &ln_trans.mint {
                let wallet = wallet_for_url(mint).await?;
                let invoice = Invoice::from_str(&ln_trans.bolt11)?;

                let proofs = wallet
                    .mint(Amount::from_sat(ln_trans.amount), &ln_trans.hash)
                    .await
                    .unwrap_or_default();

                if !proofs.is_empty() {
                    database::cashu::add_proofs(mint, &proofs).await?;
                    database::transactions::update_transaction_status(&Transaction::LNTransaction(
                        LNTransaction::new(
                            TransactionStatus::Received,
                            ln_trans.amount,
                            ln_trans.fee,
                            ln_trans.mint.clone(),
                            &ln_trans.bolt11,
                            &ln_trans.hash,
                        ),
                    ))
                    .await?;
                    return Ok(TransactionStatus::Received);
                } else if invoice.is_expired() {
                    database::transactions::update_transaction_status(&Transaction::LNTransaction(
                        LNTransaction::new(
                            TransactionStatus::Expired,
                            ln_trans.amount,
                            ln_trans.fee,
                            ln_trans.mint.clone(),
                            &ln_trans.bolt11,
                            &ln_trans.hash,
                        ),
                    ))
                    .await?;
                    return Ok(TransactionStatus::Expired);
                }
            }
            Ok(ln_trans.status)
        }
    }
}
