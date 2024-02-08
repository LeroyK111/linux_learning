# 外星人工具（alien）实现RPM与Deb软件包格式互转

与其它软件包共存 Debian 包格式并非唯一用于自由软件领域的软件包格式。主要竞争者是红帽 Linux 发行版的 RPM 格式以及其衍生格式。红帽是一个非常流行的商业化发行版。对于来自第三方的软件，常以 RPM 格式软件包提供，而非 Debian 格式。

这个情况下，你应该知道rpm程序是如何处理RPM软件包的，这种格式在Debian软件包中也可用。需要谨慎的使用，尽管如何，这些操作会限制从一个软件包中解压并且提取出信息以验证其完整性。实际上，不应该在Debian系统中使用rpm来安装一个RPM软件包；RPM使用了它自己的数据库以便和Debian的软件中分离（比如dpkg）。这也就是为什么不可能确保两个包管理系统共存在一个系统中，而这个系统还能保持稳定。

另一方面，alien 可以把RPM软件包转换成Debian软件包，反之亦然。

使用alien开始转换 rpm包为deb包。这里的fakeroot是让命令觉得自己以root权限执行，这样可以伪装命令产生的文件有root权限，而不是当前普通用户账号权限。root文件权限打包后在其他系统上有更好的兼容性。

```sh
$ fakeroot alien --to-deb phpMyAdmin-5.1.1-2.fc35.noarch.rpm  
[..]  
Warning: Skipping conversion of scripts in package phpMyAdmin: postinst  
Warning: Use the --scripts parameter to include the scripts.  
[..]  
phpmyadmin_5.1.1-3_all.deb generated
```
此时从 rpm 包生成了phpmyadmin的deb包。
```sh
$ ls -sh phpmyadmin_5.1.1-3_all.deb  
  6,0M phpmyadmin_5.1.1-3_all.deb
```
查看该deb文件包含的文件：
```sh
$ dpkg -c phpmyadmin_5.1.1-3_all.deb  
drwxr-xr-x root/root         0 2024-01-20 02:02 ./  
drwxr-xr-x root/root         0 2024-01-20 02:02 ./etc/  
drwxr-xr-x root/root         0 2024-01-20 02:02 ./etc/httpd/  
drwxr-xr-x root/root         0 2024-01-20 02:02 ./etc/httpd/conf.d/  
-rw-r--r-- root/root      1181 2024-01-20 09:32 ./etc/httpd/conf.d/phpMyAdmin.conf  
drwxr-xr-x root/root         0 2024-01-20 02:02 ./etc/nginx/  
drwxr-xr-x root/root         0 2024-01-20 02:02 ./etc/nginx/default.d/  
-rw-r--r-- root/root       430 2024-01-20 09:32 ./etc/nginx/default.d/phpMyAdmin.conf  
drwxr-x--- root/root         0 2024-01-20 02:02 ./etc/phpMyAdmin/  
-rw-r----- root/root      4546 2024-01-20 09:34 ./etc/phpMyAdmin/config.inc.php  
drwxr-xr-x root/root         0 2024-01-20 02:02 ./usr/  
drwxr-xr-x root/root         0 2024-01-20 02:02 ./usr/share/  
drwxr-xr-x root/root         0 2024-01-20 02:02 ./usr/share/doc/  
drwxr-xr-x root/root         0 2024-01-20 02:02 ./usr/share/doc/phpMyAdmin/  
[..]
```

根据之前文章对deb包格式的介绍，实际上rpm跟deb包的构成有很多相似之处，文件布局都是按Unix/Linux标准文件系统的目录层次存储的，所以他们之间的转换就变得可行。

使用dpkg -I 查看deb包文件的信息：
```sh
$ dpkg -I phpmyadmin_5.1.1-3_all.deb  
 new Debian package, version 2.0.  
 size 6195324 bytes: control archive=44444 bytes.  
     102 bytes,     3 lines      conffiles  
     593 bytes,    15 lines      control  
  180405 bytes,  1919 lines      md5sums  
     448 bytes,    11 lines   *  postinst             #!/bin/sh  
 Package: phpmyadmin  
 Version: 5.1.1-3  
 Architecture: all  
 Maintainer: Daniel Leidert <dleidert@debian.org>  
 Installed-Size: 40693  
 Section: alien  
 Priority: extra  
 Description: A web interface for MySQL and MariaDB  
  phpMyAdmin is a tool written in PHP intended to handle the administration of  
  MySQL over the Web. Currently it can create and drop databases,  
  create/drop/alter tables, delete/edit/add fields, execute any SQL statement,  
  manage keys on fields, manage privileges,export data into various formats and  
  is available in 50 languages  
  .  
  (Converted from a rpm package by alien version 8.95.4.)
```
作为对比，使用`rpm -qi` 命令 查询 rpm包信息的方式为：
```sh
# rpm -qi phpMyAdmin-5.2.1-1.el7.remi.noarch.rpm  
warning: phpMyAdmin-5.2.1-1.el7.remi.noarch.rpm: Header V4 DSA/SHA1 Signature, key ID 00f97f56: NOKEY  
Name        : phpMyAdmin  
Version     : 5.2.1  
Release     : 1.el7.remi  
Architecture: noarch  
Install Date: (not installed)  
Group       : Unspecified  
Size        : 49748878  
License     : GPL-2.0-or-later AND MIT AND BSD 2-Clause AND BSD 3-Clause AND LGPL-3.0-or-later AND MPL-2.0 AND ISC  
Signature   : DSA/SHA1, Wed Feb  8 14:36:12 2023, Key ID 004e6f4700f97f56  
Source RPM  : phpMyAdmin-5.2.1-1.el7.remi.src.rpm  
Build Date  : Wed Feb  8 14:30:01 2023  
Build Host  : builder.remirepo.net  
Packager    : Remi Collet  
Vendor      : Remi's RPM repository <https://rpms.remirepo.net/> #StandWithUkraine  
URL         : https://www.phpmyadmin.net/  
Bug URL     : https://forum.remirepo.net/  
Summary     : A web interface for MySQL and MariaDB  
Description :  
phpMyAdmin is a tool written in PHP intended to handle the administration of  
MySQL over the Web. Currently it can create and drop databases,  
create/drop/alter tables, delete/edit/add fields, execute any SQL statement,  
manage keys on fields, manage privileges,export data into various formats and  
is available in 50 languages
```

所以alien 软件的作用是将 rpm和deb的文件以及控制信息，按照两种格式规范转换，最终底层通过dpkg-deb和rpm-build这两个工具，分别实现重新打包。

上面介绍了rpm包转换为deb包：
```sh
$ fakeroot alien --to-deb phpMyAdmin-5.1.1-2.fc35.noarch.rpm
```

## deb包转换为rpm包：

可通过
```sh
$ fakeroot alien --to-rpm pphpmyadmin_5.1.1-3_all.deb
```

## 那么alien软件如何安装呢？

```sh
# 1. ubuntu/debian 下安装 alien：
apt install alien
# 2. 红帽系列的发行版安装 alien：
yum install epel-release -y
yum install alien fakeroot -y
```
