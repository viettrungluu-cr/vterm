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

class TestTerminalDelegate implements TerminalDelegate {
  @override
  int mapIndexToColor(int index) {
    // TODO(vtl): Probably shouldn't map using xterm256 (at least not if we want
    // to compare versus teken).
    return xterm256.mapIndexToColor(index);
  }

  @override
  int mapRGBToColor(int red, int green, int blue) {
    // TODO(vtl): Probably shouldn't map using xterm256 (at least not if we want
    // to compare versus teken).
    return xterm256.mapRGBToColor(red, green, blue);
  }

  @override
  void bell() {}

  @override
  void putResponseChar(int char) {}
}

void printUsage(String argv0) {
  stdout.write('usage: $argv0 [option]... [--] (FILE|-)...\n\n'
               '(- indicates standard input)\n');
}

void main(List<String> arguments) {
  int verbosity = 0;

  assertFailOnUnimplemented = true;
  assertFailOnUnknown = true;

  var argv0 = Platform.script.pathSegments.last;
  if (arguments.isEmpty) {
    printUsage(argv0);
    return;
  }

  // Consume options first.
  int first_file = 0;
  for (; first_file < arguments.length; first_file++) {
    if (!arguments[first_file].startsWith('-') ||
        arguments[first_file] == '-') {
      break;
    }
    if (arguments[first_file] == '--') {
      first_file++;
      break;
    }
    if (arguments[first_file] == '-h' || arguments[first_file] == '--help') {
      printUsage(argv0);
      return;
    }
    if (arguments[first_file] == '-v' || arguments[first_file] == '--verbose') {
      verbosity++;
    } else {
      // No other options yet.
      stderr.write('$argv0: unknown option ${arguments[first_file]}\n');
      exitCode = 1;
      return;
    }
  }

  if (first_file >= arguments.length) {
    stderr.write('$argv0: no inputs specified\n');
    exitCode = 1;
    return;
  }

  var terminal = new Terminal(new TestTerminalDelegate());

  for (int i = first_file; i < arguments.length; i++) {
    if (arguments[i] == '-') {
      while (true) {
        var c = fp.readByteSync();
        if (c < 0) {
          break;
        }
        terminal.putChar(c);
      }
    } else {
      try {
        var cList = (new File(arguments[i])).readAsBytesSync();
        cList.forEach((c) { terminal.putChar(c); });
      } on FileSystemException catch (e) {
        stderr.write('$argv0: error opening ${arguments[i]}: ${e.message}\n');
        exitCode = 1;
        return;
      }
    }
  }

  // TODO(vtl): Proper output format.
  for (var i = terminal.lines.length - 24; i < terminal.lines.length; i++) {
    var l = terminal.lines[i];
    for (var c in l.characters) {
      if (c == kTerminalUnfilledSpace) {
        c = 32;
      }
      stdout.writeCharCode(c);
    }
    stdout.writeCharCode(10);
  }
}
