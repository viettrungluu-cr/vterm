#!/bin/bash
# Copyright 2015 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# We're in the tools directory. Change to our root directory.
cd "$(dirname "$0")/.."

if [ ! -f LOCAL_CONFIG ]; then
  echo "$0: no LOCAL_CONFIG file"
  exit 1
fi
source LOCAL_CONFIG

DARTFMT="${DART_SDK_DIR}/bin/dartfmt"
find . -name '*.dart' -print0 | xargs -0 "$DARTFMT" -w
