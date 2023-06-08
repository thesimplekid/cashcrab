use anyhow::{bail, Result};

use crate::{api::wallet_for_url, database, types::Mint};
/// Fetch Mint into
pub(crate) async fn fetch_mint_info(url: &str) -> Result<()> {
    let wallet = wallet_for_url(url).await?;
    let mint_info = wallet.client.get_info().await?;

    database::cashu::update_mint_info(url, mint_info.into()).await?;
    Ok(())
}
