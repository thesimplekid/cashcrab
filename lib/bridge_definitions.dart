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
  Future<void> initDb({required String storagePath, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kInitDbConstMeta;

  Future<void> initCashu({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kInitCashuConstMeta;

  Future<String> initNostr(
      {required String storagePath, String? privateKey, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kInitNostrConstMeta;

  Future<KeyData?> getKeys({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetKeysConstMeta;

  Future<void> nostrLogout({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kNostrLogoutConstMeta;

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

  Future<String?> getContactPictureId({required String pubkey, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetContactPictureIdConstMeta;

  /// Fetech and save image from url
  Future<String> fetchPicture({required String url, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kFetchPictureConstMeta;

  Future<Conversation> sendMessage(
      {required String pubkey, required Message message, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kSendMessageConstMeta;

  Future<Conversation> getConversation({required String pubkey, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetConversationConstMeta;

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

  /// Check spendable for messages
  Future<TransactionStatus> checkSpendable(
      {required Transaction transaction, dynamic hint});

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

  Future<void> mintSwap(
      {required String fromMint,
      required String toMint,
      required int amount,
      dynamic hint});

  FlutterRustBridgeTaskConstMeta get kMintSwapConstMeta;

  Future<Transaction> melt(
      {required int amount,
      required String invoice,
      required String mint,
      dynamic hint});

  FlutterRustBridgeTaskConstMeta get kMeltConstMeta;

  /// Decode invoice
  Future<InvoiceInfo> decodeInvoice(
      {required String encodedInvoice, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kDecodeInvoiceConstMeta;

  Future<List<Transaction>> getTransactions({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetTransactionsConstMeta;

  Future<List<Transaction>> getInbox({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetInboxConstMeta;

  Future<void> redeamInbox({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kRedeamInboxConstMeta;

  Future<Transaction?> getTransaction({required String tid, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetTransactionConstMeta;

  /// Get connected mints
  Future<List<Mint>> getMints({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetMintsConstMeta;

  /// Get Mint Information
  Future<MintInformation?> getMintInformation(
      {required String mint, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetMintInformationConstMeta;

  /// Get Active Mint
  Future<Mint?> getActiveMint({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetActiveMintConstMeta;

  /// Set Active Mint
  Future<void> setActiveMint({String? mintUrl, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kSetActiveMintConstMeta;

  Future<void> restoreTokens({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kRestoreTokensConstMeta;

  Future<String> backupMints({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kBackupMintsConstMeta;

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
  final String? from;

  const CashuTransaction({
    this.id,
    required this.status,
    required this.time,
    required this.amount,
    required this.mint,
    required this.token,
    this.from,
  });
}

/// Contact info
class Contact {
  /// Nostr Hex Pubkey
  final String pubkey;

  /// Nostr NPub
  final String npub;

  /// Username
  final String? name;

  /// Picture Info
  final Picture? picture;

  /// Lud16
  final String? lud16;

  /// create_at
  final int? createdAt;

  const Contact({
    required this.pubkey,
    required this.npub,
    this.name,
    this.picture,
    this.lud16,
    this.createdAt,
  });
}

class Conversation {
  final List<Message> messages;
  final List<Transaction> transactions;

  const Conversation({
    required this.messages,
    required this.transactions,
  });
}

enum Direction {
  Sent,
  Received,
}

class InvoiceInfo {
  final String bolt11;
  final int amount;
  final String hash;
  final String? memo;
  final String? mint;
  final InvoiceStatus status;

  const InvoiceInfo({
    required this.bolt11,
    required this.amount,
    required this.hash,
    this.memo,
    this.mint,
    required this.status,
  });
}

enum InvoiceStatus {
  Paid,
  Unpaid,
  Expired,
}

class KeyData {
  final String npub;
  final String? nsec;

  const KeyData({
    required this.npub,
    this.nsec,
  });
}

class LNTransaction {
  final String? id;
  final TransactionStatus status;
  final int time;
  final int amount;
  final int? fee;
  final String? mint;
  final String bolt11;
  final String hash;

  const LNTransaction({
    this.id,
    required this.status,
    required this.time,
    required this.amount,
    this.fee,
    this.mint,
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
    required String transactionId,
  }) = Message_Invoice;
  const factory Message.token({
    required Direction direction,
    required int time,
    required String transactionId,
  }) = Message_Token;
}

class Mint {
  /// Mint Url
  final String url;

  /// Active Keyset Id
  final String? activeKeyset;

  /// Key Set Ids
  final List<String> keysets;

  /// Mint Information
  final MintInformation? info;

  const Mint({
    required this.url,
    this.activeKeyset,
    required this.keysets,
    this.info,
  });
}

class MintInformation {
  /// name of the mint and should be recognizable
  final String? name;

  /// hex pubkey of the mint
  final String? pubkey;

  /// implementation name and the version running
  final String? version;

  /// short description of the mint
  final String? description;

  /// long description
  final String? descriptionLong;

  /// contact methods to reach the mint operator
  final List<List<String>> contact;

  /// shows which NUTs the mint supports
  final List<String> nuts;

  /// message of the day that the wallet must display to the user
  final String? motd;

  const MintInformation({
    this.name,
    this.pubkey,
    this.version,
    this.description,
    this.descriptionLong,
    required this.contact,
    required this.nuts,
    this.motd,
  });
}

enum Pending {
  Send,
  Receive,
}

/// Profile Picture Info
class Picture {
  final String url;
  final String? hash;
  final int updated;

  const Picture({
    required this.url,
    this.hash,
    required this.updated,
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

@freezed
class Transaction with _$Transaction {
  const factory Transaction.cashuTransaction(
    CashuTransaction field0,
  ) = Transaction_CashuTransaction;
  const factory Transaction.lnTransaction(
    LNTransaction field0,
  ) = Transaction_LNTransaction;
}

@freezed
class TransactionStatus with _$TransactionStatus {
  const factory TransactionStatus.sent() = TransactionStatus_Sent;
  const factory TransactionStatus.received() = TransactionStatus_Received;
  const factory TransactionStatus.pending(
    Pending field0,
  ) = TransactionStatus_Pending;
  const factory TransactionStatus.failed() = TransactionStatus_Failed;
  const factory TransactionStatus.expired() = TransactionStatus_Expired;
}
