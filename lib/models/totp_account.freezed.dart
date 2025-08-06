// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'totp_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TotpAccount {
  String get id;
  String get issuer;
  String get name;
  String get secret;
  String get colorType;

  /// Create a copy of TotpAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TotpAccountCopyWith<TotpAccount> get copyWith =>
      _$TotpAccountCopyWithImpl<TotpAccount>(this as TotpAccount, _$identity);

  /// Serializes this TotpAccount to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TotpAccount &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.issuer, issuer) || other.issuer == issuer) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.secret, secret) || other.secret == secret) &&
            (identical(other.colorType, colorType) ||
                other.colorType == colorType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, issuer, name, secret, colorType);

  @override
  String toString() {
    return 'TotpAccount(id: $id, issuer: $issuer, name: $name, secret: $secret, colorType: $colorType)';
  }
}

/// @nodoc
abstract mixin class $TotpAccountCopyWith<$Res> {
  factory $TotpAccountCopyWith(
          TotpAccount value, $Res Function(TotpAccount) _then) =
      _$TotpAccountCopyWithImpl;
  @useResult
  $Res call(
      {String id, String issuer, String name, String secret, String colorType});
}

/// @nodoc
class _$TotpAccountCopyWithImpl<$Res> implements $TotpAccountCopyWith<$Res> {
  _$TotpAccountCopyWithImpl(this._self, this._then);

  final TotpAccount _self;
  final $Res Function(TotpAccount) _then;

  /// Create a copy of TotpAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? issuer = null,
    Object? name = null,
    Object? secret = null,
    Object? colorType = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      issuer: null == issuer
          ? _self.issuer
          : issuer // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      secret: null == secret
          ? _self.secret
          : secret // ignore: cast_nullable_to_non_nullable
              as String,
      colorType: null == colorType
          ? _self.colorType
          : colorType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [TotpAccount].
extension TotpAccountPatterns on TotpAccount {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TotpAccount value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TotpAccount() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TotpAccount value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TotpAccount():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TotpAccount value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TotpAccount() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String id, String issuer, String name, String secret,
            String colorType)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TotpAccount() when $default != null:
        return $default(
            _that.id, _that.issuer, _that.name, _that.secret, _that.colorType);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String id, String issuer, String name, String secret,
            String colorType)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TotpAccount():
        return $default(
            _that.id, _that.issuer, _that.name, _that.secret, _that.colorType);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String id, String issuer, String name, String secret,
            String colorType)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TotpAccount() when $default != null:
        return $default(
            _that.id, _that.issuer, _that.name, _that.secret, _that.colorType);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TotpAccount implements TotpAccount {
  const _TotpAccount(
      {required this.id,
      required this.issuer,
      required this.name,
      required this.secret,
      this.colorType = 'default'});
  factory _TotpAccount.fromJson(Map<String, dynamic> json) =>
      _$TotpAccountFromJson(json);

  @override
  final String id;
  @override
  final String issuer;
  @override
  final String name;
  @override
  final String secret;
  @override
  @JsonKey()
  final String colorType;

  /// Create a copy of TotpAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TotpAccountCopyWith<_TotpAccount> get copyWith =>
      __$TotpAccountCopyWithImpl<_TotpAccount>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TotpAccountToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TotpAccount &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.issuer, issuer) || other.issuer == issuer) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.secret, secret) || other.secret == secret) &&
            (identical(other.colorType, colorType) ||
                other.colorType == colorType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, issuer, name, secret, colorType);

  @override
  String toString() {
    return 'TotpAccount(id: $id, issuer: $issuer, name: $name, secret: $secret, colorType: $colorType)';
  }
}

/// @nodoc
abstract mixin class _$TotpAccountCopyWith<$Res>
    implements $TotpAccountCopyWith<$Res> {
  factory _$TotpAccountCopyWith(
          _TotpAccount value, $Res Function(_TotpAccount) _then) =
      __$TotpAccountCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id, String issuer, String name, String secret, String colorType});
}

/// @nodoc
class __$TotpAccountCopyWithImpl<$Res> implements _$TotpAccountCopyWith<$Res> {
  __$TotpAccountCopyWithImpl(this._self, this._then);

  final _TotpAccount _self;
  final $Res Function(_TotpAccount) _then;

  /// Create a copy of TotpAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? issuer = null,
    Object? name = null,
    Object? secret = null,
    Object? colorType = null,
  }) {
    return _then(_TotpAccount(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      issuer: null == issuer
          ? _self.issuer
          : issuer // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      secret: null == secret
          ? _self.secret
          : secret // ignore: cast_nullable_to_non_nullable
              as String,
      colorType: null == colorType
          ? _self.colorType
          : colorType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
