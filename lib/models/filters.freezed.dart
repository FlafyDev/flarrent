// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Filters _$FiltersFromJson(Map<String, dynamic> json) {
  return _Filters.fromJson(json);
}

/// @nodoc
mixin _$Filters {
  String get query => throw _privateConstructorUsedError;
  List<TorrentState> get states => throw _privateConstructorUsedError;
  SortBy get sortBy => throw _privateConstructorUsedError;
  bool get ascending => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FiltersCopyWith<Filters> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FiltersCopyWith<$Res> {
  factory $FiltersCopyWith(Filters value, $Res Function(Filters) then) =
      _$FiltersCopyWithImpl<$Res, Filters>;
  @useResult
  $Res call(
      {String query, List<TorrentState> states, SortBy sortBy, bool ascending});
}

/// @nodoc
class _$FiltersCopyWithImpl<$Res, $Val extends Filters>
    implements $FiltersCopyWith<$Res> {
  _$FiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? states = null,
    Object? sortBy = null,
    Object? ascending = null,
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      states: null == states
          ? _value.states
          : states // ignore: cast_nullable_to_non_nullable
              as List<TorrentState>,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as SortBy,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_FiltersCopyWith<$Res> implements $FiltersCopyWith<$Res> {
  factory _$$_FiltersCopyWith(
          _$_Filters value, $Res Function(_$_Filters) then) =
      __$$_FiltersCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String query, List<TorrentState> states, SortBy sortBy, bool ascending});
}

/// @nodoc
class __$$_FiltersCopyWithImpl<$Res>
    extends _$FiltersCopyWithImpl<$Res, _$_Filters>
    implements _$$_FiltersCopyWith<$Res> {
  __$$_FiltersCopyWithImpl(_$_Filters _value, $Res Function(_$_Filters) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? states = null,
    Object? sortBy = null,
    Object? ascending = null,
  }) {
    return _then(_$_Filters(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      states: null == states
          ? _value._states
          : states // ignore: cast_nullable_to_non_nullable
              as List<TorrentState>,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as SortBy,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Filters with DiagnosticableTreeMixin implements _Filters {
  const _$_Filters(
      {required this.query,
      required final List<TorrentState> states,
      required this.sortBy,
      required this.ascending})
      : _states = states;

  factory _$_Filters.fromJson(Map<String, dynamic> json) =>
      _$$_FiltersFromJson(json);

  @override
  final String query;
  final List<TorrentState> _states;
  @override
  List<TorrentState> get states {
    if (_states is EqualUnmodifiableListView) return _states;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_states);
  }

  @override
  final SortBy sortBy;
  @override
  final bool ascending;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Filters(query: $query, states: $states, sortBy: $sortBy, ascending: $ascending)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Filters'))
      ..add(DiagnosticsProperty('query', query))
      ..add(DiagnosticsProperty('states', states))
      ..add(DiagnosticsProperty('sortBy', sortBy))
      ..add(DiagnosticsProperty('ascending', ascending));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Filters &&
            (identical(other.query, query) || other.query == query) &&
            const DeepCollectionEquality().equals(other._states, _states) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.ascending, ascending) ||
                other.ascending == ascending));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, query,
      const DeepCollectionEquality().hash(_states), sortBy, ascending);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_FiltersCopyWith<_$_Filters> get copyWith =>
      __$$_FiltersCopyWithImpl<_$_Filters>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_FiltersToJson(
      this,
    );
  }
}

abstract class _Filters implements Filters {
  const factory _Filters(
      {required final String query,
      required final List<TorrentState> states,
      required final SortBy sortBy,
      required final bool ascending}) = _$_Filters;

  factory _Filters.fromJson(Map<String, dynamic> json) = _$_Filters.fromJson;

  @override
  String get query;
  @override
  List<TorrentState> get states;
  @override
  SortBy get sortBy;
  @override
  bool get ascending;
  @override
  @JsonKey(ignore: true)
  _$$_FiltersCopyWith<_$_Filters> get copyWith =>
      throw _privateConstructorUsedError;
}
