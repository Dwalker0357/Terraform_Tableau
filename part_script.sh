#!/bin/sh

hdd="/dev/nvme1n1"
for i in $hdd;do
echo "n
p
1
w
"|fdisk $i;mkfs.ext3 $i;done