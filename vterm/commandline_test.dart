// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Simple program that sends stdin to be rendered by the model, and when done
// prints out the rendered characters (ignoring colors and attributes).
// This is probably most useful when stdin/stdout are redirected from/to files.

import 'dart:core';
import 'dart:io';

import 'terminal_model.dart';
import 'xterm256_colors.dart' as xterm256;

class SimpleTerminalModelDelegate implements TerminalModelDelegate {
  @override
  int mapIndexToColor(int index) {
    return xterm256.mapIndexToColor(index);
  }

  @override
  int mapRGBToColor(int red, int green, int blue) {
    return xterm256.mapRGBToColor(red, green, blue);
  }

  @override
  void bell() {
  }

  @override
  void putResponseChar(int char) {
  }
}

void main(List<String> arguments) {
  var m = new TerminalModel(new SimpleTerminalModelDelegate());
  while (true) {
    var i = stdin.readByteSync();
    if (i < 0) {
      break;
    }
    m.putChar(i);
  }

  for (var l in m.lines) {
    for (var c in l.characters) {
      if (c == kTerminalModelUnfilledSpace) {
        c = 32;
      }
      stdout.writeCharCode(c);
    }
    stdout.writeCharCode(10);
  }
}
