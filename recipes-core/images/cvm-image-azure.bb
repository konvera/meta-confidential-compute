SUMMARY = "A small image just capable of allowing a device to boot."

IMAGE_INSTALL = ""

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image

# override vhd conversion cmd - azure rquirements of virtual size aligned to 1 MiB
CONVERSION_CMD:vhd:prepend = "truncate -s %1MiB ${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wic; \
                              qemu-img convert -O vpc -o subformat=fixed,force_size ${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wic ${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wic.vhd; \
                              echo "

IMAGE_FEATURES[validitems] += "hyperv"
IMAGE_FEATURES = "hyperv"

IMAGE_FSTYPES = "wic wic.vhd"
WKS_FILE = "mkefiinitrd.wks"
