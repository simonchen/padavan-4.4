# padavan-4.4 #

This project is based on original rt-n56u with latest mtk 4.4.198 kernel, which is fetch from D-LINK GPL code.

#### Extra functions / changes
- Tune kernel configs (for NEWIFI / K2P only)
- Decline the load average over multiple-cores for compatiable with more old apps running well.
- Revise the MTD storage partition for 16M flash, the firmware size must be less than 10MB as possible.
- Revise the MTD storage partition for 32M flash, the firmware size has no change as before, but the storage size can have more than 15MB.
- Adding user/chinadns-ng , and fix shadowsocks + chinadns-ng using local domain whitellist.
- FRP supported (dynamically loaded)
- AP relay auto-daemon


#### SS/SSR
- Transparent proxy (iptables) wasn't cleaned completely, this issue is fixed.
- Adding DNSProxy , Local DNS integrated with SS/SSR 
- Dnsmasq optimization specially for SS/SSR 
- Resolve DNS pollution - Adding DNS i/p in china-route mode
- Fast-open option is enabled according to linux version

#### Compile notes
- Be careful: if you run the same workflow twice again , it could directly reload the previous `Makefile` from cache. 
  so if you made change of `Makefile` , you will have to run a new workfolow!!!

<hr />

**Below is all changes from [tsl0922/padavan](https://github.com/tsl0922/padavan)**

##### Enhancements in this repo

- commits has beed rewritten on top of [hanwckf/rt-n56u](https://github.com/hanwckf/rt-n56u) repo for better history tracking
- Optimized Makefiles and build scripts, added a toplevel Makefile
- Added ccache support, may save up to 50%+ build time
- Upgraded the toolchain and libc:
  - gcc 10.3.0
  - uClibc-ng 1.0.42
 - Enabled kernel cgroups support
 - Fixed K2P led label names
 - Replaced udpxy with msd_lite
 - Replaced Web Console with ttyd
 - Upgraded libs and user packages
 - And a lot of package related fixes
 - ...

# Features

- Based on 4.4.198 Linux kernel
- Support MT7621 based devices
- Support MT7615D/MT7615N/MT7915D wireless chips
- Support raeth and mt7621 hwnat with legency driver
- Support qca shortcut-fe
- Support IPv6 NAT based on netfilter
- Support WireGuard integrated in kernel
- Support fullcone NAT (by Chion82)
- Support LED&GPIO control via sysfs

# Supported devices

- CR660x
- JCG-Q20
- JCG-AC860M
- JCG-836PRO
- JCG-Y2
- DIR-878
- DIR-882
- K2P
- K2P-USB
- NETGEAR-BZV
- MR2600
- MI-4
- MI-R3G
- MI-R3P
- R2100
- XY-C1
- NEWIFI (New added, MT7621E HW_NAT has single thread issue on 5G wifi, it's not resolved yet)

# Compilation steps

- Install dependencies
  ```sh
  # Debian/Ubuntu
  sudo apt install unzip libtool-bin ccache curl cmake gperf gawk flex bison nano xxd \
      fakeroot kmod cpio git python3-docutils gettext automake autopoint \
      texinfo build-essential help2man pkg-config zlib1g-dev libgmp3-dev \
      libmpc-dev libmpfr-dev libncurses5-dev libltdl-dev wget libc-dev-bin
  ```
  **Optional:** install [golang](https://go.dev/doc/install) (and add it to PATH), if you are going to build go programs
- Clone source code
  ```sh
  git clone https://github.com/tsl0922/padavan.git
  ```
- Modify template file and start compiling
  ```sh
  # (Optional) Modify template file
  # vi trunk/configs/templates/K2P.config

  # Start compiling with: make PRODUCT_NAME
  make K2P

  # To build firmware for other devices, clean the tree after previous build
  make clean
  ```
  
- Driver modulde compilation
  
  Copy / Paste the below codes then put it in the ending of the Makefile in the driver package folder (e.g, mt76x2_ap)
  **Assume that /work is the root path with padavan-4.4**
  ```
  CROSS=/work/padavan-4.4/toolchain-mipsel/toolchain-4.4.x/bin/mipsel-linux-uclibc-
  KERNEL=/work/padavan-4.4/trunk/linux-4.4.x/
  STRIP=/work/padavan-4.4/toolchain-mipsel/toolchain-4.4.x/bin/mipsel-linux-uclibc-strip

  all:
        #make ARCH=mips CROSS_COMPILE=$(CROSS) -C $(KERNEL) SUBDIRS=$(PWD) modules
        $(STRIP) $(PWD)/$(RT_DRV_NAME).ko
  clean:
        make -C $(KERNEL) SUBDIRS=$(PWD) clean
  ```

# Package Development

- Makefile examples
  - [Makefile project](trunk/libs/libpcre/Makefile) 
  - [CMake project](trunk/user/ttyd/Makefile)
- Compiling a single package (cd to `trunk` first)
  - build: `make libs/libpcre_only`
  - clean: `make libs/libpcre_clean`
  - romfs: `make libs/libpcre_romfs`

# Manuals

- Controlling GPIO and LEDs via sysfs
- How to use NAND RWFS partition
- How to use IPv6 NAT and fullcone NAT
- How to add new device support with device tree
