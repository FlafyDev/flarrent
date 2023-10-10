// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'config.freezed.dart';
part 'config.g.dart';

@freezed
class Config with _$Config {
  const factory Config({
    @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) Color? color,
    @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) Color? backgroundColor,
    String? connection,
  }) = _Config;

  factory Config.fromJson(Map<String, Object?> json) => _$ConfigFromJson(json);
}

Color? _colorFromJson(String colorString) {
  final intColor = int.tryParse(colorString, radix: 16);
  if (intColor == null) {
    return null;
  } else {
    return Color(intColor);
  }
}

String _colorToJson(Color? color) => color?.value.toRadixString(16) ?? '';
