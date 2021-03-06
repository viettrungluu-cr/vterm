#!/bin/bash
# Copyright 2015 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# We're in the tools directory.
ROOT_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${ROOT_DIR}/tools/common.sh"

cd "${ROOT_DIR}"
DARTFMT="${DART_SDK_DIR}/bin/dartfmt"
find . -name '*.dart' -print0 | xargs -0 "$DARTFMT" -w
