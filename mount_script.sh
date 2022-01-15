#!/bin/sh

mkdir /etc/Tableau_Data_Volume
mount /dev/nvme1n1 /etc/Tableau_Data_Volume
echo "/dev/nvme1n1 /etc/Tableau_Data_Volume xfs defaults 0 0" >> /etc/fstab