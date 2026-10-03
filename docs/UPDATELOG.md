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

