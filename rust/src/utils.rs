use std::time::SystemTime;

use anyhow::Result;
use bitcoin::secp256k1::XOnlyPublicKey;
use nostr_sdk::prelude::{FromBech32, PREFIX_BECH32_PUBLIC_KEY};
use std::str::FromStr;

pub fn encode_pubkey(pubkey: &XOnlyPublicKey) -> String {
    let ser = pubkey.serialize();
    hex::encode(ser)
}

pub fn unix_time() -> u64 {
    SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .map(|x| x.as_secs())
        .unwrap_or(0)
}

pub fn convert_str_to_xonly(pubkey: &str) -> Result<XOnlyPublicKey> {
    match pubkey.starts_with(PREFIX_BECH32_PUBLIC_KEY) {
        true => Ok(XOnlyPublicKey::from_bech32(pubkey)?),
        false => Ok(XOnlyPublicKey::from_str(pubkey)?),
    }
}
