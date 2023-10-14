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
sudo apt install nfs-common -y
sudo mount ip_of_server:/path/to/remote/directory /path/to/local/directory

vi /etc/fastab 
 ip_of_server:/path/to/remote/directory /path/to/local/directory nfs defaults 0 0 

 
# Use Network Block devices
sudo apt install nbd-server -y

lsblk 
NAME                                                                    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
nvme0n1                                                                 259:0    0   100G  0 disk 
├─nvme0n1p1                                                             259:1    0  99.9G  0 part /
├─nvme0n1p14                                                            259:2    0     4M  0 part 
└─nvme0n1p15                                                            259:3    0   106M  0 part /boot/efi
nvme1n1                                                                 259:4    0    10G  0 disk 
├─nvme1n1p1                                                             259:11   0     4G  0 part /mnt1
├─nvme1n1p2                                                             259:12   0     4G  0 part /mnt2
└─nvme1n1p3                                                             259:13   0     2G  0 part 
nvme2n1                                                                 259:5    0    10G  0 disk 
nvme3n1                                                                 259:6    0   100G  0 disk 
nvme4n1                                                                 259:7    0    10G  0 disk

sudo mkdir /mnt2/test{1..10}

sudo vi /etc/nbd-server/config

# If you want to run everything as root rather than the nbd user, you
# may either say "root" in the two following lines, or remove them
# altogether. Do not remove the [generic] section, however.
        user = nbd
        group = nbd
        includedir = /etc/nbd-server/conf.d

# What follows are export definitions. You may create as much of them as
# you want, but the section header has to be unique.

# If you want to run everything as root rather than the nbd user, you
# may either say "root" in the two following lines, or remove them
# altogether. Do not remove the [generic] section, however.
#        user = nbd
#        group = nbd
        includedir = /etc/nbd-server/conf.d
        allowlist = true
# What follows are export definitions. You may create as much of them as
# you want, but the section header has to be unique.
[partition1]
  exportname = /dev/nvme1n1p2

sudo systemctl status nbd-server.service 
● nbd-server.service - LSB: Network Block Device server
     Loaded: loaded (/etc/init.d/nbd-server; generated)
     Active: active (exited) since Fri 2023-10-13 19:31:12 +04; 6min ago
       Docs: man:systemd-sysv-generator(8)
    Process: 342410 ExecStart=/etc/init.d/nbd-server start (code=exited, status=0/SUCCESS)
        CPU: 5ms

Oct 13 19:31:12 oslfcssrv systemd[1]: Starting LSB: Network Block Device server...
Oct 13 19:31:12 oslfcssrv nbd-server[342411]: Could not parse config file: The config file does not specify any exports
Oct 13 19:31:12 oslfcssrv nbd-server[342411]: No configured exports; quitting.
Oct 13 19:31:12 oslfcssrv nbd-server[342410]:  nbd-server.
Oct 13 19:31:12 oslfcssrv systemd[1]: Started LSB: Network Block Device server.
      
sudo systemctl restart nbd-server.service 

sudo systemctl status nbd-server.service 
● nbd-server.service - LSB: Network Block Device server
     Loaded: loaded (/etc/init.d/nbd-server; generated)
     Active: active (running) since Fri 2023-10-13 19:38:22 +04; 40s ago
       Docs: man:systemd-sysv-generator(8)
    Process: 343035 ExecStart=/etc/init.d/nbd-server start (code=exited, status=0/SUCCESS)
      Tasks: 1 (limit: 9247)
     Memory: 772.0K
        CPU: 468ms
     CGroup: /system.slice/nbd-server.service
             └─343037 /bin/nbd-server

Oct 13 19:38:22 oslfcssrv systemd[1]: Starting LSB: Network Block Device server...
Oct 13 19:38:22 oslfcssrv nbd-server[343035]:  nbd-server.
Oct 13 19:38:22 oslfcssrv systemd[1]: Started LSB: Network Block Device server.

# On the client side - attaching the remote block device
sudo apt install nbd-client -y
sudo modprobe nbd

sudo vi /etc/modules-load.d/modules.conf
nbd

# Open port 10809 on server
sudo nbd-client 3.28.241.128 -N partition1
Negotiation: ..size = 102288MB
Connected /dev/nbd0

sudo mkdir /mnt2
sudo mount /dev/nbd2 /mnt2
ls
lost+found  test  test1  test10  test2  test3  test4  test5  test6  test7  test8  test9
sudo touch test-from-client
ubuntu@nfsclient:/mnt2$ ls
lost+found  test  test-from-client  test1  test10  test2  test3  test4  test5  test6  test7  test8  test9
cd 
sudo umount /mnt2

lsblk
NAME         MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
nbd0          43:0    0  99.9G  0 disk 
nbd1          43:16   0     4G  0 disk 
nbd2          43:32   0     4G  0 disk

sudo nbd-client -d /dev/nbd2
sudo nbd-client -d /dev/nbd1
sudo nbd-client -d /dev/nbd0

lsblk
NAME         MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
nbd0          43:0    0     0B  0 disk 
nbd1          43:16   0     0B  0 disk 
nbd2          43:32   0     0B  0 disk

# To get the exported partitions shared from the server
ubuntu@nfsclient:~$ sudo nbd-client 3.28.241.128 -l
Negotiation: ..
partition1

# Storage Monitoring
iostat - Input Output statistics
pidstat - Process ID statistics

sudo apt install sysstat -y

ubuntu@oslfcssrv:~$ iostat 
Linux 6.2.0-1013-aws (oslfcssrv)        10/13/2023      _x86_64_        (2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           2.76    0.01    0.68    0.28    0.02   96.24

Device             tps    kB_read/s    kB_wrtn/s    kB_dscd/s    kB_read    kB_wrtn    kB_dscd
dm-0              0.00         0.00         0.00         0.00         20        176          0
dm-1              0.00         0.00         0.00         0.00          0          0          0
loop0             0.00         0.03         0.00         0.00       4276          0          0
loop1             0.00         0.00         0.00         0.00        664          0          0
loop2             0.00         0.02         0.00         0.00       2695          0          0
loop3             0.00         0.18         0.00         0.00      28788          0          0
loop4             0.00         0.00         0.00         0.00        686          0          0
loop5             0.13        16.63         0.40         0.00    2733234      66404          0
loop6             0.00         0.02         0.00         0.00       3674          0          0
loop7             0.00         0.11         0.00         0.00      17399          0          0
loop8             0.00         0.00         0.00         0.00         10          0          0
nvme0n1          16.27        22.08       206.76         0.00    3629218   33981161          0
nvme1n1           0.02         0.34         1.35         0.00      56203     221163          0
nvme2n1           0.00         0.01         0.00         0.00       1056          0          0
nvme3n1           0.00         0.01         0.00         0.00       1056          0          0
nvme4n1           0.00         0.01         0.00         0.00       1056          0          0

# Get starts for the last 10 seconds
iostat 10
Linux 6.2.0-1013-aws (oslfcssrv)        10/13/2023      _x86_64_        (2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           2.76    0.01    0.68    0.28    0.02   96.24

Device             tps    kB_read/s    kB_wrtn/s    kB_dscd/s    kB_read    kB_wrtn    kB_dscd
dm-0              0.00         0.00         0.00         0.00         20        176          0
dm-1              0.00         0.00         0.00         0.00          0          0          0
loop0             0.00         0.03         0.00         0.00       4276          0          0
loop1             0.00         0.00         0.00         0.00        664          0          0
loop2             0.00         0.02         0.00         0.00       2695          0          0
loop3             0.00         0.17         0.00         0.00      28788          0          0
loop4             0.00         0.00         0.00         0.00        686          0          0
loop5             0.13        16.64         0.40         0.00    2739378      66404          0
loop6             0.00         0.02         0.00         0.00       3674          0          0
loop7             0.00         0.11         0.00         0.00      17399          0          0
loop8             0.00         0.00         0.00         0.00         10          0          0
nvme0n1          16.27        22.08       206.58         0.00    3635362   34015501          0
nvme1n1           0.02         0.34         1.34         0.00      56203     221163          0
nvme2n1           0.00         0.01         0.00         0.00       1056          0          0
nvme3n1           0.00         0.01         0.00         0.00       1056          0          0
nvme4n1           0.00         0.01         0.00         0.00       1056          0          0

# Removing the cpu starts

iostat -d
iostat -d
Linux 6.2.0-1013-aws (oslfcssrv)        10/13/2023      _x86_64_        (2 CPU)

Device             tps    kB_read/s    kB_wrtn/s    kB_dscd/s    kB_read    kB_wrtn    kB_dscd
dm-0              0.00         0.00         0.00         0.00         20        176          0
dm-1              0.00         0.00         0.00         0.00          0          0          0
loop0             0.00         0.03         0.00         0.00       4276          0          0
loop1             0.00         0.00         0.00         0.00        664          0          0
loop2             0.00         0.02         0.00         0.00       2695          0          0
loop3             0.00         0.17         0.00         0.00      28788          0          0
loop4             0.00         0.00         0.00         0.00        686          0          0
loop5             0.13        16.63         0.40         0.00    2740402      66404          0
loop6             0.00         0.02         0.00         0.00       3674          0          0
loop7             0.00         0.11         0.00         0.00      17399          0          0
loop8             0.00         0.00         0.00         0.00         10          0          0
nvme0n1          16.27        22.07       206.58         0.00    3636386   34031965          0
nvme1n1           0.02         0.34         1.34         0.00      56203     221163          0
nvme2n1           0.00         0.01         0.00         0.00       1056          0          0
nvme3n1           0.00         0.01         0.00         0.00       1056          0          0
nvme4n1           0.00         0.01         0.00         0.00       1056          0          0


# To get the stats in human readable format

iostat -h
iostat -h
Linux 6.2.0-1013-aws (oslfcssrv)        10/13/2023      _x86_64_        (2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           2.8%    0.0%    0.7%    0.3%    0.0%   96.2%

      tps    kB_read/s    kB_wrtn/s    kB_dscd/s    kB_read    kB_wrtn    kB_dscd Device
     0.00         0.0k         0.0k         0.0k      20.0k     176.0k       0.0k dm-0
     0.00         0.0k         0.0k         0.0k       0.0k       0.0k       0.0k dm-1
     0.00         0.0k         0.0k         0.0k       4.2M       0.0k       0.0k loop0
     0.00         0.0k         0.0k         0.0k     664.0k       0.0k       0.0k loop1
     0.00         0.0k         0.0k         0.0k       2.6M       0.0k       0.0k loop2
     0.00         0.2k         0.0k         0.0k      28.1M       0.0k       0.0k loop3
     0.00         0.0k         0.0k         0.0k     686.0k       0.0k       0.0k loop4
     0.13        16.6k         0.4k         0.0k       2.6G      64.8M       0.0k loop5
     0.00         0.0k         0.0k         0.0k       3.6M       0.0k       0.0k loop6
     0.00         0.1k         0.0k         0.0k      17.0M       0.0k       0.0k loop7
     0.00         0.0k         0.0k         0.0k      10.0k       0.0k       0.0k loop8
    16.27        22.1k       206.6k         0.0k       3.5G      32.5G       0.0k nvme0n1
     0.02         0.3k         1.3k         0.0k      54.9M     216.0M       0.0k nvme1n1
     0.00         0.0k         0.0k         0.0k       1.0M       0.0k       0.0k nvme2n1
     0.00         0.0k         0.0k         0.0k       1.0M       0.0k       0.0k nvme3n1
     0.00         0.0k         0.0k         0.0k       1.0M       0.0k       0.0k nvme4n1

 sudo dd if=/dev/zero of=DELETEME bs=1 count=1000000 oflag=dsync &    

iostat
sudo pidstat -d  --human 1
Linux 6.2.0-1013-aws (nfsclient)        10/13/2023      _x86_64_        (2 CPU)

08:46:28 PM   UID       PID   kB_rd/s   kB_wr/s kB_ccwr/s iodelay  Command
08:46:29 PM     0      7358      0.00   2300.99      0.00       0  dd


Average:      UID       PID   kB_rd/s   kB_wr/s kB_ccwr/s iodelay  Command
Average:        0      7358      0.00   2300.99      0.00       0  dd 

ps 7358
    PID TTY      STAT   TIME COMMAND
   7358 pts/1    D      0:05 dd if=/dev/zero of=DELETEME bs=1 count=1000000 oflag=dsync

sudo kill 7358
[1]+  Terminated              sudo dd if=/dev/zero of=DELETEME bs=1 count=1000000 oflag=dsync

ostat -p nvme0n1 -h
Linux 6.2.0-1013-aws (nfsclient)        10/13/2023      _x86_64_        (2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.2%    0.0%    0.4%    3.0%    0.3%   96.0%

      tps    kB_read/s    kB_wrtn/s    kB_dscd/s    kB_read    kB_wrtn    kB_dscd Device
   111.32        75.1k       645.0k         0.0k     419.4M       3.5G       0.0k nvme0n1
   111.25        73.6k       645.0k         0.0k     411.2M       3.5G       0.0k nvme0n1p1
     0.01         0.1k         0.0k         0.0k     289.0k       0.0k       0.0k nvme0n1p14
     0.05         1.2k         0.0k         0.0k       6.9M       1.0k       0.0k nvme0n1p15

# Manage and Configure LVM(Logical Volume Manager) Storage
# On Redhat based systems LVM2
sudo dnf install lvm2
# Some abbreviation
# PV Physical Volumes
# VG Volume Group
# LV Logical Volume
# PE Physical Extent

# To see what physical volumes are available for us
sudo lvmdiskscan

/dev/nvme0n1    [      30.00 GiB] 
  /dev/loop0      [     <24.39 MiB] 
  /dev/nvme0n1p1  [      29.89 GiB] 
  /dev/loop1      [     <55.64 MiB] 
  /dev/nvme0n1p14 [       4.00 MiB] 
  /dev/loop2      [     <63.34 MiB] 
  /dev/nvme0n1p15 [     106.00 MiB] 
  /dev/loop3      [    <111.95 MiB] 
  /dev/loop4      [     <53.24 MiB] 
  0 disks
  9 partitions
  0 LVM physical volume whole disks
  0 LVM physical volumes

sudo pvcreate /dev/nvme2n1 /dev/nvme3n1
sudo pvs
  PV         VG                        Fmt  Attr PSize   PFree
  /dev/loop5 stack-volumes-lvmdriver-1 lvm2 a--  <30.00g 1.43g

sudo vgcreate my_volume /dev/nvme2n1 /dev/nvme3n1
sudo pvcreate /dev/nvme4n1
sudo vgextend my_volume /dev/nvme4n1
sudo vgs
sudo vgreduce my_volume /dev/nvme4n1
sudo pvremove /dev/nvme4n1
sudo lvcreate --size 2G --name partition1 my_volume
sudo lvcreate --size 6G --name partition2 my_volume
sudo lvs
sudo vgs
sudo lvresize --extents 100%VG my_volume/partition1
sudo lvresize --size 2G my_volume/partition1
sudo lvdisplay
sudo mkfs.xfs /dev/my_volume/partition1
sudo lvcreate --resize --size 8G --name partition1 my_volume

# Create and Configure Encrypted Storage In Linux using Cryptsetup and both Open and Plain Options
sudo cryptsetup --verify-passphrase open --type plain /dev/nvme4n1 mysecuredisk
Enter passphrase for /dev/nvme4n1: secure2023
Verify passphrase: secure2023

sudo mkfs.xfs /dev/mapper/mysecuredisk

meta-data=/dev/mapper/mysecuredisk isize=512    agcount=16, agsize=163840 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1    bigtime=0 inobtcount=0
data     =                       bsize=4096   blocks=2621440, imaxpct=25
         =                       sunit=1      swidth=1 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=1 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

sudo mount /dev/mapper/mysecuredisk /mnt1

sudo umount /mnt

findmnt -t ext4,xfs
TARGET  SOURCE                   FSTYPE OPTIONS
/       /dev/nvme0n1p1           ext4   rw,relatime,discard,errors=remount-ro
└─/mnt1 /dev/mapper/mysecuredisk xfs    rw,relatime,attr2,inode64,logbufs=8,logbsize=32k,sunit=8,swidth=8,noquota

sudo umount /mnt1
sudo cryptsetup close mysecuredisk

# Create and Configure Encrypted Storage In Linux using LUKSFormat
sudo cryptsetup luksFormat /dev/nvme4n1

WARNING!
========
This will overwrite data on /dev/nvme4n1 irrevocably.

Are you sure? (Type 'yes' in capital letters): YES
Enter passphrase for /dev/nvme4n1: secure2023
Verify passphrase: secure2023 

sudo cryptsetup luksChangeKey /dev/nvme4n1
Enter passphrase to be changed: 
Enter new passphrase: anothersecure2023
Verify passphrase: anothersecure2023

sudo cryptsetup open /dev/nvme4n1 mysecuredisk
Enter passphrase for /dev/nvme4n1:anothersecure2023

sudo mkfs.xfs /dev/mapper/mysecuredisk
sudo cryptsetup close /dev/mapper/mysecuredisk

sudo cryptsetup luksFormat /dev/nvme4n1p1
sudo cryptsetup luksFormat /dev/nvme4n1p2
sudo cryptsetup luksFormat /dev/nvme4n1p3
sudo cryptsetup luksFormat /dev/nvme4n1p4

# Create and Manage Raid(Redundant Array of Independent Disk)
Redundant - keep the same data in multiple places
Level 0 is not redundant
Level 1 array / mirrored array
Level 5 uses parity - a small backup used to rebuild lost information we can loss 1 disk and still be able to recover data
Level 6 uses 4 disks to create such an array, we can loss two disks and still be able to recover the data
Level 10/1+0 - its a combination of levle 1 and level 0

lsblk
NAME                                                                    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
nvme2n1                                                                 259:5    0    10G  0 disk 
nvme3n1                                                                 259:6    0   100G  0 disk 
nvme4n1                                                                 259:7    0    10G  0 disk

sudo mdadm --create /dev/md0 --level=0 --raid-devices=3 /dev/nvme2n1  /dev/nvme3n1 /dev/nvme4n1
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.

sudo mkfs.ext4 /dev/md0
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 31450368 4k blocks and 7864320 inodes
Filesystem UUID: 9ec1f86e-dc23-40b0-ba5c-78eaf5eface7
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
        4096000, 7962624, 11239424, 20480000, 23887872

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (131072 blocks): done
Writing superblocks and filesystem accounting information: done

sudo mdadm --stop /dev/md0
mdadm: stopped /dev/md0

sudo mdadm --zero-superblock  /dev/nvme2n1  /dev/nvme3n1 /dev/nvme4n1

# Adding a spare disk to an array
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/nvme2n1  /dev/nvme3n1 --spare-devices=1 /dev/nvme4n1
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: largest drive (/dev/nvme3n1) exceeds size (10476544K) by more than 1%
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.

# Another scenario of adding disks to an array
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/nvme2n1  /dev/nvme3n1
sudo mdadm --manage /dev/md0 --add /dev/nvme4n1

cat /proc/mdstat
Personalities : [raid0] [raid1] 
md0 : active raid1 nvme4n1[2](S) nvme3n1[1] nvme2n1[0]
      10476544 blocks super 1.2 [2/2] [UU]
      
unused devices: <none>

sudo mdadm --manage /dev/md0 --remove /dev/nvme4n1

cat /proc/mdstat
Personalities : [raid0] [raid1] 
md0 : active raid1 nvme3n1[1] nvme2n1[0]
      10476544 blocks super 1.2 [2/2] [UU]
      
unused devices: <none>

# Creating, managing and diagnose advanced file system permissions
touch file{1..3}

ls -l
total 32
-rw-rw-r--. 1 timeline timeline     0 Oct 14 13:26 file1
-rw-rw-r--. 1 timeline timeline     0 Oct 14 13:26 file2
-rw-rw-r--. 1 timeline timeline     0 Oct 14 13:26 file3

echo "This is the file content" > examplefile
sudo groupadd ftp
sudo useradd adm -g ftp
sudo chown adm:ftp examplefile

ls -l
rw-rw-r--. 1 adm      ftp         25 Oct 14 13:29 examplefile

id
uid=1000(timeline) gid=1000(timeline) groups=1000(timeline)

echo "This is the NEW content" > examplefile 
bash: examplefile: Permission denied

cat examplefile
This is the file content

# Using set file access control list(setfacl)
sudo setfacl --modify user:timeline:rw examplefile

echo "This is the NEW content" >> examplefile 
cat examplefile
This is the file content
This is the NEW content

# To see files with ACL 
ls -l  - will show the file with a plus mark
-rw-rw-r--+ 1 adm      ftp         49 Oct 14 13:39 examplefile

getfacl examplefile
# file: examplefile
# owner: adm
# group: ftp
user::rw-
user:timeline:rw-
group::rw-
mask::rw-
other::r--

# Modifying the mask
sudo setfacl --modify mask:r examplefile

getfacl examplefile
# file: examplefile
# owner: adm
# group: ftp
user::rw-
user:timeline:rw-               #effective:r--
group::rw-                      #effective:r--
mask::r--
other::r--

# To let any user in the group to read and write the file
sudo setfacl --modify group:wheel:rw examplefile

# To deny permissions to a specific user
sudo setfacl --modify user:adm:--- examplefile

# To remove acl for a specific user or group
sudo setfacl --remove user:adm examplefile
sudo setfacl --remove group:wheel examplefile
sudo setfacl --recursive -m user:aron:rwx exampleDir_plus_subDirs_and_files
sudo setfacl --recursive --modify user:adm:rwx exampleDir_plus_subDirs_and_files
sudo setfacl --recursive  --remove user:adm:exampleDir_plus_subDirs_and_files

# Append only and Immutable Attribute Options
echo "This is old content" > newfile
sudo chattr +a newfile
echo "Replace existing Content" > newfile
newfile: Operation not permitted

echo "Instead of replace existing Content, let's append it" >? newfile

cat newfile 
"This is old content"
"Instead of replace existing Content, let's append it"

# Remove the attribute
sudo chattr -a newfile

# Add immutability to a file and freez it no OS user including root can do anything on the file
sudo chattr +i newfile

# Check immutability in a file
sudo lsattr newfile
----i---------e----- newfile

sudo chattr -i newfile

# Setup user and group disk quotas for filesystems
sudo dnf install quota -y
sudo apt install quota -y

# Choosing file systems where we want to enforce quotas - enable quotas for users(usrquota) and groups(grpquota) on XFS file system
sudo vi /etc/fstab
/dev/vdb1 /mybackups xfs ro,noexec 0 2
/dev/vdb1 /mybackups xfs defaults,usrquota,grpquota 0 2
sudo systemctl reboot

# Choosing file systems where we want to enforce quotas - enable quotas for users(usrquota) and groups(grpquota) on ext4 file system
sudo vi /etc/fstab
/dev/vdb1 /mybackups ext4 ro,noexec 0 2
/dev/vdb1 /mybackups ext4 defaults,usrquota,grpquota 0 2
sudo xfs_quota -x -c 'limit bsoft=100m bhard=500m john' /mybackups/
sudo quotacheck --create-files --user --group /dev/vdb1
ls
aquota.group aquota.user
sudo quotaon  /mybackups
sudo systemctl reboot

# Example of managing quotas
sudo mkdir /mybackups/cedric
sudo chown cedric:cedric /mybackups/cedric/
fallocate --length 100M /mybackups/cedric/100Mfile

# 
fallocate --length 60M /mybackups/cedric/60Mfile

sudo quota --user cedric
sudo edquota --user cedric

# Add Grace Period on a limit of quota
sudo --quota --edit-period

# For group

sudo quota --group adm
sudo edquota --group adm










