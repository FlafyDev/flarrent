// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cli_args.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CliArgs _$$_CliArgsFromJson(Map<String, dynamic> json) => _$_CliArgs(
      configLocation: json['configLocation'] as String?,
      torrentsLinks: (json['torrentsLinks'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$_CliArgsToJson(_$_CliArgs instance) =>
    <String, dynamic>{
      'configLocation': instance.configLocation,
      'torrentsLinks': instance.torrentsLinks,
    };
