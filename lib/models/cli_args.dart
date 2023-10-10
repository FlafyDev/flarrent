import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cli_args.freezed.dart';
part 'cli_args.g.dart';

@freezed
class CliArgs with _$CliArgs {
  const factory CliArgs({
    String? configLocation,
    List<String>? torrentsLinks,
  }) = _CliArgs;

  factory CliArgs.fromJson(Map<String, Object?> json) => _$CliArgsFromJson(json);
}
