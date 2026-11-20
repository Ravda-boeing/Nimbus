# Chapter 9 configuration record

This records the system-specific choices applied to the LFS root at `/mnt/lfs`.
The corresponding live files are in the USB LFS filesystem; these copies make
the configuration reproducible if that filesystem is rebuilt.

## Decisions

- Hostname: `Nimbus`.
- Network manager: `systemd-networkd`, with IPv4 DHCP on wired interfaces named
  `en*` or `eth*`.
- Interface naming: keep systemd-udev's default predictable names; no custom
  `.link` file is needed.
- DNS: `systemd-resolved`, using its stub resolver.
- Locale: `en_AU.UTF-8`. The locale was generated with `localedef`; the LFS
  locale archive lists it as `en_AU.utf8`.
- Console keymap and font: `us` and `Lat2-Terminus16`.
- Time zone: `Australia/Melbourne`.
- RTC: the ThinkBook host reports `LocalRTC=no`, so configure the LFS system
  for a UTC hardware clock. `/etc/adjtime` should contain the UTC setting
  shown below. This file is present in the LFS root.
- No device-specific udev rules are needed at present. Revisit Section 9.4 if
  duplicate devices or unstable device names cause a real problem.
- Section 9.10: retain systemd defaults; no local overrides are selected.

`systemd-networkd` configures addressing after a wireless connection is
authenticated, but does not authenticate to Wi-Fi. Add a Wi-Fi manager such as
iwd before expecting Wi-Fi networking to work.

## Configuration files

### `/etc/hostname`

```text
Nimbus
```

### `/etc/hosts`

```text
# Begin /etc/hosts
127.0.0.1 localhost.localdomain localhost Nimbus
::1       localhost.localdomain localhost ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters
# End /etc/hosts
```

### `/etc/systemd/network/10-ethernet-dhcp.network`

```ini
[Match]
Name=en* eth*

[Network]
DHCP=ipv4

[DHCPv4]
UseDomains=true
```

### `/etc/resolv.conf`

This is a symbolic link to `/run/systemd/resolve/stub-resolv.conf`.

### `/etc/adjtime`

```text
0.0 0 0.0
0
UTC
```

### `/etc/localtime`

This is a symbolic link to `/usr/share/zoneinfo/Australia/Melbourne`.

### `/etc/vconsole.conf`

```text
KEYMAP=us
FONT=Lat2-Terminus16
```

### `/etc/locale.conf`

```text
LANG=en_AU.UTF-8
```

### `/etc/profile`

```bash
# Begin /etc/profile
for i in $(locale); do
  unset ${i%=*}
done

if [[ "$TERM" = linux ]]; then
  export LANG=C.UTF-8
else
  source /etc/locale.conf
  for i in $(locale); do
    key=${i%=*}
    if [[ -v $key ]]; then
      export $key
    fi
  done
fi
# End /etc/profile
```

### `/etc/inputrc`

```text
# Begin /etc/inputrc
set horizontal-scroll-mode Off
set meta-flag On
set input-meta On
set convert-meta Off
set output-meta On
set bell-style none
"\eOd": backward-word
"\eOc": forward-word
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert
"\eOH": beginning-of-line
"\eOF": end-of-line
"\e[H": beginning-of-line
"\e[F": end-of-line
# End /etc/inputrc
```

### `/etc/shells`

```text
# Begin /etc/shells
/bin/sh
/bin/bash
# End /etc/shells
```

## Apply or verify

Generate the Australian English locale from inside the LFS root:

```bash
sudo chroot /mnt/lfs /usr/bin/localedef -i en_AU -f UTF-8 en_AU.UTF-8
sudo chroot /mnt/lfs /usr/bin/locale -a | grep -i '^en_AU'
sudo chroot /mnt/lfs /usr/bin/env LC_ALL=en_AU.UTF-8 /usr/bin/locale charmap
```

The current host reports `LocalRTC=no`. Write the UTC RTC setting inside LFS:

```bash
sudo chroot /mnt/lfs /bin/bash -lc 'cat > /etc/adjtime << "EOF"
0.0 0 0.0
0
UTC
EOF'
```

Run the read-only configuration checker from the repository root:

```bash
tools/phase1/check-chapter9.sh /mnt/lfs
```

The locale is available at runtime as `en_AU.utf8`; running
`LC_ALL=en_AU.UTF-8 locale charmap` reports `UTF-8`. The configuration checker
passes all checks, including the explicit UTC `/etc/adjtime` setting.

The chroot's `systemd-networkd` and `systemd-resolved` services are enabled.
`systemd-networkd-wait-online` is enabled as well. The resolver symlink is for
the booted LFS system; when a build needs DNS inside the chroot before first
boot, temporarily provide a working `/etc/resolv.conf` and remove it again
before booting.
