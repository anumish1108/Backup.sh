#!/bin/bash
mkdir -m 755 /tmp/`hostname`-backup-28-02-2023
cd /tmp/`hostname`-backup-28-02-2023
date > date.before
cp /var/spool/cron/root /tmp/rootcron
netstat -nr>netstat.before
uptime > uptime.before
umask>Umask.before
crontab -l > cron.before
 
rpm -qa > rpm.before
 
vgs > vgs.before
 
pvscan > pvscan.before
 
vgscan > vgscan.before
 
lvs > lvs.before
 
lvscan > lvscan.before
 
vgs > vgs.before
 
pvdisplay > pvdisplay.before
 
vgdisplay -v > vgdisplay.before
 
lvdisplay -v > lvdisplay.before
 
lvmdiskscan > lvmdiskscan.before
 
ls -lrtha /dev/vg > DEV_VG.before
 
lsmod |grep qla > QLA.DRIVER
 
cat /proc/mdstat > mdstat.before
 
cat /etc/mdadm.conf > mdadm.conf.before
 
/opt/DynamicLinkManager/bin/dlnkmgr view -drv > drv.before
 
/opt/DynamicLinkManager/bin/dlnkmgr view -path > path.before
 
/opt/DynamicLinkManager/bin/dlnkmgr view -lu > lu.before
 
/opt/DynamicLinkManager/bin/dlnkmgr view -sys > sys.before
 
df -Ph > df-Ph.before
 
df -Th > df-h.before
 
dkms status > dkms.before
 
dmidecode > dmidecode.before
 
lspci > lspci.before
 
dmesg > dmesg.before
 
cat /proc/meminfo > meminfo.before
 
free -m > free.before
 
cat /proc/mtrr > mtrr.before
 
ifconfig -a > ifconfig.before
 
rpm -qi HDLM > HDLM.before
 
cat /etc/fstab > fstab.before
 
cat /etc/fstab > etcfstab.before
 
fdisk -l > fdisk-l.before
 
uname -a > uname.before
 
cat /etc/grub.conf > grub.before
 
mount > mount.before
 
cat /proc/mounts > mounts.before
 
cat /etc/modprobe.conf > modprobe.before
 
cat /etc/redhat-release > release.before
 
cat /proc/cpuinfo > cpuinfo.before
 
cat /etc/grub.conf > grub.before
 
pvs > pvs.before
 
ps -ef | grep vcs > vcs.before
 
chkconfig --list > chkconfig.before
 
/opt/VRTSvcs/bin/hastatus -sum > hastatus.before
 
vxdisk list > vxdisk.before
 
vxdg list > vxdg.before
 
vxprint > vxprint.before
 
vxprint -Aht > vxprint.Aht.before
 
cat /etc/llttab  > lltab.before
 
vgdisplay > vg.before
 
lvdisplay > lv.before
 
pvdisplay > pv.before
 
pvscan > pvscan.before
 
lvscan > lvscan.before
 
cat /etc/exports > exports.before
 
mii-tool > mii_tool.before
 
cat /etc/sysconfig/network-scripts/ifcfg-bond0 > bond0.before
 
cat /etc/sysconfig/network-scripts/ifcfg-bond1 > bond1.before
 
cat /etc/sysconfig/network-scripts/ifcfg-eth0  > eth0.before
 
cat /etc/sysconfig/network-scripts/ifcfg-eth1  > eth1.before
 
cat /etc/sysconfig/network-scripts/ifcfg-eth2  > eth2.before
 
cat /etc/sysconfig/network-scripts/ifcfg-eth3  > eth3.before
 
cat /etc/sysconfig/network-scripts/ifcfg-eth4  > eth4.before
 
cat /etc/sysconfig/network-scripts/ifcfg-eth5  > eth5.before
 
scp -pr /tmp/`hostname`-backup-28-02-2023 root@10.20.238.239:/tmp/ 
 
