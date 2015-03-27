#!/bin/bash
# Copyright 2015 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# We're in the tools directory. Change to our root directory.
cd "$(dirname "$0")/.."

ROOT_DIR=.
source tools/common.sh

DARTFMT="${DART_SDK_DIR}/bin/dartfmt"
find . -name '*.dart' -print0 | xargs -0 "$DARTFMT" -w
