#!/bin/bash
# Copyright 2015 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# We're in the tools directory.
ROOT_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${ROOT_DIR}/tools/common.sh"

if [ $# -lt 1 ]; then
  echo "usage: $0 <foo.dart> [args ...]"
fi

SCRIPT_FILE="$1"
shift
exec "${DART_SDK_DIR}/bin/dart" -c "${SCRIPT_FILE}" $*
