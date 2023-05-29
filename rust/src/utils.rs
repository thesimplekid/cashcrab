use std::time::SystemTime;

use bitcoin::secp256k1::XOnlyPublicKey;

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
