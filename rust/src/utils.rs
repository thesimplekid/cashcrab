use bitcoin::secp256k1::XOnlyPublicKey;

pub fn encode_pubkey(pubkey: &XOnlyPublicKey) -> String {
    let ser = pubkey.serialize();
    hex::encode(ser)
}
