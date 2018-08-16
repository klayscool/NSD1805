#! /bin/bash
#本脚本用于在虚拟机内使用，使用前请给脚本执行权限

#安装mysql依赖包及主程序
cd /root/soft/mysql
yum -y install perl-JSON
rpm -Uvh mysql-community-*.rpm

#启动服务
systemctl  start mysqld
systemctl  enable mysqld

#修改主配置文件
sed -i '4a validate_password_policy=0' /etc/my.cnf
sed -i '5a validate_password_length=6' /etc/my.cnf

#重起服务
systemctl restart mysqld 

#初次进入mysql服务
pass=`awk '/password/{print $11}' /var/log/mysqld.log | head -1`
mysql -uroot -p$pass

#请自行修改密码

