use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_init_db(port_: i64, path: *mut wire_uint_8_list) {
    wire_init_db_impl(port_, path)
}

#[no_mangle]
pub extern "C" fn wire_init_nostr(port_: i64) {
    wire_init_nostr_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_get_relays(port_: i64) {
    wire_get_relays_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_add_relay(port_: i64, relay: *mut wire_uint_8_list) {
    wire_add_relay_impl(port_, relay)
}

#[no_mangle]
pub extern "C" fn wire_remove_relay(port_: i64, relay: *mut wire_uint_8_list) {
    wire_remove_relay_impl(port_, relay)
}

#[no_mangle]
pub extern "C" fn wire_fetch_contacts(port_: i64, pubkey: *mut wire_uint_8_list) {
    wire_fetch_contacts_impl(port_, pubkey)
}

#[no_mangle]
pub extern "C" fn wire_add_contact(port_: i64, pubkey: *mut wire_uint_8_list) {
    wire_add_contact_impl(port_, pubkey)
}

#[no_mangle]
pub extern "C" fn wire_remove_contact(port_: i64, pubkey: *mut wire_uint_8_list) {
    wire_remove_contact_impl(port_, pubkey)
}

#[no_mangle]
pub extern "C" fn wire_get_contacts(port_: i64) {
    wire_get_contacts_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_send_message(
    port_: i64,
    pubkey: *mut wire_uint_8_list,
    message: *mut wire_Message,
) {
    wire_send_message_impl(port_, pubkey, message)
}

#[no_mangle]
pub extern "C" fn wire_get_conversation(port_: i64, pubkey: *mut wire_uint_8_list) {
    wire_get_conversation_impl(port_, pubkey)
}

#[no_mangle]
pub extern "C" fn wire_get_balances(port_: i64) {
    wire_get_balances_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_add_mint(port_: i64, url: *mut wire_uint_8_list) {
    wire_add_mint_impl(port_, url)
}

#[no_mangle]
pub extern "C" fn wire_get_wallets(port_: i64) {
    wire_get_wallets_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_remove_wallet(port_: i64, url: *mut wire_uint_8_list) {
    wire_remove_wallet_impl(port_, url)
}

#[no_mangle]
pub extern "C" fn wire_add_new_wallets(port_: i64, _mints: *mut wire_StringList) {
    wire_add_new_wallets_impl(port_, _mints)
}

#[no_mangle]
pub extern "C" fn wire_set_mints(port_: i64, mints: *mut wire_StringList) {
    wire_set_mints_impl(port_, mints)
}

#[no_mangle]
pub extern "C" fn wire_check_spendable(port_: i64, transaction: *mut wire_Transaction) {
    wire_check_spendable_impl(port_, transaction)
}

#[no_mangle]
pub extern "C" fn wire_receive_token(port_: i64, encoded_token: *mut wire_uint_8_list) {
    wire_receive_token_impl(port_, encoded_token)
}

#[no_mangle]
pub extern "C" fn wire_send(port_: i64, amount: u64, active_mint: *mut wire_uint_8_list) {
    wire_send_impl(port_, amount, active_mint)
}

#[no_mangle]
pub extern "C" fn wire_request_mint(port_: i64, amount: u64, mint_url: *mut wire_uint_8_list) {
    wire_request_mint_impl(port_, amount, mint_url)
}

#[no_mangle]
pub extern "C" fn wire_mint_token(
    port_: i64,
    amount: u64,
    hash: *mut wire_uint_8_list,
    mint: *mut wire_uint_8_list,
) {
    wire_mint_token_impl(port_, amount, hash, mint)
}

#[no_mangle]
pub extern "C" fn wire_melt(
    port_: i64,
    amount: u64,
    invoice: *mut wire_uint_8_list,
    mint: *mut wire_uint_8_list,
) {
    wire_melt_impl(port_, amount, invoice, mint)
}

#[no_mangle]
pub extern "C" fn wire_decode_invoice(port_: i64, invoice: *mut wire_uint_8_list) {
    wire_decode_invoice_impl(port_, invoice)
}

#[no_mangle]
pub extern "C" fn wire_get_transactions(port_: i64) {
    wire_get_transactions_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_get_transaction(port_: i64, tid: *mut wire_uint_8_list) {
    wire_get_transaction_impl(port_, tid)
}

#[no_mangle]
pub extern "C" fn wire_get_mints(port_: i64) {
    wire_get_mints_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_get_active_mint(port_: i64) {
    wire_get_active_mint_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_set_active_mint(port_: i64, mint_url: *mut wire_uint_8_list) {
    wire_set_active_mint_impl(port_, mint_url)
}

#[no_mangle]
pub extern "C" fn wire_decode_token(port_: i64, encoded_token: *mut wire_uint_8_list) {
    wire_decode_token_impl(port_, encoded_token)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_StringList_0(len: i32) -> *mut wire_StringList {
    let wrap = wire_StringList {
        ptr: support::new_leak_vec_ptr(<*mut wire_uint_8_list>::new_with_null_ptr(), len),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_cashu_transaction_0() -> *mut wire_CashuTransaction {
    support::new_leak_box_ptr(wire_CashuTransaction::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_ln_transaction_0() -> *mut wire_LNTransaction {
    support::new_leak_box_ptr(wire_LNTransaction::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_message_0() -> *mut wire_Message {
    support::new_leak_box_ptr(wire_Message::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_transaction_0() -> *mut wire_Transaction {
    support::new_leak_box_ptr(wire_Transaction::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_uint_8_list_0(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}
impl Wire2Api<Vec<String>> for *mut wire_StringList {
    fn wire2api(self) -> Vec<String> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}
impl Wire2Api<CashuTransaction> for *mut wire_CashuTransaction {
    fn wire2api(self) -> CashuTransaction {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<CashuTransaction>::wire2api(*wrap).into()
    }
}
impl Wire2Api<LNTransaction> for *mut wire_LNTransaction {
    fn wire2api(self) -> LNTransaction {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<LNTransaction>::wire2api(*wrap).into()
    }
}
impl Wire2Api<Message> for *mut wire_Message {
    fn wire2api(self) -> Message {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<Message>::wire2api(*wrap).into()
    }
}
impl Wire2Api<Transaction> for *mut wire_Transaction {
    fn wire2api(self) -> Transaction {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<Transaction>::wire2api(*wrap).into()
    }
}
impl Wire2Api<CashuTransaction> for wire_CashuTransaction {
    fn wire2api(self) -> CashuTransaction {
        CashuTransaction {
            id: self.id.wire2api(),
            status: self.status.wire2api(),
            time: self.time.wire2api(),
            amount: self.amount.wire2api(),
            mint: self.mint.wire2api(),
            token: self.token.wire2api(),
        }
    }
}

impl Wire2Api<LNTransaction> for wire_LNTransaction {
    fn wire2api(self) -> LNTransaction {
        LNTransaction {
            id: self.id.wire2api(),
            status: self.status.wire2api(),
            time: self.time.wire2api(),
            amount: self.amount.wire2api(),
            mint: self.mint.wire2api(),
            bolt11: self.bolt11.wire2api(),
            hash: self.hash.wire2api(),
        }
    }
}
impl Wire2Api<Message> for wire_Message {
    fn wire2api(self) -> Message {
        match self.tag {
            0 => unsafe {
                let ans = support::box_from_leak_ptr(self.kind);
                let ans = support::box_from_leak_ptr(ans.Text);
                Message::Text {
                    direction: ans.direction.wire2api(),
                    time: ans.time.wire2api(),
                    content: ans.content.wire2api(),
                }
            },
            1 => unsafe {
                let ans = support::box_from_leak_ptr(self.kind);
                let ans = support::box_from_leak_ptr(ans.Invoice);
                Message::Invoice {
                    direction: ans.direction.wire2api(),
                    time: ans.time.wire2api(),
                    transaction_id: ans.transaction_id.wire2api(),
                }
            },
            2 => unsafe {
                let ans = support::box_from_leak_ptr(self.kind);
                let ans = support::box_from_leak_ptr(ans.Token);
                Message::Token {
                    direction: ans.direction.wire2api(),
                    time: ans.time.wire2api(),
                    transaction_id: ans.transaction_id.wire2api(),
                }
            },
            _ => unreachable!(),
        }
    }
}

impl Wire2Api<Transaction> for wire_Transaction {
    fn wire2api(self) -> Transaction {
        match self.tag {
            0 => unsafe {
                let ans = support::box_from_leak_ptr(self.kind);
                let ans = support::box_from_leak_ptr(ans.CashuTransaction);
                Transaction::CashuTransaction(ans.field0.wire2api())
            },
            1 => unsafe {
                let ans = support::box_from_leak_ptr(self.kind);
                let ans = support::box_from_leak_ptr(ans.LNTransaction);
                Transaction::LNTransaction(ans.field0.wire2api())
            },
            _ => unreachable!(),
        }
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}
// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_StringList {
    ptr: *mut *mut wire_uint_8_list,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_CashuTransaction {
    id: *mut wire_uint_8_list,
    status: i32,
    time: u64,
    amount: u64,
    mint: *mut wire_uint_8_list,
    token: *mut wire_uint_8_list,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_LNTransaction {
    id: *mut wire_uint_8_list,
    status: i32,
    time: u64,
    amount: u64,
    mint: *mut wire_uint_8_list,
    bolt11: *mut wire_uint_8_list,
    hash: *mut wire_uint_8_list,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_Message {
    tag: i32,
    kind: *mut MessageKind,
}

#[repr(C)]
pub union MessageKind {
    Text: *mut wire_Message_Text,
    Invoice: *mut wire_Message_Invoice,
    Token: *mut wire_Message_Token,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_Message_Text {
    direction: i32,
    time: u64,
    content: *mut wire_uint_8_list,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_Message_Invoice {
    direction: i32,
    time: u64,
    transaction_id: *mut wire_uint_8_list,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_Message_Token {
    direction: i32,
    time: u64,
    transaction_id: *mut wire_uint_8_list,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_Transaction {
    tag: i32,
    kind: *mut TransactionKind,
}

#[repr(C)]
pub union TransactionKind {
    CashuTransaction: *mut wire_Transaction_CashuTransaction,
    LNTransaction: *mut wire_Transaction_LNTransaction,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_Transaction_CashuTransaction {
    field0: *mut wire_CashuTransaction,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_Transaction_LNTransaction {
    field0: *mut wire_LNTransaction,
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

impl NewWithNullPtr for wire_CashuTransaction {
    fn new_with_null_ptr() -> Self {
        Self {
            id: core::ptr::null_mut(),
            status: Default::default(),
            time: Default::default(),
            amount: Default::default(),
            mint: core::ptr::null_mut(),
            token: core::ptr::null_mut(),
        }
    }
}

impl Default for wire_CashuTransaction {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_LNTransaction {
    fn new_with_null_ptr() -> Self {
        Self {
            id: core::ptr::null_mut(),
            status: Default::default(),
            time: Default::default(),
            amount: Default::default(),
            mint: core::ptr::null_mut(),
            bolt11: core::ptr::null_mut(),
            hash: core::ptr::null_mut(),
        }
    }
}

impl Default for wire_LNTransaction {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl Default for wire_Message {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_Message {
    fn new_with_null_ptr() -> Self {
        Self {
            tag: -1,
            kind: core::ptr::null_mut(),
        }
    }
}

#[no_mangle]
pub extern "C" fn inflate_Message_Text() -> *mut MessageKind {
    support::new_leak_box_ptr(MessageKind {
        Text: support::new_leak_box_ptr(wire_Message_Text {
            direction: Default::default(),
            time: Default::default(),
            content: core::ptr::null_mut(),
        }),
    })
}

#[no_mangle]
pub extern "C" fn inflate_Message_Invoice() -> *mut MessageKind {
    support::new_leak_box_ptr(MessageKind {
        Invoice: support::new_leak_box_ptr(wire_Message_Invoice {
            direction: Default::default(),
            time: Default::default(),
            transaction_id: core::ptr::null_mut(),
        }),
    })
}

#[no_mangle]
pub extern "C" fn inflate_Message_Token() -> *mut MessageKind {
    support::new_leak_box_ptr(MessageKind {
        Token: support::new_leak_box_ptr(wire_Message_Token {
            direction: Default::default(),
            time: Default::default(),
            transaction_id: core::ptr::null_mut(),
        }),
    })
}

impl Default for wire_Transaction {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_Transaction {
    fn new_with_null_ptr() -> Self {
        Self {
            tag: -1,
            kind: core::ptr::null_mut(),
        }
    }
}

#[no_mangle]
pub extern "C" fn inflate_Transaction_CashuTransaction() -> *mut TransactionKind {
    support::new_leak_box_ptr(TransactionKind {
        CashuTransaction: support::new_leak_box_ptr(wire_Transaction_CashuTransaction {
            field0: core::ptr::null_mut(),
        }),
    })
}

#[no_mangle]
pub extern "C" fn inflate_Transaction_LNTransaction() -> *mut TransactionKind {
    support::new_leak_box_ptr(TransactionKind {
        LNTransaction: support::new_leak_box_ptr(wire_Transaction_LNTransaction {
            field0: core::ptr::null_mut(),
        }),
    })
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturn(ptr: support::WireSyncReturn) {
    unsafe {
        let _ = support::box_from_leak_ptr(ptr);
    };
}
