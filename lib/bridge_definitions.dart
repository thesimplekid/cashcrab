// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.76.0.
// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, unnecessary_import, prefer_single_quotes, prefer_const_constructors, use_super_parameters, always_use_package_imports, annotate_overrides, invalid_use_of_protected_member, constant_identifier_names, invalid_use_of_internal_member, prefer_is_empty, unnecessary_const

import 'dart:convert';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:uuid/uuid.dart';
import 'package:freezed_annotation/freezed_annotation.dart' hide protected;

part 'bridge_definitions.freezed.dart';

abstract class Rust {
  Future<void> initDb({required String path, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kInitDbConstMeta;

  Future<String> initNostr({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kInitNostrConstMeta;

  Future<List<String>> getRelays({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetRelaysConstMeta;

  Future<void> addRelay({required String relay, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kAddRelayConstMeta;

  Future<void> removeRelay({required String relay, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kRemoveRelayConstMeta;

  /// Fetch contacts from relay for a given pubkey
  Future<List<Contact>> fetchContacts({required String pubkey, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kFetchContactsConstMeta;

  Future<void> addContact({required String pubkey, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kAddContactConstMeta;

  Future<void> removeContact({required String pubkey, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kRemoveContactConstMeta;

  Future<List<Contact>> getContacts({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetContactsConstMeta;

  Future<Message> sendMessage(
      {required String pubkey, required Message message, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kSendMessageConstMeta;

  Future<List<Message>> getMessages({required String pubkey, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetMessagesConstMeta;

  Future<String> getBalances({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetBalancesConstMeta;

  /// Add Mint
  Future<void> addMint({required String url, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kAddMintConstMeta;

  Future<List<String>> getWallets({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetWalletsConstMeta;

  /// Remove wallet (mint)
  Future<String> removeWallet({required String url, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kRemoveWalletConstMeta;

  /// Check proofs for mints that should be added
  Future<void> addNewWallets({required List<String> mints, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kAddNewWalletsConstMeta;

  /// Set mints (wallets)
  Future<List<String>> setMints({required List<String> mints, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kSetMintsConstMeta;

  Future<bool> checkSpendable({required Transaction transaction, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kCheckSpendableConstMeta;

  /// Receive
  Future<Transaction> receiveToken(
      {required String encodedToken, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kReceiveTokenConstMeta;

  Future<Transaction> send(
      {required int amount, required String activeMint, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kSendConstMeta;

  Future<Transaction> requestMint(
      {required int amount, required String mintUrl, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kRequestMintConstMeta;

  Future<void> mintToken(
      {required int amount,
      required String hash,
      required String mint,
      dynamic hint});

  FlutterRustBridgeTaskConstMeta get kMintTokenConstMeta;

  Future<void> melt(
      {required int amount,
      required String invoice,
      required String mint,
      dynamic hint});

  FlutterRustBridgeTaskConstMeta get kMeltConstMeta;

  /// Decode invoice
  Future<InvoiceInfo> decodeInvoice({required String invoice, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kDecodeInvoiceConstMeta;

  Future<List<Transaction>> getTransactions({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetTransactionsConstMeta;

  Future<Transaction?> getTransaction({required String tid, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetTransactionConstMeta;

  Future<List<Mint>> getMints({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetMintsConstMeta;

  Future<Mint?> getActiveMint({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetActiveMintConstMeta;

  Future<void> setActiveMint({String? mintUrl, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kSetActiveMintConstMeta;

  Future<TokenData> decodeToken({required String encodedToken, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kDecodeTokenConstMeta;
}

class CashuTransaction {
  final String? id;
  final TransactionStatus status;
  final int time;
  final int amount;
  final String mint;
  final String token;

  const CashuTransaction({
    this.id,
    required this.status,
    required this.time,
    required this.amount,
    required this.mint,
    required this.token,
  });
}

class Contact {
  final String pubkey;
  final String npub;
  final String? name;
  final String? picture;
  final String? lud16;

  const Contact({
    required this.pubkey,
    required this.npub,
    this.name,
    this.picture,
    this.lud16,
  });
}

enum Direction {
  Sent,
  Received,
}

class InvoiceInfo {
  final int amount;
  final String hash;
  final String? memo;

  const InvoiceInfo({
    required this.amount,
    required this.hash,
    this.memo,
  });
}

enum InvoiceStatus {
  Paid,
  Unpaid,
  Expired,
}

class LNTransaction {
  final String? id;
  final TransactionStatus status;
  final int time;
  final int amount;
  final String mint;
  final String bolt11;
  final String hash;

  const LNTransaction({
    this.id,
    required this.status,
    required this.time,
    required this.amount,
    required this.mint,
    required this.bolt11,
    required this.hash,
  });
}

@freezed
class Message with _$Message {
  const factory Message.text({
    required Direction direction,
    required int time,
    required String content,
  }) = Message_Text;
  const factory Message.invoice({
    required Direction direction,
    required int time,
    required String bolt11,
    int? amount,
    required InvoiceStatus status,
  }) = Message_Invoice;
  const factory Message.token({
    required Direction direction,
    required int time,
    required String token,
    required String mint,
    int? amount,
    required TokenStatus status,
  }) = Message_Token;
}

class Mint {
  final String url;
  final String? activeKeyset;
  final List<String> keysets;

  const Mint({
    required this.url,
    this.activeKeyset,
    required this.keysets,
  });
}

class TokenData {
  final String encodedToken;
  final String mint;
  final int amount;
  final String? memo;

  const TokenData({
    required this.encodedToken,
    required this.mint,
    required this.amount,
    this.memo,
  });
}

enum TokenStatus {
  Spendable,
  Claimed,
}

@freezed
class Transaction with _$Transaction {
  const factory Transaction.cashuTransaction(
    CashuTransaction field0,
  ) = Transaction_CashuTransaction;
  const factory Transaction.lnTransaction(
    LNTransaction field0,
  ) = Transaction_LNTransaction;
}

enum TransactionStatus {
  Sent,
  Received,
  Pending,
  Failed,
}
