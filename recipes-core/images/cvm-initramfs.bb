# Simple initramfs image artifact generation for tiny images.
DESCRIPTION = "Tiny image capable of booting a device. The kernel includes \
the Minimal RAM-based Initial Root Filesystem (initramfs), which finds the \
first 'init' program more efficiently. core-image-tiny-initramfs doesn't \
actually generate an image but rather generates boot and rootfs artifacts \
that can subsequently be picked up by external image generation tools such as wic."

CVM_DEPS = "busybox-mdev e2fsprogs-resize2fs parted init-ifupdown initscripts base-files base-passwd netbase busybox-udhcpd"

# delve gdb strace
PACKAGE_INSTALL = "e2fsprogs-mke2fs go-ethereum ca-certificates sysvinit busybox-udhcpd dropbear ${CVM_DEPS} ${VIRTUAL-RUNTIME_base-utils} ${ROOTFS_BOOTSTRAP_INSTALL}"

INITRAMFS_MAXSIZE = "200000"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = "debug-tweaks"

export IMAGE_BASENAME = "cvm-initramfs"
IMAGE_NAME_SUFFIX ?= ""
IMAGE_LINGUAS = ""

LICENSE = "MIT"

# don't actually generate an image, just the artifacts needed for one
IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"

inherit core-image

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

# Use the same restriction as initramfs-live-install
COMPATIBLE_HOST = "x86_64.*-linux"

# QB_KERNEL_CMDLINE_APPEND += "debugshell=3 init=/bin/busybox sh init"
