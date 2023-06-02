#![allow(
    non_camel_case_types,
    unused,
    clippy::redundant_closure,
    clippy::useless_conversion,
    clippy::unit_arg,
    clippy::double_parens,
    non_snake_case,
    clippy::too_many_arguments
)]
// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.76.0.

use crate::api::*;
use core::panic::UnwindSafe;
use flutter_rust_bridge::*;
use std::ffi::c_void;
use std::sync::Arc;

// Section: imports

use crate::types::CashuTransaction;
use crate::types::Contact;
use crate::types::Conversation;
use crate::types::Direction;
use crate::types::InvoiceInfo;
use crate::types::LNTransaction;
use crate::types::Message;
use crate::types::Mint;
use crate::types::Picture;
use crate::types::TokenData;
use crate::types::Transaction;
use crate::types::TransactionStatus;

// Section: wire functions

fn wire_init_db_impl(port_: MessagePort, storage_path: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "init_db",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_storage_path = storage_path.wire2api();
            move |task_callback| init_db(api_storage_path)
        },
    )
}
fn wire_init_nostr_impl(port_: MessagePort, storage_path: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "init_nostr",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_storage_path = storage_path.wire2api();
            move |task_callback| init_nostr(api_storage_path)
        },
    )
}
fn wire_get_relays_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_relays",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| get_relays(),
    )
}
fn wire_add_relay_impl(port_: MessagePort, relay: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "add_relay",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_relay = relay.wire2api();
            move |task_callback| add_relay(api_relay)
        },
    )
}
fn wire_remove_relay_impl(port_: MessagePort, relay: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "remove_relay",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_relay = relay.wire2api();
            move |task_callback| remove_relay(api_relay)
        },
    )
}
fn wire_fetch_contacts_impl(port_: MessagePort, pubkey: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "fetch_contacts",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_pubkey = pubkey.wire2api();
            move |task_callback| fetch_contacts(api_pubkey)
        },
    )
}
fn wire_add_contact_impl(port_: MessagePort, pubkey: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "add_contact",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_pubkey = pubkey.wire2api();
            move |task_callback| add_contact(api_pubkey)
        },
    )
}
fn wire_remove_contact_impl(port_: MessagePort, pubkey: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "remove_contact",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_pubkey = pubkey.wire2api();
            move |task_callback| remove_contact(api_pubkey)
        },
    )
}
fn wire_get_contacts_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_contacts",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| get_contacts(),
    )
}
fn wire_get_contact_picture_id_impl(
    port_: MessagePort,
    pubkey: impl Wire2Api<String> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_contact_picture_id",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_pubkey = pubkey.wire2api();
            move |task_callback| get_contact_picture_id(api_pubkey)
        },
    )
}
fn wire_fetch_picture_impl(port_: MessagePort, url: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "fetch_picture",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_url = url.wire2api();
            move |task_callback| fetch_picture(api_url)
        },
    )
}
fn wire_send_message_impl(
    port_: MessagePort,
    pubkey: impl Wire2Api<String> + UnwindSafe,
    message: impl Wire2Api<Message> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "send_message",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_pubkey = pubkey.wire2api();
            let api_message = message.wire2api();
            move |task_callback| send_message(api_pubkey, api_message)
        },
    )
}
fn wire_get_conversation_impl(port_: MessagePort, pubkey: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_conversation",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_pubkey = pubkey.wire2api();
            move |task_callback| get_conversation(api_pubkey)
        },
    )
}
fn wire_get_balances_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_balances",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| get_balances(),
    )
}
fn wire_add_mint_impl(port_: MessagePort, url: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "add_mint",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_url = url.wire2api();
            move |task_callback| add_mint(api_url)
        },
    )
}
fn wire_get_wallets_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_wallets",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| get_wallets(),
    )
}
fn wire_remove_wallet_impl(port_: MessagePort, url: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "remove_wallet",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_url = url.wire2api();
            move |task_callback| remove_wallet(api_url)
        },
    )
}
fn wire_check_spendable_impl(
    port_: MessagePort,
    transaction: impl Wire2Api<Transaction> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "check_spendable",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_transaction = transaction.wire2api();
            move |task_callback| check_spendable(api_transaction)
        },
    )
}
fn wire_receive_token_impl(port_: MessagePort, encoded_token: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "receive_token",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_encoded_token = encoded_token.wire2api();
            move |task_callback| receive_token(api_encoded_token)
        },
    )
}
fn wire_send_impl(
    port_: MessagePort,
    amount: impl Wire2Api<u64> + UnwindSafe,
    active_mint: impl Wire2Api<String> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "send",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_amount = amount.wire2api();
            let api_active_mint = active_mint.wire2api();
            move |task_callback| send(api_amount, api_active_mint)
        },
    )
}
fn wire_request_mint_impl(
    port_: MessagePort,
    amount: impl Wire2Api<u64> + UnwindSafe,
    mint_url: impl Wire2Api<String> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "request_mint",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_amount = amount.wire2api();
            let api_mint_url = mint_url.wire2api();
            move |task_callback| request_mint(api_amount, api_mint_url)
        },
    )
}
fn wire_mint_token_impl(
    port_: MessagePort,
    amount: impl Wire2Api<u64> + UnwindSafe,
    hash: impl Wire2Api<String> + UnwindSafe,
    mint: impl Wire2Api<String> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "mint_token",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_amount = amount.wire2api();
            let api_hash = hash.wire2api();
            let api_mint = mint.wire2api();
            move |task_callback| mint_token(api_amount, api_hash, api_mint)
        },
    )
}
fn wire_melt_impl(
    port_: MessagePort,
    amount: impl Wire2Api<u64> + UnwindSafe,
    invoice: impl Wire2Api<String> + UnwindSafe,
    mint: impl Wire2Api<String> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "melt",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_amount = amount.wire2api();
            let api_invoice = invoice.wire2api();
            let api_mint = mint.wire2api();
            move |task_callback| melt(api_amount, api_invoice, api_mint)
        },
    )
}
fn wire_decode_invoice_impl(
    port_: MessagePort,
    encoded_invoice: impl Wire2Api<String> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "decode_invoice",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_encoded_invoice = encoded_invoice.wire2api();
            move |task_callback| decode_invoice(api_encoded_invoice)
        },
    )
}
fn wire_get_transactions_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_transactions",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| get_transactions(),
    )
}
fn wire_get_transaction_impl(port_: MessagePort, tid: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_transaction",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_tid = tid.wire2api();
            move |task_callback| get_transaction(api_tid)
        },
    )
}
fn wire_get_mints_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_mints",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| get_mints(),
    )
}
fn wire_get_active_mint_impl(port_: MessagePort) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "get_active_mint",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || move |task_callback| get_active_mint(),
    )
}
fn wire_set_active_mint_impl(
    port_: MessagePort,
    mint_url: impl Wire2Api<Option<String>> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "set_active_mint",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_mint_url = mint_url.wire2api();
            move |task_callback| set_active_mint(api_mint_url)
        },
    )
}
fn wire_decode_token_impl(port_: MessagePort, encoded_token: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap(
        WrapInfo {
            debug_name: "decode_token",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_encoded_token = encoded_token.wire2api();
            move |task_callback| decode_token(api_encoded_token)
        },
    )
}
// Section: wrapper structs

// Section: static checks

// Section: allocate functions

// Section: related functions

// Section: impl Wire2Api

pub trait Wire2Api<T> {
    fn wire2api(self) -> T;
}

impl<T, S> Wire2Api<Option<T>> for *mut S
where
    *mut S: Wire2Api<T>,
{
    fn wire2api(self) -> Option<T> {
        (!self.is_null()).then(|| self.wire2api())
    }
}

impl Wire2Api<Direction> for i32 {
    fn wire2api(self) -> Direction {
        match self {
            0 => Direction::Sent,
            1 => Direction::Received,
            _ => unreachable!("Invalid variant for Direction: {}", self),
        }
    }
}
impl Wire2Api<i32> for i32 {
    fn wire2api(self) -> i32 {
        self
    }
}

impl Wire2Api<TransactionStatus> for i32 {
    fn wire2api(self) -> TransactionStatus {
        match self {
            0 => TransactionStatus::Sent,
            1 => TransactionStatus::Received,
            2 => TransactionStatus::Pending,
            3 => TransactionStatus::Failed,
            4 => TransactionStatus::Expired,
            _ => unreachable!("Invalid variant for TransactionStatus: {}", self),
        }
    }
}
impl Wire2Api<u64> for u64 {
    fn wire2api(self) -> u64 {
        self
    }
}
impl Wire2Api<u8> for u8 {
    fn wire2api(self) -> u8 {
        self
    }
}

// Section: impl IntoDart

impl support::IntoDart for CashuTransaction {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.id.into_dart(),
            self.status.into_dart(),
            self.time.into_dart(),
            self.amount.into_dart(),
            self.mint.into_dart(),
            self.token.into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for CashuTransaction {}

impl support::IntoDart for Contact {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.pubkey.into_dart(),
            self.npub.into_dart(),
            self.name.into_dart(),
            self.picture.into_dart(),
            self.lud16.into_dart(),
            self.created_at.into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for Contact {}

impl support::IntoDart for Conversation {
    fn into_dart(self) -> support::DartAbi {
        vec![self.messages.into_dart(), self.transactions.into_dart()].into_dart()
    }
}
impl support::IntoDartExceptPrimitive for Conversation {}

impl support::IntoDart for Direction {
    fn into_dart(self) -> support::DartAbi {
        match self {
            Self::Sent => 0,
            Self::Received => 1,
        }
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for Direction {}

impl support::IntoDart for InvoiceInfo {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.bolt11.into_dart(),
            self.amount.into_dart(),
            self.hash.into_dart(),
            self.memo.into_dart(),
            self.mint.into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for InvoiceInfo {}

impl support::IntoDart for LNTransaction {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.id.into_dart(),
            self.status.into_dart(),
            self.time.into_dart(),
            self.amount.into_dart(),
            self.fee.into_dart(),
            self.mint.into_dart(),
            self.bolt11.into_dart(),
            self.hash.into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for LNTransaction {}

impl support::IntoDart for Message {
    fn into_dart(self) -> support::DartAbi {
        match self {
            Self::Text {
                direction,
                time,
                content,
            } => vec![
                0.into_dart(),
                direction.into_dart(),
                time.into_dart(),
                content.into_dart(),
            ],
            Self::Invoice {
                direction,
                time,
                transaction_id,
            } => vec![
                1.into_dart(),
                direction.into_dart(),
                time.into_dart(),
                transaction_id.into_dart(),
            ],
            Self::Token {
                direction,
                time,
                transaction_id,
            } => vec![
                2.into_dart(),
                direction.into_dart(),
                time.into_dart(),
                transaction_id.into_dart(),
            ],
        }
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for Message {}
impl support::IntoDart for Mint {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.url.into_dart(),
            self.active_keyset.into_dart(),
            self.keysets.into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for Mint {}

impl support::IntoDart for Picture {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.url.into_dart(),
            self.hash.into_dart(),
            self.updated.into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for Picture {}

impl support::IntoDart for TokenData {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.encoded_token.into_dart(),
            self.mint.into_dart(),
            self.amount.into_dart(),
            self.memo.into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for TokenData {}

impl support::IntoDart for Transaction {
    fn into_dart(self) -> support::DartAbi {
        match self {
            Self::CashuTransaction(field0) => vec![0.into_dart(), field0.into_dart()],
            Self::LNTransaction(field0) => vec![1.into_dart(), field0.into_dart()],
        }
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for Transaction {}
impl support::IntoDart for TransactionStatus {
    fn into_dart(self) -> support::DartAbi {
        match self {
            Self::Sent => 0,
            Self::Received => 1,
            Self::Pending => 2,
            Self::Failed => 3,
            Self::Expired => 4,
        }
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for TransactionStatus {}

// Section: executor

support::lazy_static! {
    pub static ref FLUTTER_RUST_BRIDGE_HANDLER: support::DefaultHandler = Default::default();
}

#[cfg(not(target_family = "wasm"))]
#[path = "bridge_generated.io.rs"]
mod io;
#[cfg(not(target_family = "wasm"))]
pub use io::*;
