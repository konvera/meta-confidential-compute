#!/usr/bin/env bash
# Copyright (c) Edgeless Systems GmbH
#
# SPDX-License-Identifier: AGPL-3.0-only

# This script is used to precalculate the PCR[4] value for a Constellation OS image.
# Usage: precalculate_pcr_4.sh <path to image> <path to output file>

set -euo pipefail
shopt -s inherit_errexit
source "$(dirname "$0")/measure_util.sh"

ev_efi_action_sha256=3d6772b4f84ed47595d72a2c4c5ffd15f5bb72c7507fe26f2aaee2c69d5633ba
ev_efi_separator_sha256=df3f619804a92fdb4057192dc43dd748ea778adc52bc498ce80524c014b81119

authentihash() {
  local path="$1"
  "$(dirname "$0")/extract_authentihash.py" "${path}"
}

get_kernel_from_uki() {
  local uki="$1"
  local output="$2"
  objcopy -O binary --only-section=.linux "${uki}" "${output}"
}

write_output() {
  local out="$1"
  cat > "${out}" << EOF
{
  "measurements": {
    "4": {
      "expected": "${expected_pcr_4}"
    }
  },
  "efistages": [
    {
      "name": "systemd-boot",
      "sha256": "${sd_boot_authentihash}"
    },
    {
      "name": "uki",
      "sha256": "${uki_authentihash}"
    },
    {
      "name": "linux",
      "sha256": "${kernel_authentihash}"
    }
  ]
}
EOF
}

DIR=$(mktempdir)
trap 'cleanup "${DIR}"' EXIT

extract "$1" "/EFI/BOOT/bootx64.efi" "${DIR}/01-sd-boot.efi"
extract "$1" "/EFI/Linux" "${DIR}/uki"
sudo chown -R "${USER}:${USER}" "${DIR}/uki"
cp "${DIR}"/uki/*.efi "${DIR}/02-uki.efi"

sd_boot_authentihash=$(authentihash "${DIR}/01-sd-boot.efi")
uki_authentihash=$(authentihash "${DIR}/02-uki.efi")
get_kernel_from_uki "${DIR}/02-uki.efi" "${DIR}/linux"

kernel_authentihash=$(authentihash "${DIR}/linux")
cleanup "${DIR}"

expected_pcr_4=0000000000000000000000000000000000000000000000000000000000000000
expected_pcr_4=$(pcr_extend "${expected_pcr_4}" "${ev_efi_action_sha256}" "sha256sum")
expected_pcr_4=$(pcr_extend "${expected_pcr_4}" "${ev_efi_separator_sha256}" "sha256sum")
expected_pcr_4=$(pcr_extend "${expected_pcr_4}" "${sd_boot_authentihash}" "sha256sum")
expected_pcr_4=$(pcr_extend "${expected_pcr_4}" "${uki_authentihash}" "sha256sum")
expected_pcr_4=$(pcr_extend "${expected_pcr_4}" "${kernel_authentihash}" "sha256sum")

echo "Authentihashes:"
echo "Stage 1 - sd-boot:                    ${sd_boot_authentihash}"
echo "Stage 2 - Unified Kernel Image (UKI): ${uki_authentihash}"
echo "Stage 3 - Linux Kernel:               ${kernel_authentihash}"
echo ""
echo "Expected PCR[4]:                      ${expected_pcr_4}"
echo ""

write_output "$2"
