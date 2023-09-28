import 'package:freezed_annotation/freezed_annotation.dart';

@immutable
class Equal<T extends Object> {
  const Equal(this.value, this._equal, [this._hashCode]);
  final T value;
  final bool Function(T value, T other) _equal;
  final int Function(T value)? _hashCode;

  @override
  bool operator ==(Object other) => _equal(value, (other as Equal<T>).value);

  @override
  int get hashCode => _hashCode?.call(value) ?? super.hashCode;
}
