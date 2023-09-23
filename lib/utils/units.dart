// ignore_for_file: constant_identifier_names

enum Unit {
  GiB,
  MiB,
  KiB,
  B,
}

Unit detectUnit(int bytes) {
  if (bytes >= 1024 * 1024 * 1024) {
    return Unit.GiB;
  } else if (bytes >= 1024 * 1024) {
    return Unit.GiB;
  } else if (bytes >= 1024) {
    return Unit.MiB;
  } else {
    return Unit.KiB;
  }
}

double fromBytesToUnit(int bytes, {Unit? unit}) {
  final dBytes = bytes.toDouble();
  switch (unit ?? detectUnit(bytes)) {
    case Unit.GiB:
      return dBytes / 1024 / 1024 / 1024;
    case Unit.MiB:
      return dBytes / 1024 / 1024;
    case Unit.KiB:
      return dBytes / 1024;
    case Unit.B:
      return dBytes;
  }
}

String printBytesWithUnits(int bytes, {Unit? unit}) {
  unit ??= detectUnit(bytes);

  return '''${fromBytesToUnit(bytes, unit: unit).toStringAsFixed(2)} ${unit.name}''';
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
  return '''${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}''';
}
