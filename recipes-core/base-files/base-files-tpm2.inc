do_install:append() {
    echo 'securityfs  /sys/kernel/security  securityfs  defaults  0  0' >> "${D}${sysconfdir}/fstab"
}
