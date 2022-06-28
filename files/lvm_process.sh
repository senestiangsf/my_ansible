#!/bin/bash
for disk in nvme{0..4}n1 sd{a..z} sda{a..g}
do
  wipefs -a /dev/${disk}
done

#Create the volume groups for RocksDB (for SATA disks) on the 2.9T NVMe disks and WAL (for both SSD and SATA) on the 349,3G NVMe disks
vgcreate wal-vg1 /dev/nvme0n1
vgcreate wal-vg2 /dev/nvme4n1
vgcreate db-vg1 /dev/nvme1n1
vgcreate db-vg2 /dev/nvme2n1
vgcreate db-vg3 /dev/nvme3n1

#Create the volume groups for data on each SATA disk
for disk in sd{a..z} sda{a..g}
do
  vgcreate data-vg-${disk} /dev/${disk}
done

#Next, we check the extents of the volume group and calculate the appropriate number of extents for each volume that will hold RocksDB and WAL. We want to split traffic as equally as possibly and note that RocksDB for SSD disk will be colocated with the the data.
for disk in sda sd{d..l}
do
  lvcreate -y -n db-lv-${disk} -L 64G db-vg1
done

for disk in sdb sd{m..w}
do
  lvcreate -y -n db-lv-${disk} -L 64G db-vg2
done

for disk in sdc sd{x..z} sda{a..g}
do
  lvcreate -y -n db-lv-${disk} -L 64G db-vg3
done

for disk in sda sdb sd{d..r}
do
  lvcreate -y -n wal-lv-${disk} -l 5260 wal-vg1
done

for disk in sdc sd{s..z} sda{a..g}
do
  lvcreate -y -n wal-lv-${disk} -l 5260 wal-vg2
done

#Now we create the data logical volumes for the SATA disks
for disk in sd{a..z} sda{a..g}
do
  lvcreate -y -n data-lv-${disk} -l 100%FREE data-vg-${disk}
done
