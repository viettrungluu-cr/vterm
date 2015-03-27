// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:core';

// Set to true to fail assertions on not-yet-implemented things (codes, etc.).
bool assertFailOnUnimplemented = false;

// Set to true to fail assertions on unknown codes.
bool assertFailOnUnknown = false;

const int kTerminalUnfilledSpace = 0;

// TODO(vtl): Make generic?
int _clamp(int a, int n, int c) {
  if (n < a) {
    return a;
  }
  if (n > c) {
    return c;
  }
  return n;
}

// Returns |list[index]| if |index >= 0| and |list[list.length + index]| if
// |index < 0|. Returns 0 if the subscript is out of range.
int _listGet(List<int> list, int index) {
  if (index < 0) {
    index += list.length;
  }
  return (index >= 0 && index < list.length) ? list[index] : 0;
}

abstract class TerminalDelegate {
  // Maps |index| (in [0, 255]) to a "color".
  int mapIndexToColor(int index);

  // Maps the RGB triple (each in the range [0, 255]) to a "color".
  int mapRGBToColor(int red, int green, int blue);

  // These methods are only called (synchronously) in direct response to
  // |putChar()|.
  void bell();
  void putResponseChar(int char);
}

// Numbers in comments correspond to <N> in for ^[[<N>m.
const int kAttributeFlagBold = 1; // <N> = 1.
const int kAttributeFlagFaint = 2; // <N> = 2.
const int kAttributeFlagItalicized = 4; // <N> = 3.
const int kAttributeFlagUnderlined = 8; // <N> = 4.
const int kAttributeFlagBlink = 16; // <N> = 5.
const int kAttributeFlagInverse = 32; // <N> = 6.
const int kAttributeFlagInvisible = 64; // <N> = 7.
const int kAttributeFlagCrossedOut = 128; // <N> = 8.
const int kAttributeFlagDoublyUnderlined = 256; // <N> = 21.
// Values not mentioned above:
//  <N> = 0: Normal (default). TODO(vtl): Resets everything, I assume?
//  <N> = 22: Normal (neither bold nor faint).
//  <N> = 23: Not italicized.
//  <N> = 24: Not underlined. TODO(vtl): Also not doubly-underlined, I assume.
//  <N> = 25: Steady (not blinking).
//  (What happened to <N> = 26?)
//  <N> = 27: Positive (not inverse).
//  <N> = 28: Visible (not invisible).
//  <N> = 29: Not crossed out.
// TODO(vtl): I assume that doubly-underlined and underlined are mutually
// exclusive (or perhaps the latter implies the former).

class TerminalLine {
  // Parallel lists of the same length (the |Terminal|'s |width|), giving
  // character, color, and attribute data for a given line.
  List<int> characters;
  List<int> fgColors;
  List<int> bgColors;
  List<int> attributeFlags;

  TerminalLine(
      int width, int character, int fgColor, int bgColor, int attributeFlag)
      : characters = new List<int>.filled(width, character),
        fgColors = new List<int>.filled(width, fgColor),
        bgColors = new List<int>.filled(width, bgColor),
        attributeFlags = new List<int>.filled(width, attributeFlag) {}

  void setAt(
      int index, int character, int fgColor, int bgColor, int attributeFlag) {
    characters[index] = character;
    fgColors[index] = fgColor;
    bgColors[index] = bgColor;
    attributeFlags[index] = attributeFlag;
  }
}

enum TerminalState {
  // Normal state (not in an escape sequence).
  NORMAL,

  // Received ESC.
  ESCAPE,

  // Just eat the next character if it's a normal (printable) character, else
  // send it down the same path as NORMAL.
  EAT_NORMAL,

  // CSI commands begin with ESC '[', and are of the general form:
  //   ESC '[' C1? (P (';' P)*)? C2? C3
  // where:
  //   * a trailing ? indicates that something is optional;
  //   * C1, C2, and C3 are single (specific) printable characters; and
  //   * each P is a possibly-empty sequence of decimal digits (if empty its
  //     value is taken to be zero).
  // TODO(vtl): Apparently, for RGB triples, xterm may accept P ':' P ':' P
  // (i.e., separating the components using colons instead of semicolons).
  //
  // Allowable C1: '?', '>', '!'.
  // Allowable C2: '$', '"', SP, '\'', '*'.
  // Allowable C3: '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
  //     'L', 'M', 'P', 'S', 'T', 'X', 'Z', '`', 'a', 'b', 'c', 'd', 'e', 'f',
  //     'g', 'h', 'i', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w',
  //     'x', 'y', 'z', '{', '|', '}', '~' (we'll accept all letters for C3).
  //
  // States and transitions:
  //   CSI1: got ESC '['
  //     on C1 -> CSI2
  //     on C2 -> CSI3
  //     on C3 -> NORMAL
  //     on digit -> CSI2
  //     on ';' -> CSI2
  //   CSI2: processing Ps
  //     on C2 -> CSI3
  //     on C3 -> NORMAL
  //     on digit -> CSI2
  //     on ';' -> CSI2
  //   CSI3: got C2
  //     on C3 -> NORMAL
  CSI1,
  CSI2,
  CSI3,
}

// Notes:
// * Colors are integers, opaque to |Terminal|. (It's up to the consumer of the
//   modelled data to decide how to assign actual colors to those integers.) We
//   do NOT render cursors.
// * Our coordinates are all zero-based.
class Terminal {
  TerminalDelegate delegate;

  // |resize()| must be called after modifying these.
  int width;
  int height;
  int maxScrollback; // In addition to |height|.

  int fgColor;
  int bgColor;

  int attributeFlags;

  bool reverseVideo;

  // Cursor position and visibility.
  int cursorX; // In [0, width).
  int cursorY; // In [0, height).
  bool cursorVisible;

  // Scroll region start Y position.
  int scrollRegionY; // In [0, height).
  int scrollRegionHeight; // In [0, height-scrollRegionY].

  // Automatically wrap and advance to next line (and possibly scroll) at end of
  // line (else just stay at the end of the line).
  bool autoWrap;

  // Saved cursor position.
  bool haveSavedCursor;
  int savedCursorX; // In [0, width).
  int savedCursorY; // In [0, height).

  // List of tabstop flags, of length |width|.
  List<bool> tabstops;

  // TODO(vtl): Are there any cursor attributes to track (e.g., color), even if
  // we don't render them?

  // TODO(vtl): Other state.
  // - "auto linefeed"?
  // - insert mode?

  // List of line data (for the viewport and scrollback), of length at least
  // |height| and at most |height + maxScrollback|. (The viewport data is in the
  // *last* |height| entries.)
  List<TerminalLine> lines;

  TerminalState state;
  // Valid only in the CSI states.
  int _csiC1; // Optional leading character (0 if not present).
  List<int> _csiParams; // Always non-null.
  int _csiC2; // Optional trailing character (o if not present).

  Terminal(this.delegate,
      {this.width: 80, this.height: 24, this.maxScrollback: 1000}) {
    assert(delegate != null);
    _reset(true);
    _csiParams = new List<int>();
  }

  void putChar(int char) {
    switch (state) {
      case TerminalState.NORMAL:
        _normalPutChar(char);
        break;
      case TerminalState.ESCAPE:
        _escapePutChar(char);
        break;
      case TerminalState.EAT_NORMAL:
        _eatNormalPutChar(char);
        break;
      case TerminalState.CSI1:
        _csi1PutChar(char);
        break;
      case TerminalState.CSI2:
        _csi2PutChar(char);
        break;
      case TerminalState.CSI3:
        _csi3PutChar(char);
        break;
    }
  }

  void _normalPutChar(int char) {
    if (char < 32) {
      switch (char) {
        case 0: // NUL (^@/'\0').
          // Just ignore it.
          break;
        case 5: // ENQ (^E).
          // TODO(vtl): Could provide a response string.
          break;
        case 7: // BEL (^G/'\a').
          delegate.bell();
          break;
        case 8: // BS (^H/'\b').
          if (cursorX > 0) {
            cursorX--;
          }
          break;
        case 9: // TAB (^I/'\t').
          while (cursorX < width - 1 && !tabstops[cursorX + 1]) {
            cursorX++;
          }
          break;
        case 10: // LF (^J/'\n').
        case 11: // VT (^K).
        case 12: // FF (^L).
          _advanceLine();
          cursorX = 0;
          break;
        case 13: // CR (^M/'\r').
          cursorX = 0;
          break;
        case 27: // ESC.
          state = TerminalState.ESCAPE;
          break;
        default:
          // TODO(vtl): Did I miss anything? Should we do anything with invalid
          // special characters?
          break;
      }
      return;
    }

    var l = _currentLine();
    l.characters[cursorX] = char;
    l.fgColors[cursorX] = fgColor;
    l.bgColors[cursorX] = bgColor;
    l.attributeFlags[cursorX] = attributeFlags;
    _advanceCursor();
  }

  void _escapePutChar(int char) {
    if (char < 32) {
      _normalPutChar(char);
      return;
    }

    switch (char) {
      // Commands of the form ESC C1 C2:

      // Unimplemented.
      case 32: // SP (' ').
      case 35: // '#'.
      case 37: // '%'.
      case 40: // '('.
      case 41: // ')'.
      case 42: // '*'.
      case 43: // '+'.
      case 45: // '-'.
      case 46: // '.'.
      case 47: // '/'.
        // We'll be liberal and eat any printable C2.
        state = TerminalState.EAT_NORMAL;
        break;

      // Commands of the form ESC C:

      // Unimplemented.
      case 54: // '6'. TODO(vtl): Cursor left, but may scroll left?
      case 57: // '9'. TODO(vtl): Cursor right, but may scroll right?
      case 61: // '='.
      case 62: // '>'.
      case 70: // 'F'.
      case 108: // 'l'.
      case 109: // 'm'.
      case 110: // 'n'.
      case 111: // 'o'.
      case 124: // '|'.
      case 125: // '}'.
      case 126: // '~'.
        state = TerminalState.NORMAL;
        break;

      case 55: // '7': Save cursor.
        // TODO(vtl): Do I need to save attributes? (Which ones?)
        haveSavedCursor = true;
        savedCursorX = cursorX;
        savedCursorY = cursorY;
        state = TerminalState.NORMAL;
        break;

      case 56: // '8': Restore cursor.
        if (haveSavedCursor) {
          // TODO(vtl): Do I need to restore attributes? (Which ones?)
          cursorX = savedCursorX;
          cursorY = savedCursorY;
        } // Else ignore.
        state = TerminalState.NORMAL;
        break;

      case 99: // 'c': Full reset.
        _reset(false);
        break;

      // Commands using CSI (ESC '[' ...). See description of CSIn states for
      // more details.
      case 91: // '['.
        _csiStart();
        state = TerminalState.CSI1;
        break;

      default:
        // Eat the character in this case (TODO(vtl): is this right?) and leave
        // ESCAPE.
        state = TerminalState.NORMAL;
        break;
    }
  }

  void _eatNormalPutChar(int char) {
    if (char < 32) {
      _normalPutChar(char);
      return;
    }

    // Just eat the character and return to NORMAL.
    state = TerminalState.NORMAL;
  }

  void _csi1PutChar(int char) {
    // Leave handling of escape chars to |_csi2PutChar()|.
    if (_csiIsC1(char)) {
      _csiC1 = char;
      state = TerminalState.CSI2;
      return;
    }

    // Everything else is as if we were in CSI2 already.
    _csi2PutChar(char);
  }

  void _csi2PutChar(int char) {
    if (char < 32) {
      _normalPutChar(char);
      return;
    }

    if (_csiIsC2(char)) {
      _csiC2 = char;
      state = TerminalState.CSI3;
      return;
    }

    if (_csiIsC3(char)) {
      _csiFinish(char);
      state = TerminalState.NORMAL;
      return;
    }

    if (char >= 48 && char <= 57) {
      // Digit.
      _csiHandleDigit(char);
      state = TerminalState.CSI2;
      return;
    }

    if (char == 59) {
      // ';'.
      _csiHandleSemicolon();
      state = TerminalState.CSI2;
      return;
    }

    // Bad sequence: just eat everything.
    state = TerminalState.NORMAL;
  }

  void _csi3PutChar(int char) {
    if (char < 32) {
      _normalPutChar(char);
      return;
    }

    if (_csiIsC3(char)) {
      _csiFinish(char);
      state = TerminalState.NORMAL;
      return;
    }

    // Bad sequence: just eat everything.
    state = TerminalState.NORMAL;
  }

  void _csiStart() {
    _csiC1 = 0;
    _csiParams.clear();
    _csiParams.add(0);
    _csiC2 = 0;
  }

  bool _csiIsC1(int char) {
    // '!', '>', '!'.
    return char == 63 || char == 62 || char == 33;
  }

  bool _csiIsC2(int char) {
    // '$', '"', SP, '\'', '*'.
    return char == 36 || char == 34 || char == 32 || char == 39 || char == 42;
  }

  bool _csiIsC3(int char) {
    // '@', 'A' to 'Z', '`', 'a' to 'z', '{', '|', '}', '~'.
    return (char >= 64 && char <= 90) || (char >= 96 && char <= 126);
  }

  void _csiHandleDigit(int char) {
    assert(char >= 48 && char <= 57);
    assert(_csiParams.isNotEmpty);
    _csiParams[_csiParams.length - 1] = _csiParams.last * 10 + (char - 48);
  }

  void _csiHandleSemicolon() {
    assert(_csiParams.isNotEmpty);
    // Prevent |_csiParams| from growing unboundedly.
    if (_csiParams.length <= 100) {
      _csiParams.add(0);
    } else {
      _csiParams[_csiParams.length - 1] = 0;
    }
  }

  void _csiFinish(int C3) {
    assert(_csiIsC3(C3));

    switch (C3) {
      case 64: // '@'.
        // TODO(vtl): What does this do?
        break;
      case 65: // 'A': Cursor up.
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        cursorY = _clampY(cursorY - _clamp(1, _csiParams[0], height - 1));
        break;
      case 66: // 'B': Cursor down.
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        cursorY = _clampY(cursorY + _clamp(1, _csiParams[0], height - 1));
        break;
      case 67: // 'C': Cursor forward.
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        cursorX = _clampX(cursorX + _clamp(1, _csiParams[0], width - 1));
        break;
      case 68: // 'D': Cursor backward.
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        cursorX = _clampX(cursorX - _clamp(1, _csiParams[0], width - 1));
        break;
      case 69: // 'E': Cursor next line.
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        cursorX = 0;
        cursorY = _clampY(cursorY + _clamp(1, _csiParams[0], height - 1));
        break;
      case 70: // 'F': Cursor previous line.
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        cursorX = 0;
        cursorY = _clampY(cursorY - _clamp(1, _csiParams[0], height - 1));
        break;
      case 71: // 'G'.
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        cursorX = _clampX(_csiGetParam(0) - 1);
        break;
      case 72: // 'H'.
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        cursorY = _clampY(_csiGetParam(0) - 1);
        cursorX = _clampX(_csiGetParam(1) - 1);
        break;
      case 73:
        {
          // 'I'.
          if (_csiC1 != 0) {
            // Only accept no C1.
            break;
          }
          var n = _clamp(1, _csiParams[0], width - 1);
          for (var i = 0; i < n && cursorX < width - 1;) {
            cursorX++;
            if (tabstops[cursorX]) {
              i++;
            }
          }
          break;
        }
      case 74: // 'J'.
        // P = 0: Erase below, and current line from cursor (inclusive) to the
        //        end.
        // P = 1: Erase above, and current line from cursor (inclusive) to the
        //        beginning.
        // P = 2: Erase all.
        // P = 3: Erase saved lines. (xterm) TODO(vtl): What does this mean?
        //
        // Erase means: clear character (set to unfilled space), set fg/bg color
        // and *no* attributes.
        //
        // C1 = '?' means "selective erase". (TODO(vtl): Figure out how this
        // differs from normal/unselective erase.)
        if (_csiC1 != 0 && _csiC1 != 63) {
          // Only accept no C1 or C1 = '?'.
          break;
        }
        switch (_csiParams[0]) {
          case 0:
            {
              var l = _currentLine();
              for (var x = cursorX; x < width; x++) {
                l.setAt(x, kTerminalUnfilledSpace, fgColor, bgColor, 0);
              }
              for (var y = cursorY + 1; y < height; y++) {
                lines[lines.length - height + y] = _newBlankLine();
              }
              break;
            }
          case 1:
            {
              var l = _currentLine();
              for (var x = cursorX; x >= 0; x--) {
                l.setAt(x, kTerminalUnfilledSpace, fgColor, bgColor, 0);
              }
              for (var y = cursorY - 1; y >= 0; y--) {
                lines[lines.length - height + y] = _newBlankLine();
              }
              break;
            }
          case 2:
            for (var y = 0; y < height; y++) {
              lines[lines.length - height + y] = _newBlankLine();
            }
            break;
          case 3:
            // TODO(vtl)
            break;
          default:
            // Ignore everything else.
            break;
        }
        break;
      case 75: // 'K'.
        // Similar to 'J' above, but only for the current line (and P = 3 is not
        // valid/specified).
        if (_csiC1 != 0 && _csiC1 != 63) {
          // Only accept no C1 or C1 = '?'.
          break;
        }
        switch (_csiParams[0]) {
          case 0:
            {
              var l = _currentLine();
              for (var x = cursorX; x < width; x++) {
                l.setAt(x, kTerminalUnfilledSpace, fgColor, bgColor, 0);
              }
              break;
            }
          case 1:
            {
              var l = _currentLine();
              for (var x = cursorX; x >= 0; x--) {
                l.setAt(x, kTerminalUnfilledSpace, fgColor, bgColor, 0);
              }
              break;
            }
          case 2:
            lines[lines.length - height + cursorY] = _newBlankLine();
            break;
          default:
            // Ignore everything else.
            break;
        }
        break;
      case 76:
        {
          // 'L': Insert lines.
          // Inserts blank lines "at" current line (moves current and below
          // lines "down"). Leaves cursor on the same row but in the first
          // column.
          if (_csiC1 != 0) {
            // Only accept no C1.
            break;
          }
          var n = _clamp(1, _csiParams[0], height - cursorY);
          for (var i = 0; i < n; i++) {
            lines.insert(lines.length - height + cursorY, _newBlankLine());
            lines.removeLast();
          }
          cursorX = 0;
          break;
        }
      case 77:
        {
          // 'M': Delete lines.
          // Deletes lines starting at current line (moves lines below "up",
          // inserting blank lines at the bottom). Leaves cursor on the same row
          // but in the first column.
          if (_csiC1 != 0) {
            // Only accept no C1.
            break;
          }
          var n = _clamp(1, _csiParams[0], height - cursorY);
          for (var i = 0; i < n; i++) {
            lines.removeAt(lines.length - height + cursorY);
            lines.add(_newBlankLine());
          }
          cursorX = 0;
          break;
        }
      case 78: // 'N': Not actually valid/specified.
        break;
      case 79: // 'O': Not actually valid/specified.
        break;
      case 80:
        {
          // 'P': Delete characers.
          if (_csiC1 != 0) {
            // Only accept no C1.
            break;
          }
          var l = _currentLine();
          var n = _clamp(1, _csiParams[0], width - cursorX);
          var x = cursorX;
          for (; x < cursorX + n; x++) {
            if (x + n < width) {
              l.setAt(x, l.characters[x + n], l.fgColors[x + n],
                  l.bgColors[x + n], l.attributeFlags[x + n]);
            } else {
              l.setAt(x, kTerminalUnfilledSpace, fgColor, bgColor, 0);
            }
          }
          for (; x < width; x++) {
            l.setAt(x, kTerminalUnfilledSpace, fgColor, bgColor, 0);
          }
          break;
        }
      case 81: // 'Q': Not actually valid/specified.
        break;
      case 82: // 'R': Not actually valid/specified.
        break;
      case 83:
        {
          // 'S': Scroll up.
          // Adds blank lines at the bottom, scrolling the rest of the screen
          // up. Leaves the cursor in the current position.
          // TODO(vtl): C1 = '?' is actually specified (for Sixel or ReGIS
          // Graphics). Haha.
          if (_csiC1 != 0) {
            // Only accept no C1.
            break;
          }
          // We'll clamp this at |height|, but allow the scrolled-up contents to
          // go into scrollback.
          var n = _clamp(1, _csiParams[0], height);
          for (var i = 0; i < n; i++) {
            lines.add(_newBlankLine());
          }
          while (lines.length > height + maxScrollback) {
            lines.removeAt(0);
          }
          break;
        }
      case 84:
        {
          // 'T': Scroll down.
          // Adds blank lines at the top, scrolling the rest of the screen down.
          // Leaves the cursor in the current position.
          // TODO(vtl): C1 = '>' is actually specified (reset title mode
          // features).
          if (_csiC1 != 0) {
            // Only accept no C1.
            break;
          }
          // TODO(vtl): A 5-parameter version (no C1) is actually specified
          // (initiate mouse highlight tracking). But xterm ignores 2-4
          // parameter sequences.
          if (_csiParams.length > 1) {
            break;
          }
          var n = _clamp(1, _csiParams[0], height);
          for (var i = 0; i < n; i++) {
            lines.insert(lines.length - height, _newBlankLine());
            lines.removeLast();
          }
          break;
        }
      case 85: // 'U': Not actually valid/specified.
        break;
      case 86: // 'V': Not actually valid/specified.
        break;
      case 87: // 'W': Not actually valid/specified.
        break;
      case 88:
        {
          // 'X': Erase characters.
          // Starting at the current position, *replaces* characters on the
          // current line with blank characters. Leaves the cursor in the
          // current position.
          if (_csiC1 != 0) {
            // Only accept no C1.
            break;
          }
          var l = _currentLine();
          var n = _clamp(1, _csiParams[0], width - cursorX);
          for (var i = 0; i < n; i++) {
            l.setAt(cursorX + i, kTerminalUnfilledSpace, fgColor, bgColor, 0);
          }
          break;
        }
      case 89: // 'Y': Not actually valid/specified.
        break;
      case 90: // 'Z': Cursor backward tabulation.
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        // TODO(vtl): Check that this is remotely correct.
        for (var n = _clamp(1, _csiParams[0], width); cursorX > 0 && n > 0;) {
          cursorX--;
          if (tabstops[cursorX]) {
            n--;
          }
        }
        break;
      case 96: // '`': Character position absolute.
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        cursorX = _clampX(_clamp(1, _csiParams[0], width) - 1);
        break;
      case 97: // 'a': Character position relative.
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        cursorX = _clampX(cursorX + _clamp(1, _csiParams[0], width));
        break;
      case 98: // 'b': Repeat the preceding graphic character.
        // TODO(vtl): FIXME soon.
        assert(!assertFailOnUnimplemented);
        break;
      case 99: // 'c': Send device attributes.
        // TODO(vtl): FIXME soon.
        assert(!assertFailOnUnimplemented);
        break;
      case 100: // 'd': Line position absolute.
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        cursorY = _clampY(_clamp(1, _csiParams[0], height) - 1);
        break;
      case 101: // 'e': Line position relative.
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        cursorY = _clampY(cursorY + _clamp(1, _csiParams[0], height));
        break;
      case 102: // 'f': Horizontal and vertical position.
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        cursorY = _clampY(_clamp(1, _csiParams[0], height) - 1);
        cursorX = _clampX(_clamp(1, _csiGetParam(1), width) - 1);
        break;
      case 103: // 'g': Tab clear.
        // P = 0: Current column.
        // P = 3: All.
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        switch (_csiParams[0]) {
          case 0:
            tabstops[cursorX] = false;
            break;
          case 3:
            for (var i = 0; i < tabstops.length; i++) {
              tabstops[i] = false;
            }
            break;
        }
        break;
      case 104: // 'h': Set mode.
        if (_csiC1 == 0) {
          // No C1.
          switch (_csiParams[0]) {
            case 2:
            case 4:
            case 12:
            case 20:
              // TODO(vtl): FIXME soon.
              assert(!assertFailOnUnimplemented);
              break;
            default:
              assert(!assertFailOnUnknown);
              break;
          }
        } else if (_csiC1 == 63) {
          // C1 = '?'.
          switch (_csiParams[0]) {
            case 1:
            case 2:
            case 3:
            case 4:
              // TODO(vtl): FIXME soon.
              assert(!assertFailOnUnimplemented);
              break;
            case 5: // Reverse video.
              reverseVideo = true;
              break;
            case 6:
              // TODO(vtl): FIXME soon.
              assert(!assertFailOnUnimplemented);
              break;
            case 7: // Wraparound mode.
              autoWrap = true;
              break;
            case 8:
            case 9:
            case 10:
            case 12:
              // TODO(vtl): FIXME soon.
              assert(!assertFailOnUnimplemented);
              break;
            case 18: // Print form feed.
              break;
            case 19: // Set print extent to full screen.
              break;
            case 25: // Show cursor.
              cursorVisible = true;
              break;
            case 30: // Show scrollbar.
            case 35: // Enable font-shifting functions.
            case 38:
            case 40:
            case 41:
            case 42:
            case 44:
            case 45:
            case 46:
            case 47:
            case 66:
            case 67:
            case 69:
            case 95:
              // TODO(vtl): FIXME soon.
              assert(!assertFailOnUnimplemented);
            case 1001:
            case 1002:
            case 1003:
            case 1004:
            case 1005:
            case 1006:
            case 1007:
            case 1010:
            case 1011:
            case 1015:
            case 1034:
            case 1035:
            case 1036:
            case 1037:
            case 1039:
            case 1040:
            case 1041:
            case 1042:
            case 1043:
            case 1047:
            case 1048:
            case 1049:
            case 1050:
            case 1051:
            case 1052:
            case 1053:
            case 1060:
            case 1061:
            case 2004:
              // TODO(vtl): FIXME soon.
              assert(!assertFailOnUnimplemented);
            default:
              assert(!assertFailOnUnknown);
              break;
          }
        }
        break;
      case 105: // 'i': Media copy.
        // TODO(vtl): FIXME soon.
        assert(!assertFailOnUnimplemented);
        break;
      case 106: // 'j': Not actually valid/specified.
        break;
      case 107: // 'k': Not actually valid/specified.
        break;
      case 108: // 'l': Reset mode.
        if (_csiC1 == 0) {
          // No C1.
          switch (_csiParams[0]) {
            case 2:
            case 4:
            case 12:
            case 20:
              // TODO(vtl): FIXME soon.
              assert(!assertFailOnUnimplemented);
              break;
            default:
              assert(!assertFailOnUnknown);
              break;
          }
        } else if (_csiC1 == 63) {
          // C1 = '?'.
          switch (_csiParams[0]) {
            case 1:
            case 2:
            case 3:
            case 4:
              // TODO(vtl): FIXME soon.
              assert(!assertFailOnUnimplemented);
              break;
            case 5:
              reverseVideo = false;
              break;
            case 6:
              // TODO(vtl): FIXME soon.
              assert(!assertFailOnUnimplemented);
              break;
            case 7: // Wraparound mode.
              // TODO(vtl): FIXME soon.
              assert(!assertFailOnUnimplemented);
              autoWrap = false;
              break;
            case 8:
            case 9:
            case 10:
            case 12:
              // TODO(vtl): FIXME soon.
              assert(!assertFailOnUnimplemented);
              break;
            case 18: // Don't print form feed.
              break;
            case 19: // Limit print to scrolling region.
              break;
            case 25: // Hide cursor.
              cursorVisible = false;
              break;
            case 30: // Don't show scrollbar.
            case 35: // Disable font-shifting functions.
            case 38:
            case 40:
            case 41:
            case 42:
            case 44:
            case 45:
            case 46:
            case 47:
            case 66:
            case 67:
            case 69:
            case 95:
              assert(!assertFailOnUnimplemented);
              break;
            case 1001:
            case 1002:
            case 1003:
            case 1004:
            case 1005:
            case 1006:
            case 1007:
            case 1010:
            case 1011:
            case 1015:
            case 1034:
            case 1035:
            case 1036:
            case 1037:
            case 1039:
            case 1040:
            case 1041:
            case 1042:
            case 1043:
            case 1047:
            case 1048:
            case 1049:
            case 1050:
            case 1051:
            case 1052:
            case 1053:
            case 1060:
            case 1061:
            case 2004:
              assert(!assertFailOnUnimplemented);
              break;
            default:
              assert(!assertFailOnUnknown);
              break;
          }
        }
        break;
      case 109: // 'm': Character attributes.
        // TODO(vtl): C1 = '>' is actually specified (for xterm).
        if (_csiC1 != 0) {
          // Only accept no C1.
          break;
        }
        switch (_csiParams[0]) {
          case 0: // Normal.
            attributeFlags = 0;
            break;
          case 1: // Bold.
            attributeFlags |= kAttributeFlagBold;
            break;
          case 2: // Faint.
            attributeFlags |= kAttributeFlagFaint;
            break;
          case 3: // Italicized.
            attributeFlags |= kAttributeFlagItalicized;
            break;
          case 4: // Underlined.
            attributeFlags |= kAttributeFlagUnderlined;
            // TODO(vtl): Is unsetting doubly-underlined right?
            attributeFlags &= ~kAttributeFlagDoublyUnderlined;
            break;
          case 5: // Blink.
            attributeFlags |= kAttributeFlagBlink;
            break;
          case 7: // Inverse.
            attributeFlags |= kAttributeFlagInverse;
            break;
          case 8: // Invisible.
            attributeFlags |= kAttributeFlagInvisible;
            break;
          case 9: // Crossed-out characters.
            attributeFlags |= kAttributeFlagCrossedOut;
            break;
          case 21: // Doubly-underlined.
            attributeFlags |= kAttributeFlagDoublyUnderlined;
            // TODO(vtl): Is unsetting (singly-)underlined right?
            attributeFlags &= ~kAttributeFlagUnderlined;
            break;
          case 22: // Normal (neither bold nor faint).
            attributeFlags &= ~(kAttributeFlagBold | kAttributeFlagFaint);
            break;
          case 23: // Not italicized.
            attributeFlags &= ~kAttributeFlagItalicized;
            break;
          case 24: // Not underlined.
            attributeFlags &= ~kAttributeFlagUnderlined;
            // TODO(vtl): Is unsetting doubly-underlined right?
            attributeFlags &= ~kAttributeFlagDoublyUnderlined;
            break;
          case 25: // Steady (not blinking).
            attributeFlags &= ~kAttributeFlagBlink;
            break;
          case 27: // Positive (not inverse).
            attributeFlags &= ~kAttributeFlagInverse;
            break;
          case 28: // Visible, i.e., not invisible.
            attributeFlags &= ~kAttributeFlagInvisible;
            break;
          case 29: // Not crossed-out (ISO 6429).
            attributeFlags &= ~kAttributeFlagCrossedOut;
            break;
          case 30: // Set foreground color to Black.
          case 31: // Set foreground color to Red.
          case 32: // Set foreground color to Green.
          case 33: // Set foreground color to Yellow.
          case 34: // Set foreground color to Blue.
          case 35: // Set foreground color to Magenta.
          case 36: // Set foreground color to Cyan.
          case 37: // Set foreground color to White.
            fgColor = delegate.mapIndexToColor(_csiParams[0] - 30);
            break;
          case 39: // Set foreground color to default (original).
            // TODO(vtl): Hmmm.
            fgColor = delegate.mapIndexToColor(7);
            break;
          case 40: // Set background color to Black.
          case 41: // Set background color to Red.
          case 42: // Set background color to Green.
          case 43: // Set background color to Yellow.
          case 44: // Set background color to Blue.
          case 45: // Set background color to Magenta.
          case 46: // Set background color to Cyan.
          case 47: // Set background color to White.
            bgColor = delegate.mapIndexToColor(_csiParams[0] - 40);
            break;
          case 49: // Set background color to default (original).
            bgColor = delegate.mapIndexToColor(0);
            break;

          // 16-color support:
          case 90: // Set foreground color to Black.
          case 91: // Set foreground color to Red.
          case 92: // Set foreground color to Green.
          case 93: // Set foreground color to Yellow.
          case 94: // Set foreground color to Blue.
          case 95: // Set foreground color to Magenta.
          case 96: // Set foreground color to Cyan.
          case 97: // Set foreground color to White.
            fgColor = delegate.mapIndexToColor(8 + _csiParams[0] - 90);
            break;
          case 100: // Set background color to Black.
          case 101: // Set background color to Red.
          case 102: // Set background color to Green.
          case 103: // Set background color to Yellow.
          case 104: // Set background color to Blue.
          case 105: // Set background color to Magenta.
          case 106: // Set background color to Cyan.
          case 107: // Set background color to White.
            bgColor = delegate.mapIndexToColor(8 + _csiParams[0] - 100);
            break;

          // ISO-8613-3 color support:
          case 38: // Set foreground color.
            if (_csiParams.length == 5 && _csiParams[1] == 2) {
              // Match RGB.
              fgColor = delegate.mapRGBToColor(_clamp(0, _csiParams[2], 255),
                  _clamp(0, _csiParams[3], 255), _clamp(0, _csiParams[4], 255));
            } else if (_csiParams.length == 3 && _csiParams[1] == 5) {
              // xterm-256 index color.
              fgColor = delegate.mapIndexToColor(_clamp(0, _csiParams[2], 255));
            }
            break;
          case 48: // Set background color.
            if (_csiParams.length == 5 && _csiParams[1] == 2) {
              // Match RGB.
              bgColor = delegate.mapRGBToColor(_clamp(0, _csiParams[2], 255),
                  _clamp(0, _csiParams[3], 255), _clamp(0, _csiParams[4], 255));
            } else if (_csiParams.length == 3 && _csiParams[1] == 5) {
              // xterm-256 index color.
              bgColor = delegate.mapIndexToColor(_clamp(0, _csiParams[2], 255));
            }
            break;
          default:
            assert(!assertFailOnUnknown);
            break;
        }
        break;
      case 110: // 'n': Device status report.
        // TODO(vtl): FIXME soon.
        assert(!assertFailOnUnimplemented);
        break;
      case 111: // 'o'.
      case 112: // 'p'.
      case 113: // 'q'.
        // TODO(vtl): FIXME soon.
        assert(!assertFailOnUnimplemented);
        break;
      case 114: // 'r'.
        if (_csiC1 == 0) {
          // No C1.
          if (_csiParams.length == 1) {
            scrollRegionY = _clamp(1, _csiParams[0], height - 1);
            scrollRegionHeight = height - scrollRegionY;
          } else {
            if (_csiParams[1] >= _csiParams[0]) {
              scrollRegionY = _clamp(1, _csiParams[0], height - 1);
              scrollRegionHeight = _clamp(
                  0, _csiParams[1] - _csiParams[0] + 1, height - scrollRegionY);
            }
          }
        } else if (_csiC1 == 63) {
          // C1 = '?'.
          // TODO(vtl): FIXME soon.
          assert(!assertFailOnUnimplemented);
        }
        break;
      case 115: // 's'.
        if (_csiC1 == 0) {
          // No C1.
          haveSavedCursor = true;
          savedCursorX = cursorX;
          savedCursorY = cursorY;
        } else if (_csiC1 == 63) {
          // C1 = '?'.
          // TODO(vtl): FIXME soon.
          assert(!assertFailOnUnimplemented);
        }
        break;
      case 116: // 't'.
      case 117: // 'u'.
      case 118: // 'v'.
      case 119: // 'w'.
      case 120: // 'x'.
      case 121: // 'y'.
      case 122: // 'z'.
      case 123: // '{'.
      case 124: // '|'.
      case 125: // '}'.
      case 126: // '~'.
        // TODO(vtl): FIXME soon.
        assert(!assertFailOnUnimplemented);
        break;
      default:
        assert(!assertFailOnUnknown);
        break;
    }

    state = TerminalState.NORMAL;
  }

  int _csiGetParam(int index) => _listGet(_csiParams, index);

  TerminalLine _newBlankLine() => new TerminalLine(
      width, kTerminalUnfilledSpace, fgColor, bgColor, attributeFlags);

  TerminalLine _currentLine() => lines[lines.length - height + cursorY];

  int _clampX(int n) => _clamp(0, n, width - 1);
  int _clampY(int n) => _clamp(0, n, height - 1);

  void _reset(bool clearScrollback) {
    fgColor = delegate.mapIndexToColor(7);
    bgColor = delegate.mapIndexToColor(0);
    attributeFlags = 0;
    reverseVideo = false;
    cursorX = 0;
    cursorY = 0;
    cursorVisible = true;
    scrollRegionY = 0;
    scrollRegionHeight = height;
    autoWrap = true;
    haveSavedCursor = false;
    savedCursorX = 0;
    savedCursorY = 0;

    tabstops = new List<bool>.filled(width, false);
    for (var i = 0; i < width; i++) {
      tabstops[i] = i % 8 == 0;
    }

    if (clearScrollback) {
      lines = new List<TerminalLine>();
      lines.length = height;
      for (var i = 0; i < height; i++) {
        lines[i] = _newBlankLine();
      }
    } else {
      assert(lines.length >= height);
      for (var i = 0; i < height; i++) {
        lines[lines.length - height + i] = _newBlankLine();
      }
    }

    state = TerminalState.NORMAL;
  }

  void _advanceCursor() {
    cursorX++;
    if (cursorX >= width) {
      assert(cursorX == width);
      if (autoWrap) {
        _advanceLine();
        cursorX = 0;
      } else {
        cursorX = width - 1;
      }
    }
  }

  void _advanceLine() {
    cursorY++;
    if (scrollRegionHeight > 0 &&
        cursorY == scrollRegionY + scrollRegionHeight) {
      _scroll(1);
      cursorY = scrollRegionY + scrollRegionHeight - 1;
    } else if (cursorY >= height) {
      assert(cursorY == height);
      cursorY = height - 1;
    }
  }

  // |amount| may be negative.
  void _scroll(int amount) {
    if (amount == 0) {
      return;
    }

    if (amount > 0 && scrollRegionY == 0 && scrollRegionHeight == height) {
      _scrollFull(amount);
    } else {
      _scrollRegion(amount);
    }
  }

  // Scroll the full screen, updating scrollback. |amount| must be positive.
  void _scrollFull(int amount) {
    assert(amount >= 0);
    for (var i = 0; i < amount; i++) {
      lines.add(_newBlankLine());
    }
    while (lines.length > height + maxScrollback) {
      lines.removeAt(0);
    }
  }

  // Scroll the region, without updating scrollback. |amount| may be negative.
  void _scrollRegion(int amount) {
    if (amount > 0) {
      for (var i = 0; i < scrollRegionHeight; i++) {
        var j = i + amount;
        lines[scrollRegionY + i] = (j < scrollRegionHeight)
            ? lines[scrollRegionY + j]
            : _newBlankLine();
      }
    } else if (amount < 0) {
      for (var i = scrollRegionHeight; i > 0;) {
        i--;
        var j = i + amount;
        lines[scrollRegionY + i] =
            (j >= 0) ? lines[scrollRegionY + j] : _newBlankLine();
      }
    }
  }
}
