# 一键DD脚本
一键DD脚本，支持性好，更智能更全面。

##安装重装系统的前提组件:
#Debian/Ubuntu:
```shell
apt-get install -y xz-utils openssl gawk file wget screen && screen -S os
```
#RedHat/CentOS:
```shell
yum install -y xz openssl gawk file glibc-common wget screen && screen -S os
```
##如果出现异常，请刷新Mirrors缓存或更换镜像源。
#RedHat/CentOS:
```shell
yum makecache && yum update -y
```
#Debian/Ubuntu:
```shell
apt update -y && apt dist-upgrade -y
```

##使用:
```shell
wget --no-check-certificate -O AutoReinstall.sh https://raw.githubusercontent.com/fcurrk/reinstall/master/AutoReinstall.sh && chmod a+x AutoReinstall.sh && bash AutoReinstall.sh
```


