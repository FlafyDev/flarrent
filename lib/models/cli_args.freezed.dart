// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cli_args.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CliArgs _$CliArgsFromJson(Map<String, dynamic> json) {
  return _CliArgs.fromJson(json);
}

/// @nodoc
mixin _$CliArgs {
  String? get configLocation => throw _privateConstructorUsedError;
  List<String>? get torrentsLinks => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CliArgsCopyWith<CliArgs> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CliArgsCopyWith<$Res> {
  factory $CliArgsCopyWith(CliArgs value, $Res Function(CliArgs) then) =
      _$CliArgsCopyWithImpl<$Res, CliArgs>;
  @useResult
  $Res call({String? configLocation, List<String>? torrentsLinks});
}

/// @nodoc
class _$CliArgsCopyWithImpl<$Res, $Val extends CliArgs>
    implements $CliArgsCopyWith<$Res> {
  _$CliArgsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? configLocation = freezed,
    Object? torrentsLinks = freezed,
  }) {
    return _then(_value.copyWith(
      configLocation: freezed == configLocation
          ? _value.configLocation
          : configLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      torrentsLinks: freezed == torrentsLinks
          ? _value.torrentsLinks
          : torrentsLinks // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CliArgsCopyWith<$Res> implements $CliArgsCopyWith<$Res> {
  factory _$$_CliArgsCopyWith(
          _$_CliArgs value, $Res Function(_$_CliArgs) then) =
      __$$_CliArgsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? configLocation, List<String>? torrentsLinks});
}

/// @nodoc
class __$$_CliArgsCopyWithImpl<$Res>
    extends _$CliArgsCopyWithImpl<$Res, _$_CliArgs>
    implements _$$_CliArgsCopyWith<$Res> {
  __$$_CliArgsCopyWithImpl(_$_CliArgs _value, $Res Function(_$_CliArgs) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? configLocation = freezed,
    Object? torrentsLinks = freezed,
  }) {
    return _then(_$_CliArgs(
      configLocation: freezed == configLocation
          ? _value.configLocation
          : configLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      torrentsLinks: freezed == torrentsLinks
          ? _value._torrentsLinks
          : torrentsLinks // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CliArgs with DiagnosticableTreeMixin implements _CliArgs {
  const _$_CliArgs({this.configLocation, final List<String>? torrentsLinks})
      : _torrentsLinks = torrentsLinks;

  factory _$_CliArgs.fromJson(Map<String, dynamic> json) =>
      _$$_CliArgsFromJson(json);

  @override
  final String? configLocation;
  final List<String>? _torrentsLinks;
  @override
  List<String>? get torrentsLinks {
    final value = _torrentsLinks;
    if (value == null) return null;
    if (_torrentsLinks is EqualUnmodifiableListView) return _torrentsLinks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CliArgs(configLocation: $configLocation, torrentsLinks: $torrentsLinks)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CliArgs'))
      ..add(DiagnosticsProperty('configLocation', configLocation))
      ..add(DiagnosticsProperty('torrentsLinks', torrentsLinks));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CliArgs &&
            (identical(other.configLocation, configLocation) ||
                other.configLocation == configLocation) &&
            const DeepCollectionEquality()
                .equals(other._torrentsLinks, _torrentsLinks));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, configLocation,
      const DeepCollectionEquality().hash(_torrentsLinks));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CliArgsCopyWith<_$_CliArgs> get copyWith =>
      __$$_CliArgsCopyWithImpl<_$_CliArgs>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CliArgsToJson(
      this,
    );
  }
}

abstract class _CliArgs implements CliArgs {
  const factory _CliArgs(
      {final String? configLocation,
      final List<String>? torrentsLinks}) = _$_CliArgs;

  factory _CliArgs.fromJson(Map<String, dynamic> json) = _$_CliArgs.fromJson;

  @override
  String? get configLocation;
  @override
  List<String>? get torrentsLinks;
  @override
  @JsonKey(ignore: true)
  _$$_CliArgsCopyWith<_$_CliArgs> get copyWith =>
      throw _privateConstructorUsedError;
}
