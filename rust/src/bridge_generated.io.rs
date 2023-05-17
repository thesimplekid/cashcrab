use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_init_db(port_: i64, path: *mut wire_uint_8_list) {
    wire_init_db_impl(port_, path)
}

#[no_mangle]
pub extern "C" fn wire_get_balances(port_: i64) {
    wire_get_balances_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_create_wallet(port_: i64, url: *mut wire_uint_8_list) {
    wire_create_wallet_impl(port_, url)
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
pub extern "C" fn wire_check_spendable(port_: i64, encoded_token: *mut wire_uint_8_list) {
    wire_check_spendable_impl(port_, encoded_token)
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
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
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

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturn(ptr: support::WireSyncReturn) {
    unsafe {
        let _ = support::box_from_leak_ptr(ptr);
    };
}
