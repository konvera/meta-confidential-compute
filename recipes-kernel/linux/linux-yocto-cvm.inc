FILESEXTRAPATHS:prepend := "${THISDIR}/linux-yocto:"

SRC_URI += "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'cvm', \
                         'file://cvm.scc file://cvm.cfg', '', d)} \
"
