// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthConfig {
  bool get biometricEnabled;
  bool get passwordEnabled;
  int get authTimeoutMinutes;
  ThemeMode get themeMode;
  String? get hashedPassword;
  int get failedAttempts;
  DateTime? get lockoutEndTime;
  DateTime? get lastAuthTime;

  /// Create a copy of AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthConfigCopyWith<AuthConfig> get copyWith =>
      _$AuthConfigCopyWithImpl<AuthConfig>(this as AuthConfig, _$identity);

  /// Serializes this AuthConfig to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthConfig &&
            (identical(other.biometricEnabled, biometricEnabled) ||
                other.biometricEnabled == biometricEnabled) &&
            (identical(other.passwordEnabled, passwordEnabled) ||
                other.passwordEnabled == passwordEnabled) &&
            (identical(other.authTimeoutMinutes, authTimeoutMinutes) ||
                other.authTimeoutMinutes == authTimeoutMinutes) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.hashedPassword, hashedPassword) ||
                other.hashedPassword == hashedPassword) &&
            (identical(other.failedAttempts, failedAttempts) ||
                other.failedAttempts == failedAttempts) &&
            (identical(other.lockoutEndTime, lockoutEndTime) ||
                other.lockoutEndTime == lockoutEndTime) &&
            (identical(other.lastAuthTime, lastAuthTime) ||
                other.lastAuthTime == lastAuthTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      biometricEnabled,
      passwordEnabled,
      authTimeoutMinutes,
      themeMode,
      hashedPassword,
      failedAttempts,
      lockoutEndTime,
      lastAuthTime);

  @override
  String toString() {
    return 'AuthConfig(biometricEnabled: $biometricEnabled, passwordEnabled: $passwordEnabled, authTimeoutMinutes: $authTimeoutMinutes, themeMode: $themeMode, hashedPassword: $hashedPassword, failedAttempts: $failedAttempts, lockoutEndTime: $lockoutEndTime, lastAuthTime: $lastAuthTime)';
  }
}

/// @nodoc
abstract mixin class $AuthConfigCopyWith<$Res> {
  factory $AuthConfigCopyWith(
          AuthConfig value, $Res Function(AuthConfig) _then) =
      _$AuthConfigCopyWithImpl;
  @useResult
  $Res call(
      {bool biometricEnabled,
      bool passwordEnabled,
      int authTimeoutMinutes,
      ThemeMode themeMode,
      String? hashedPassword,
      int failedAttempts,
      DateTime? lockoutEndTime,
      DateTime? lastAuthTime});
}

/// @nodoc
class _$AuthConfigCopyWithImpl<$Res> implements $AuthConfigCopyWith<$Res> {
  _$AuthConfigCopyWithImpl(this._self, this._then);

  final AuthConfig _self;
  final $Res Function(AuthConfig) _then;

  /// Create a copy of AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? biometricEnabled = null,
    Object? passwordEnabled = null,
    Object? authTimeoutMinutes = null,
    Object? themeMode = null,
    Object? hashedPassword = freezed,
    Object? failedAttempts = null,
    Object? lockoutEndTime = freezed,
    Object? lastAuthTime = freezed,
  }) {
    return _then(_self.copyWith(
      biometricEnabled: null == biometricEnabled
          ? _self.biometricEnabled
          : biometricEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      passwordEnabled: null == passwordEnabled
          ? _self.passwordEnabled
          : passwordEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      authTimeoutMinutes: null == authTimeoutMinutes
          ? _self.authTimeoutMinutes
          : authTimeoutMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      themeMode: null == themeMode
          ? _self.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      hashedPassword: freezed == hashedPassword
          ? _self.hashedPassword
          : hashedPassword // ignore: cast_nullable_to_non_nullable
              as String?,
      failedAttempts: null == failedAttempts
          ? _self.failedAttempts
          : failedAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      lockoutEndTime: freezed == lockoutEndTime
          ? _self.lockoutEndTime
          : lockoutEndTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastAuthTime: freezed == lastAuthTime
          ? _self.lastAuthTime
          : lastAuthTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AuthConfig].
extension AuthConfigPatterns on AuthConfig {
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
    TResult Function(_AuthConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthConfig() when $default != null:
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
    TResult Function(_AuthConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthConfig():
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
    TResult? Function(_AuthConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthConfig() when $default != null:
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
    TResult Function(
            bool biometricEnabled,
            bool passwordEnabled,
            int authTimeoutMinutes,
            ThemeMode themeMode,
            String? hashedPassword,
            int failedAttempts,
            DateTime? lockoutEndTime,
            DateTime? lastAuthTime)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthConfig() when $default != null:
        return $default(
            _that.biometricEnabled,
            _that.passwordEnabled,
            _that.authTimeoutMinutes,
            _that.themeMode,
            _that.hashedPassword,
            _that.failedAttempts,
            _that.lockoutEndTime,
            _that.lastAuthTime);
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
    TResult Function(
            bool biometricEnabled,
            bool passwordEnabled,
            int authTimeoutMinutes,
            ThemeMode themeMode,
            String? hashedPassword,
            int failedAttempts,
            DateTime? lockoutEndTime,
            DateTime? lastAuthTime)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthConfig():
        return $default(
            _that.biometricEnabled,
            _that.passwordEnabled,
            _that.authTimeoutMinutes,
            _that.themeMode,
            _that.hashedPassword,
            _that.failedAttempts,
            _that.lockoutEndTime,
            _that.lastAuthTime);
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
    TResult? Function(
            bool biometricEnabled,
            bool passwordEnabled,
            int authTimeoutMinutes,
            ThemeMode themeMode,
            String? hashedPassword,
            int failedAttempts,
            DateTime? lockoutEndTime,
            DateTime? lastAuthTime)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthConfig() when $default != null:
        return $default(
            _that.biometricEnabled,
            _that.passwordEnabled,
            _that.authTimeoutMinutes,
            _that.themeMode,
            _that.hashedPassword,
            _that.failedAttempts,
            _that.lockoutEndTime,
            _that.lastAuthTime);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AuthConfig implements AuthConfig {
  const _AuthConfig(
      {this.biometricEnabled = false,
      this.passwordEnabled = false,
      this.authTimeoutMinutes = 15,
      this.themeMode = ThemeMode.system,
      this.hashedPassword,
      this.failedAttempts = 0,
      this.lockoutEndTime,
      this.lastAuthTime});
  factory _AuthConfig.fromJson(Map<String, dynamic> json) =>
      _$AuthConfigFromJson(json);

  @override
  @JsonKey()
  final bool biometricEnabled;
  @override
  @JsonKey()
  final bool passwordEnabled;
  @override
  @JsonKey()
  final int authTimeoutMinutes;
  @override
  @JsonKey()
  final ThemeMode themeMode;
  @override
  final String? hashedPassword;
  @override
  @JsonKey()
  final int failedAttempts;
  @override
  final DateTime? lockoutEndTime;
  @override
  final DateTime? lastAuthTime;

  /// Create a copy of AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AuthConfigCopyWith<_AuthConfig> get copyWith =>
      __$AuthConfigCopyWithImpl<_AuthConfig>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AuthConfigToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AuthConfig &&
            (identical(other.biometricEnabled, biometricEnabled) ||
                other.biometricEnabled == biometricEnabled) &&
            (identical(other.passwordEnabled, passwordEnabled) ||
                other.passwordEnabled == passwordEnabled) &&
            (identical(other.authTimeoutMinutes, authTimeoutMinutes) ||
                other.authTimeoutMinutes == authTimeoutMinutes) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.hashedPassword, hashedPassword) ||
                other.hashedPassword == hashedPassword) &&
            (identical(other.failedAttempts, failedAttempts) ||
                other.failedAttempts == failedAttempts) &&
            (identical(other.lockoutEndTime, lockoutEndTime) ||
                other.lockoutEndTime == lockoutEndTime) &&
            (identical(other.lastAuthTime, lastAuthTime) ||
                other.lastAuthTime == lastAuthTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      biometricEnabled,
      passwordEnabled,
      authTimeoutMinutes,
      themeMode,
      hashedPassword,
      failedAttempts,
      lockoutEndTime,
      lastAuthTime);

  @override
  String toString() {
    return 'AuthConfig(biometricEnabled: $biometricEnabled, passwordEnabled: $passwordEnabled, authTimeoutMinutes: $authTimeoutMinutes, themeMode: $themeMode, hashedPassword: $hashedPassword, failedAttempts: $failedAttempts, lockoutEndTime: $lockoutEndTime, lastAuthTime: $lastAuthTime)';
  }
}

/// @nodoc
abstract mixin class _$AuthConfigCopyWith<$Res>
    implements $AuthConfigCopyWith<$Res> {
  factory _$AuthConfigCopyWith(
          _AuthConfig value, $Res Function(_AuthConfig) _then) =
      __$AuthConfigCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool biometricEnabled,
      bool passwordEnabled,
      int authTimeoutMinutes,
      ThemeMode themeMode,
      String? hashedPassword,
      int failedAttempts,
      DateTime? lockoutEndTime,
      DateTime? lastAuthTime});
}

/// @nodoc
class __$AuthConfigCopyWithImpl<$Res> implements _$AuthConfigCopyWith<$Res> {
  __$AuthConfigCopyWithImpl(this._self, this._then);

  final _AuthConfig _self;
  final $Res Function(_AuthConfig) _then;

  /// Create a copy of AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? biometricEnabled = null,
    Object? passwordEnabled = null,
    Object? authTimeoutMinutes = null,
    Object? themeMode = null,
    Object? hashedPassword = freezed,
    Object? failedAttempts = null,
    Object? lockoutEndTime = freezed,
    Object? lastAuthTime = freezed,
  }) {
    return _then(_AuthConfig(
      biometricEnabled: null == biometricEnabled
          ? _self.biometricEnabled
          : biometricEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      passwordEnabled: null == passwordEnabled
          ? _self.passwordEnabled
          : passwordEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      authTimeoutMinutes: null == authTimeoutMinutes
          ? _self.authTimeoutMinutes
          : authTimeoutMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      themeMode: null == themeMode
          ? _self.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
      hashedPassword: freezed == hashedPassword
          ? _self.hashedPassword
          : hashedPassword // ignore: cast_nullable_to_non_nullable
              as String?,
      failedAttempts: null == failedAttempts
          ? _self.failedAttempts
          : failedAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      lockoutEndTime: freezed == lockoutEndTime
          ? _self.lockoutEndTime
          : lockoutEndTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastAuthTime: freezed == lastAuthTime
          ? _self.lastAuthTime
          : lastAuthTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
