#!/bin/sh

if [[ $EUID -ne 0 ]]; then
    clear
    echo "Error: This script must be run as root!" 1>&2
    exit 1
fi

function isValidIp() {
  local ip=$1
  local ret=1
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    ip=(${ip//\./ })
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    ret=$?
  fi
  return $ret
}

function updateIp() {
  CopyRight
  read -r -p "Your IP: " MAINIP
  read -r -p "Your Gateway: " GATEWAYIP
  read -r -p "Your Netmask: " NETMASK
}

function ipCheck() {
  isLegal=0
  for add in $MAINIP $GATEWAYIP $NETMASK; do
    isValidIp $add
    if [ $? -eq 1 ]; then
      isLegal=1
    fi
  done
  return $isLegal
}

function CopyRight() {
  clear
  echo "########################################################"
  echo "#                                                      #"
  echo "#  Auto Reinstall Script                               #"
  echo "#                                                      #"
  echo "#  Author: hiCasper & Minijer                          #"
  echo "#  Last Modified: 2020-02-21                           #"
  echo "#                                                      #"
  echo "#  Supported by MoeClub & cxthhhhh                     #"
  echo "#                                                      #"
  echo "########################################################"
  echo -e "\n"
}

function start() {
  CopyRight
  echo "IP: $MAINIP"
  echo "Gateway: $GATEWAYIP"
  echo "Netmask: $NETMASK"
  echo -e "\nPlease select an OS:"
  echo "   1) CentOS 7.7 (ext4)"
  echo "   2) CentOS 8 (cxthhhh)"
  echo "   3) CentOS 7 (cxthhhh)"
  echo "   4) CentOS 6"
  echo "   5) Debian 10"
  echo "   6) Debian 9"
  echo "   7) Debian 8"
  echo "   8) Debian 7"
  echo "   9) Ubuntu 18.04"
  echo "  10) Ubuntu 16.04"
  echo "  11) Ubuntu 14.04"
  echo "  12) Windows Server 2019"
  echo "  13) Windows Server 2016"
  echo "  14) Windows Server 2012"
  echo "  15) Windows Server 2012 Lite"
  echo "  16) Windows Server 2008"
  echo "  17) Windows Server 2008 Lite"
  echo "  18) Windows Server 2003"
  echo "  19) Windows Server 2003 Lite"
  echo "  20) Windows 10 LTSC Lite"
  echo "  21) Windows 7 x86 Lite"
  echo "  22) Windows 7 Ent Lite"
  echo "  99) Custom image"
  echo "   0) Exit"
  echo -ne "\nYour option: "
  read N
  case $N in
    1) echo -e "\nPassword: Pwd@CentOS\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'http://disk.29296819.xyz/92shidai.com/dd/os/veip007/CentOS-7.img.gz' $DMIRROR ;;
    2) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'http://disk.29296819.xyz/92shidai.com/dd/os/cxthhhhh/CentOS_8.X_NetInstallation.vhd.gz' $DMIRROR ;;
    3) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'http://disk.29296819.xyz/92shidai.com/dd/os/cxthhhhh/CentOS_7.X_NetInstallation.vhd.gz' $DMIRROR ;;
    4) echo -e "\nPassword: Minijer.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -c 6.10 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK $CMIRROR ;;
    5) echo -e "\nPassword: Minijer.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -d 10 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK $DMIRROR ;;
    6) echo -e "\nPassword: Minijer.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -d 9 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK $DMIRROR ;;
    7) echo -e "\nPassword: Minijer.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -d 8 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK $DMIRROR ;;
    8) echo -e "\nPassword: Minijer.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -d 7 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK $DMIRROR ;;
    9) echo -e "\nPassword: Minijer.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -u 18.04 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK $UMIRROR ;;
    10) echo -e "\nPassword: Minijer.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -u 16.04 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK $UMIRROR ;;
    11) echo -e "\nPassword: Minijer.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh -u 14.04 -v 64 -a --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK $UMIRROR ;;
    12) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'http://disk.29296819.xyz/92shidai.com/dd/os/cxthhhhh/Disk_Windows_Server_2019_DataCenter_CN.vhd.gz' $DMIRROR ;;
    13) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'http://disk.29296819.xyz/92shidai.com/dd/os/cxthhhhh/Disk_Windows_Server_2016_DataCenter_CN.vhd.gz' $DMIRROR ;;
    14) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'http://disk.29296819.xyz/92shidai.com/dd/os/cxthhhhh/Disk_Windows_Server_2012R2_DataCenter_CN.vhd.gz' $DMIRROR ;;
    15) echo -e "\nPassword: WinSrv2012r2\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'http://disk.29296819.xyz/92shidai.com/dd/os/laosiji/WinSrv2012r2x64/lite/WinSrv2012r2_v2.vhd.gz' $DMIRROR ;;
    16) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'http://disk.29296819.xyz/92shidai.com/dd/os/cxthhhhh/Disk_Windows_Server_2008R2_DataCenter_CN.vhd.gz' $DMIRROR ;;
    17) echo -e "\nPassword: WinSrv2008x64-Chinese\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'http://disk.29296819.xyz/92shidai.com/dd/os/laosiji/WinSrv2008x64/lite/WinSrv2008x64-Chinese.vhd.gz' $DMIRROR ;;
    18) echo -e "\nPassword: Linode\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'http://disk.29296819.xyz/92shidai.com/dd/os/other/cn2003-virtio-pass-Linode.gz' $DMIRROR ;;
    19) echo -e "\nPassword: WinSrv2003x86-Chinese\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'http://disk.29296819.xyz/92shidai.com/dd/os/laosiji/WinSrv2003/10G/WinSrv2003x86-Chinese-C10G.vhd.gz' $DMIRROR ;;
    20) echo -e "\nPassword: www.nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'http://disk.29296819.xyz/92shidai.com/dd/os/laosiji/Win10/Win10_x64.vhd.gz' $DMIRROR ;;
    21) echo -e "\nPassword: Windows7x86-Chinese\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'http://disk.29296819.xyz/92shidai.com/dd/os/laosiji/Win7/Windows7x86-Chinese.vhd.gz' $DMIRROR ;;
    22) echo -e "\nPassword: www.nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/Core_Install.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd 'http://disk.29296819.xyz/92shidai.com/dd/os/laosiji/Win7/Win7-Ent.gz' $DMIRROR ;;        
    99)
      echo -e "\n"
      read -r -p "Custom image URL: " imgURL
      echo -e "\n"
      read -r -p "Are you sure start reinstall? [Y/n]: " input
      case $input in
        [yY][eE][sS]|[yY]) bash /tmp/Core_Install.sh --ip-addr $MAINIP --ip-gate $GATEWAYIP --ip-mask $NETMASK -dd $imgURL $DMIRROR ;;
        *) clear; echo "Canceled by user!"; exit 1;;
      esac
      ;;
    0) exit 0;;
    *) echo "Wrong input!"; exit 1;;
  esac
}

CMIRROR=''
CVMIRROR=''
DMIRROR=''
UMIRROR=''
isCN='0'

geoip=$(wget --no-check-certificate -qO- https://api.ip.sb/geoip | grep "\"country_code\":\"CN\"")
if [[ "$geoip" != "" ]];then
  isCN='1'
fi

if [ -f "/tmp/Core_Install.sh" ]; then
  rm -f /tmp/Core_Install.sh
fi
wget --no-check-certificate -qO /tmp/Core_Install.sh 'https://github.com/fcurrk/reinstall/Core_Install.sh' && chmod a+x /tmp/Core_Install.sh

if [[ "$isCN" == '1' ]];then
  sed -i 's#http://disk.29296819.xyz/92shidai.com/dd/img/wget_udeb_amd64.tar.gz#https://github.com/fcurrk/reinstall/wget_udeb_amd64.tar.gz#' /tmp/Core_Install.sh
  CMIRROR="--mirror http://mirrors.aliyun.com/centos/"
  CVMIRROR="--mirror http://mirrors.tuna.tsinghua.edu.cn/centos-vault/"
  DMIRROR="--mirror http://mirrors.aliyun.com/debian/"
  UMIRROR="--mirror http://mirrors.aliyun.com/ubuntu/"
fi

sed -i 's/$1$UIl1uSg0$tAW9qjOqoCto0CIUgUwHT1/$1$C7j0ZaEl$4qQdj2VyJFH1neyqcO0qm0/' /tmp/Core_Install.sh

MAINIP=$(ip route get 1 | awk -F 'src ' '{print $2}' | awk '{print $1}')
GATEWAYIP=$(ip route | grep default | awk '{print $3}')
SUBNET=$(ip -o -f inet addr show | awk '/scope global/{sub(/[^.]+\//,"0/",$4);print $4}' | head -1 | awk -F '/' '{print $2}')
value=$(( 0xffffffff ^ ((1 << (32 - $SUBNET)) - 1) ))
NETMASK="$(( (value >> 24) & 0xff )).$(( (value >> 16) & 0xff )).$(( (value >> 8) & 0xff )).$(( value & 0xff ))"

ipCheck
if [ $? -eq 0 ]; then
  CopyRight
  echo "IP: $MAINIP"
  echo "Gateway: $GATEWAYIP"
  echo "Netmask: $NETMASK"
  if [[ "$isCN" == '1' ]];then
    echo "Using domestic mode."
  fi
  echo -ne "\n"
  read -r -p "Please confirm your network infomation [Y/n]: " input
  case $input in
    [yY][eE][sS]|[yY]) start;;
    [nN][oO]|[nN])
      updateIp
      ipCheck
      if [ $? -eq 0 ]; then
        start
      else
        echo -e "\nIllegal address!"; exit 1
      fi
      ;;
    *) echo "Wrong input!"; exit 1;;
  esac
else
  echo -e "\nIllegal address!"
  updateIp
  ipCheck
  if [ $? -eq 0 ]; then
    start
  else
    echo -e "\nIllegal address!"
  fi
fi
