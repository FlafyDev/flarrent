// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Config _$ConfigFromJson(Map<String, dynamic> json) {
  return _Config.fromJson(json);
}

/// @nodoc
mixin _$Config {
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  Color? get color => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  Color? get backgroundColor => throw _privateConstructorUsedError;
  String? get connection => throw _privateConstructorUsedError;
  bool? get smoothScroll => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConfigCopyWith<Config> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConfigCopyWith<$Res> {
  factory $ConfigCopyWith(Config value, $Res Function(Config) then) =
      _$ConfigCopyWithImpl<$Res, Config>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
          Color? color,
      @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
          Color? backgroundColor,
      String? connection,
      bool? smoothScroll});
}

/// @nodoc
class _$ConfigCopyWithImpl<$Res, $Val extends Config>
    implements $ConfigCopyWith<$Res> {
  _$ConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? color = freezed,
    Object? backgroundColor = freezed,
    Object? connection = freezed,
    Object? smoothScroll = freezed,
  }) {
    return _then(_value.copyWith(
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color?,
      backgroundColor: freezed == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      connection: freezed == connection
          ? _value.connection
          : connection // ignore: cast_nullable_to_non_nullable
              as String?,
      smoothScroll: freezed == smoothScroll
          ? _value.smoothScroll
          : smoothScroll // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ConfigCopyWith<$Res> implements $ConfigCopyWith<$Res> {
  factory _$$_ConfigCopyWith(_$_Config value, $Res Function(_$_Config) then) =
      __$$_ConfigCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
          Color? color,
      @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
          Color? backgroundColor,
      String? connection,
      bool? smoothScroll});
}

/// @nodoc
class __$$_ConfigCopyWithImpl<$Res>
    extends _$ConfigCopyWithImpl<$Res, _$_Config>
    implements _$$_ConfigCopyWith<$Res> {
  __$$_ConfigCopyWithImpl(_$_Config _value, $Res Function(_$_Config) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? color = freezed,
    Object? backgroundColor = freezed,
    Object? connection = freezed,
    Object? smoothScroll = freezed,
  }) {
    return _then(_$_Config(
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color?,
      backgroundColor: freezed == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      connection: freezed == connection
          ? _value.connection
          : connection // ignore: cast_nullable_to_non_nullable
              as String?,
      smoothScroll: freezed == smoothScroll
          ? _value.smoothScroll
          : smoothScroll // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Config with DiagnosticableTreeMixin implements _Config {
  const _$_Config(
      {@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
          this.color,
      @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
          this.backgroundColor,
      this.connection,
      this.smoothScroll});

  factory _$_Config.fromJson(Map<String, dynamic> json) =>
      _$$_ConfigFromJson(json);

  @override
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color? color;
  @override
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color? backgroundColor;
  @override
  final String? connection;
  @override
  final bool? smoothScroll;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Config(color: $color, backgroundColor: $backgroundColor, connection: $connection, smoothScroll: $smoothScroll)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Config'))
      ..add(DiagnosticsProperty('color', color))
      ..add(DiagnosticsProperty('backgroundColor', backgroundColor))
      ..add(DiagnosticsProperty('connection', connection))
      ..add(DiagnosticsProperty('smoothScroll', smoothScroll));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Config &&
            const DeepCollectionEquality().equals(other.color, color) &&
            const DeepCollectionEquality()
                .equals(other.backgroundColor, backgroundColor) &&
            (identical(other.connection, connection) ||
                other.connection == connection) &&
            (identical(other.smoothScroll, smoothScroll) ||
                other.smoothScroll == smoothScroll));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(color),
      const DeepCollectionEquality().hash(backgroundColor),
      connection,
      smoothScroll);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ConfigCopyWith<_$_Config> get copyWith =>
      __$$_ConfigCopyWithImpl<_$_Config>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ConfigToJson(
      this,
    );
  }
}

abstract class _Config implements Config {
  const factory _Config(
      {@JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
          final Color? color,
      @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
          final Color? backgroundColor,
      final String? connection,
      final bool? smoothScroll}) = _$_Config;

  factory _Config.fromJson(Map<String, dynamic> json) = _$_Config.fromJson;

  @override
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  Color? get color;
  @override
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  Color? get backgroundColor;
  @override
  String? get connection;
  @override
  bool? get smoothScroll;
  @override
  @JsonKey(ignore: true)
  _$$_ConfigCopyWith<_$_Config> get copyWith =>
      throw _privateConstructorUsedError;
}
