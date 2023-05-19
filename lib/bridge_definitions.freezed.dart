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
