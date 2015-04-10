// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Based on libteken's |teken_256to8()|.
int mapIndexToColor(int index) {
  const int kBlack = 0;
  const int kRed = 1;
  const int kGreen = 2;
  const int kBrown = 3;
  const int kBlue = 4;
  const int kMagenta = 5;
  const int kCyan = 6;
  const int kWhite = 7;

  assert(0 <= index && index <= 255);

  if (index < 16) {
    // Traditional color indices.
    return index % 8;
  }
  if (index >= 244) {
    // Upper grayscale colors.
    return kWhite;
  }
  if (index >= 232) {
    // Lower grayscale colors.
    return kBlack;
  }

  // Convert to RGB.
  int rgb = index - 16;
  int r = rgb ~/ 36;
  int g = (rgb ~/ 6) % 6;
  int b = rgb % 6;
  return _mapRGBToColorHelper(rgb ~/ 36, (rgb ~/ 6) % 6, rgb % 6, 6);
}

int mapRGBToColor(int red, int green, int blue) {
  assert(0 <= red && red <= 255);
  assert(0 <= green && green <= 255);
  assert(0 <= blue && blue <= 255);

  return _mapRGBToColorHelper(red, green, blue, 256);
}

// Based on libteken's |teken_256to8()|.
int _mapRGBToColorHelper(int r, int g, int b, int maxPlusOne) {
  assert(0 <= r && r < maxPlusOne);
  assert(0 <= g && g < maxPlusOne);
  assert(0 <= b && b < maxPlusOne);

  if (r < g) {
    // Possibly green.
    if (g < b) {
      return kBlue;
    }
    if (g > b) {
      return kGreen;
    }
    return kCyan;
  }
  if (r > g) {
    // Possibly red.
    if (r < b) {
      return kBlue;
    }
    if (r > b) {
      return kRed;
    }
    return kMagenta;
  }
  // Possibly brown.
  if (g < b) {
    return kBlue;
  }
  if (g > b) {
    return kBrown;
  }
  if (r < maxPlusOne ~/ 2) {
    return kBlack;
  }
  return kWhite;
}
