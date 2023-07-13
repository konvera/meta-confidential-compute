FILESEXTRAPATHS:prepend := "${THISDIR}/linux-yocto:"

SRC_URI += "\
    ${@bb.utils.contains('IMAGE_FEATURES', 'hyperv', \
                         'file://hyperv.scc file://hyperv.cfg', '', d)} \
"
