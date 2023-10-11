// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Config _$$_ConfigFromJson(Map<String, dynamic> json) => _$_Config(
      color: _colorFromJson(json['color'] as String),
      backgroundColor: _colorFromJson(json['backgroundColor'] as String),
      connection: json['connection'] as String?,
      smoothScroll: json['smoothScroll'] as bool?,
      animateOnlyOnFocus: json['animateOnlyOnFocus'] as bool?,
    );

Map<String, dynamic> _$$_ConfigToJson(_$_Config instance) => <String, dynamic>{
      'color': _colorToJson(instance.color),
      'backgroundColor': _colorToJson(instance.backgroundColor),
      'connection': instance.connection,
      'smoothScroll': instance.smoothScroll,
      'animateOnlyOnFocus': instance.animateOnlyOnFocus,
    };
