#! /bin/bash
#本脚本要求：
#1/在/root目录下放置需要的软件包
#2/如需实现自动配置mysql目的，还需和mysql.sh脚本一同使用
#3/在/root目录下放置主机密钥文件authorized_keys
#4/在/root下放置想导入虚拟机中的软件包，然后可继续补入下面的脚本中

#获取虚拟机后缀，自定义主机名，IP地址后缀
read -p "指挥官您好，请输入你新建的虚拟机的名称后缀:" num
read -p "请您输入您想定义的主机名:" name
read -p "请输入您想建的网卡名:"  ethx
read -p "请您输入您想建的IP地址:" ip

#创建挂载点
mkdir /mnt/mount_kvm   &> /dev/null

#将虚拟机挂在到/mnt/mount_kvm目录下
guestmount -a /var/lib/libvirt/images/rh7_node"$num".img -i /mnt/mount_kvm

#判断虚拟机硬盘是否挂载上
if [ $? -ne 0 ];then
	exit  &&  echo "虚拟机未挂载到/MNT目录下"
fi

#配置主机名
echo $name  > /mnt/mount_kvm/etc/hostname

#配置网卡
echo "TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=$ethx
DEVICE=$ethx
ONBOOT=yes
IPADDR=$ip
PREFIX=24" > /mnt/mount_kvm/etc/sysconfig/network-scripts/ifcfg-$ethx

#配置YUM
rm -rf /mnt/mount_kvm/etc/yum.repos.d/*
echo "[rhel7]
name=rhel7
baseurl=ftp://192.168.4.254/rhel7
enabled=1
gpgcheck=0" > /mnt/mount_kvm/etc/yum.repos.d/rhel.repo

#将需要的软件包复制到虚拟机/root目录下
cp -r /root/lnmp_soft /mnt/mount_kvm/root/
cp -r /root/soft /mnt/mount_kvm/root/
cp /root/myshell/auto_mysql.sh /mnt/mount_kvm/root/

#将ssh密钥复制到虚拟机/root/.ssh/目录下
mkdir /mnt/mount_kvm/root/.ssh/
cp /root/authorized_keys /mnt/mount_kvm/root/.ssh/

#将虚拟机硬盘卸载
umount /mnt/mount_kvm

#打开虚拟机
virsh start rh7_node$num

#清理屏幕多于输出信息
clear

#报告信息
echo "*********************************************************************************"

echo
echo
echo
echo "                         虚拟机已初始化完毕，您现在可以远程登陆使用"
echo
echo
echo

echo "*********************************************************************************"
