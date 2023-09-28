// ignore_for_file: constant_identifier_names

enum Unit {
  GiB,
  MiB,
  KiB,
  B,
}

Unit detectUnit(int bytes) {
  if (bytes >= 1000 * 1000 * 1000) {
    return Unit.GiB;
  } else if (bytes >= 1000 * 1000) {
    return Unit.MiB;
  } else if (bytes >= 1000) {
    return Unit.KiB;
  } else {
    return Unit.KiB;
  }
}

String fromBytesToUnit(int bytes, {Unit? unit}) {
  final dBytes = bytes.toDouble();
  switch (unit ?? detectUnit(bytes)) {
    case Unit.GiB:
      return (dBytes / 1024 / 1024 / 1024)
          .toStringAsFixed(dBytes / 1024 / 1024 / 1024 > 100 ? 1 : 2);
    case Unit.MiB:
      return (dBytes / 1024 / 1024)
          .toStringAsFixed(dBytes / 1024 / 1024 > 100 ? 1 : 2);
    case Unit.KiB:
      return (dBytes / 1024).toStringAsFixed(0);
    case Unit.B:
      return dBytes.toStringAsFixed(0);
  }
}

String stringBytesWithUnits(int bytes, {Unit? unit}) {
  unit ??= detectUnit(bytes);

  return '''${fromBytesToUnit(bytes, unit: unit)} ${unit.name}''';
}

String stringBytesOfWithUnits(int bytes1, int bytes2, {Unit? unit}) {
  var unit1 = detectUnit(bytes1).name;
  final unit2 = detectUnit(bytes2).name;

  if (unit1 == unit2) {
    unit1 = '';
  } else {
    unit1 = ' $unit1';
  }

  return '''${fromBytesToUnit(bytes1, unit: unit)}$unit1 of ${fromBytesToUnit(bytes2, unit: unit)} $unit2''';
}

String formatDuration(Duration duration) {
  final timeUnits = <String, int>{
    'd': duration.inDays,
    'h': duration.inHours % 24,
    'm': duration.inMinutes % 60,
    's': duration.inSeconds % 60,
  };

  var format = '';
  for (final entry in timeUnits.entries) {
    if (format != '') {
      if (entry.value != 0) {
        format += ' ${entry.value}${entry.key}';
      }
      break;
    }
    if (entry.value > 0) {
      format += '${entry.value}${entry.key}';
    }
  }
  return format;
}

String dateTimeToString(DateTime dateTime) {
  pad(int num) => num.toString().padLeft(2, '0');
  return '''${dateTime.year}-${pad(dateTime.month)}-${pad(dateTime.day)} ${pad(dateTime.hour)}:${pad(dateTime.minute)}:${pad(dateTime.second)}''';
}
