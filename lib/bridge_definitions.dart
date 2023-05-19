// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.75.3.
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

  Future<String> getBalances({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetBalancesConstMeta;

  /// Create Wallet
  Future<void> createWallet({required String url, dynamic hint});

  FlutterRustBridgeTaskConstMeta get kCreateWalletConstMeta;

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

  Future<RequestMintInfo> requestMint(
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

  Future<List<Mint>> getMints({dynamic hint});

  FlutterRustBridgeTaskConstMeta get kGetMintsConstMeta;

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

class LNTransaction {
  final String? id;
  final TransactionStatus status;
  final int time;
  final int amount;
  final String mint;
  final String bolt11;

  const LNTransaction({
    this.id,
    required this.status,
    required this.time,
    required this.amount,
    required this.mint,
    required this.bolt11,
  });
}

class Mint {
  final String url;
  final String activeKeyset;
  final List<String> keysets;

  const Mint({
    required this.url,
    required this.activeKeyset,
    required this.keysets,
  });
}

class RequestMintInfo {
  final String pr;
  final String hash;

  const RequestMintInfo({
    required this.pr,
    required this.hash,
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

enum TransactionStatus {
  Sent,
  Received,
  Pending,
  Failed,
}
