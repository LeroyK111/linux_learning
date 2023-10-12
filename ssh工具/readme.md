# ssh工具用法

不同系统环境的ssh工具安装方式不同。
## 安装方式

Linux/ubuntu
```shell
apt install ssh
```

MacOs
```
brew install openssh
```

windows/可选功能
`勾选可选功能，选择安装ssh服务器`
![](../../readme.assets/Pasted%20image%2020231004004518.png)
![](../../readme.assets/Pasted%20image%2020231004004538.png)

```powershell
# ssh client order
ssh root@127.0.0.1 -p 22

# ssh service order
net stop sshd
net start sshd
net restart sshd
```

## linux配置方法
本文只专注于linux ssh工具配置。

```
# ssh 配置文件夹
/etc/ssh/
sshd_config
ssh_config
moduli
ssh_config.d
ssh_host_ecdsa_key.pub
ssh_host_ed25519_key.pub 
ssh_host_rsa_key.pub  
sshd_config.d
ssh_host_ecdsa_key  
ssh_host_ed25519_key    
ssh_host_rsa_key          
```

### ssh_config
```shell
  

# This is the ssh client system-wide configuration file.  See

# ssh_config(5) for more information.  This file provides defaults for

# users, and the values can be changed in per-user configuration files

# or on the command line.

  

# Configuration data is parsed as follows:

#  1. command line options

#  2. user-specific file

#  3. system-wide file

# Any configuration value is only changed the first time it is set.

# Thus, host-specific definitions should be at the beginning of the

# configuration file, and defaults at the end.

  

# Site-wide defaults for some commonly used options.  For a comprehensive

# list of available options, their meanings and defaults, please see the

# ssh_config(5) man page.

  

Include /etc/ssh/ssh_config.d/*.conf

# 任意ip

Host *

# 此行将 ForwardAgent 设置为 no，表示禁用SSH代理转发。

#   ForwardAgent no

# 此行将 ForwardX11 设置为 no，表示禁用X11转发。

#   ForwardX11 no

# 此行将 ForwardX11Trusted 设置为 yes，表示允许在X11转发时信任客户端的X11显示。

#   ForwardX11Trusted yes

# 设置为 yes，表示允许密码身份验证。

#   PasswordAuthentication yes

# 设置为 no，表示禁用基于主机的身份验证。

#   HostbasedAuthentication no

# GSSAPI协议强化

#   GSSAPIAuthentication no

#   GSSAPIDelegateCredentials no

#   GSSAPIKeyExchange no

#   GSSAPITrustDNS no

# 此行将 BatchMode 设置为 no，表示不启用批处理模式。

#   BatchMode no

# 此行将 CheckHostIP 设置为 yes，表示SSH将检查远程主机的IP地址以确保其与之前连接的主机具有相同的IP地址。

#   CheckHostIP yes

# 此行将 AddressFamily 设置为 any，表示SSH服务器将侦听任何IP地址族的连接，包括IPv4和IPv6。

#   AddressFamily any

# 此行将 ConnectTimeout 设置为0，表示连接超时被禁用。

#   ConnectTimeout 0

# 私钥地址

#   StrictHostKeyChecking ask

#   IdentityFile ~/.ssh/id_rsa

#   IdentityFile ~/.ssh/id_dsa

#   IdentityFile ~/.ssh/id_ecdsa

#   IdentityFile ~/.ssh/id_ed25519

# 端口

#   Port 22

# 密钥算法

#   Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc

#   MACs hmac-md5,hmac-sha1,umac-64@openssh.com

# 此行将 EscapeChar 设置为 ~，表示 ~ 字符将被用作SSH逃脱字符。

#   EscapeChar ~

# 此行将 Tunnel 设置为 no，表示禁用SSH隧道功能。

#   Tunnel no

# 此行指定了SSH隧道的设备参数。在这里，配置为 any:any，表示隧道可以使用任何可用的网络设备。

#   TunnelDevice any:any

#  此行将 PermitLocalCommand 设置为 no，表示禁止在SSH会话中执行本地命令。

#   PermitLocalCommand no

# 此行将 VisualHostKey 设置为 no，表示禁用SSH客户端的可视主机密钥功能。

#   VisualHostKey no

# 此行配置了SSH客户端的代理命令。

#   ProxyCommand ssh -q -W %h:%p gateway.example.com

# 此行配置了重新协商密钥的限制。

#   RekeyLimit 1G 1h

# 此行指定了用户已知主机文件的路径。

#   UserKnownHostsFile ~/.ssh/known_hosts.d/%k

# 环境变量

    SendEnv LANG LC_*

# 此行将 HashKnownHosts 设置为 yes，表示在用户已知主机文件 (~/.ssh/known_hosts) 中对主机名和公钥进行散列处理。

    HashKnownHosts yes

# 此行将 GSSAPIAuthentication 设置为 yes，表示启用GSSAPI身份验证。

    GSSAPIAuthentication yes
```


### sshd_config
```shell
#   $OpenBSD: sshd_config,v 1.103 2018/04/09 20:41:22 tj Exp $

# This is the sshd server system-wide configuration file.  See

# sshd_config(5) for more information.

  

# This sshd was compiled with PATH=/usr/bin:/bin:/usr/sbin:/sbin

  

# The strategy used for options in the default sshd_config shipped with

# OpenSSH is to specify options with their default value where

# possible, but leave them commented.  Uncommented options override the

# default value.

  

# 目录中的附加配置文件。它允许你将SSH服务器配置分成多个文件，以便更好地组织。

Include /etc/ssh/sshd_config.d/*.conf

  

# 监听端口

Port 22

# 监听地址类型

AddressFamily any

# ipv4

ListenAddress 0.0.0.0

# ipv6

ListenAddress ::

  

# 密钥地址

#HostKey /etc/ssh/ssh_host_rsa_key

#HostKey /etc/ssh/ssh_host_ecdsa_key

#HostKey /etc/ssh/ssh_host_ed25519_key

  

#  是一个OpenSSH服务器配置选项，它用于控制在SSH连接中重新协商密钥的频率。具体来说，RekeyLimit 可以设置为两个值，分别表示数据传输量和时间

#RekeyLimit default none

  

# ssh服务器日志选项

#SyslogFacility AUTH

#LogLevel INFO

  

# 登录选项

# Authentication:

  

# 用于指定允许用户在成功登录之前等待的时间

#LoginGraceTime 2m

# 选项用于控制是否允许 root 用户直接通过 SSH 登录到服务器

#PermitRootLogin prohibit-password

PermitRootLogin yes

# 用于控制是否强制对用户家目录和.ssh 目录的权限进行严格检查。

#StrictModes yes

# 用于设置在一个连接中允许的最大身份验证尝试次数。

#MaxAuthTries 6

# 用于限制一个用户能够同时拥有的最大SSH会话数

#MaxSessions 10

  

# 用于启用或禁用公钥身份验证

#PubkeyAuthentication yes

  

# 用于指定用于公钥身份验证的授权密钥文件的路径。

# Expect .ssh/authorized_keys2 to be disregarded by default in future.

#AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2

  

# 是用于配置 OpenSSH 服务器的选项，它用于指定一个文件，其中包含了授权用户的主体（principals）列表。

#AuthorizedPrincipalsFile none

  

# 这行配置指定了授权密钥的命令，但它被设置为 none，表示禁用了授权密钥命令。

#AuthorizedKeysCommand none

# 如果启用了授权密钥命令，这行配置指定了运行授权密钥命令的用户。

#AuthorizedKeysCommandUser nobody

  

# 是一个用于配置 OpenSSH 服务器的选项，它用于控制是否允许基于主机的身份验证（Host-based Authentication）。

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts

#HostbasedAuthentication no

# 是一个用于配置 OpenSSH 服务器的选项，它控制服务器是否忽略用户的个人 known_hosts 文件中的主机密钥。

# Change to yes if you don't trust ~/.ssh/known_hosts for

# HostbasedAuthentication

#IgnoreUserKnownHosts no

# 是一个用于配置 OpenSSH 服务器的选项，它用于控制是否忽略用户的 .rhosts 和 .shosts 文件，这些文件通常与 rsh（远程shell）和rlogin（远程登录）相关联。

# Don't read the user's ~/.rhosts and ~/.shosts files

#IgnoreRhosts yes

  

# 是 OpenSSH 服务器配置选项之一，它控制是否允许使用密码进行身份验证。

# To disable tunneled clear text passwords, change to no here!

PasswordAuthentication yes

# 支持空密码验证登录

PermitEmptyPasswords yes

  

# 是 OpenSSH 服务器配置选项之一，它用于控制是否允许使用挑战-响应身份验证方式

# Change to yes to enable challenge-response passwords (beware issues with

# some PAM modules and threads)

ChallengeResponseAuthentication no

  

# Kerberos身份验证选项，这是一种高度安全的身份验证协议

# Kerberos options

  

# 此行将Kerberos身份验证禁用，因为KerberosAuthentication被设置为 no。Kerberos身份验证通常用于强化SSH连接的安全性，但在某些情况下可能需要额外的配置和集成。

#KerberosAuthentication no

#  此行将KerberosOrLocalPasswd设置为 yes，表示如果Kerberos身份验证失败，SSH服务器将尝试本地密码身份验证。这允许用户在Kerberos身份验证不可用或失败时使用密码登录。

#KerberosOrLocalPasswd yes

# 此行将KerberosTicketCleanup设置为 yes，表示SSH服务器将负责清理已过期的Kerberos票证。

#KerberosTicketCleanup yes

# 此行将KerberosGetAFSToken设置为 no，表示SSH服务器不会获取AFS（Andrew File System）令牌。AFS是一个分布式文件系统，通常与Kerberos一起使用。

#KerberosGetAFSToken no

  

# 身份验证选项，它是一种用于增强SSH连接安全性的身份验证协议。

# GSSAPI options

# 此行将GSSAPI身份验证禁用，因为 GSSAPIAuthentication 被设置为 no。

#GSSAPIAuthentication no

# 设置为 yes，表示SSH服务器将负责清理GSSAPI凭据。

#GSSAPICleanupCredentials yes

# 此行将 GSSAPIStrictAcceptorCheck 设置为 yes，表示SSH服务器将对客户端提供的GSSAPI凭据进行严格的接收者检查。

#GSSAPIStrictAcceptorCheck yes

# 此行将 GSSAPIKeyExchange 设置为 no，表示禁用GSSAPI密钥交换。

#GSSAPIKeyExchange no

  

# Set this to 'yes' to enable PAM authentication, account processing,

# and session processing. If this is enabled, PAM authentication will

# be allowed through the ChallengeResponseAuthentication and

# PasswordAuthentication.  Depending on your PAM configuration,

# PAM authentication via ChallengeResponseAuthentication may bypass

# the setting of "PermitRootLogin without-password".

# If you just want the PAM account and session checks to run without

# PAM authentication, then enable this but set PasswordAuthentication

# and ChallengeResponseAuthentication to 'no'.

UsePAM yes

  

# 此配置行启用了代理转发（Agent Forwarding）。代理转发允许SSH客户端在连接到服务器时将其密钥代理（SSH代理）传递给服务器，以便在服务器上访问密钥来进行身份验证，通常用于跳板服务器或多级SSH连接的场景。

#AllowAgentForwarding yes

  

# 此配置行允许TCP端口转发。TCP端口转发允许SSH客户端通过SSH隧道将本地端口映射到远程服务器上，从而实现网络服务的访问，例如访问服务器上的Web应用程序。

#AllowTcpForwarding yes

  

#  此配置行控制TCP端口转发时的网关端口行为。如果设置为 no，则远程主机上的端口只会绑定到本地主机，不会绑定到远程主机的所有网络接口。

#GatewayPorts no

  

# 这行配置启用了X11转发，允许在SSH会话中运行图形化应用程序。这对于远程访问图形界面非常有用。

X11Forwarding yes

  

# 这行配置指定了X11显示的偏移量。X11是用于图形用户界面（GUI）的协议，它允许在SSH会话中运行图形化应用程序。

#X11DisplayOffset 10

  

# 此行将 X11UseLocalhost 设置为 yes，表示X11服务器将仅监听本地主机（localhost）的连接请求。

#X11UseLocalhost yes

  

# 这是一个被注释掉的配置行，用于控制是否允许SSH用户分配伪终端（PTY）。伪终端是用于与终端应用程序交互的模拟终端设备。

#PermitTTY yes

  

# 此行将 PrintMotd 设置为 no，表示服务器不会在用户登录时显示MOTD（Message of the Day）消息。

PrintMotd no

  

# 此行将 PrintLastLog 设置为 yes，表示SSH服务器会在用户登录时显示最后一次登录的信息。

PrintLastLog yes

  

# 这是一个被注释掉的配置行，用于控制是否启用TCP Keep-Alive。

#TCPKeepAlive yes

  

# 这是一个被注释掉的配置行，用于控制是否允许SSH用户定义自己的环境变量。

#PermitUserEnvironment no

  

# 此行配置了延迟压缩，这意味着SSH服务器将在通信开始后应用数据压缩。

#Compression delayed

  

# 这是一个被注释掉的配置行，用于设置客户端存活检测的时间间隔。

#ClientAliveInterval 0

  

# 这是一个被注释掉的配置行，用于设置客户端存活检测的最大尝试次数。

#ClientAliveCountMax 3

  

# 此行将 UseDNS 设置为 no，表示服务器将禁用DNS反向解析来验证客户端的主机名。

#UseDNS no

  

# 这是一个被注释掉的配置行，用于指定SSH服务器的进程ID（PID）文件的路径。

#PidFile /var/run/sshd.pid

  

# 这是一个被注释掉的配置行，用于控制允许的最大并发SSH连接数。

#MaxStartups 10:30:100

  

# 此行将 PermitTunnel 设置为 no，表示禁用了SSH隧道功能。

#PermitTunnel no

  

# 这是一个被注释掉的配置行，用于指定Chroot（Change Root）环境的根目录。

#ChrootDirectory none

# 这是一个被注释掉的配置行，用于指定SSH服务器版本信息的附加内容。

#VersionAddendum none

  

# 是一个OpenSSH服务器的配置选项，用于指定登录前的自定义欢迎横幅（Banner）信息。

# no default banner path

# Banner /etc/ssh/banner.txt

#Banner none

  

# 是 OpenSSH 服务器的配置选项之一，用于控制哪些环境变量可以从SSH客户端传递到SSH服务器。

# Allow client to pass locale environment variables

AcceptEnv LANG LC_*

  

# OpenSSH服务器的配置选项，用于指定SFTP（SSH文件传输协议）子系统的执行程序。

# override default of no subsystems

Subsystem   sftp    /usr/lib/openssh/sftp-server

  

# 为不同的用户提供不同的配置

# Example of overriding settings on a per-user basis

#Match User anoncvs

#   X11Forwarding no

#   AllowTcpForwarding no

#   PermitTTY no

#   ForceCommand cvs server
```

## 常用命令

### 设置账号密码登录
```
passwd root
```

### 基本命令
不同的release version Linux 则有不同且类似的命令。 
这里我们用早期Debian GNU/Linux 命令。

```shell
service ssh {start|stop|reload|force-reload|restart|try-restart|status}
```


### 为 docker ekuiper 写一个启动script

```shell
#!/bin/bash
service ssh start
echo "ssh starting..."
```
```sh
# 启动脚本
./bin/myShell.sh
```