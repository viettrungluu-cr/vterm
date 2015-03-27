# Copyright 2015 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# To be sourced, not executed. ROOT_DIR must already be set.

if [ ! -f "${ROOT_DIR}/LOCAL_CONFIG" ]; then
  echo "$0: no LOCAL_CONFIG file"
  exit 1
fi
source "${ROOT_DIR}/LOCAL_CONFIG"
