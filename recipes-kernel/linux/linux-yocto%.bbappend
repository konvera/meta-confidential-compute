KMACHINE:sev-snp ?= "common-pc-64"
COMPATIBLE_MACHINE:sev-snp = "sev-snp"

KERNEL_FEATURES:append:sev-snp=" features/scsi/disk.scc"
KERNEL_FEATURES:append:sev-snp=" cfg/virtio.scc cfg/paravirt_kvm.scc cfg/fs/ext4.scc"
KERNEL_FEATURES:append:sev-snp=" sev-snp.scc tpm2.scc hyperv.scc"

#require ${@bb.utils.contains('IMAGE_FEATURES', 'hyperv', 'linux-yocto-hyperv.inc', '', d)}
require ${@bb.utils.contains('DISTRO_FEATURES', 'cvm', 'linux-yocto-cvm.inc', '', d)}
