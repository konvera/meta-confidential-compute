#!/usr/bin/env python
# Copyright (c) Edgeless Systems GmbH
#
# SPDX-License-Identifier: AGPL-3.0-only

# This script calculates the authentihash of a PE / EFI binary.
# Install prerequisites:
#   pip install signify

import sys
import signify.fingerprinter
import hashlib

def authentihash(path, alg="sha256"):
    with open(path, "rb") as fh:
        fpr = signify.fingerprinter.AuthenticodeFingerprinter(fh)
        fpr.add_authenticode_hashers(getattr(hashlib, alg))
        return fpr.hash()[alg]

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <filename>")
        sys.exit(1)
    print(authentihash(sys.argv[1]).hex())
