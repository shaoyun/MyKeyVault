// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'biometric_capability.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BiometricCapability {
  bool get isAvailable;
  bool get isDeviceSupported;
  List<BiometricType> get availableTypes;
  bool get canCheckBiometrics;

  /// Create a copy of BiometricCapability
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BiometricCapabilityCopyWith<BiometricCapability> get copyWith =>
      _$BiometricCapabilityCopyWithImpl<BiometricCapability>(
          this as BiometricCapability, _$identity);

  /// Serializes this BiometricCapability to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BiometricCapability &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.isDeviceSupported, isDeviceSupported) ||
                other.isDeviceSupported == isDeviceSupported) &&
            const DeepCollectionEquality()
                .equals(other.availableTypes, availableTypes) &&
            (identical(other.canCheckBiometrics, canCheckBiometrics) ||
                other.canCheckBiometrics == canCheckBiometrics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isAvailable, isDeviceSupported,
      const DeepCollectionEquality().hash(availableTypes), canCheckBiometrics);

  @override
  String toString() {
    return 'BiometricCapability(isAvailable: $isAvailable, isDeviceSupported: $isDeviceSupported, availableTypes: $availableTypes, canCheckBiometrics: $canCheckBiometrics)';
  }
}

/// @nodoc
abstract mixin class $BiometricCapabilityCopyWith<$Res> {
  factory $BiometricCapabilityCopyWith(
          BiometricCapability value, $Res Function(BiometricCapability) _then) =
      _$BiometricCapabilityCopyWithImpl;
  @useResult
  $Res call(
      {bool isAvailable,
      bool isDeviceSupported,
      List<BiometricType> availableTypes,
      bool canCheckBiometrics});
}

/// @nodoc
class _$BiometricCapabilityCopyWithImpl<$Res>
    implements $BiometricCapabilityCopyWith<$Res> {
  _$BiometricCapabilityCopyWithImpl(this._self, this._then);

  final BiometricCapability _self;
  final $Res Function(BiometricCapability) _then;

  /// Create a copy of BiometricCapability
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isAvailable = null,
    Object? isDeviceSupported = null,
    Object? availableTypes = null,
    Object? canCheckBiometrics = null,
  }) {
    return _then(_self.copyWith(
      isAvailable: null == isAvailable
          ? _self.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      isDeviceSupported: null == isDeviceSupported
          ? _self.isDeviceSupported
          : isDeviceSupported // ignore: cast_nullable_to_non_nullable
              as bool,
      availableTypes: null == availableTypes
          ? _self.availableTypes
          : availableTypes // ignore: cast_nullable_to_non_nullable
              as List<BiometricType>,
      canCheckBiometrics: null == canCheckBiometrics
          ? _self.canCheckBiometrics
          : canCheckBiometrics // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [BiometricCapability].
extension BiometricCapabilityPatterns on BiometricCapability {
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
    TResult Function(_BiometricCapability value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BiometricCapability() when $default != null:
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
    TResult Function(_BiometricCapability value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BiometricCapability():
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
    TResult? Function(_BiometricCapability value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BiometricCapability() when $default != null:
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
    TResult Function(bool isAvailable, bool isDeviceSupported,
            List<BiometricType> availableTypes, bool canCheckBiometrics)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BiometricCapability() when $default != null:
        return $default(_that.isAvailable, _that.isDeviceSupported,
            _that.availableTypes, _that.canCheckBiometrics);
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
    TResult Function(bool isAvailable, bool isDeviceSupported,
            List<BiometricType> availableTypes, bool canCheckBiometrics)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BiometricCapability():
        return $default(_that.isAvailable, _that.isDeviceSupported,
            _that.availableTypes, _that.canCheckBiometrics);
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
    TResult? Function(bool isAvailable, bool isDeviceSupported,
            List<BiometricType> availableTypes, bool canCheckBiometrics)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BiometricCapability() when $default != null:
        return $default(_that.isAvailable, _that.isDeviceSupported,
            _that.availableTypes, _that.canCheckBiometrics);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _BiometricCapability implements BiometricCapability {
  const _BiometricCapability(
      {this.isAvailable = false,
      this.isDeviceSupported = false,
      final List<BiometricType> availableTypes = const [],
      this.canCheckBiometrics = false})
      : _availableTypes = availableTypes;
  factory _BiometricCapability.fromJson(Map<String, dynamic> json) =>
      _$BiometricCapabilityFromJson(json);

  @override
  @JsonKey()
  final bool isAvailable;
  @override
  @JsonKey()
  final bool isDeviceSupported;
  final List<BiometricType> _availableTypes;
  @override
  @JsonKey()
  List<BiometricType> get availableTypes {
    if (_availableTypes is EqualUnmodifiableListView) return _availableTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableTypes);
  }

  @override
  @JsonKey()
  final bool canCheckBiometrics;

  /// Create a copy of BiometricCapability
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BiometricCapabilityCopyWith<_BiometricCapability> get copyWith =>
      __$BiometricCapabilityCopyWithImpl<_BiometricCapability>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BiometricCapabilityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BiometricCapability &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.isDeviceSupported, isDeviceSupported) ||
                other.isDeviceSupported == isDeviceSupported) &&
            const DeepCollectionEquality()
                .equals(other._availableTypes, _availableTypes) &&
            (identical(other.canCheckBiometrics, canCheckBiometrics) ||
                other.canCheckBiometrics == canCheckBiometrics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isAvailable, isDeviceSupported,
      const DeepCollectionEquality().hash(_availableTypes), canCheckBiometrics);

  @override
  String toString() {
    return 'BiometricCapability(isAvailable: $isAvailable, isDeviceSupported: $isDeviceSupported, availableTypes: $availableTypes, canCheckBiometrics: $canCheckBiometrics)';
  }
}

/// @nodoc
abstract mixin class _$BiometricCapabilityCopyWith<$Res>
    implements $BiometricCapabilityCopyWith<$Res> {
  factory _$BiometricCapabilityCopyWith(_BiometricCapability value,
          $Res Function(_BiometricCapability) _then) =
      __$BiometricCapabilityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isAvailable,
      bool isDeviceSupported,
      List<BiometricType> availableTypes,
      bool canCheckBiometrics});
}

/// @nodoc
class __$BiometricCapabilityCopyWithImpl<$Res>
    implements _$BiometricCapabilityCopyWith<$Res> {
  __$BiometricCapabilityCopyWithImpl(this._self, this._then);

  final _BiometricCapability _self;
  final $Res Function(_BiometricCapability) _then;

  /// Create a copy of BiometricCapability
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isAvailable = null,
    Object? isDeviceSupported = null,
    Object? availableTypes = null,
    Object? canCheckBiometrics = null,
  }) {
    return _then(_BiometricCapability(
      isAvailable: null == isAvailable
          ? _self.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      isDeviceSupported: null == isDeviceSupported
          ? _self.isDeviceSupported
          : isDeviceSupported // ignore: cast_nullable_to_non_nullable
              as bool,
      availableTypes: null == availableTypes
          ? _self._availableTypes
          : availableTypes // ignore: cast_nullable_to_non_nullable
              as List<BiometricType>,
      canCheckBiometrics: null == canCheckBiometrics
          ? _self.canCheckBiometrics
          : canCheckBiometrics // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
