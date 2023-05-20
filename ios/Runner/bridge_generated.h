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

typedef struct wire_StringList {
  struct wire_uint_8_list **ptr;
  int32_t len;
} wire_StringList;

typedef struct wire_CashuTransaction {
  struct wire_uint_8_list *id;
  int32_t status;
  uint64_t time;
  uint64_t amount;
  struct wire_uint_8_list *mint;
  struct wire_uint_8_list *token;
} wire_CashuTransaction;

typedef struct wire_Transaction_CashuTransaction {
  struct wire_CashuTransaction *field0;
} wire_Transaction_CashuTransaction;

typedef struct wire_LNTransaction {
  struct wire_uint_8_list *id;
  int32_t status;
  uint64_t time;
  uint64_t amount;
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

void wire_init_db(int64_t port_, struct wire_uint_8_list *path);

void wire_get_balances(int64_t port_);

void wire_create_wallet(int64_t port_, struct wire_uint_8_list *url);

void wire_get_wallets(int64_t port_);

void wire_remove_wallet(int64_t port_, struct wire_uint_8_list *url);

void wire_add_new_wallets(int64_t port_, struct wire_StringList *_mints);

void wire_set_mints(int64_t port_, struct wire_StringList *mints);

void wire_check_spendable(int64_t port_, struct wire_Transaction *transaction);

void wire_receive_token(int64_t port_, struct wire_uint_8_list *encoded_token);

void wire_send(int64_t port_, uint64_t amount, struct wire_uint_8_list *active_mint);

void wire_request_mint(int64_t port_, uint64_t amount, struct wire_uint_8_list *mint_url);

void wire_mint_token(int64_t port_,
                     uint64_t amount,
                     struct wire_uint_8_list *hash,
                     struct wire_uint_8_list *mint);

void wire_melt(int64_t port_,
               uint64_t amount,
               struct wire_uint_8_list *invoice,
               struct wire_uint_8_list *mint);

void wire_decode_invoice(int64_t port_, struct wire_uint_8_list *invoice);

void wire_get_transactions(int64_t port_);

void wire_get_transaction(int64_t port_, struct wire_uint_8_list *tid);

void wire_get_mints(int64_t port_);

void wire_get_active_mint(int64_t port_);

void wire_set_active_mint(int64_t port_, struct wire_uint_8_list *mint_url);

void wire_decode_token(int64_t port_, struct wire_uint_8_list *encoded_token);

struct wire_StringList *new_StringList_0(int32_t len);

struct wire_CashuTransaction *new_box_autoadd_cashu_transaction_0(void);

struct wire_LNTransaction *new_box_autoadd_ln_transaction_0(void);

struct wire_Transaction *new_box_autoadd_transaction_0(void);

struct wire_uint_8_list *new_uint_8_list_0(int32_t len);

union TransactionKind *inflate_Transaction_CashuTransaction(void);

union TransactionKind *inflate_Transaction_LNTransaction(void);

void free_WireSyncReturn(WireSyncReturn ptr);

static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_init_db);
    dummy_var ^= ((int64_t) (void*) wire_get_balances);
    dummy_var ^= ((int64_t) (void*) wire_create_wallet);
    dummy_var ^= ((int64_t) (void*) wire_get_wallets);
    dummy_var ^= ((int64_t) (void*) wire_remove_wallet);
    dummy_var ^= ((int64_t) (void*) wire_add_new_wallets);
    dummy_var ^= ((int64_t) (void*) wire_set_mints);
    dummy_var ^= ((int64_t) (void*) wire_check_spendable);
    dummy_var ^= ((int64_t) (void*) wire_receive_token);
    dummy_var ^= ((int64_t) (void*) wire_send);
    dummy_var ^= ((int64_t) (void*) wire_request_mint);
    dummy_var ^= ((int64_t) (void*) wire_mint_token);
    dummy_var ^= ((int64_t) (void*) wire_melt);
    dummy_var ^= ((int64_t) (void*) wire_decode_invoice);
    dummy_var ^= ((int64_t) (void*) wire_get_transactions);
    dummy_var ^= ((int64_t) (void*) wire_get_transaction);
    dummy_var ^= ((int64_t) (void*) wire_get_mints);
    dummy_var ^= ((int64_t) (void*) wire_get_active_mint);
    dummy_var ^= ((int64_t) (void*) wire_set_active_mint);
    dummy_var ^= ((int64_t) (void*) wire_decode_token);
    dummy_var ^= ((int64_t) (void*) new_StringList_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_cashu_transaction_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_ln_transaction_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_transaction_0);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list_0);
    dummy_var ^= ((int64_t) (void*) inflate_Transaction_CashuTransaction);
    dummy_var ^= ((int64_t) (void*) inflate_Transaction_LNTransaction);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturn);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    dummy_var ^= ((int64_t) (void*) get_dart_object);
    dummy_var ^= ((int64_t) (void*) drop_dart_object);
    dummy_var ^= ((int64_t) (void*) new_dart_opaque);
    return dummy_var;
}
