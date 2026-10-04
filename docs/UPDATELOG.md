# Update log for Nimbus 
## ANY CHANGES MADE TO NIMBUS MUST BE EXPLICITLY STATED IN THIS DOCUMENT

### 2026-10-03 - Rav
- Initial repo structure
- Added base Makefile
- stubbed init system entry point
- Established dual-version architecture (Linux distro + custom kernel)
- Prepared repo for Nimbus Linux distro development
- Cleaned project structure for userland-only build path
- Added new kernel configuration work for Nimbus (Linux 7.2.8)
- Identified and resolved DWARF dependency issue (libdw-dev)
- Identified Ubuntu/Mint certificate subsystem conflict (canonical-certs.pem)
- Updated kernel configuration to disable trusted keyring and certificate requirements
- Began full kernel build process; halted due to insufficient disk space on Acer device
- Prepared migration plan to continue kernel build on secondary machine with adequate storage
- Added /dev mount support via devtmpfs
- Updated /init to mount /proc and /sys
- Verified BusyBox shell boots cleanly
- Confirmed QEMU boot sequence stable

This will be all I shall do for tonight
I shall resume this tomorrow.
Hopefully you can grasp an understanding on what I'm doing and **HOPEFULLY** one day we could stand at the auditorium presenting Nimbus
but that's for another day
farewell, and good night comrade

### 2026-10-4 - Rav
- Created a clean, minimal Nimbus root filesystem (rootfs/)
- Added BusyBox-based /bin/sh for initial userspace shell
- Implemented first Nimbus /sbin/init with boot banner and shell handoff
- Updated initramfs /init to:
  - mount /dev, /proc, /sys
  - read root= from kernel cmdline
  - mount real rootfs at /mnt/root
  - verify /bin/sh and /sbin/init
  - switch_root into Nimbus userspace
- Completed full boot pipeline for Nimbus 0.1
- Ready to boot Nimbus rootfs in QEMU
- Added init.d scripts: mountfs, banner, network, login
- Implemented Nimbus logging system (var/log/nimbus.log)
- Created Nimbus branding foundation and visual logo concept
- Updated boot sequence messages for consistent Nimbus identity
- Prepared repository for commit and push


