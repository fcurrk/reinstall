#!/bin/sh

if [[ $EUID -ne 0 ]]; then
    clear
    echo "Error: This script must be run as root!" 1>&2
    exit 1
fi

function CopyRight() {
  clear
  echo "########################################################"
  echo "#                                                      #"
  echo "#  New Reinstall Script                                #"
  echo "#                                                      #"
  echo "#  Author: Minijer & hiCasper                          #"
  echo "#  Last Modified: 2023-03-13                           #"
  echo "#                                                      #"
  echo "#  Shell By MoeClub                                    #"
  echo "#                                                      #"
  echo "########################################################"
  echo -e "\n"
}

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

function GetIp() {
  MAINIP=$(ip route get 1 | awk -F 'src ' '{print $2}' | awk '{print $1}')
  GATEWAYIP=$(ip route | grep default | awk '{print $3}')
  SUBNET=$(ip -o -f inet addr show | awk '/scope global/{sub(/[^.]+\//,"0/",$4);print $4}' | head -1 | awk -F '/' '{print $2}')
  value=$(( 0xffffffff ^ ((1 << (32 - $SUBNET)) - 1) ))
  NETMASK="$(( (value >> 24) & 0xff )).$(( (value >> 16) & 0xff )).$(( (value >> 8) & 0xff )).$(( value & 0xff ))"
}

function UpdateIp() {
  read -r -p "Your IP: " MAINIP
  read -r -p "Your Gateway: " GATEWAYIP
  read -r -p "Your Netmask: " NETMASK
}

function SetNetwork() {
  isAuto='0'
  if [[ -f '/etc/network/interfaces' ]];then
    [[ ! -z "$(sed -n '/iface.*inet static/p' /etc/network/interfaces)" ]] && isAuto='1'
    [[ -d /etc/network/interfaces.d ]] && {
      cfgNum="$(find /etc/network/interfaces.d -name '*.cfg' |wc -l)" || cfgNum='0'
      [[ "$cfgNum" -ne '0' ]] && {
        for netConfig in `ls -1 /etc/network/interfaces.d/*.cfg`
        do 
          [[ ! -z "$(cat $netConfig | sed -n '/iface.*inet static/p')" ]] && isAuto='1'
        done
      }
    }
  fi
  
  if [[ -d '/etc/sysconfig/network-scripts' ]];then
    cfgNum="$(find /etc/network/interfaces.d -name '*.cfg' |wc -l)" || cfgNum='0'
    [[ "$cfgNum" -ne '0' ]] && {
      for netConfig in `ls -1 /etc/sysconfig/network-scripts/ifcfg-* | grep -v 'lo$' | grep -v ':[0-9]\{1,\}'`
      do 
        [[ ! -z "$(cat $netConfig | sed -n '/BOOTPROTO.*[sS][tT][aA][tT][iI][cC]/p')" ]] && isAuto='1'
      done
    }
  fi
}

function NetMode() {
  CopyRight
  if [ "$isAuto" == '0' ]; then
    read -r -p "Using DHCP to configure network automatically? [Y/n]:" input
    case $input in
      [yY][eE][sS]|[yY]) NETSTR='' ;;
      [nN][oO]|[nN]) isAuto='1' ;;
      *) clear; echo "Canceled by user!"; exit 1;;
    esac
  fi

  if [ "$isAuto" == '1' ]; then
    GetIp
    ipCheck
    if [ $? -ne 0 ]; then
      echo -e "Error occurred when detecting ip. Please input manually.\n"
      UpdateIp
    else
      CopyRight
      echo "IP: $MAINIP"
      echo "Gateway: $GATEWAYIP"
      echo "Netmask: $NETMASK"
      echo -e "\n"
      read -r -p "Confirm? [Y/n]:" input
      case $input in
        [yY][eE][sS]|[yY]) ;;
        [nN][oO]|[nN])
          echo -e "\n"
          UpdateIp
          ipCheck
          [[ $? -ne 0 ]] && {
            clear
            echo -e "Input error!\n"
            exit 1
          }
        ;;
        *) clear; echo "Canceled by user!"; exit 1;;
      esac
    fi
    NETSTR="--ip-addr ${MAINIP} --ip-gate ${GATEWAYIP} --ip-mask ${NETMASK}"
  fi
}

function Start() {
  read -r -p "Using CN Mode? [Y/n]:" input
  case $input in
      [yY][eE][sS]|[yY]) isCN='1' ;;
      [nN][oO]|[nN])
      isCN='0'
      geoip=$(wget --no-check-certificate -qO- https://api.myip.com | grep "\"country\":\"China\"")
      if [[ "$geoip" != "" ]];then
         isCN='1'
      fi;;
      *) clear; echo "Canceled by user!"; exit 1;;
   esac

  if [ "$isAuto" == '0' ]; then
    echo "Using DHCP mode."
  else
    echo "IP: $MAINIP"
    echo "Gateway: $GATEWAYIP"
    echo "Netmask: $NETMASK"
  fi

  [[ "$isCN" == '1' ]] && echo "Using domestic mode."

  if [ -f "/tmp/InstallNET.sh" ]; then
    rm -f /tmp/InstallNET.sh
  fi

  if [[ "$isCN" == '1' ]]; then
   wget --no-check-certificate -qO /tmp/InstallNET.sh 'https://cdn.jsdelivr.net/gh/fcurrk/reinstall@master/InstallNET.sh' && chmod a+x /tmp/InstallNET.sh
  else 
   wget --no-check-certificate -qO /tmp/InstallNET.sh 'https://raw.githubusercontent.com/fcurrk/reinstall/master/InstallNET.sh' && chmod a+x /tmp/InstallNET.sh
  fi
  
  CMIRROR=''
  CVMIRROR=''
  DMIRROR=''
  UMIRROR=''
  SYSMIRROR1='http://disk.29296819.xyz/d/dd/os/veip007/CentOS-7.img.gz'
  SYSMIRROR2='http://disk.29296819.xyz/d/dd/os/cxthhhhh/CentOS_7.X_x64_Legacy_NetInstallation_Final_v9.8.vhd.gz'
  SYSMIRROR3='http://disk.29296819.xyz/d/dd/os/cxthhhhh/CentOS_7.X_ARM64_UEFI_NetInstallation_Final_v9.11.vhd.gz'
  SYSMIRROR4='http://disk.29296819.xyz/d/dd/os/cxthhhhh/CentOS_8.X_x64_Legacy_NetInstallation_Stable_v6.8.vhd.gz'
  SYSMIRROR5='http://disk.29296819.xyz/d/dd/os/cxthhhhh/Rocky_8.X_x64_Legacy_NetInstallation_Stable_v6.8.vhd.gz'
  SYSMIRROR6='http://disk.29296819.xyz/d/dd/os/cxthhhhh/Rocky_8.X_x64_UEFI_NetInstallation_Stable_v6.9.vhd.gz'
  SYSMIRROR7='http://disk.29296819.xyz/d/dd/os/cxthhhhh/Rocky_8.X_ARM64_UEFI_NetInstallation_Stable_v6.11.vhd.gz'
  SYSMIRROR8='http://disk.29296819.xyz/d/dd/os/cxthhhhh/CentOS_9.X_x64_Legacy_NetInstallation_Stable_v1.6.vhd.gz'
  SYSMIRROR17='http://disk.29296819.xyz/d/dd/os/cxthhhhh/new/Disk_Windows_Server_2022_DataCenter_CN_v2.12.vhd.gz'
  SYSMIRROR18='http://disk.29296819.xyz/d/dd/os/cxthhhhh/new/Disk_Windows_Server_2022_DataCenter_CN_v2.12_UEFI.vhd.gz'
  SYSMIRROR19='http://disk.29296819.xyz/d/dd/os/cxthhhhh/new/Disk_Windows_Server_2019_DataCenter_CN_v5.1.vhd.gz'
  SYSMIRROR20='http://disk.29296819.xyz/d/dd/os/cxthhhhh/new/Disk_Windows_Server_2016_DataCenter_CN_v4.12.vhd.gz'
  SYSMIRROR21='http://disk.29296819.xyz/d/dd/os/cxthhhhh/new/Disk_Windows_Server_2012R2_DataCenter_CN_v4.29.vhd.gz'
  SYSMIRROR22='http://disk.29296819.xyz/d/dd/os/cxthhhhh/new/Disk_Windows_Server_2008R2_DataCenter_CN_v3.27.vhd.gz'
  SYSMIRROR23='http://disk.29296819.xyz/d/dd/os/cxthhhhh/new/Disk_Windows_Server_2003_DataCenter_CN_v7.1.vhd.gz'
  SYSMIRROR24='https://disk.29296819.xyz/d/dd/os/teddysun/zh-cn_windows10_ltsc.xz'
  SYSMIRROR25='https://disk.29296819.xyz/d/dd/os/teddysun/uefi/zh-cn_win10_ltsc_uefi.xz'
  SYSMIRROR26='http://disk.29296819.xyz/d/dd/os/laosiji/Win7/guajibao/VirtAll-win7-sp1-ent/VirtAll-win7-sp1-ent-x86-cn.vhd.gzz'
  SYSMIRROR27='http://disk.29296819.xyz/d/dd/os/laosiji/Win7/guajibao/guajibao-win7-sp1-ent-x86-cn-aliyun.vhd.gz'
  SYSMIRROR28='http://disk.29296819.xyz/d/dd/os/laosiji/Win7/guajibao/VirtAll-win7-sp1-ent/VirtAll-win7-sp1-ent-x64-cn.vhd.gz'
  SYSMIRROR29='http://disk.29296819.xyz/d/dd/os/laosiji/Win7/guajibao/guajibao-win7-sp1-ent-x64-cn-efi.vhd.gz'
  SYSMIRROR30='http://disk.29296819.xyz/d/dd/os/laosiji/Win10/guajibao/guajibao-win10-ent-ltsc-2021-x64-cn.vhd.gz'
  SYSMIRROR31='http://disk.29296819.xyz/d/dd/os/laosiji/Win10/guajibao/guajibao-win10-ent-ltsc-2021-x64-cn-aliyun.vhd.gz'
  SYSMIRROR32='http://disk.29296819.xyz/d/dd/os/laosiji/Win10/guajibao/guajibao-win10-ent-ltsc-2021-x64-cn-efi.vhd.gz'
  SYSMIRROR33='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2003/10G/WinSrv2003x86-Chinese-C10G.vhd.gz'
  SYSMIRROR34='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2008x64/lite/winsrv2008r2-data-sp1-x64-cn.vhd.gz'
  SYSMIRROR35='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2008x64/lite/winsrv2008r2-data-sp1-x64-cn-efi.vhd.gz'
  SYSMIRROR36='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2012r2x64/guajibao/guajibao-winsrv2012r2-data-x64-cn.vhd.gz'
  SYSMIRROR37='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2012r2x64/guajibao/guajibao-winsrv2012r2-data-x64-cn-efi.vhd.gz'
  SYSMIRROR38='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2016x64/guajibao/guajibao-winsrv2016-data-x64-cn.vhd.gz'
  SYSMIRROR39='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2016x64/guajibao/guajibao-winsrv2016-data-x64-cn-efi.vhd.gz'
  SYSMIRROR40='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2022x64/guajibao/guajibao-winsrv2022-data-x64-cn.vhd.gz'
  SYSMIRROR41='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2022x64/guajibao/guajibao-winsrv2022-data-x64-cn-efi.vhd.gz'

  if [[ "$isCN" == '1' ]];then
    CMIRROR="--mirror http://mirrors.aliyun.com/centos/"
    CVMIRROR="--mirror http://mirrors.tuna.tsinghua.edu.cn/centos-vault/"
    DMIRROR="--mirror http://mirrors.aliyun.com/debian/"
    UMIRROR="--mirror http://mirrors.aliyun.com/ubuntu/"
    SYSMIRROR1='http://disk.29296819.xyz/d/dd/os/veip007/CentOS-7.img.gz'
    SYSMIRROR2='http://disk.29296819.xyz/d/dd/os/cxthhhhh/CentOS_7.X_x64_Legacy_NetInstallation_Final_v9.8.vhd.gz'
    SYSMIRROR3='http://disk.29296819.xyz/d/dd/os/cxthhhhh/CentOS_7.X_ARM64_UEFI_NetInstallation_Final_v9.11.vhd.gz'
    SYSMIRROR4='http://disk.29296819.xyz/d/dd/os/cxthhhhh/CentOS_8.X_x64_Legacy_NetInstallation_Stable_v6.8.vhd.gz'
    SYSMIRROR5='http://disk.29296819.xyz/d/dd/os/cxthhhhh/Rocky_8.X_x64_Legacy_NetInstallation_Stable_v6.8.vhd.gz'
    SYSMIRROR6='http://disk.29296819.xyz/d/dd/os/cxthhhhh/Rocky_8.X_x64_UEFI_NetInstallation_Stable_v6.9.vhd.gz'
    SYSMIRROR7='http://disk.29296819.xyz/d/dd/os/cxthhhhh/Rocky_8.X_ARM64_UEFI_NetInstallation_Stable_v6.11.vhd.gz'
    SYSMIRROR8='http://disk.29296819.xyz/d/dd/os/cxthhhhh/CentOS_9.X_x64_Legacy_NetInstallation_Stable_v1.6.vhd.gz'
    SYSMIRROR17='http://disk.29296819.xyz/d/dd/os/cxthhhhh/new/Disk_Windows_Server_2022_DataCenter_CN_v2.12.vhd.gz'
    SYSMIRROR18='http://disk.29296819.xyz/d/dd/os/cxthhhhh/new/Disk_Windows_Server_2022_DataCenter_CN_v2.12_UEFI.vhd.gz'
    SYSMIRROR19='http://disk.29296819.xyz/d/dd/os/cxthhhhh/new/Disk_Windows_Server_2019_DataCenter_CN_v5.1.vhd.gz'
    SYSMIRROR20='http://disk.29296819.xyz/d/dd/os/cxthhhhh/new/Disk_Windows_Server_2016_DataCenter_CN_v4.12.vhd.gz'
    SYSMIRROR21='http://disk.29296819.xyz/d/dd/os/cxthhhhh/new/Disk_Windows_Server_2012R2_DataCenter_CN_v4.29.vhd.gz'
    SYSMIRROR22='http://disk.29296819.xyz/d/dd/os/cxthhhhh/new/Disk_Windows_Server_2008R2_DataCenter_CN_v3.27.vhd.gz'
    SYSMIRROR23='http://disk.29296819.xyz/d/dd/os/cxthhhhh/new/Disk_Windows_Server_2003_DataCenter_CN_v7.1.vhd.gz'
    SYSMIRROR24='https://disk.29296819.xyz/d/dd/os/teddysun/zh-cn_windows10_ltsc.xz'
    SYSMIRROR25='https://disk.29296819.xyz/d/dd/os/teddysun/uefi/zh-cn_win10_ltsc_uefi.xz'
    SYSMIRROR26='http://disk.29296819.xyz/d/dd/os/laosiji/Win7/guajibao/VirtAll-win7-sp1-ent/VirtAll-win7-sp1-ent-x86-cn.vhd.gzz'
    SYSMIRROR27='http://disk.29296819.xyz/d/dd/os/laosiji/Win7/guajibao/guajibao-win7-sp1-ent-x86-cn-aliyun.vhd.gz'
    SYSMIRROR28='http://disk.29296819.xyz/d/dd/os/laosiji/Win7/guajibao/VirtAll-win7-sp1-ent/VirtAll-win7-sp1-ent-x64-cn.vhd.gz'
    SYSMIRROR29='http://disk.29296819.xyz/d/dd/os/laosiji/Win7/guajibao/guajibao-win7-sp1-ent-x64-cn-efi.vhd.gz'
    SYSMIRROR30='http://disk.29296819.xyz/d/dd/os/laosiji/Win10/guajibao/guajibao-win10-ent-ltsc-2021-x64-cn.vhd.gz'
    SYSMIRROR31='http://disk.29296819.xyz/d/dd/os/laosiji/Win10/guajibao/guajibao-win10-ent-ltsc-2021-x64-cn-aliyun.vhd.gz'
    SYSMIRROR32='http://disk.29296819.xyz/d/dd/os/laosiji/Win10/guajibao/guajibao-win10-ent-ltsc-2021-x64-cn-efi.vhd.gz'
    SYSMIRROR33='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2003/10G/WinSrv2003x86-Chinese-C10G.vhd.gz'
    SYSMIRROR34='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2008x64/lite/winsrv2008r2-data-sp1-x64-cn.vhd.gz'
    SYSMIRROR35='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2008x64/lite/winsrv2008r2-data-sp1-x64-cn-efi.vhd.gz'
    SYSMIRROR36='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2012r2x64/guajibao/guajibao-winsrv2012r2-data-x64-cn.vhd.gz'
    SYSMIRROR37='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2012r2x64/guajibao/guajibao-winsrv2012r2-data-x64-cn-efi.vhd.gz'
    SYSMIRROR38='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2016x64/guajibao/guajibao-winsrv2016-data-x64-cn.vhd.gz'
    SYSMIRROR39='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2016x64/guajibao/guajibao-winsrv2016-data-x64-cn-efi.vhd.gz'
    SYSMIRROR40='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2022x64/guajibao/guajibao-winsrv2022-data-x64-cn.vhd.gz'
    SYSMIRROR41='http://disk.29296819.xyz/d/dd/os/laosiji/WinSrv2022x64/guajibao/guajibao-winsrv2022-data-x64-cn-efi.vhd.gz'

  fi

  echo -e "\nPlease select an OS:"
  echo "   1) CentOS 7.7 [X64-Legacy-ext4-cxthhhhh]"
  echo "   2) CentOS 7 [X64-Legacy-cxthhhhh]"
  echo "   3) CentOS 7 [ARM64-UEFI-cxthhhhh]"
  echo "   4) CentOS 8 [X64-Legacy-cxthhhhh]"
  echo "   5) Rocky 8 [X64-Legacy-cxthhhhh]"
  echo "   6) Rocky 8 [X64-UEFI-cxthhhhh]"
  echo "   7) Rocky 8 [ARM64-UEFI-cxthhhhh]"
  echo "   8) CentOS 9 [X64-Legacy-cxthhhhh]"
  echo "   9) CentOS 6"
  echo "  10) Debian 11"
  echo "  11) Debian 10"
  echo "  12) Debian 9"
  echo "  13) Debian 8"
  echo "  14) Ubuntu 20.04"
  echo "  15) Ubuntu 18.04"
  echo "  16) Ubuntu 16.04"
  echo "  17) Windows Server 2022 [X64-Legacy-cxthhhhh]"
  echo "  18) Windows Server 2022 [X64-UEFI-cxthhhhh]"
  echo "  19) Windows Server 2019 [X64-Legacy-cxthhhhh]"
  echo "  20) Windows Server 2016 [X64-Legacy-cxthhhhh]"
  echo "  21) Windows Server 2012 [X64-Legacy-cxthhhhh]"
  echo "  22) Windows Server 2008 [X64-Legacy-cxthhhhh]"
  echo "  23) Windows Server 2003 [X86-Legacy-cxthhhhh]"
  echo "  24) Windows 10 LTSC [X64-Legacy-teddysun]"
  echo "  25) Windows 10 LTSC [X64-UEFI-teddysun]"
  echo "  26) Windows 7 x86 Lite [X86-Legacy-nat.ee]"
  echo "  27) Windows 7 x86 Lite [X86-Legacy-aliyun-nat.ee]"
  echo "  28) Windows 7 x64 Lite [X64-Legacy-nat.ee]"
  echo "  29) Windows 7 x64 Lite [X64-UEFI-nat.ee]"
  echo "  30) Windows 10 LTSC Lite [X64-Legacy-nat.ee]"
  echo "  31) Windows 10 LTSC Lite [X64-Legacy-aliyun-nat.ee]"
  echo "  32) Windows 10 LTSC Lite [X64-UEFI-nat.ee]"
  echo "  33) Windows Server 2003 Lite [X86-Legacy-nat.ee]"
  echo "  34) Windows Server 2008 Lite [X64-Legacy-nat.ee]"
  echo "  35) Windows Server 2008 Lite [X64-UEFI-nat.ee]"
  echo "  36) Windows Server 2012 Lite [X64-Legacy-nat.ee]"
  echo "  37) Windows Server 2012 Lite [X64-UEFI-nat.ee]"
  echo "  38) Windows Server 2016 Lite [X64-Legacy-nat.ee]"
  echo "  39) Windows Server 2016 Lite [X64-UEFI-nat.ee]"
  echo "  40) Windows Server 2022 Lite [X64-Legacy-nat.ee]"
  echo "  41) Windows Server 2022 Lite [X64-UEFI-nat.ee]"
  echo "  99) Custom install"
  echo "   0) Exit"
  echo -ne "\nYour option: "
  read N
  case $N in
    1) echo -e "\nPassword: Pwd@CentOS\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR1 $DMIRROR ;;
    2) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR2 $DMIRROR ;;
    3) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR3 $DMIRROR ;;
    4) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR4 $DMIRROR ;;
    5) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR5 $DMIRROR ;;
    6) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR6 $DMIRROR ;;
    7) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR7 $DMIRROR ;;
    8) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR8 $DMIRROR ;;
    9) 
       echo -e "\n"
       read -r -p "Custom Password? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The password must start with character or numbers."
	 echo -e "It can be character numbers and .!$@#&%"
	 echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
         read -r -p "Press input Password: " mypasswd
	 until [[ "$mypasswd" =~ ^[a-zA-Z0-9][a-zA-Z0-9\!\$\@\#\&\%\.]{8,16}$ ]]
           do
           echo -e "\n"
           echo -e "The password does not meet the requirements."
	   echo -e "The password must start with character or numbers."
	   echo -e "It can be character numbers and .!$@#&%"
	   echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
           read -r -p "Please input the password again: " mypasswd
         done
         MYPASSWORD="-p ${mypasswd}";;
	 *) MYPASSWORD="";;
	 esac
       read -r -p "Custom SSH Port? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The Port must be numeric."
	 echo -e "The valid range is 1-65535. eg: 19100"
         read -r -p "Press input Port: " mysshPort
	 until [[ $mysshPort =~ ^[0-9]{1,5}$ ]] && [[ $mysshPort -lt 65535 ]] && [[ $mysshPort -gt 0 ]]
           do
           echo -e "\n"
	   echo -e "The Port must be numeric."
	   echo -e "The valid range is 1-65535. eg: 19100"
           read -r -p "Please input the Port again: " mysshPort
         done
         MYSSHPORT="-port ${mysshPort}";;
	 *) MYSSHPORT="";;
	 esac
         echo -e "\nPlease check the custom data:"
	 if [ "$MYPASSWORD" == '' ]; then
         echo -e "\nPassword: Minijer.com"
	 else
         echo -e "\nPassword: $mypasswd"
	 fi
	 if [ "$MYSSHPORT" == '' ]; then
         echo -e "\nSSH Port: 22\n"
	 else
         echo -e "\nSSH Port: $mysshPort\n"
	 fi	 
	 read -s -n1 -p "Press any key to continue..."; bash /tmp/InstallNET.sh -c 6.10 -v 64 $MYPASSWORD $MYSSHPORT $NETSTR $CMIRROR ;;
    10) 
       echo -e "\n"
       read -r -p "Custom Password? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The password must start with character or numbers."
	 echo -e "It can be character numbers and .!$@#&%"
	 echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
         read -r -p "Press input Password: " mypasswd
	 until [[ "$mypasswd" =~ ^[a-zA-Z0-9][a-zA-Z0-9\!\$\@\#\&\%\.]{8,16}$ ]]
           do
           echo -e "\n"
           echo -e "The password does not meet the requirements."
	   echo -e "The password must start with character or numbers."
	   echo -e "It can be character numbers and .!$@#&%"
	   echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
           read -r -p "Please input the password again: " mypasswd
         done
         MYPASSWORD="-p ${mypasswd}";;
	 *) MYPASSWORD="";;
	 esac
       read -r -p "Custom SSH Port? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The Port must be numeric."
	 echo -e "The valid range is 1-65535. eg: 19100"
         read -r -p "Press input Port: " mysshPort
	 until [[ $mysshPort =~ ^[0-9]{1,5}$ ]] && [[ $mysshPort -lt 65535 ]] && [[ $mysshPort -gt 0 ]]
           do
           echo -e "\n"
	   echo -e "The Port must be numeric."
	   echo -e "The valid range is 1-65535. eg: 19100"
           read -r -p "Please input the Port again: " mysshPort
         done
         MYSSHPORT="-port ${mysshPort}";;
	 *) MYSSHPORT="";;
	 esac
         echo -e "\nPlease check the custom data:"
	 if [ "$MYPASSWORD" == '' ]; then
         echo -e "\nPassword: Minijer.com"
	 else
         echo -e "\nPassword: $mypasswd"
	 fi
	 if [ "$MYSSHPORT" == '' ]; then
         echo -e "\nSSH Port: 22\n"
	 else
         echo -e "\nSSH Port: $mysshPort\n"
	 fi	 
	 read -s -n1 -p "Press any key to continue..."; bash /tmp/InstallNET.sh -d 11 -v 64 $MYPASSWORD $MYSSHPORT $NETSTR $DMIRROR ;;
    11) 
       echo -e "\n"
       read -r -p "Custom Password? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The password must start with character or numbers."
	 echo -e "It can be character numbers and .!$@#&%"
	 echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
         read -r -p "Press input Password: " mypasswd
	 until [[ "$mypasswd" =~ ^[a-zA-Z0-9][a-zA-Z0-9\!\$\@\#\&\%\.]{8,16}$ ]]
           do
           echo -e "\n"
           echo -e "The password does not meet the requirements."
	   echo -e "The password must start with character or numbers."
	   echo -e "It can be character numbers and .!$@#&%"
	   echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
           read -r -p "Please input the password again: " mypasswd
         done
         MYPASSWORD="-p ${mypasswd}";;
	 *) MYPASSWORD="";;
	 esac
       read -r -p "Custom SSH Port? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The Port must be numeric."
	 echo -e "The valid range is 1-65535. eg: 19100"
         read -r -p "Press input Port: " mysshPort
	 until [[ $mysshPort =~ ^[0-9]{1,5}$ ]] && [[ $mysshPort -lt 65535 ]] && [[ $mysshPort -gt 0 ]]
           do
           echo -e "\n"
	   echo -e "The Port must be numeric."
	   echo -e "The valid range is 1-65535. eg: 19100"
           read -r -p "Please input the Port again: " mysshPort
         done
         MYSSHPORT="-port ${mysshPort}";;
	 *) MYSSHPORT="";;
	 esac
         echo -e "\nPlease check the custom data:"
	 if [ "$MYPASSWORD" == '' ]; then
         echo -e "\nPassword: Minijer.com"
	 else
         echo -e "\nPassword: $mypasswd"
	 fi
	 if [ "$MYSSHPORT" == '' ]; then
         echo -e "\nSSH Port: 22\n"
	 else
         echo -e "\nSSH Port: $mysshPort\n"
	 fi	 
	 read -s -n1 -p "Press any key to continue..."; bash /tmp/InstallNET.sh -d 10 -v 64 $MYPASSWORD $MYSSHPORT $NETSTR $DMIRROR ;; 
    12) 
       echo -e "\n"
       read -r -p "Custom Password? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The password must start with character or numbers."
	 echo -e "It can be character numbers and .!$@#&%"
	 echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
         read -r -p "Press input Password: " mypasswd
	 until [[ "$mypasswd" =~ ^[a-zA-Z0-9][a-zA-Z0-9\!\$\@\#\&\%\.]{8,16}$ ]]
           do
           echo -e "\n"
           echo -e "The password does not meet the requirements."
	   echo -e "The password must start with character or numbers."
	   echo -e "It can be character numbers and .!$@#&%"
	   echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
           read -r -p "Please input the password again: " mypasswd
         done
         MYPASSWORD="-p ${mypasswd}";;
	 *) MYPASSWORD="";;
	 esac
       read -r -p "Custom SSH Port? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The Port must be numeric."
	 echo -e "The valid range is 1-65535. eg: 19100"
         read -r -p "Press input Port: " mysshPort
	 until [[ $mysshPort =~ ^[0-9]{1,5}$ ]] && [[ $mysshPort -lt 65535 ]] && [[ $mysshPort -gt 0 ]]
           do
           echo -e "\n"
	   echo -e "The Port must be numeric."
	   echo -e "The valid range is 1-65535. eg: 19100"
           read -r -p "Please input the Port again: " mysshPort
         done
         MYSSHPORT="-port ${mysshPort}";;
	 *) MYSSHPORT="";;
	 esac
         echo -e "\nPlease check the custom data:"
	 if [ "$MYPASSWORD" == '' ]; then
         echo -e "\nPassword: Minijer.com"
	 else
         echo -e "\nPassword: $mypasswd"
	 fi
	 if [ "$MYSSHPORT" == '' ]; then
         echo -e "\nSSH Port: 22\n"
	 else
         echo -e "\nSSH Port: $mysshPort\n"
	 fi	 
	 read -s -n1 -p "Press any key to continue..."; bash /tmp/InstallNET.sh -d 9 -v 64 $MYPASSWORD $MYSSHPORT $NETSTR $DMIRROR ;;
    13)
       echo -e "\n"
       read -r -p "Custom Password? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The password must start with character or numbers."
	 echo -e "It can be character numbers and .!$@#&%"
	 echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
         read -r -p "Press input Password: " mypasswd
	 until [[ "$mypasswd" =~ ^[a-zA-Z0-9][a-zA-Z0-9\!\$\@\#\&\%\.]{8,16}$ ]]
           do
           echo -e "\n"
           echo -e "The password does not meet the requirements."
	   echo -e "The password must start with character or numbers."
	   echo -e "It can be character numbers and .!$@#&%"
	   echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
           read -r -p "Please input the password again: " mypasswd
         done
         MYPASSWORD="-p ${mypasswd}";;
	 *) MYPASSWORD="";;
	 esac
       read -r -p "Custom SSH Port? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The Port must be numeric."
	 echo -e "The valid range is 1-65535. eg: 19100"
         read -r -p "Press input Port: " mysshPort
	 until [[ $mysshPort =~ ^[0-9]{1,5}$ ]] && [[ $mysshPort -lt 65535 ]] && [[ $mysshPort -gt 0 ]]
           do
           echo -e "\n"
	   echo -e "The Port must be numeric."
	   echo -e "The valid range is 1-65535. eg: 19100"
           read -r -p "Please input the Port again: " mysshPort
         done
         MYSSHPORT="-port ${mysshPort}";;
	 *) MYSSHPORT="";;
	 esac
         echo -e "\nPlease check the custom data:"
	 if [ "$MYPASSWORD" == '' ]; then
         echo -e "\nPassword: Minijer.com"
	 else
         echo -e "\nPassword: $mypasswd"
	 fi
	 if [ "$MYSSHPORT" == '' ]; then
         echo -e "\nSSH Port: 22\n"
	 else
         echo -e "\nSSH Port: $mysshPort\n"
	 fi	 
	 read -s -n1 -p "Press any key to continue..."; bash /tmp/InstallNET.sh -d 8 -v 64 $MYPASSWORD $MYSSHPORT $NETSTR $DMIRROR ;;
    14) 
       echo -e "\n"
       read -r -p "Custom Password? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The password must start with character or numbers."
	 echo -e "It can be character numbers and .!$@#&%"
	 echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
         read -r -p "Press input Password: " mypasswd
	 until [[ "$mypasswd" =~ ^[a-zA-Z0-9][a-zA-Z0-9\!\$\@\#\&\%\.]{8,16}$ ]]
           do
           echo -e "\n"
           echo -e "The password does not meet the requirements."
	   echo -e "The password must start with character or numbers."
	   echo -e "It can be character numbers and .!$@#&%"
	   echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
           read -r -p "Please input the password again: " mypasswd
         done
         MYPASSWORD="-p ${mypasswd}";;
	 *) MYPASSWORD="";;
	 esac
       read -r -p "Custom SSH Port? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The Port must be numeric."
	 echo -e "The valid range is 1-65535. eg: 19100"
         read -r -p "Press input Port: " mysshPort
	 until [[ $mysshPort =~ ^[0-9]{1,5}$ ]] && [[ $mysshPort -lt 65535 ]] && [[ $mysshPort -gt 0 ]]
           do
           echo -e "\n"
	   echo -e "The Port must be numeric."
	   echo -e "The valid range is 1-65535. eg: 19100"
           read -r -p "Please input the Port again: " mysshPort
         done
         MYSSHPORT="-port ${mysshPort}";;
	 *) MYSSHPORT="";;
	 esac
         echo -e "\nPlease check the custom data:"
	 if [ "$MYPASSWORD" == '' ]; then
         echo -e "\nPassword: Minijer.com"
	 else
         echo -e "\nPassword: $mypasswd"
	 fi
	 if [ "$MYSSHPORT" == '' ]; then
         echo -e "\nSSH Port: 22\n"
	 else
         echo -e "\nSSH Port: $mysshPort\n"
	 fi	 
	 read -s -n1 -p "Press any key to continue..."; bash /tmp/InstallNET.sh -u 20.04 -v 64 $MYPASSWORD $MYSSHPORT $NETSTR $UMIRROR ;;
    15) 
       echo -e "\n"
       read -r -p "Custom Password? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The password must start with character or numbers."
	 echo -e "It can be character numbers and .!$@#&%"
	 echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
         read -r -p "Press input Password: " mypasswd
	 until [[ "$mypasswd" =~ ^[a-zA-Z0-9][a-zA-Z0-9\!\$\@\#\&\%\.]{8,16}$ ]]
           do
           echo -e "\n"
           echo -e "The password does not meet the requirements."
	   echo -e "The password must start with character or numbers."
	   echo -e "It can be character numbers and .!$@#&%"
	   echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
           read -r -p "Please input the password again: " mypasswd
         done
         MYPASSWORD="-p ${mypasswd}";;
	 *) MYPASSWORD="";;
	 esac
       read -r -p "Custom SSH Port? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The Port must be numeric."
	 echo -e "The valid range is 1-65535. eg: 19100"
         read -r -p "Press input Port: " mysshPort
	 until [[ $mysshPort =~ ^[0-9]{1,5}$ ]] && [[ $mysshPort -lt 65535 ]] && [[ $mysshPort -gt 0 ]]
           do
           echo -e "\n"
	   echo -e "The Port must be numeric."
	   echo -e "The valid range is 1-65535. eg: 19100"
           read -r -p "Please input the Port again: " mysshPort
         done
         MYSSHPORT="-port ${mysshPort}";;
	 *) MYSSHPORT="";;
	 esac
         echo -e "\nPlease check the custom data:"
	 if [ "$MYPASSWORD" == '' ]; then
         echo -e "\nPassword: Minijer.com"
	 else
         echo -e "\nPassword: $mypasswd"
	 fi
	 if [ "$MYSSHPORT" == '' ]; then
         echo -e "\nSSH Port: 22\n"
	 else
         echo -e "\nSSH Port: $mysshPort\n"
	 fi	 
	 read -s -n1 -p "Press any key to continue..."; bash /tmp/InstallNET.sh -u 18.04 -v 64 $MYPASSWORD $MYSSHPORT $NETSTR $UMIRROR ;;
    16) 
       echo -e "\n"
       read -r -p "Custom Password? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The password must start with character or numbers."
	 echo -e "It can be character numbers and .!$@#&%"
	 echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
         read -r -p "Press input Password: " mypasswd
	 until [[ "$mypasswd" =~ ^[a-zA-Z0-9][a-zA-Z0-9\!\$\@\#\&\%\.]{8,16}$ ]]
           do
           echo -e "\n"
           echo -e "The password does not meet the requirements."
	   echo -e "The password must start with character or numbers."
	   echo -e "It can be character numbers and .!$@#&%"
	   echo -e "Password length limit 8-16 bits. eg: Minijer@520\n"
           read -r -p "Please input the password again: " mypasswd
         done
         MYPASSWORD="-p ${mypasswd}";;
	 *) MYPASSWORD="";;
	 esac
       read -r -p "Custom SSH Port? [Y/n]: " input
       case $input in
         [yY][eE][sS]|[yY])
	 echo -e "\n"
	 echo -e "The Port must be numeric."
	 echo -e "The valid range is 1-65535. eg: 19100"
         read -r -p "Press input Port: " mysshPort
	 until [[ $mysshPort =~ ^[0-9]{1,5}$ ]] && [[ $mysshPort -lt 65535 ]] && [[ $mysshPort -gt 0 ]]
           do
           echo -e "\n"
	   echo -e "The Port must be numeric."
	   echo -e "The valid range is 1-65535. eg: 19100"
           read -r -p "Please input the Port again: " mysshPort
         done
         MYSSHPORT="-port ${mysshPort}";;
	 *) MYSSHPORT="";;
	 esac
         echo -e "\nPlease check the custom data:"
	 if [ "$MYPASSWORD" == '' ]; then
         echo -e "\nPassword: Minijer.com"
	 else
         echo -e "\nPassword: $mypasswd"
	 fi
	 if [ "$MYSSHPORT" == '' ]; then
         echo -e "\nSSH Port: 22\n"
	 else
         echo -e "\nSSH Port: $mysshPort\n"
	 fi	 
	 read -s -n1 -p "Press any key to continue..."; bash /tmp/InstallNET.sh -u 16.04 -v 64 $MYPASSWORD $MYSSHPORT $NETSTR $UMIRROR ;;
    17) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR17 $DMIRROR ;;
    18) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR18 $DMIRROR ;;
    19) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR19 $DMIRROR ;;
    20) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR20 $DMIRROR ;;
    21) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR21 $DMIRROR ;;
    22) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR22 $DMIRROR ;;
    23) echo -e "\nPassword: cxthhhhh.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR23 $DMIRROR ;;
    24) echo -e "\nPassword: Teddysun.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR24 $DMIRROR ;;
    25) echo -e "\nPassword: Teddysun.com\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR25 $DMIRROR ;;
    26) echo -e "\nPassword: nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR26 $DMIRROR ;;
    27) echo -e "\nPassword: nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR27 $DMIRROR ;;
    28) echo -e "\nPassword: nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR28 $DMIRROR ;;
    29) echo -e "\nPassword: nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR29 $DMIRROR ;;
    30) echo -e "\nPassword: nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR30 $DMIRROR ;;
    31) echo -e "\nPassword: nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR31 $DMIRROR ;;
    32) echo -e "\nPassword: nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR32 $DMIRROR ;;
    33) echo -e "\nPassword: WinSrv2003x86-Chinese\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR33 $DMIRROR ;;
    34) echo -e "\nPassword: nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR34 $DMIRROR ;;
    34) echo -e "\nPassword: nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR35 $DMIRROR ;;
    36) echo -e "\nPassword: nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR36 $DMIRROR ;;
    37) echo -e "\nPassword: nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR37 $DMIRROR ;;
    38) echo -e "\nPassword: nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR38 $DMIRROR ;;
    39) echo -e "\nPassword: nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR39 $DMIRROR ;;
    40) echo -e "\nPassword: nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR40 $DMIRROR ;;
    41) echo -e "\nPassword: nat.ee\n"; read -s -n1 -p "Press any key to continue..." ; bash /tmp/InstallNET.sh $NETSTR -dd $SYSMIRROR41 $DMIRROR ;;
    99)
      echo -e "\n"
      read -r -p "Custom image URL: " imgURL
      echo -e "\n"
      read -r -p "Are you sure start reinstall? [Y/n]: " input
      case $input in
        [yY][eE][sS]|[yY]) bash /tmp/InstallNET.sh $NETSTR -dd $imgURL $DMIRROR ;;
        *) clear; echo "Canceled by user!"; exit 1;;
      esac
      ;;
    0) exit 0;;
    *) echo "Wrong input!"; exit 1;;
  esac
}

SetNetwork
NetMode
Start
