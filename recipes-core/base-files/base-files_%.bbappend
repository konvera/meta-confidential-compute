require ${@bb.utils.contains('MACHINE_FEATURES', 'tpm2', 'base-files-tpm2.inc', '', d)}
