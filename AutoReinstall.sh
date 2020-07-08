#!binsh

if [[ $EUID -ne 0 ]]; then
    clear
    echo Error This script must be run as root! 1&2
    exit 1
fi

function CopyRight() {
  clear
  echo ########################################################
  echo #                                                      #
  echo #  Auto Reinstall Script                               #
  echo #                                                      #
  echo #  Author hiCasper & Minijer                          #
  echo #  Last Modified 2020-07-08                           #
  echo #                                                      #
  echo #  Supported by MoeClub & cxthhhhh                     #
  echo #                                                      #
  echo ########################################################
  echo -e n
}

function isValidIp() {
  local ip=$1
  local ret=1
  if [[ $ip =~ ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$ ]]; then
    ip=(${ip. })
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    ret=$
  fi
  return $ret
}

function ipCheck() {
  isLegal=0
  for add in $MAINIP $GATEWAYIP $NETMASK; do
    isValidIp $add
    if [ $ -eq 1 ]; then
      isLegal=1
    fi
  done
  return $isLegal
}

function GetIp() {
  MAINIP=$(ip route get 1  awk -F 'src ' '{print $2}'  awk '{print $1}')
  GATEWAYIP=$(ip route  grep default  awk '{print $3}')
  SUBNET=$(ip -o -f inet addr show  awk 'scope global{sub([^.]+,0,$4);print $4}'  head -1  awk -F '' '{print $2}')
  value=$(( 0xffffffff ^ ((1  (32 - $SUBNET)) - 1) ))
  NETMASK=$(( (value  24) & 0xff )).$(( (value  16) & 0xff )).$(( (value  8) & 0xff )).$(( value & 0xff ))
}

function UpdateIp() {
  read -r -p Your IP  MAINIP
  read -r -p Your Gateway  GATEWAYIP
  read -r -p Your Netmask  NETMASK
}

function SetNetwork() {
  isAuto='0'
  if [[ -f 'etcnetworkinterfaces' ]];then
    [[ ! -z $(sed -n 'iface.inet staticp' etcnetworkinterfaces) ]] && isAuto='1'
    [[ -d etcnetworkinterfaces.d ]] && {
      cfgNum=$(find etcnetworkinterfaces.d -name '.cfg' wc -l)  cfgNum='0'
      [[ $cfgNum -ne '0' ]] && {
        for netConfig in `ls -1 etcnetworkinterfaces.d.cfg`
        do 
          [[ ! -z $(cat $netConfig  sed -n 'iface.inet staticp') ]] && isAuto='1'
        done
      }
    }
  fi
  
  if [[ -d 'etcsysconfignetwork-scripts' ]];then
    cfgNum=$(find etcnetworkinterfaces.d -name '.cfg' wc -l)  cfgNum='0'
    [[ $cfgNum -ne '0' ]] && {
      for netConfig in `ls -1 etcsysconfignetwork-scriptsifcfg-  grep -v 'lo$'  grep -v '[0-9]{1,}'`
      do 
        [[ ! -z $(cat $netConfig  sed -n 'BOOTPROTO.[sS][tT][aA][tT][iI][cC]p') ]] && isAuto='1'
      done
    }
  fi
}

function NetMode() {
  CopyRight

  if [ $isAuto == '0' ]; then
    read -r -p Using DHCP to configure network automatically [Yn] input
    case $input in
      [yY][eE][sS][yY]) NETSTR='' ;;
      [nN][oO][nN]) isAuto='1' ;;
      ) clear; echo Canceled by user!; exit 1;;
    esac
  fi

  if [ $isAuto == '1' ]; then
    GetIp
    ipCheck
    if [ $ -ne 0 ]; then
      echo -e Error occurred when detecting ip. Please input manually.n
      UpdateIp
    else
      CopyRight
      echo IP $MAINIP
      echo Gateway $GATEWAYIP
      echo Netmask $NETMASK
      echo -e n
      read -r -p Confirm [Yn] input
      case $input in
        [yY][eE][sS][yY]) ;;
        [nN][oO][nN])
          echo -e n
          UpdateIp
          ipCheck
          [[ $ -ne 0 ]] && {
            clear
            echo -e Input error!n
            exit 1
          }
        ;;
        ) clear; echo Canceled by user!; exit 1;;
      esac
    fi
    NETSTR=--ip-addr ${MAINIP} --ip-gate ${GATEWAYIP} --ip-mask ${NETMASK}
  fi
}

function Start() {
  CopyRight
  
  isCN='0'
  geoip=$(wget --no-check-certificate -qO- httpsapi.ip.sbgeoip  grep country_codeCN)
  if [[ $geoip !=  ]];then
    isCN='1'
  fi

  if [ $isAuto == '0' ]; then
    echo Using DHCP mode.
  else
    echo IP $MAINIP
    echo Gateway $GATEWAYIP
    echo Netmask $NETMASK
  fi

  [[ $isCN == '1' ]] && echo Using domestic mode.

  if [ -f tmpCore_Install.sh ]; then
    rm -f tmpCore_Install.sh
  fi
  wget --no-check-certificate -qO tmpCore_Install.sh 'httpsraw.githubusercontent.comfcurrkreinstallmasterCore_Install.sh' && chmod a+x tmpCore_Install.sh
  
  CMIRROR=''
  CVMIRROR=''
  DMIRROR=''
  UMIRROR=''
  SYSMIRROR1='httpdisk.29296819.xyz92shidai.comddosveip007CentOS-7.img.gz'
  SYSMIRROR2='httpdisk.29296819.xyz92shidai.comddoscxthhhhhCentOS_7.X_NetInstallation.vhd.gz'
  SYSMIRROR3='httpdisk.29296819.xyz92shidai.comddoscxthhhhhCentOS_8.X_NetInstallation.vhd.gz'
  SYSMIRROR12='httpdisk.29296819.xyz92shidai.comddoscxthhhhhDisk_Windows_Server_2019_DataCenter_CN.vhd.gz'
  SYSMIRROR13='httpdisk.29296819.xyz92shidai.comddoscxthhhhhDisk_Windows_Server_2016_DataCenter_CN.vhd.gz'
  SYSMIRROR14='httpdisk.29296819.xyz92shidai.comddoscxthhhhhDisk_Windows_Server_2012R2_DataCenter_CN.vhd.gz'
  SYSMIRROR15='httpdisk.29296819.xyz92shidai.comddoslaosijiWinSrv2012r2x64liteWinSrv2012r2_v2.vhd.gz'
  SYSMIRROR16='httpdisk.29296819.xyz92shidai.comddoscxthhhhhDisk_Windows_Server_2008R2_DataCenter_CN.vhd.gz'
  SYSMIRROR17='httpdisk.29296819.xyz92shidai.comddoslaosijiWinSrv2008x64liteWinSrv2008x64-Chinese.vhd.gz'
  SYSMIRROR18='httpdisk.29296819.xyz92shidai.comddosothercn2003-virtio-pass-Linode.gz'
  SYSMIRROR19='httpdisk.29296819.xyz92shidai.comddoslaosijiWinSrv200310GWinSrv2003x86-Chinese-C10G.vhd.gz'
  SYSMIRROR20='httpdisk.29296819.xyz92shidai.comddoslaosijiWin10Win10_x64.vhd.gz'
  SYSMIRROR21='httpdisk.29296819.xyz92shidai.comddoslaosijiWin7Windows7x86-Chinese.vhd.gz'
  SYSMIRROR22='httpdisk.29296819.xyz92shidai.comddoslaosijiWin7Win7-Ent.gz'

  if [[ $isCN == '1' ]];then
    sed -i 's#httpdisk.29296819.xyz92shidai.cnddimgwget_udeb_amd64.tar.gz#httpsraw.githubusercontent.comfcurrkreinstallmasterwget_udeb_amd64.tar.gz#' tmpCore_Install.sh
    CMIRROR=--mirror httpmirrors.aliyun.comcentos
    CVMIRROR=--mirror httpmirrors.tuna.tsinghua.edu.cncentos-vault
    DMIRROR=--mirror httpmirrors.aliyun.comdebian
    UMIRROR=--mirror httpmirrors.aliyun.comubuntu
    SYSMIRROR1='httpdisk.29296819.xyz92shidai.cnddosveip007CentOS-7.img.gz'
    SYSMIRROR2='httpdisk.29296819.xyz92shidai.cnddoscxthhhhhCentOS_7.X_NetInstallation.vhd.gz'
    SYSMIRROR3='httpdisk.29296819.xyz92shidai.cnddoscxthhhhhCentOS_8.X_NetInstallation.vhd.gz'
    SYSMIRROR12='httpdisk.29296819.xyz92shidai.cnddoscxthhhhhDisk_Windows_Server_2019_DataCenter_CN.vhd.gz'
    SYSMIRROR13='httpdisk.29296819.xyz92shidai.cnddoscxthhhhhDisk_Windows_Server_2016_DataCenter_CN.vhd.gz'
    SYSMIRROR14='httpdisk.29296819.xyz92shidai.cnddoscxthhhhhDisk_Windows_Server_2012R2_DataCenter_CN.vhd.gz'
    SYSMIRROR15='httpdisk.29296819.xyz92shidai.cnddoslaosijiWinSrv2012r2x64liteWinSrv2012r2_v2.vhd.gz'
    SYSMIRROR16='httpdisk.29296819.xyz92shidai.cnddoscxthhhhhDisk_Windows_Server_2008R2_DataCenter_CN.vhd.gz'
    SYSMIRROR17='httpdisk.29296819.xyz92shidai.cnddoslaosijiWinSrv2008x64liteWinSrv2008x64-Chinese.vhd.gz'
    SYSMIRROR18='httpdisk.29296819.xyz92shidai.cnddosothercn2003-virtio-pass-Linode.gz'
    SYSMIRROR19='httpdisk.29296819.xyz92shidai.cnddoslaosijiWinSrv200310GWinSrv2003x86-Chinese-C10G.vhd.gz'
    SYSMIRROR20='httpdisk.29296819.xyz92shidai.cnddoslaosijiWin10Win10_x64.vhd.gz'
    SYSMIRROR21='httpdisk.29296819.xyz92shidai.cnddoslaosijiWin7Windows7x86-Chinese.vhd.gz'
    SYSMIRROR22='httpdisk.29296819.xyz92shidai.cnddoslaosijiWin7Win7-Ent.gz'

  fi
  
  sed -i 's$1$UIl1uSg0$tAW9qjOqoCto0CIUgUwHT1$1$C7j0ZaEl$4qQdj2VyJFH1neyqcO0qm0' tmpCore_Install.sh

  echo -e nPlease select an OS
  echo    1) CentOS 7.7 (ext4)
  echo    2) CentOS 7 (cxthhhh)
  echo    3) CentOS 8 (cxthhhh)
  echo    4) CentOS 6
  echo    5) Debian 10
  echo    6) Debian 9
  echo    7) Debian 8
  echo    8) Debian 7
  echo    9) Ubuntu 18.04
  echo   10) Ubuntu 16.04
  echo   11) Ubuntu 14.04
  echo   12) Windows Server 2019
  echo   13) Windows Server 2016
  echo   14) Windows Server 2012
  echo   15) Windows Server 2012 Lite
  echo   16) Windows Server 2008
  echo   17) Windows Server 2008 Lite
  echo   18) Windows Server 2003
  echo   19) Windows Server 2003 Lite
  echo   20) Windows 10 LTSC Lite
  echo   21) Windows 7 x86 Lite
  echo   22) Windows 7 Ent Lite
  echo   99) Custom image
  echo    0) Exit
  echo -ne nYour option 
  read N
  case $N in
    1) echo -e nPassword Pwd@CentOSn; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh $NETSTR -dd $SYSMIRROR1 $DMIRROR ;;
    2) echo -e nPassword cxthhhhh.comn; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh $NETSTR -dd $SYSMIRROR2 $DMIRROR ;;
    3) echo -e nPassword cxthhhhh.comn; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh $NETSTR -dd $SYSMIRROR3 $DMIRROR ;;
    4) echo -e nPassword Minijer.comn; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh -c 6.10 -v 64 -a $NETSTR $CMIRROR ;;
    5) echo -e nPassword Minijer.comn; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh -d 10 -v 64 -a $NETSTR $DMIRROR ;;
    6) echo -e nPassword Minijer.comn; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh -d 9 -v 64 -a $NETSTR $DMIRROR ;;
    7) echo -e nPassword Minijer.comn; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh -d 8 -v 64 -a $NETSTR $DMIRROR ;;
    8) echo -e nPassword Minijer.comn; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh -d 7 -v 64 -a $NETSTR $DMIRROR ;;
    9) echo -e nPassword Minijer.comn; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh -u 18.04 -v 64 -a $NETSTR $UMIRROR ;;
    10) echo -e nPassword Minijer.comn; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh -u 16.04 -v 64 -a $NETSTR $UMIRROR ;;
    11) echo -e nPassword Minijer.comn; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh -u 14.04 -v 64 -a $NETSTR $UMIRROR ;;
    12) echo -e nPassword cxthhhhh.comn; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh $NETSTR -dd $SYSMIRROR12 $DMIRROR ;;
    13) echo -e nPassword cxthhhhh.comn; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh $NETSTR -dd $SYSMIRROR13 $DMIRROR ;;
    14) echo -e nPassword cxthhhhh.comn; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh $NETSTR -dd $SYSMIRROR14 $DMIRROR ;;
    15) echo -e nPassword WinSrv2012r2n; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh $NETSTR -dd $SYSMIRROR15 $DMIRROR ;;
    16) echo -e nPassword cxthhhhh.comn; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh $NETSTR -dd $SYSMIRROR16 $DMIRROR ;;
    17) echo -e nPassword WinSrv2008x64-Chinesen; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh $NETSTR -dd $SYSMIRROR17 $DMIRROR ;;
    18) echo -e nPassword Linoden; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh $NETSTR -dd $SYSMIRROR18 $DMIRROR ;;
    19) echo -e nPassword WinSrv2003x86-Chinesen; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh $NETSTR -dd $SYSMIRROR19 $DMIRROR ;;
    20) echo -e nPassword www.nat.een; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh $NETSTR -dd $SYSMIRROR20 $DMIRROR ;;
    21) echo -e nPassword Windows7x86-Chinesen; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh $NETSTR -dd $SYSMIRROR21 $DMIRROR ;;
    22) echo -e nPassword www.nat.een; read -s -n1 -p Press any key to continue... ; bash tmpCore_Install.sh $NETSTR -dd $SYSMIRROR22 $DMIRROR ;;        
    99)
      echo -e n
      read -r -p Custom image URL  imgURL
      echo -e n
      read -r -p Are you sure start reinstall [Yn]  input
      case $input in
        [yY][eE][sS][yY]) bash tmpCore_Install.sh $NETSTR -dd $imgURL $DMIRROR ;;
        ) clear; echo Canceled by user!; exit 1;;
      esac
      ;;
    0) exit 0;;
    ) echo Wrong input!; exit 1;;
  esac
}

SetNetwork
NetMode
Start
