#!/bin/bash

GREEN='\033[01;32m'
NONE='\033[00m'
YELLOW='\033[01;33m'
RED='\033[01;31m'
BLUE='\033[01;34m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
hclog="/tmp/healthcheck_`hostname`_`date +%d%m%Y`"
>hclog
echo -e "${BLUE} ====================================== Healthcheck Status ========================================${NONE}"

echo "Hostname= `hostname`"
echo "Host Arch= `arch`"
echo "Host Kernel= `uname -r`"
echo "Host Physical Memory= `cat /proc/meminfo|grep MemTotal|awk {'print $2''$3'}`"
echo "Host SWAP Memory= `cat /proc/meminfo|grep SwapTotal|awk {'print $2''$3'}`"
echo "Total Physical CPUs= `cat /proc/cpuinfo|grep "physical id"|sort|uniq|wc -l`"
echo "Physical CPU cores= `cat /proc/cpuinfo|grep "cpu cores"|sort|uniq|awk {'print $4'}`"
echo "Physical CPU siblings= `cat /proc/cpuinfo|grep "siblings"|sort|uniq|awk {'print $3'}`"
echo "Total System CPUs= `cat /proc/cpuinfo|grep processor|sort|uniq|wc -l`"
echo "CPU model= `cat /proc/cpuinfo|grep "model name"|sort|uniq|awk {'print $4$5$6$7$8$9$10$11$12'}`"

echo "Hostname= `hostname`" >> $hclog
echo "Host Arch= `arch`" >> $hclog
echo "Host Kernel= `uname -r`" >> $hclog
echo "Host Physical Memory= `cat /proc/meminfo|grep MemTotal|awk {'print $2''$3'}`" >> $hclog
echo "Host SWAP Memory= `cat /proc/meminfo|grep SwapTotal|awk {'print $2''$3'}`" >> $hclog
echo "Total Physical CPUs= `cat /proc/cpuinfo|grep "physical id"|sort|uniq|wc -l`" >> $hclog
echo "Physical CPU cores= `cat /proc/cpuinfo|grep "cpu cores"|sort|uniq|awk {'print $4'}`" >> $hclog
echo "Physical CPU siblings= `cat /proc/cpuinfo|grep "siblings"|sort|uniq|awk {'print $3'}`" >> $hclog
echo "Total System CPUs= `cat /proc/cpuinfo|grep processor|sort|uniq|wc -l`" >> $hclog
echo "CPU model= `cat /proc/cpuinfo|grep "model name"|sort|uniq|awk {'print $4$5$6$7$8$9$10$11$12'}`" >> $hclog

echo ""
echo "==================================== Memory USAGE start ===================================="
sar -r 1 1|grep kbmemfree; sar -r 1 3|grep Average
echo ""
free
echo "==================================== Memory USAGE end    ===================================="

echo ""
echo "==============HEALTCHECK STATUS as below ===============" >> $hclog
echo "==================================== CPU USAGE start     ===================================="
sar -P ALL 1 3|grep Average |grep all 
sar -P ALL 1 3|grep Average |grep all > /tmp/lhsar
echo -e "Current CPU %idle value is  ${BLUE} ${BOLD} `cat /tmp/lhsar |grep Average |awk '{print $7}' |cut -d "." -f1` ${NONE}" >> $hclog
sleep 5

echo "==================================== CPU USAGE end       ===================================="
echo ""
echo "==================================== CPU load avg start  ====================================="
sar -q 1 5

sleep 5

if [ `uptime |awk '{print $10}' | cut -d "." -f1` -lt 5 ]; then
        echo -e "Current Load Avg of server is ${GREEN}${BOLD} Below 5${NONE}" >> $hclog
else
        echo -e "Current Load Avg of server is ${RED}${BOLD} Above 5${NONE}" >> $hclog
fi

echo "==================================== CPU load avg end    ====================================="
echo ""
echo "==================================== Mounted filesystem start ================================="
fstab_check_fs=$(cat /etc/fstab | egrep -v '#|devpts|auto|/media/|swap|/proc|/sys|^$'|awk '{print $2}'|wc -l)
current_df=$(df -Ph | egrep -v 'Filesyste'|awk '{print $NF}'|wc -l)
NFSMOUNT=`cat /etc/fstab |grep -v grep |grep ':' |grep -v '#'| wc -l`
NFSMOUNTED=`cat /proc/mounts |grep -v grep |grep ':'|wc -l`
vcscheck=`ps -ef | grep vcs | grep -v grep|wc -l`


NFScheck()
{
        if [ $NFSMOUNT == $NFSMOUNTED ] ;then
                        echo -e "${GREEN}${BOLD}  Mounted Filesystems are OK ${NONE}"
                        echo -e "Mounted Filesystem  - All are mounted ${GREEN}${BOLD} OK ${NONE}" >> $hclog
        else
                NFScheckBKP=$(cat /usr/semasupp/log/CHKDF.$[`date +%y%m%d`-1].org | grep ':'|grep -v '^$'|wc -l)
                if [ $NFScheckBKP == $NFSMOUNTED ] ; then
                                echo -e " ${GREEN}${BOLD}  Mounted Filesystems are OK ${NONE}"
                                echo -e "Mounted Filesystems - All are mounted ${GREEN}${BOLD} OK ${NONE}" >> $hclog
                          else
                                echo -e " ${RED}${BOLD}  Mounted Filesystems are NOT OK ${NONE}"
                                echo -e " Mounted Filesystems - All are ${RED}${BOLD} NOT OK ${NONE}" >> $hclog
                fi
        fi
}
mountpintcheck()
{
if [ $vcscheck -ge '3' ]; then
        if [ $fstab_check_fs == $current_df ] || [ $chkdf_check == $current_df ]; then
                NFScheck
        else
                echo -e "${RED}${BOLD}  Mounted Filesystems are NOT OK ${NONE}"
                echo -e "Mounted Filesystems - All are ${RED}${BOLD} NOT OK ${NONE}" >> $hclog

        fi
else
        if [ $fstab_check_fs == $current_df ] ; then
                NFScheck
        else
                if [ $chkdf_check == $current_df ]; then
                        NFScheck
                else
                        echo -e "${RED}${BOLD}  Mounted Filesystems are NOT OK ${NONE}"
                        echo -e "  Mounted Filesystems - All are ${RED}${BOLD}  NOT OK ${NONE}" >> $hclog

                fi
        fi
fi
}



if [ -f /usr/semasupp/log/CHKDF.$[`date +%y%m%d`-1] ]; then
    chkdf_check=$(cat /usr/semasupp/log/CHKDF.$[`date +%y%m%d`-1] | egrep -v '===|without_NFS|^$' | awk '{print $1}' | sort | uniq |wc -l)
        mountpintcheck
elif [ -f /usr/semasupp/log/CHKDF. ]; then
    chkdf_check=$(cat /usr/semasupp/log/CHKDF. | egrep -v '===|without_NFS|^$' | awk '{print $1}' | sort | uniq |wc -l)
        mountpintcheck
else
        echo -e "${RED}${BOLD}  Mounted Filesystems are NOT OK,CHKDF.$[`date +%y%m%d`-1] and CHKDF. file does not exist. Please verify manually ${NONE}"
        echo -e "Mounted Filesystems - All are ${RED}${BOLD} NOT OK,CHKDF.$[`date +%y%m%d`-1] and CHKDF. file does not exist. Please verify manually ${NONE}" >> $hclog

fi
echo "==================================== Mounted filesystem end ======================================="


echo "==================================== FS USAGE start         ======================================="
rm -f /tmp/fs_thresh
rm -f /tmp/fs_details
df -Ph |grep -v Mounted |grep -v mnt |awk '{print $6}' > /tmp/fs_details
for i in `cat /tmp/fs_details`; do
if [ `df -Ph $i |grep -v Use | column -t  |awk '{ print $5 }' | sed 's/%//'` -gt 80 ]; then
        echo -e $i " is Above threshold" >> /tmp/fs_thresh
else
        echo $i " below threshold" >> /tmp/fs_thresh
fi
done

if [ `cat /tmp/fs_thresh |grep Above -w|grep -v grep |wc -l` -gt 0 ]; then
        echo -e "${RED}${BOLD} `cat /tmp/fs_thresh |grep Above |awk '{print $1 "\t \t \t" $2 " "$3 " " $4 }'` ${NONE}"
        echo -e "${RED}${BOLD} `cat /tmp/fs_thresh |grep Above |awk '{print $1 "\t" $2 " "$3 " " $4 }'` ${NONE}" >> $hclog
else
        echo -e " ${GREEN}${BOLD} All filesystems are below threshold ${NONE}"
        echo -e "All filesystems are ${GREEN}${BOLD} Below ${NONE} threshold " >> $hclog
fi
echo "==================================== FS USAGE end            ======================================"
echo ""
echo "==================================== Inode USAGE start       ======================================="
for inod in `cat /tmp/fs_details`; do
if [ `df -Pi $inod |grep -v Use | column -t  |awk '{ print $5}' | sed 's/%//'` -gt 80 ]; then
        echo $inod  " inode is Above threshold" >> /tmp/fs_thresh
else
        echo $inod " inode is below threshold" >> /tmp/fs_thresh
fi
done

if [ `cat /tmp/fs_thresh |grep inode|grep Above -w |grep -v grep |wc -l` -gt 0 ]; then
        echo -e "${RED}${BOLD} `cat /tmp/fs_thresh |grep inode|grep Above -w|awk '{print $1 "\t \t \t" $2 " "$3 " " $4 " " $5 }'` ${NONE}"
        echo -e "${RED}${BOLD} `cat /tmp/fs_thresh |grep inode|grep Above -w|awk '{print $1 "\t \t \t" $2 " "$3 " " $4 " " $5 }'` ${NONE}" >> $hclog
else
        echo -e "${GREEN}${BOLD}  Inode of All filesystems are below threshold ${NONE}"
        echo -e "Inode of All filesystems are ${GREEN}${BOLD} Below ${NONE} threshold" >> $hclog
fi
echo ""
echo "==================================== Inode USAGE end        ========================================="
echo ""
echo "==================================== Filesystem status start========================================="

if [ `cat /proc/mounts |awk '{print $1,$3,$4}'|sed -s 's/,data=ordered//;s/,nosuid//' |grep ro -w |wc -l` != 0 ]; then
        echo -e "${RED}============================Below Filesystem/s is/are in RO mode==================================${NONE}"
        echo -e " ${RED}${BOLD} `cat /proc/mounts |grep -v mnt |awk '{print $2,$3,$4}'|sed -s 's/,data=ordered//;s/,nosuid//' |grep ro -w` ${NONE}"
        echo -e "${RED}============================Below Filesystem/s is/are in RO mode==================================${NONE}" >> $hclog
        echo -e " ${RED}${BOLD} `cat /proc/mounts |grep -v mnt |awk '{print $2,$3,$4}'|sed -s 's/,data=ordered//;s/,nosuid//' |grep ro -w` ${NONE}" >> $hclog
else
        echo -e " ${GREEN}${BOLD} All Filesysetm are in read-write mode ${NONE}"
        echo -e "All Filesysetm are in  - ${GREEN}${BOLD} read-write ${NONE} mode" >> $hclog
fi

echo "==================================== Filesystem status end   ========================================"

echo "==================================== runque details start    ========================================"
vmstat 1 20
echo "****************** CPU Usage ******************"

echo "Remark : Normal Benchmark (Total System Usage): below 90%"
echo "Remark :Normal Benchmark (User Usage): below 90%"
echo "Remark : Benchmark (Block Queue): below 50"
echo "Remark : Benchmark (Run Queue): below 100"
echo "If Block and/or Run queue higher than benchmark, start separate session to monitor those values."

echo "==================================== runque details end      ========================================="
echo " "
echo "==================================== HBA & MULTIPATH STATS start  ===================================="
VXVM_check=`rpm -qa|grep -v grep|grep  VRTSvxvm|wc -l`
HDLM_check=`rpm -qa|grep -v grep| grep HDLM |wc -l`
if [ $HDLM_check != 0 ]; then
        echo -e "${GREEN}${BOLD}  Server is using HDLM for multipathing ${NONE}"
        if [ -d /proc/scsi/qla2xxx ]; then
                portstat=`grep "loop state" /proc/scsi/qla2*/* |grep READY |grep -v grep |wc -l`
                if [ $portstat != 0 ]; then
                        echo -e "${GREEN}${BOLD} FC PORTs are ONLINE ${NONE}"
                        echo -e "FC PORTs are ${GREEN}${BOLD} ONLINE ${NONE}" >> $hclog
                else
                        echo -e "${RED}${BOLD} Plz check the FC PORT ${NONE}"
                        echo -e "FC PORTS are ${RED}${BOLD}Not ${NONE}ok, Plz check the FC PORT." >> $hclog
                fi
        else
                npath=`cat /sys/class/fc_host/host?/port_state |grep Online|grep -v grep |wc -l`
                if [ $npath -eq 2 ]; then
                        echo -e " ${GREEN}${BOLD} FC port status is Normal ${NONE}"
                        echo -e "FC port status is ${GREEN}${BOLD}  Normal ${NONE}" >> $hclog
                else
                        echo -e " ${RED}${BOLD} Alert - Check FC port status of server ${NONE}"
                        cat /sys/class/fc_host/host?/port_state
                        echo -e "${RED}${BOLD}Alert ${NONE}"- Check FC port status of server >> $hclog
                        cat /sys/class/fc_host/host?/port_state >> $hclog
                fi
        fi
elif  [ $VXVM_check != 0 ]; then
        echo -e "${GREEN}  Server is using VERITAS VxVM for multipathing ${NONE}"
        if [ -d /proc/scsi/qla2xxx ]; then
        portstat=`grep "loop state" /proc/scsi/qla2*/* |grep READY |grep -v grep |wc -l`
                if [ $portstat != 0 ]; then
                        echo -e "${GREEN}${BOLD}  FC PORTs are ONLINE ${NONE}"
                        echo -e "FC PORT status is - ${GREEN}${BOLD} Normal ${NONE}" >>$hclog
                else
                        echo -e "${RED}${BOLD}  Plz check the FC PORT ${NONE}"
                        echo -e "FC PORT - ${RED}${BOLD} please check manually${NONE}" >>$hclog
                fi
        else
                npath=`cat /sys/class/fc_host/host?/port_state |grep Online|grep -v grep |wc -l`
                if [ $npath -eq 2 ]; then
                        echo -e " ${GREEN}${BOLD}  FC port status is Normal ${NONE}"
                        echo -e "FC port status is - ${GREEN}${BOLD} Normal ${NONE}" >>$hclog
                else
                        echo -e " ${RED}${BOLD}  Alert - Check FC port status of server ${NONE}"
                        echo -e "FC port status -  ${RED}${BOLD}Alert${NONE} - Check FC port status of server" >> $hclog
                        cat /sys/class/fc_host/host?/port_state
                        cat /sys/class/fc_host/host?/port_state >> $hclog
                fi
        fi
else
                echo -e "${YELLOW}${BOLD}  Server is not using any multipathing ${NONE}"
                echo -e "SAN Multipathing  - ${YELLOW}${BOLD}Server is not using multipathing utility ${NONE}" >> $hclog
fi
echo ""
if [ -f /tmp/lunstatus.log ]; then
        noff=$(cat /tmp/lunstatus.log  |grep Offline |grep -v grep |wc -l)
                if [ $noff != 0 ]; then
                        echo -e "${RED}${BOLD} some disks are OFFLINE ${NONE}"
                        echo -e "SAN disk status -   some disks are ${RED}${BOLD} OFFLINE ${NONE}" >> $hclog
                else
                        echo -e "${GREEN}${BOLD} All disks are ONLINE ${NONE}"
                        echo -e "SAN disk status  -${GREEN}${BOLD}All disks are ONLINE ${NONE}" >> $hclog
                fi
else
        echo -e "${RED}${BOLD} /tmp/lunstatus.log file doesnt exist ${NONE}"
        echo -e "SAN dist status - lunstatus.log file ${YELLOW}${BOLD}doesnt${NONE} exist" >> $hclog
fi

echo "====================================HBA & MULTIPATH STATS end     ===================================="
echo ""
echo "==================================== NTP STATS start              ====================================="
ntps=`ntpstat |grep synchronised |grep -v grep |wc -l`
if [ $ntps != 0 ]; then
        echo -e "${GREEN}${BOLD} NTP is in sync ${NONE}"
        echo -e "NTP status - ${GREEN}${BOLD} Time is in sync ${NONE}" >> $hclog
else
        echo -e "${RED}${BOLD} NTP is NOT in sync ${NONE}"
        echo -e "NTP status - ${RED}${BOLD} Time is NOT in sync ${NONE}" >> $hclog
fi
echo "==================================== NTP STATS end                 ===================================="

echo "==================================== Top 10 processes consuming CPU start ============================="
ps -eo %cpu,pid,comm | sort -r | head -10
echo "===========Top 10 Processes consuming CPU ====================" >> $hclog
ps -eo %cpu,pid,comm | sort -r | head -10 >> $hclog
echo "==============================================================" >> $hclog
echo "==================================== Top 10 processes consuming CPU end ==============================="

echo "==================================== Top 10 processes consuming Memory start ==========================="
ps axo %mem,pid,euser,cmd | sort -r | head -n 10
echo "===========Top 10 Processes consuming memory ================" >> $hclog
ps axo %mem,pid,euser | sort -r | head -n 10 >> $hclog
echo "=============================================================" >> $hclog
echo "==================================== Top 10 processes consuming Memory end ============================="

echo "==================================== List of zombie or defunct process  ================================"
ps -e -o ppid,pid,stat,command | egrep "Z|z|defunct" -w |grep -v grep
echo "===========List of zombie & defunct processes ================" >> $hclog
zcount=`ps -e -o ppid,pid,stat,command | egrep "Z|z|defunct" -w |grep -v grep|wc -l`
if [ $zcount -gt 0 ]; then
        ps -e -o ppid,pid,stat,command | egrep "Z|z|defunct" -w |grep -v grep >> $hclog
else
        echo -e "${GREEN}${BOLD}No zombie or defunct process found ${NONE}" >> $hclog
fi
echo "=============================================================" >> $hclog
echo "==================================== List of zombie or defunct process  ================================"

echo "==================================== Network drop/error start  ========================================="
/sbin/ifconfig |egrep "Link|drop"
echo "==================================== Network drop/error end  ==========================================="

echo "============================= VCS status ===================================="
VCSProc=`ps -u root -o args|grep hashadow`
if [ -n "$VCSProc" ]
then
 /usr/local/sudo/bin/sudo /opt/VRTSvcs/bin/hastatus -sum
 echo " "
 echo " Make sure all necessary resource groups are in ONLINE state."
else
 echo "No VCS running."
fi

echo "============================== VCS status end ==============================="
echo " "
echo "======================= TrueCopy (TC) status ================================"
HORCMProc=`ps -ef|grep horcm|grep -v grep|awk '{print $NF}'|cut -d"_" -f2`
HORCMProcc=`ps -ef|grep horcm|grep -v grep|awk '{print $NF}'|cut -d"_" -f2 |wc -l`
if [ $HORCMProcc -gt 0 ] && [ -d /HORCM ]; then
SkipChkTC=No
        for i in `echo $HORCMProc`
                do
                        #ls -l /etc/horcm`echo "$i+0"|bc`.conf
                        if [ ! -r /etc/horcm`echo "$i+0"|bc`.conf ]
                        then
                                echo -e "${YELLOW}${BOLD} No read access to HORCM files in /etc.${NONE}"
                                echo "${YELLOW}${BOLD} Please use root to perform this check. ${NONE}"
                                echo -e "True Copy Status - ${YELLOW}{BOLD} not able to read conf file, please use EID to check TC ${NONE}"
                        SkipChkTC=Yes
                        break
                        fi
                done
        if [ "$SkipChkTC" = "No" ]
        then
                HORCMInst=`echo "$HORCMProc+0"|bc|sort|tr -d '\n'`
                for EachTC in `grep "^TC_" /etc/horcm[$HORCMInst].conf|awk '{print $1}'|\
                        sort -u|sed 's/^\/etc\/horcm//g'|sed 's/\.conf//g'`
                do
                        TCInst=`echo $EachTC|cut -d":" -f1`
                        TCName=`echo $EachTC|cut -d":" -f2`
                        #echo "TCInst=$TCInst"
                        #echo "TCName=$TCName"
                        AnySUS=`/usr/local/sudo/bin/sudo /usr/bin/pairdisplay -IH$TCInst -g $TCName -fcxe|grep -v '^Group'|grep -ci "SUS"`
                        if [ $AnySUS -eq 0 ]
                        then
                                echo -e "${GREEN}${BOLD} TC group $TCName, instance $TCInst is in PAIR. ${NONE}"
                                echo -e "True Copy Status - TC group $TCName, instance $TCInst is in ${GREEN}${BOLD}  PAIR. ${NONE}" >> $hclog
                        else
                                echo -e "${RED}${BOLD} TC group $TCName, instance $TCInst is NOT in PAIR. ${NONE}"
                                echo -e "True Copy Status - TC group $TCName, instance $TCInst is ${RED}${BOLD} NOT${NONE} in PAIR. " >> $hclog
                        fi
                done
        fi
else
        echo -e "${YELLOW}${BOLD} Need to check if TC configuration is on media server for this box or no TC configured ${NONE}"
        echo -e "True Copy Status -  ${YELLOW}${BOLD} Need to check if TC configuration is on media server for this box or no TC configured ${NONE}" >> $hclog
fi


echo "========================== TrueCopy status end  ==============================="

echo "========================== General HW check using omreport ========================"
if [ -f /opt/dell/srvadmin/bin/omreport ]; then

crit=`/opt/dell/srvadmin/bin/omreport chassis |grep -i Critical |grep -v grep |wc -l`
        if [ $crit -gt 0 ]; then
                echo -e "${RED}${BOLD}"
                /opt/dell/srvadmin/bin/omreport chassis |grep -i Critical
                echo -e "${NONE}"
                ehco -e "${RED}${UNDERLINE}Below HW part is showing in critical state${NONE}" >> $hclog
                /opt/dell/srvadmin/bin/omreport chassis |grep -i Critical >> $hclog
        else
                echo -e "${GREEN}${BOLD} HW status seems healthy ${NONE}"
                echo -e "HARDWARE status - seems ${GREEN}${BOLD} NORMAL ${NONE}" >> $hclog
        fi
elif [ -f /opt/dell/srvadmin/oma/bin/omreport ]; then
critt=`/opt/dell/srvadmin/oma/bin/omreport chassis |grep -i Critical |grep -v grep |wc -l`
        if [ $critt -gt 0 ]; then
                echo -e "${RED}${BOLD}"
                /opt/dell/srvadmin/oma/bin/omreport chassis |grep -i Critical
                echo -e "${NONE}"
                ehco -e "${RED}${UNDERLINE}Below HW part is showing in critical state${NONE}" >> $hclog
                /opt/dell/srvadmin/bin/omreport chassis |grep -i Critical >> $hclog
        else
                echo -e "${GREEN}${BOLD} HW status seems healthy ${NONE}"
                echo -e "HARDWARE status -  seems ${GREEN}${BOLD} NORMAL ${NONE}" >> $hclog
        fi
else
        echo -e "${YELOOW} check the HW model and run specific tool for HW status ${NONE}"
        echo -e " HARDWARE status  - ${YELOOW} check the HW model and run appropriate tool for HW status ${NONE}" >> $hclog

fi
echo "========================== General HW check using omreport end ========================"


echo -e "${BLUE}${BOLD}${UNDERLINE} Recommended to run Appropriate vendor's tool to ensure H/W healthcheck is normal ${NONE}"

echo "================================= Healthcheck status end =================================== "

