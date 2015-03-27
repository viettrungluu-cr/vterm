// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Simple program that sends stdin to be rendered by the model, and when done
// prints out the rendered characters (ignoring colors and attributes).
// This is probably most useful when stdin/stdout are redirected from/to files.

import 'dart:core';
import 'dart:io';

import 'terminal.dart';
import 'xterm256_colors.dart' as xterm256;

class SimpleTerminalDelegate implements TerminalDelegate {
  @override
  int mapIndexToColor(int index) {
    return xterm256.mapIndexToColor(index);
  }

  @override
  int mapRGBToColor(int red, int green, int blue) {
    return xterm256.mapRGBToColor(red, green, blue);
  }

  @override
  void bell() {}

  @override
  void putResponseChar(int char) {}
}

void main(List<String> arguments) {
  assertFailOnUnimplemented = true;
  assertFailOnUnknown = true;

  var m = new Terminal(new SimpleTerminalDelegate());
  while (true) {
    var i = stdin.readByteSync();
    if (i < 0) {
      break;
    }
    m.putChar(i);
  }

  for (var l in m.lines) {
    for (var c in l.characters) {
      if (c == kTerminalUnfilledSpace) {
        c = 32;
      }
      stdout.writeCharCode(c);
    }
    stdout.writeCharCode(10);
  }
}
