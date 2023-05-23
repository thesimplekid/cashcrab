// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bridge_definitions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Message {
  Direction get direction => throw _privateConstructorUsedError;
  int get time => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Direction direction, int time, String content)
        text,
    required TResult Function(Direction direction, int time, String bolt11,
            int? amount, InvoiceStatus status)
        invoice,
    required TResult Function(Direction direction, int time, String token,
            String mint, int? amount, TokenStatus status)
        token,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Direction direction, int time, String content)? text,
    TResult? Function(Direction direction, int time, String bolt11, int? amount,
            InvoiceStatus status)?
        invoice,
    TResult? Function(Direction direction, int time, String token, String mint,
            int? amount, TokenStatus status)?
        token,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Direction direction, int time, String content)? text,
    TResult Function(Direction direction, int time, String bolt11, int? amount,
            InvoiceStatus status)?
        invoice,
    TResult Function(Direction direction, int time, String token, String mint,
            int? amount, TokenStatus status)?
        token,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Message_Text value) text,
    required TResult Function(Message_Invoice value) invoice,
    required TResult Function(Message_Token value) token,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Message_Text value)? text,
    TResult? Function(Message_Invoice value)? invoice,
    TResult? Function(Message_Token value)? token,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Message_Text value)? text,
    TResult Function(Message_Invoice value)? invoice,
    TResult Function(Message_Token value)? token,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call({Direction direction, int time});
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? direction = null,
    Object? time = null,
  }) {
    return _then(_value.copyWith(
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as Direction,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$Message_TextCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$Message_TextCopyWith(
          _$Message_Text value, $Res Function(_$Message_Text) then) =
      __$$Message_TextCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Direction direction, int time, String content});
}

/// @nodoc
class __$$Message_TextCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$Message_Text>
    implements _$$Message_TextCopyWith<$Res> {
  __$$Message_TextCopyWithImpl(
      _$Message_Text _value, $Res Function(_$Message_Text) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? direction = null,
    Object? time = null,
    Object? content = null,
  }) {
    return _then(_$Message_Text(
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as Direction,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$Message_Text implements Message_Text {
  const _$Message_Text(
      {required this.direction, required this.time, required this.content});

  @override
  final Direction direction;
  @override
  final int time;
  @override
  final String content;

  @override
  String toString() {
    return 'Message.text(direction: $direction, time: $time, content: $content)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Message_Text &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode => Object.hash(runtimeType, direction, time, content);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$Message_TextCopyWith<_$Message_Text> get copyWith =>
      __$$Message_TextCopyWithImpl<_$Message_Text>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Direction direction, int time, String content)
        text,
    required TResult Function(Direction direction, int time, String bolt11,
            int? amount, InvoiceStatus status)
        invoice,
    required TResult Function(Direction direction, int time, String token,
            String mint, int? amount, TokenStatus status)
        token,
  }) {
    return text(direction, time, content);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Direction direction, int time, String content)? text,
    TResult? Function(Direction direction, int time, String bolt11, int? amount,
            InvoiceStatus status)?
        invoice,
    TResult? Function(Direction direction, int time, String token, String mint,
            int? amount, TokenStatus status)?
        token,
  }) {
    return text?.call(direction, time, content);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Direction direction, int time, String content)? text,
    TResult Function(Direction direction, int time, String bolt11, int? amount,
            InvoiceStatus status)?
        invoice,
    TResult Function(Direction direction, int time, String token, String mint,
            int? amount, TokenStatus status)?
        token,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(direction, time, content);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Message_Text value) text,
    required TResult Function(Message_Invoice value) invoice,
    required TResult Function(Message_Token value) token,
  }) {
    return text(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Message_Text value)? text,
    TResult? Function(Message_Invoice value)? invoice,
    TResult? Function(Message_Token value)? token,
  }) {
    return text?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Message_Text value)? text,
    TResult Function(Message_Invoice value)? invoice,
    TResult Function(Message_Token value)? token,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(this);
    }
    return orElse();
  }
}

abstract class Message_Text implements Message {
  const factory Message_Text(
      {required final Direction direction,
      required final int time,
      required final String content}) = _$Message_Text;

  @override
  Direction get direction;
  @override
  int get time;
  String get content;
  @override
  @JsonKey(ignore: true)
  _$$Message_TextCopyWith<_$Message_Text> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$Message_InvoiceCopyWith<$Res>
    implements $MessageCopyWith<$Res> {
  factory _$$Message_InvoiceCopyWith(
          _$Message_Invoice value, $Res Function(_$Message_Invoice) then) =
      __$$Message_InvoiceCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Direction direction,
      int time,
      String bolt11,
      int? amount,
      InvoiceStatus status});
}

/// @nodoc
class __$$Message_InvoiceCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$Message_Invoice>
    implements _$$Message_InvoiceCopyWith<$Res> {
  __$$Message_InvoiceCopyWithImpl(
      _$Message_Invoice _value, $Res Function(_$Message_Invoice) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? direction = null,
    Object? time = null,
    Object? bolt11 = null,
    Object? amount = freezed,
    Object? status = null,
  }) {
    return _then(_$Message_Invoice(
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as Direction,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      bolt11: null == bolt11
          ? _value.bolt11
          : bolt11 // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as InvoiceStatus,
    ));
  }
}

/// @nodoc

class _$Message_Invoice implements Message_Invoice {
  const _$Message_Invoice(
      {required this.direction,
      required this.time,
      required this.bolt11,
      this.amount,
      required this.status});

  @override
  final Direction direction;
  @override
  final int time;
  @override
  final String bolt11;
  @override
  final int? amount;
  @override
  final InvoiceStatus status;

  @override
  String toString() {
    return 'Message.invoice(direction: $direction, time: $time, bolt11: $bolt11, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Message_Invoice &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.bolt11, bolt11) || other.bolt11 == bolt11) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, direction, time, bolt11, amount, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$Message_InvoiceCopyWith<_$Message_Invoice> get copyWith =>
      __$$Message_InvoiceCopyWithImpl<_$Message_Invoice>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Direction direction, int time, String content)
        text,
    required TResult Function(Direction direction, int time, String bolt11,
            int? amount, InvoiceStatus status)
        invoice,
    required TResult Function(Direction direction, int time, String token,
            String mint, int? amount, TokenStatus status)
        token,
  }) {
    return invoice(direction, time, bolt11, amount, status);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Direction direction, int time, String content)? text,
    TResult? Function(Direction direction, int time, String bolt11, int? amount,
            InvoiceStatus status)?
        invoice,
    TResult? Function(Direction direction, int time, String token, String mint,
            int? amount, TokenStatus status)?
        token,
  }) {
    return invoice?.call(direction, time, bolt11, amount, status);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Direction direction, int time, String content)? text,
    TResult Function(Direction direction, int time, String bolt11, int? amount,
            InvoiceStatus status)?
        invoice,
    TResult Function(Direction direction, int time, String token, String mint,
            int? amount, TokenStatus status)?
        token,
    required TResult orElse(),
  }) {
    if (invoice != null) {
      return invoice(direction, time, bolt11, amount, status);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Message_Text value) text,
    required TResult Function(Message_Invoice value) invoice,
    required TResult Function(Message_Token value) token,
  }) {
    return invoice(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Message_Text value)? text,
    TResult? Function(Message_Invoice value)? invoice,
    TResult? Function(Message_Token value)? token,
  }) {
    return invoice?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Message_Text value)? text,
    TResult Function(Message_Invoice value)? invoice,
    TResult Function(Message_Token value)? token,
    required TResult orElse(),
  }) {
    if (invoice != null) {
      return invoice(this);
    }
    return orElse();
  }
}

abstract class Message_Invoice implements Message {
  const factory Message_Invoice(
      {required final Direction direction,
      required final int time,
      required final String bolt11,
      final int? amount,
      required final InvoiceStatus status}) = _$Message_Invoice;

  @override
  Direction get direction;
  @override
  int get time;
  String get bolt11;
  int? get amount;
  InvoiceStatus get status;
  @override
  @JsonKey(ignore: true)
  _$$Message_InvoiceCopyWith<_$Message_Invoice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$Message_TokenCopyWith<$Res>
    implements $MessageCopyWith<$Res> {
  factory _$$Message_TokenCopyWith(
          _$Message_Token value, $Res Function(_$Message_Token) then) =
      __$$Message_TokenCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Direction direction,
      int time,
      String token,
      String mint,
      int? amount,
      TokenStatus status});
}

/// @nodoc
class __$$Message_TokenCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$Message_Token>
    implements _$$Message_TokenCopyWith<$Res> {
  __$$Message_TokenCopyWithImpl(
      _$Message_Token _value, $Res Function(_$Message_Token) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? direction = null,
    Object? time = null,
    Object? token = null,
    Object? mint = null,
    Object? amount = freezed,
    Object? status = null,
  }) {
    return _then(_$Message_Token(
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as Direction,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      mint: null == mint
          ? _value.mint
          : mint // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TokenStatus,
    ));
  }
}

/// @nodoc

class _$Message_Token implements Message_Token {
  const _$Message_Token(
      {required this.direction,
      required this.time,
      required this.token,
      required this.mint,
      this.amount,
      required this.status});

  @override
  final Direction direction;
  @override
  final int time;
  @override
  final String token;
  @override
  final String mint;
  @override
  final int? amount;
  @override
  final TokenStatus status;

  @override
  String toString() {
    return 'Message.token(direction: $direction, time: $time, token: $token, mint: $mint, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Message_Token &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.mint, mint) || other.mint == mint) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, direction, time, token, mint, amount, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$Message_TokenCopyWith<_$Message_Token> get copyWith =>
      __$$Message_TokenCopyWithImpl<_$Message_Token>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Direction direction, int time, String content)
        text,
    required TResult Function(Direction direction, int time, String bolt11,
            int? amount, InvoiceStatus status)
        invoice,
    required TResult Function(Direction direction, int time, String token,
            String mint, int? amount, TokenStatus status)
        token,
  }) {
    return token(direction, time, this.token, mint, amount, status);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Direction direction, int time, String content)? text,
    TResult? Function(Direction direction, int time, String bolt11, int? amount,
            InvoiceStatus status)?
        invoice,
    TResult? Function(Direction direction, int time, String token, String mint,
            int? amount, TokenStatus status)?
        token,
  }) {
    return token?.call(direction, time, this.token, mint, amount, status);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Direction direction, int time, String content)? text,
    TResult Function(Direction direction, int time, String bolt11, int? amount,
            InvoiceStatus status)?
        invoice,
    TResult Function(Direction direction, int time, String token, String mint,
            int? amount, TokenStatus status)?
        token,
    required TResult orElse(),
  }) {
    if (token != null) {
      return token(direction, time, this.token, mint, amount, status);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Message_Text value) text,
    required TResult Function(Message_Invoice value) invoice,
    required TResult Function(Message_Token value) token,
  }) {
    return token(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Message_Text value)? text,
    TResult? Function(Message_Invoice value)? invoice,
    TResult? Function(Message_Token value)? token,
  }) {
    return token?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Message_Text value)? text,
    TResult Function(Message_Invoice value)? invoice,
    TResult Function(Message_Token value)? token,
    required TResult orElse(),
  }) {
    if (token != null) {
      return token(this);
    }
    return orElse();
  }
}

abstract class Message_Token implements Message {
  const factory Message_Token(
      {required final Direction direction,
      required final int time,
      required final String token,
      required final String mint,
      final int? amount,
      required final TokenStatus status}) = _$Message_Token;

  @override
  Direction get direction;
  @override
  int get time;
  String get token;
  String get mint;
  int? get amount;
  TokenStatus get status;
  @override
  @JsonKey(ignore: true)
  _$$Message_TokenCopyWith<_$Message_Token> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Transaction {
  Object get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CashuTransaction field0) cashuTransaction,
    required TResult Function(LNTransaction field0) lnTransaction,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CashuTransaction field0)? cashuTransaction,
    TResult? Function(LNTransaction field0)? lnTransaction,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CashuTransaction field0)? cashuTransaction,
    TResult Function(LNTransaction field0)? lnTransaction,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Transaction_CashuTransaction value)
        cashuTransaction,
    required TResult Function(Transaction_LNTransaction value) lnTransaction,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Transaction_CashuTransaction value)? cashuTransaction,
    TResult? Function(Transaction_LNTransaction value)? lnTransaction,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Transaction_CashuTransaction value)? cashuTransaction,
    TResult Function(Transaction_LNTransaction value)? lnTransaction,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
          Transaction value, $Res Function(Transaction) then) =
      _$TransactionCopyWithImpl<$Res, Transaction>;
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$Transaction_CashuTransactionCopyWith<$Res> {
  factory _$$Transaction_CashuTransactionCopyWith(
          _$Transaction_CashuTransaction value,
          $Res Function(_$Transaction_CashuTransaction) then) =
      __$$Transaction_CashuTransactionCopyWithImpl<$Res>;
  @useResult
  $Res call({CashuTransaction field0});
}

/// @nodoc
class __$$Transaction_CashuTransactionCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$Transaction_CashuTransaction>
    implements _$$Transaction_CashuTransactionCopyWith<$Res> {
  __$$Transaction_CashuTransactionCopyWithImpl(
      _$Transaction_CashuTransaction _value,
      $Res Function(_$Transaction_CashuTransaction) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$Transaction_CashuTransaction(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as CashuTransaction,
    ));
  }
}

/// @nodoc

class _$Transaction_CashuTransaction implements Transaction_CashuTransaction {
  const _$Transaction_CashuTransaction(this.field0);

  @override
  final CashuTransaction field0;

  @override
  String toString() {
    return 'Transaction.cashuTransaction(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Transaction_CashuTransaction &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$Transaction_CashuTransactionCopyWith<_$Transaction_CashuTransaction>
      get copyWith => __$$Transaction_CashuTransactionCopyWithImpl<
          _$Transaction_CashuTransaction>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CashuTransaction field0) cashuTransaction,
    required TResult Function(LNTransaction field0) lnTransaction,
  }) {
    return cashuTransaction(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CashuTransaction field0)? cashuTransaction,
    TResult? Function(LNTransaction field0)? lnTransaction,
  }) {
    return cashuTransaction?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CashuTransaction field0)? cashuTransaction,
    TResult Function(LNTransaction field0)? lnTransaction,
    required TResult orElse(),
  }) {
    if (cashuTransaction != null) {
      return cashuTransaction(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Transaction_CashuTransaction value)
        cashuTransaction,
    required TResult Function(Transaction_LNTransaction value) lnTransaction,
  }) {
    return cashuTransaction(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Transaction_CashuTransaction value)? cashuTransaction,
    TResult? Function(Transaction_LNTransaction value)? lnTransaction,
  }) {
    return cashuTransaction?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Transaction_CashuTransaction value)? cashuTransaction,
    TResult Function(Transaction_LNTransaction value)? lnTransaction,
    required TResult orElse(),
  }) {
    if (cashuTransaction != null) {
      return cashuTransaction(this);
    }
    return orElse();
  }
}

abstract class Transaction_CashuTransaction implements Transaction {
  const factory Transaction_CashuTransaction(final CashuTransaction field0) =
      _$Transaction_CashuTransaction;

  @override
  CashuTransaction get field0;
  @JsonKey(ignore: true)
  _$$Transaction_CashuTransactionCopyWith<_$Transaction_CashuTransaction>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$Transaction_LNTransactionCopyWith<$Res> {
  factory _$$Transaction_LNTransactionCopyWith(
          _$Transaction_LNTransaction value,
          $Res Function(_$Transaction_LNTransaction) then) =
      __$$Transaction_LNTransactionCopyWithImpl<$Res>;
  @useResult
  $Res call({LNTransaction field0});
}

/// @nodoc
class __$$Transaction_LNTransactionCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$Transaction_LNTransaction>
    implements _$$Transaction_LNTransactionCopyWith<$Res> {
  __$$Transaction_LNTransactionCopyWithImpl(_$Transaction_LNTransaction _value,
      $Res Function(_$Transaction_LNTransaction) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$Transaction_LNTransaction(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as LNTransaction,
    ));
  }
}

/// @nodoc

class _$Transaction_LNTransaction implements Transaction_LNTransaction {
  const _$Transaction_LNTransaction(this.field0);

  @override
  final LNTransaction field0;

  @override
  String toString() {
    return 'Transaction.lnTransaction(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Transaction_LNTransaction &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$Transaction_LNTransactionCopyWith<_$Transaction_LNTransaction>
      get copyWith => __$$Transaction_LNTransactionCopyWithImpl<
          _$Transaction_LNTransaction>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CashuTransaction field0) cashuTransaction,
    required TResult Function(LNTransaction field0) lnTransaction,
  }) {
    return lnTransaction(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CashuTransaction field0)? cashuTransaction,
    TResult? Function(LNTransaction field0)? lnTransaction,
  }) {
    return lnTransaction?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CashuTransaction field0)? cashuTransaction,
    TResult Function(LNTransaction field0)? lnTransaction,
    required TResult orElse(),
  }) {
    if (lnTransaction != null) {
      return lnTransaction(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Transaction_CashuTransaction value)
        cashuTransaction,
    required TResult Function(Transaction_LNTransaction value) lnTransaction,
  }) {
    return lnTransaction(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Transaction_CashuTransaction value)? cashuTransaction,
    TResult? Function(Transaction_LNTransaction value)? lnTransaction,
  }) {
    return lnTransaction?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Transaction_CashuTransaction value)? cashuTransaction,
    TResult Function(Transaction_LNTransaction value)? lnTransaction,
    required TResult orElse(),
  }) {
    if (lnTransaction != null) {
      return lnTransaction(this);
    }
    return orElse();
  }
}

abstract class Transaction_LNTransaction implements Transaction {
  const factory Transaction_LNTransaction(final LNTransaction field0) =
      _$Transaction_LNTransaction;

  @override
  LNTransaction get field0;
  @JsonKey(ignore: true)
  _$$Transaction_LNTransactionCopyWith<_$Transaction_LNTransaction>
      get copyWith => throw _privateConstructorUsedError;
}
