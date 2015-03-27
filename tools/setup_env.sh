# Copyright 2015 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Adds our tools directory to the path. To be sourced, not executed.

# We're in the tools directory.
export PATH="$(dirname "$(readlink -f "$0")"):${PATH}"
