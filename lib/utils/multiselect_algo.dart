import 'dart:math';

import 'package:flutter/services.dart';

List<int> multiselectAlgo({
  required List<int> selectedIndexes,
  required int index,
}) {
  final shiftKeys = [
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight
  ];

  final ctrlKeys = [
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
  ];

  final isShiftPressed =
      RawKeyboard.instance.keysPressed.where(shiftKeys.contains).isNotEmpty;

  final isCtrlPressed =
      RawKeyboard.instance.keysPressed.where(ctrlKeys.contains).isNotEmpty;

  if (isShiftPressed && selectedIndexes.isNotEmpty) {
    var firstIndex = selectedIndexes.first;
    var lastIndex = 0;

    for (final i in selectedIndexes) {
      firstIndex = min(firstIndex, i);
      lastIndex = max(lastIndex, i);
    }

    if (firstIndex < index) {
      return [for (var i = firstIndex; i <= index; i++) i];
    } else {
      return [for (var i = index; i <= lastIndex; i++) i];
    }
  } else if (isCtrlPressed) {
    if (selectedIndexes.contains(index)) {
      return selectedIndexes.where((i) => i != index).toList();
    }
    return [
      ...selectedIndexes,
      index,
    ];
  } else {
    if (selectedIndexes.length == 1 && selectedIndexes.first == index) {
      return [];
    } else {
      return [index];
    }
  }
}
