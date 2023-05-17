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

void wire_check_spendable(int64_t port_, struct wire_uint_8_list *encoded_token);

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

void wire_decode_token(int64_t port_, struct wire_uint_8_list *encoded_token);

struct wire_StringList *new_StringList_0(int32_t len);

struct wire_uint_8_list *new_uint_8_list_0(int32_t len);

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
    dummy_var ^= ((int64_t) (void*) wire_decode_token);
    dummy_var ^= ((int64_t) (void*) new_StringList_0);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list_0);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturn);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    dummy_var ^= ((int64_t) (void*) get_dart_object);
    dummy_var ^= ((int64_t) (void*) drop_dart_object);
    dummy_var ^= ((int64_t) (void*) new_dart_opaque);
    return dummy_var;
}
