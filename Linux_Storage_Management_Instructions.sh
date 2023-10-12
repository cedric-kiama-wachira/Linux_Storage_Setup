#!/bin/bash

 sudo lsblk
NAME                                                                    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0                                                                     7:0    0  24.6M  1 loop /snap/amazon-ssm-agent/7528
loop1                                                                     7:1    0  55.7M  1 loop /snap/core18/2790
loop2                                                                     7:2    0  63.5M  1 loop /snap/core20/2015
loop3                                                                     7:3    0  40.8M  1 loop /snap/snapd/20092
loop4                                                                     7:4    0 111.9M  1 loop /snap/lxd/24322
loop5                                                                     7:5    0    30G  0 loop 
├─stack--volumes--lvmdriver--1-stack--volumes--lvmdriver--1--pool_tmeta 253:0    0    32M  0 lvm  
│ └─stack--volumes--lvmdriver--1-stack--volumes--lvmdriver--1--pool     253:2    0  28.5G  0 lvm  
└─stack--volumes--lvmdriver--1-stack--volumes--lvmdriver--1--pool_tdata 253:1    0  28.5G  0 lvm  
  └─stack--volumes--lvmdriver--1-stack--volumes--lvmdriver--1--pool     253:2    0  28.5G  0 lvm  
loop6                                                                     7:6    0  24.9M  1 loop /snap/amazon-ssm-agent/7628
loop7                                                                     7:7    0  40.9M  1 loop /snap/snapd/20290
nvme0n1                                                                 259:0    0   100G  0 disk 
├─nvme0n1p1                                                             259:1    0  99.9G  0 part /
├─nvme0n1p14                                                            259:2    0     4M  0 part 
└─nvme0n1p15                                                            259:3    0   106M  0 part /boot/efi
nvme1n1                                                                 259:4    0    10G  0 disk 
nvme2n1                                                                 259:5    0    10G  0 disk 
nvme3n1                                                                 259:6    0   100G  0 disk 
nvme4n1                                                                 259:7    0    10G  0 disk 

sudo fdisk --list /dev/nvme0n1

Disk /dev/nvme0n1: 100 GiB, 107374182400 bytes, 209715200 sectors
Disk model: Amazon Elastic Block Store              
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: B3F8B8BC-6206-4B08-8022-448584C72D0D

Device           Start       End   Sectors  Size Type
/dev/nvme0n1p1  227328 209715166 209487839 99.9G Linux filesystem
/dev/nvme0n1p14   2048     10239      8192    4M BIOS boot
/dev/nvme0n1p15  10240    227327    217088  106M EFI System

Partition table entries are not in disk order.

Start sector no = 2048
Sector size     = 512

2048 * 512 = 1048576 bytes = 1 MB
# This means that this partition has 1MB storage space being used before it

nvme1n1                                                                 259:4    0    10G  0 disk 
nvme2n1                                                                 259:5    0    10G  0 disk 
nvme3n1                                                                 259:6    0   100G  0 disk 
nvme4n1

sudo cfdisk  /dev/nvme1n1

sudo fdisk --list /dev/nvme1n1

Disk /dev/nvme1n1: 10 GiB, 10737418240 bytes, 20971520 sectors
Disk model: Amazon Elastic Block Store              
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 5F006836-9F25-7C4B-ABF9-CE772C1A9874

Device            Start      End Sectors Size Type
/dev/nvme1n1p1     2048  8390655 8388608   4G Linux filesystem
/dev/nvme1n1p2  8390656 16779263 8388608   4G Linux filesystem
/dev/nvme1n1p3 16779264 20971486 4192223   2G Linux swap


# Create and manage a swap space using partition
swapon --show

sudo mkswap /dev/nvme1n1p3

Setting up swapspace version 1, size = 2 GiB (2146410496 bytes)
no label, UUID=b70fc4fb-9953-4244-9d34-de124fba1c86

swapon --show

NAME           TYPE      SIZE USED PRIO
/dev/nvme1n1p3 partition   2G   0B   -2

sudo swapon --verbose /dev/nvme1n1p3

swapon: /dev/nvme1n1p3: found signature [pagesize=4096, signature=swap]
swapon: /dev/nvme1n1p3: pagesize=4096, swapsize=2146414592, devsize=2146418176
swapon /dev/nvme1n1p3

# Creat a swap space using a file

sudo swapoff /dev/nvme1n1p3

sudo dd if=/dev/zero of=/swap2 bs=1M count=2048 status=progress

sudo chmod 0600 /swap2

sudo mkswap /swap2
mkswap: /swap2: warning: wiping old swap signature.
Setting up swapspace version 1, size = 2 GiB (2147479552 bytes)
no label, UUID=8f3c4980-1320-457d-a8b1-7307b1d83cf7

mount 

sudo swapon --show

NAME   TYPE SIZE USED PRIO
/swap2 file   2G   0B   -2

# Increase the size by one GB
sudo dd if=/dev/zero of=/swap2 bs=1M count=1024 oflag=append conv=notrunc
sudo swapoff /swap2
sudo mkswap /swap2
sudo swapon /swap2

# Create and configure a file system on a new partition
sudo file -s /dev/nvme1n1

sudo mkfs.xfs -L "Backup_Vol2" -i size=1024 /dev/nvme1n1p1
sudo mkfs.ext4  -L "Backup_Vol" -N 500000 /dev/nvme1n1p2

sudo xfs_admin -l /dev/nvme1n1p1
sudo xfs_admin -L "FirstFs"  /dev/nvme1n1p1 

sudo tune2fs -l  /dev/nvme1n1p2
sudo tune2fs -L "SecondFs"  /dev/nvme1n1p2

sudo file -s /dev/nvme1n2

# Configure a system to mount a file system at or during boot time
sudo mkdir /mnt1
sudo mkdir /mnt2
ls /mnt1
ls /mnt2
sudo mount /dev/nvme1n1p1 /mnt1
sudo mount /dev/nvme1n1p2 /mnt2

sudo cp /etc/fstab /etc/fstab.original
sudo vi /etc/fstab
LABEL=FirstFs   /mnt1   xfs     defaults        0 2
LABEL=SecondFs  /mnt2   ext4    defaults        0 2
sudo systemctl daemon-reload
sudo vi /etc/fstab
/swap2  none    swap    defaults        0 0

# On Demand mounting!
sudo dnf install -y autofs
sudo apt install -y autofs
sudo systemctl enable autofs.service
sudo systemctl start autofs.service
sudo dnf install nfs-util -y
sudo apt install nfs-server -y

sudo vi /etc/exports
/etc 127.0.0.1(ro) 

sudo vi /etc/auto.master
/shares/ /etc/auto.shares --timeout=400

sudo vi /etc/auto.shares
mynetworkshares -fstype=auto 127.0.0.1:/etc
mynetworkshares -fstype=auto www.slfcssrv.com:/etc
mynetworkshares -fstype=nfs4 127.0.0.1:/etc
mynetworkshares -fstype=auto,ro 127.0.0.1:/etc

sudo systemctl reload autofs

sudo vi /etc/auto.master
/- /etc/auto.shares --timeout=400
sudo systemctl reload autofs
sudo vi /etc/auto.shares
/mynetworkshares -fstype=auto 127.0.0.1:/etc

# Evaluate and compare the basic Filesystem Features and Options
findmnt
findmnt -t xfs,ext4
TARGET  SOURCE         FSTYPE OPTIONS
/       /dev/nvme0n1p1 ext4   rw,relatime,discard,errors=remount-ro
├─/mnt1 /dev/nvme1n1p1 xfs    rw,relatime,attr2,inode64,logbufs=8,logbsize=32k,sunit=8,swidth=8,noquota
└─/mnt2 /dev/nvme1n1p2 ext4   rw,relatime

sudo umount /mnt1
sudo mount -o ro /dev/nvme1n1p1 /mnt1
findmnt -t xfs,ext4

TARGET  SOURCE         FSTYPE OPTIONS
/       /dev/nvme0n1p1 ext4   rw,relatime,discard,errors=remount-ro
├─/mnt1 /dev/nvme1n1p1 xfs    ro,relatime,attr2,inode64,logbufs=8,logbsize=32k,sunit=8,swidth=8,noquota
└─/mnt2 /dev/nvme1n1p2 ext4   rw,relatime

sudo sudo umount /mnt2
sudo mount -o ro,noexec,nosuid /dev/nvme1n1p2 /mnt2
sudo mount -o remount,rw,noexec,nosuid /dev/nvme1n1p2 /mnt2

findmnt -t xfs,ext4
TARGET  SOURCE         FSTYPE OPTIONS
/       /dev/nvme0n1p1 ext4   rw,relatime,discard,errors=remount-ro
├─/mnt1 /dev/nvme1n1p1 xfs    ro,relatime,attr2,inode64,logbufs=8,logbsize=32k,sunit=8,swidth=8,noquota
└─/mnt2 /dev/nvme1n1p2 ext4   rw,nosuid,noexec,relatim

sudo umount /mnt1
sudo mount -o allocsize=64k /dev/nvme1n1p1 /mnt1
indmnt -t xfs,ext4
TARGET  SOURCE         FSTYPE OPTIONS
/       /dev/nvme0n1p1 ext4   rw,relatime,discard,errors=remount-ro
├─/mnt1 /dev/nvme1n1p1 xfs    rw,relatime,attr2,inode64,allocsize=64k,logbufs=8,logbsize=32k,sunit=8,swidth=8,noquota
└─/mnt2 /dev/nvme1n1p2 ext4   rw,nosuid,noexec,relatime

sudo vi /etc/fstab
/dev/nvme1n1p1  /mnt1  xfs ro,noexec 0 2

# Use Remote FIle System NFS - Server configurations
sudo apt install nfs-kernel-server -y

sudo vi /etc/exports
/etc 127.0.0.1(ro)

sudo exportfs -r
exportfs: /etc/exports [2]: Neither 'subtree_check' or 'no_subtree_check' specified for export "127.0.0.1:/etc".
  Assuming default behaviour ('no_subtree_check').
  NOTE: this default has changed since nfs-utils version 1.0.x

sudo exportfs -v
/etc            127.0.0.1(sync,wdelay,hide,no_subtree_check,sec=sys,ro,secure,root_squash,no_all_squash)
/etc            CIDR(sync,wdelay,hide,no_subtree_check,sec=sys,ro,secure,root_squash,no_all_squash)
/etc            *(sync,wdelay,hide,no_subtree_check,sec=sys,ro,secure,root_squash,no_all_squash)

# Use Remote FIle System NFS - client side configurations
sudo apt install nfs-common
sudo mount ip_of_server:/path/to/remote/directory /path/to/local/directory

vi /etc/fastab 
 ip_of_server:/path/to/remote/directory /path/to/local/directory nfs defaults 0 0 

 

