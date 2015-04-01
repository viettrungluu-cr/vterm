// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// See README.md. This is a "test filter" implemented using the vterm terminal
// (model).

import 'dart:convert';
import 'dart:core';
import 'dart:io';

import '../vterm/terminal.dart';
import '../vterm/xterm256_colors.dart' as xterm256;

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

void printTerminal(Terminal terminal) {
  var out = new Map();

  out['size'] = [terminal.height, terminal.width];

  out['characters'] = [];
  for (var i = 0; i < terminal.height; i++) {
    var codes = new List<int>.from(
        terminal.lines[terminal.lines.length - terminal.height + i].characters);
    for (var j = 0; j < codes.length; j++) {
      if (codes[j] == 0) {
        codes[j] = 32;
      }
    }
    out['characters'].add(new String.fromCharCodes(codes));
  }

  out['position'] = [terminal.cursorY, terminal.cursorX];

  stdout.write(const JsonEncoder.withIndent('  ').convert(out));
  stdout.write('\n');
}

void main(List<String> arguments) {
  int verbosity = 0;
  bool autoCrLf = false;

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
    } else if (arguments[first_file] == '--auto-crlf') {
      autoCrLf = true;
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
  var putChar;
  if (autoCrLf) {
    putChar = (c) {
      if (c == 10 || c == 13) {
        terminal.putChar(13);
        terminal.putChar(10);
      } else {
        terminal.putChar(c);
      }
    };
  } else {
    putChar = (c) { terminal.putChar(c); };
  }

  for (int i = first_file; i < arguments.length; i++) {
    if (arguments[i] == '-') {
      while (true) {
        var c = stdin.readByteSync();
        if (c < 0) {
          break;
        }
        putChar(c);
      }
    } else {
      try {
        var cList = (new File(arguments[i])).readAsBytesSync();
        cList.forEach((c) { putChar(c); });
      } on FileSystemException catch (e) {
        stderr.write('$argv0: error opening ${arguments[i]}: ${e.message}\n');
        exitCode = 1;
        return;
      }
    }
  }

  printTerminal(terminal);
}
