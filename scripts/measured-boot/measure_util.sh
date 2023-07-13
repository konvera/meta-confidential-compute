#!/usr/bin/env bash
# Copyright (c) Edgeless Systems GmbH
#
# SPDX-License-Identifier: AGPL-3.0-only

# This script contains shared functions for pcr calculation.

set -euo pipefail
shopt -s inherit_errexit

pcr_extend() {
  local CURRENT_PCR="$1"
  local EXTEND_WITH="$2"
  local HASH_FUNCTION="$3"
  (
    echo -n "${CURRENT_PCR}" | xxd -r -p
    echo -n "${EXTEND_WITH}" | xxd -r -p
  ) | ${HASH_FUNCTION} | cut -d " " -f 1
}

extract() {
  local image="$1"
  local path="$2"
  local output="$3"
  wic cp "${image}":1"${path}" "${output}"
}

mktempdir() {
  mktemp -d
}

cleanup() {
  local dir="$1"
  rm -rf "${dir}"
}

get_cmdline_from_uki() {
  local uki="$1"
  local output="$2"
  objcopy -O binary --only-section=.cmdline "${uki}" "${output}"
}

cmdline_measure() {
  local path="$1"
  local tmp
  tmp=$(mktemp)
  truncate -s +1 "${path}"
  # convert to utf-16le
  iconv -f utf-8 -t utf-16le "${path}" -o "${tmp}"
  sha256sum "${tmp}" | cut -d " " -f 1
  rm "${tmp}"
}


