#! /bin/bash
#本脚本要求：
#1/在/root目录下放置需要的软件包
#2/如需实现自动配置mysql目的，还需和mysql.sh脚本一同使用
#3/在/root目录下放置主机密钥文件authorized_keys
#4/在/root下放置想导入虚拟机中的软件包，然后可继续补入下面的脚本中

#获取虚拟机后缀，自定义主机名，IP地址后缀
echo "尊敬的指挥官：
	您好，我是副官T701号，现为您进行虚拟战场初始化设置"
echo
echo
echo

read -p "请输入你预定义的虚拟战场的名称后缀(rh7_nodeX):" num
read -p "请输入您预定义的虚拟战场名(hostname):" name
read -p "请输入您预定义的网卡名(eth0/eth1/eth2/eth3):"  ethx
read -p "请输入您预定义的IP地址(x.x.x.x):" ip

#创建挂载点
mkdir /mnt/mount_kvm   &> /dev/null

#防止之前因操作失误而造成挂载点的不纯净而影响本次执行
rm -rf /mnt/mount_kvm/*
umount /mnt/mount_kvm  &> /dev/null

#将虚拟机挂在到/mnt/mount_kvm目录下
guestmount -a /var/lib/libvirt/images/rh7_node"$num".img -i /mnt/mount_kvm

#判断虚拟机硬盘是否挂载上
if [ $? -ne 0 ];then
	echo "WARNING：挂载失败，请检查"  &&  exit
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

case $ethx in
eth0)
echo "[rhel7]
name=rhel7
baseurl=ftp://192.168.4.254/rhel7
enabled=1
gpgcheck=0" > /mnt/mount_kvm/etc/yum.repos.d/rhel.repo ;;
eth1)
echo "[rhel7]
name=rhel7
baseurl=ftp://192.168.2.254/rhel7
enabled=1
gpgcheck=0" > /mnt/mount_kvm/etc/yum.repos.d/rhel.repo ;;
eth2)
echo "[rhel7]
name=rhel7
baseurl=ftp://201.1.1.254/rhel7
enabled=1
gpgcheck=0" > /mnt/mount_kvm/etc/yum.repos.d/rhel.repo ;;
eth3)
echo "[rhel7]
name=rhel7
baseurl=ftp://201.1.2.254/rhel7
enabled=1
gpgcheck=0" > /mnt/mount_kvm/etc/yum.repos.d/rhel.repo ;;
*)
echo "WARNING:网卡选项未知，YUM配置错误,请检查" && exit
esac

#将需要的软件包复制到虚拟机/root目录下
#cp -r /root/one-boot/lnmp_soft /mnt/mount_kvm/root/
cp -r /root/one-boot/soft /mnt/mount_kvm/root/
cp /root/one-boot/auto_mysql.sh /mnt/mount_kvm/root/

#将ssh密钥复制到虚拟机/root/.ssh/目录下,添加hostkey到know_hosts
mkdir /mnt/mount_kvm/root/.ssh/
cp /root/one-boot/authorized_keys /mnt/mount_kvm/root/.ssh/

sed -i '35c StrictHostKeyChecking no' /etc/ssh/ssh_config

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
