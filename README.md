# Synok3s
## K3S on Synology ds218

Based on: https://medium.com/@marco.mezzaro/k3s-on-synology-what-if-it-works-e980b4b09fcb

## Compile missing kernel modules

download from sourceforge kernel source and dsm toolchain (my ds218 has rtd129x)
- https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/22259branch/rtd1296-source/
- https://sourceforge.net/projects/dsgpl/files/DSM%206.2.2%20Tool%20Chains/Realtek%20RTD129x%20Linux%204.4.59/

from a brand new debian system:
create a folder:

```
sudo apt update
sudo apt install wget 
mkdir -p ~/dsm/archives 
cd ~/dsm
```
put:
- rtd1296-gcc494_glibc220_armv8-GPL.txz
- linux-4.4.x.txz

install all build deps:

```
sudo apt-get install mc make gcc build-essential kernel-wedge libncurses5 libncurses5-dev libelf-dev binutils-dev kexec-tools makedumpfile fakeroot lzma bc libssl-dev
```

extract and move txz archives away:

```
tar Jxvf linux-4.4.x.txz 
tar Jxvf rtd1296-gcc494_glibc220_armv8-GPL.txz 
mv linux-4.4.x.txz rtd1296-gcc494_glibc220_armv8-GPL.txz archives/
```

enter in kernel source folder and copy kernel config in place

```
cd linux-4.4.x/
cp synoconfigs/rtd1296 .config
```

export magic number version (if not exported could cause headaches!) and alias for dsm make

```
export LOCALVERSION=+1
alias dsm6make='make ARCH=arm64 CROSS_COMPILE=~/dsm/aarch64-unknown-linux-gnueabi/bin/aarch64-unknown-linux-gnueabi-'
```

config the kernel, select all modules for iptables and make modules:

```
dsm6make menuconfig
dsm6make modules
find . -iname "*.ko" -type f
```

copy the kernel modules in /lib/modules on synology machine. `DO NOT OVERWRITE` already present modules.
use insmod command to load.
for troubleshooting check dmesg for errors.
