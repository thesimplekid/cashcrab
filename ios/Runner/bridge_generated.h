#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
typedef struct _Dart_Handle* Dart_Handle;

typedef struct DartCObject DartCObject;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

typedef struct wire_uint_8_list {
  uint8_t *ptr;
  int32_t len;
} wire_uint_8_list;

typedef struct wire_Message_Text {
  int32_t direction;
  uint64_t time;
  struct wire_uint_8_list *content;
} wire_Message_Text;

typedef struct wire_Message_Invoice {
  int32_t direction;
  uint64_t time;
  struct wire_uint_8_list *transaction_id;
} wire_Message_Invoice;

typedef struct wire_Message_Token {
  int32_t direction;
  uint64_t time;
  struct wire_uint_8_list *transaction_id;
} wire_Message_Token;

typedef union MessageKind {
  struct wire_Message_Text *Text;
  struct wire_Message_Invoice *Invoice;
  struct wire_Message_Token *Token;
} MessageKind;

typedef struct wire_Message {
  int32_t tag;
  union MessageKind *kind;
} wire_Message;

typedef struct wire_TransactionStatus_Sent {

} wire_TransactionStatus_Sent;

typedef struct wire_TransactionStatus_Received {

} wire_TransactionStatus_Received;

typedef struct wire_TransactionStatus_Pending {
  int32_t field0;
} wire_TransactionStatus_Pending;

typedef struct wire_TransactionStatus_Failed {

} wire_TransactionStatus_Failed;

typedef struct wire_TransactionStatus_Expired {

} wire_TransactionStatus_Expired;

typedef union TransactionStatusKind {
  struct wire_TransactionStatus_Sent *Sent;
  struct wire_TransactionStatus_Received *Received;
  struct wire_TransactionStatus_Pending *Pending;
  struct wire_TransactionStatus_Failed *Failed;
  struct wire_TransactionStatus_Expired *Expired;
} TransactionStatusKind;

typedef struct wire_TransactionStatus {
  int32_t tag;
  union TransactionStatusKind *kind;
} wire_TransactionStatus;

typedef struct wire_CashuTransaction {
  struct wire_uint_8_list *id;
  struct wire_TransactionStatus status;
  uint64_t time;
  uint64_t amount;
  struct wire_uint_8_list *mint;
  struct wire_uint_8_list *token;
  struct wire_uint_8_list *from;
} wire_CashuTransaction;

typedef struct wire_Transaction_CashuTransaction {
  struct wire_CashuTransaction *field0;
} wire_Transaction_CashuTransaction;

typedef struct wire_LNTransaction {
  struct wire_uint_8_list *id;
  struct wire_TransactionStatus status;
  uint64_t time;
  uint64_t amount;
  uint64_t *fee;
  struct wire_uint_8_list *mint;
  struct wire_uint_8_list *bolt11;
  struct wire_uint_8_list *hash;
} wire_LNTransaction;

typedef struct wire_Transaction_LNTransaction {
  struct wire_LNTransaction *field0;
} wire_Transaction_LNTransaction;

typedef union TransactionKind {
  struct wire_Transaction_CashuTransaction *CashuTransaction;
  struct wire_Transaction_LNTransaction *LNTransaction;
} TransactionKind;

typedef struct wire_Transaction {
  int32_t tag;
  union TransactionKind *kind;
} wire_Transaction;

typedef struct DartCObject *WireSyncReturn;

void store_dart_post_cobject(DartPostCObjectFnType ptr);

Dart_Handle get_dart_object(uintptr_t ptr);

void drop_dart_object(uintptr_t ptr);

uintptr_t new_dart_opaque(Dart_Handle handle);

intptr_t init_frb_dart_api_dl(void *obj);

void wire_init_db(int64_t port_, struct wire_uint_8_list *storage_path);

void wire_init_cashu(int64_t port_);

void wire_init_nostr(int64_t port_,
                     struct wire_uint_8_list *storage_path,
                     struct wire_uint_8_list *private_key);

void wire_get_keys(int64_t port_);

void wire_nostr_logout(int64_t port_);

void wire_get_relays(int64_t port_);

void wire_add_relay(int64_t port_, struct wire_uint_8_list *relay);

void wire_remove_relay(int64_t port_, struct wire_uint_8_list *relay);

void wire_fetch_contacts(int64_t port_, struct wire_uint_8_list *pubkey);

void wire_add_contact(int64_t port_, struct wire_uint_8_list *pubkey);

void wire_remove_contact(int64_t port_, struct wire_uint_8_list *pubkey);

void wire_get_contacts(int64_t port_);

void wire_get_contact_picture_id(int64_t port_, struct wire_uint_8_list *pubkey);

void wire_fetch_picture(int64_t port_, struct wire_uint_8_list *url);

void wire_send_message(int64_t port_,
                       struct wire_uint_8_list *pubkey,
                       struct wire_Message *message);

void wire_get_conversation(int64_t port_, struct wire_uint_8_list *pubkey);

void wire_get_balances(int64_t port_);

void wire_add_mint(int64_t port_, struct wire_uint_8_list *url);

void wire_get_wallets(int64_t port_);

void wire_remove_wallet(int64_t port_, struct wire_uint_8_list *url);

void wire_check_spendable(int64_t port_, struct wire_Transaction *transaction);

void wire_receive_token(int64_t port_, struct wire_uint_8_list *encoded_token);

void wire_send(int64_t port_, uint64_t amount, struct wire_uint_8_list *active_mint);

void wire_request_mint(int64_t port_, uint64_t amount, struct wire_uint_8_list *mint_url);

void wire_mint_token(int64_t port_,
                     uint64_t amount,
                     struct wire_uint_8_list *hash,
                     struct wire_uint_8_list *mint);

void wire_mint_swap(int64_t port_,
                    struct wire_uint_8_list *from_mint,
                    struct wire_uint_8_list *to_mint,
                    uint64_t amount);

void wire_melt(int64_t port_,
               uint64_t amount,
               struct wire_uint_8_list *invoice,
               struct wire_uint_8_list *mint);

void wire_decode_invoice(int64_t port_, struct wire_uint_8_list *encoded_invoice);

void wire_get_transactions(int64_t port_);

void wire_get_inbox(int64_t port_);

void wire_redeam_inbox(int64_t port_);

void wire_get_transaction(int64_t port_, struct wire_uint_8_list *tid);

void wire_get_mints(int64_t port_);

void wire_get_mint_information(int64_t port_, struct wire_uint_8_list *mint);

void wire_get_active_mint(int64_t port_);

void wire_set_active_mint(int64_t port_, struct wire_uint_8_list *mint_url);

void wire_restore_tokens(int64_t port_);

void wire_backup_mints(int64_t port_);

void wire_decode_token(int64_t port_, struct wire_uint_8_list *encoded_token);

struct wire_CashuTransaction *new_box_autoadd_cashu_transaction_0(void);

struct wire_LNTransaction *new_box_autoadd_ln_transaction_0(void);

struct wire_Message *new_box_autoadd_message_0(void);

struct wire_Transaction *new_box_autoadd_transaction_0(void);

uint64_t *new_box_autoadd_u64_0(uint64_t value);

struct wire_uint_8_list *new_uint_8_list_0(int32_t len);

union MessageKind *inflate_Message_Text(void);

union MessageKind *inflate_Message_Invoice(void);

union MessageKind *inflate_Message_Token(void);

union TransactionKind *inflate_Transaction_CashuTransaction(void);

union TransactionKind *inflate_Transaction_LNTransaction(void);

union TransactionStatusKind *inflate_TransactionStatus_Pending(void);

void free_WireSyncReturn(WireSyncReturn ptr);

static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_init_db);
    dummy_var ^= ((int64_t) (void*) wire_init_cashu);
    dummy_var ^= ((int64_t) (void*) wire_init_nostr);
    dummy_var ^= ((int64_t) (void*) wire_get_keys);
    dummy_var ^= ((int64_t) (void*) wire_nostr_logout);
    dummy_var ^= ((int64_t) (void*) wire_get_relays);
    dummy_var ^= ((int64_t) (void*) wire_add_relay);
    dummy_var ^= ((int64_t) (void*) wire_remove_relay);
    dummy_var ^= ((int64_t) (void*) wire_fetch_contacts);
    dummy_var ^= ((int64_t) (void*) wire_add_contact);
    dummy_var ^= ((int64_t) (void*) wire_remove_contact);
    dummy_var ^= ((int64_t) (void*) wire_get_contacts);
    dummy_var ^= ((int64_t) (void*) wire_get_contact_picture_id);
    dummy_var ^= ((int64_t) (void*) wire_fetch_picture);
    dummy_var ^= ((int64_t) (void*) wire_send_message);
    dummy_var ^= ((int64_t) (void*) wire_get_conversation);
    dummy_var ^= ((int64_t) (void*) wire_get_balances);
    dummy_var ^= ((int64_t) (void*) wire_add_mint);
    dummy_var ^= ((int64_t) (void*) wire_get_wallets);
    dummy_var ^= ((int64_t) (void*) wire_remove_wallet);
    dummy_var ^= ((int64_t) (void*) wire_check_spendable);
    dummy_var ^= ((int64_t) (void*) wire_receive_token);
    dummy_var ^= ((int64_t) (void*) wire_send);
    dummy_var ^= ((int64_t) (void*) wire_request_mint);
    dummy_var ^= ((int64_t) (void*) wire_mint_token);
    dummy_var ^= ((int64_t) (void*) wire_mint_swap);
    dummy_var ^= ((int64_t) (void*) wire_melt);
    dummy_var ^= ((int64_t) (void*) wire_decode_invoice);
    dummy_var ^= ((int64_t) (void*) wire_get_transactions);
    dummy_var ^= ((int64_t) (void*) wire_get_inbox);
    dummy_var ^= ((int64_t) (void*) wire_redeam_inbox);
    dummy_var ^= ((int64_t) (void*) wire_get_transaction);
    dummy_var ^= ((int64_t) (void*) wire_get_mints);
    dummy_var ^= ((int64_t) (void*) wire_get_mint_information);
    dummy_var ^= ((int64_t) (void*) wire_get_active_mint);
    dummy_var ^= ((int64_t) (void*) wire_set_active_mint);
    dummy_var ^= ((int64_t) (void*) wire_restore_tokens);
    dummy_var ^= ((int64_t) (void*) wire_backup_mints);
    dummy_var ^= ((int64_t) (void*) wire_decode_token);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_cashu_transaction_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_ln_transaction_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_message_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_transaction_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_u64_0);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list_0);
    dummy_var ^= ((int64_t) (void*) inflate_Message_Text);
    dummy_var ^= ((int64_t) (void*) inflate_Message_Invoice);
    dummy_var ^= ((int64_t) (void*) inflate_Message_Token);
    dummy_var ^= ((int64_t) (void*) inflate_Transaction_CashuTransaction);
    dummy_var ^= ((int64_t) (void*) inflate_Transaction_LNTransaction);
    dummy_var ^= ((int64_t) (void*) inflate_TransactionStatus_Pending);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturn);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    dummy_var ^= ((int64_t) (void*) get_dart_object);
    dummy_var ^= ((int64_t) (void*) drop_dart_object);
    dummy_var ^= ((int64_t) (void*) new_dart_opaque);
    return dummy_var;
}
