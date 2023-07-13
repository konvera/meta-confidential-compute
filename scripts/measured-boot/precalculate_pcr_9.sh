#!/usr/bin/env bash
# Copyright (c) Edgeless Systems GmbH
#
# SPDX-License-Identifier: AGPL-3.0-only

# This script is used to precalculate the PCR[9] value for a Constellation OS image.
# PCR[9] contains the hash of the initrd and is measured by the linux kernel after loading the initrd.
# Usage: precalculate_pcr_9.sh <path to image> <path to output file>

set -euo pipefail
shopt -s inherit_errexit

source "$(dirname "$0")/measure_util.sh"

get_initrd_from_uki() {
  local uki="$1"
  local output="$2"
  objcopy -O binary --only-section=.initrd "${uki}" "${output}"
}

initrd_measure() {
  local path="$1"
  sha256sum "${path}" | cut -d " " -f 1
}

write_output() {
  local out="$1"
  cat > "${out}" << EOF
{
  "measurements": {
    "9": {
      "expected": "${expected_pcr_9}"
    }
  },
  "cmdline-sha256": "${cmdline_hash}"
  "initrd-sha256": "${initrd_hash}"
}
EOF
}

DIR=$(mktempdir)
trap 'cleanup "${DIR}"' EXIT

extract "$1" "/EFI/Linux" "${DIR}/uki"
sudo chown -R "${USER}:${USER}" "${DIR}/uki"
cp "${DIR}"/uki/*.efi "${DIR}/03-uki.efi"
get_initrd_from_uki "${DIR}/03-uki.efi" "${DIR}/initrd"

initrd_hash=$(initrd_measure "${DIR}/initrd")

get_cmdline_from_uki "${DIR}/03-uki.efi" "${DIR}/cmdline"
cmdline=$(cat "${DIR}/cmdline")

cmdline_hash=$(cmdline_measure "${DIR}/cmdline")
cleanup "${DIR}"

expected_pcr_9=0000000000000000000000000000000000000000000000000000000000000000
expected_pcr_9=$(pcr_extend "${expected_pcr_9}" "${cmdline_hash}" "sha256sum")
expected_pcr_9=$(pcr_extend "${expected_pcr_9}" "${initrd_hash}" "sha256sum")

echo "Kernel Commandline measurement ${cmdline_hash}"
echo "Initrd measurement             ${initrd_hash}"
echo ""
echo "Expected PCR[9]:               ${expected_pcr_9}"
echo ""

write_output "$2"
