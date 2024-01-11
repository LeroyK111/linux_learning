# dpkg 基础安装包

dpkg 是 Debian/Ubuntu这类Linux发行版 系统上操作软件包的基础指令。如果有 .deb 软件包，那么可以用 dpkg 来安装或分析其内容。但此指令只能看到 Debian 世界的部分内容：它知道系统安装了那些软件包，以及命令行给出了什么，但不知道其它还有哪些可用的软件包（也不知道从哪里找到所依赖的不同软件包）。而 apt 和 aptitude 这样的工具，相反，会可产生相依性清单，来尽量自动地安装软件包。但 dpkg 和 apt 用于不同场合：dpkg常用语本地查询软件包状态、离线安装软件包，而apt常用于在线安装软件包且自动解析和安装依赖的其他软件，所以两者的一些用法有区别也是合理的。

## 使用 dpkg -i 命令安装软件包的时候，底层做了哪些事情
dpkg 是安装 Debian 已经可用软件包的工具 (因为不需下载任何东西)，如果待安装的软件包man-db_2.9.4-2_amd64.deb（假设当前目录下有个 man-db_2.9.4-2_amd64.deb 文件），依赖的其他软件包都已安装，只查这个包文件待安装，就适合使用 dpkg 代替apt去安装这个软件包。

dpkg 的参数`-i` 表示安装指定的软件包，例如：
```sh
# dpkg -i man-db_2.9.4-2_amd64.deb  
(Reading database ... 227466 files and directories currently installed.)  
Preparing to unpack man-db_2.9.4-2_amd64.deb ...  
Unpacking man-db (2.9.4-2) over (2.8.5-2) ...  
Setting up man-db (2.9.4-2) ...  
Updating database of manual pages ...  
man-db.service is a disabled or a static unit not running, not starting it.  
Processing triggers for mailcap (3.69) ...
```
dpkg -i 方式安装 deb软件包，底层实际上做了2件事（2个阶段）：

拆包（将安装包内的文件提取到目标路径）
配置（执行脚本，对软件运行所需的配置文件、文件权限等进行最后的设置、必要的调整）
所以，以上 dpkg -i man-db…….deb 等效于执行以下2步骤：
```
# dpkg --unpack man-db_2.9.4-2_amd64.deb  
……  
# dpkg --configure man-db  
……
```
```
# 当前路径下有2个空目录，一个deb安装包，其中 deb安装包来自于：apt-get download man-db 命令下载得到的文件。  
# ~/src/tmp# ls    
admindir/   
rootdir/  
man-db_2.10.2-1_amd64.deb   
  
# 为了验证 --unpack 是否解压出文件，我们指定` --root=rootdir`  
# ~/src/tmp# dpkg --admindir=admindir --root=rootdir --unpack man-db_2.10.2-1_amd64.deb    
  
# tree rootdir/
```
可以看到输出结果是 deb 安装包的文件列表，带有完整的目录层级（只不过都在当前目录下的 rootdir/目录下）
```sh
# tree  rootdir/  
rootdir/  
├── etc  
│   ├── apparmor.d  
│   │   └── usr.bin.man.dpkg-new  
│   ├── cron.daily  
│   │   └── man-db.dpkg-new  
│   ├── cron.weekly  
│   │   └── man-db.dpkg-new  
│   └── manpath.config.dpkg-new  
├── lib  
│   └── systemd  
│       └── system  
│           ├── man-db.service  
│           └── man-db.timer  
├── usr  
│   ├── bin  
│   │   ├── apropos -> whatis  
│   │   ├── catman  
│   │   ├── lexgrog  
│   │   ├── man  
│   │   ├── mandb  
│   │   ├── manpath  
│   │   ├── man-recode  
│   │   └── whatis  
│   ├── lib  
│   │   ├── man-db  
│   │   │   ├── libman-2.10.2.so  
│   │   │   ├── libmandb-2.10.2.so  
│   │   │   ├── libmandb.so -> libmandb-2.10.2.so  
│   │   │   ├── libman.so -> libman-2.10.2.so  
│   │   │   ├── man -> ../../bin/man  
│   │   │   └── mandb -> ../../bin/mandb  
│   │   ├── mime  
│   │   │   └── packages  
│   │   │       └── man-db  
│   │   └── tmpfiles.d  
│   │       └── man-db.conf  
│   ├── libexec  
│   │   └── man-db  
│   │       ├── globbing  
│   │       ├── manconv  
│   │       └── zsoelim  
│   ├── sbin  
│   │   └── accessdb  
│   └── share  
│       ├── bug  
│       │   └── man-db  
│       │       └── presubj  
│       ├── doc  
│       │   └── man-db  
│       │       ├── ChangeLog-2013.gz  
│       │       ├── changelog.Debian.gz  
│       │       ├── copyright  
……
```

我们可以用 通过 dpkg --contents (= dpkg-deb --contents) 来列出档案文件清单（deb包内的文件目录层级列表）

```sh
# dpkg  --contents man-db_2.10.2-1_amd64.deb  
  
       0 2022-03-18 03:03 ./  
       0 2022-03-18 03:03 ./etc/  
       0 2022-03-18 03:03 ./etc/apparmor.d/  
    3448 2022-03-18 03:03 ./etc/apparmor.d/usr.bin.man  
       0 2022-03-18 03:03 ./etc/cron.daily/  
    1330 2022-03-18 03:03 ./etc/cron.daily/man-db  
       0 2022-03-18 03:03 ./etc/cron.weekly/  
    1020 2022-03-18 03:03 ./etc/cron.weekly/man-db  
    5217 2022-03-18 03:03 ./etc/manpath.config  
       0 2022-03-18 03:03 ./lib/  
       0 2022-03-18 03:03 ./lib/systemd/  
       0 2022-03-18 03:03 ./lib/systemd/system/  
     738 2022-03-18 03:03 ./lib/systemd/system/man-db.service  
     171 2022-03-18 03:03 ./lib/systemd/system/man-db.timer  
       0 2022-03-18 03:03 ./usr/  
       0 2022-03-18 03:03 ./usr/bin/  
   35592 2022-03-18 03:03 ./usr/bin/catman  
  102144 2022-03-18 03:03 ./usr/bin/lexgrog  
  120504 2022-03-18 03:03 ./usr/bin/man  
   36536 2022-03-18 03:03 ./usr/bin/man-recode  
  143296 2022-03-18 03:03 ./usr/bin/mandb  
   31520 2022-03-18 03:03 ./usr/bin/manpath  
   48416 2022-03-18 03:03 ./usr/bin/whatis  
       0 2022-03-18 03:03 ./usr/lib/  
       0 2022-03-18 03:03 ./usr/lib/man-db/  
  193008 2022-03-18 03:03 ./usr/lib/man-db/libman-2.10.2.so  
   30864 2022-03-18 03:03 ./usr/lib/man-db/libmandb-2.10.2.so  
       0 2022-03-18 03:03 ./usr/lib/mime/  
       0 2022-03-18 03:03 ./usr/lib/mime/packages/  
    1863 2022-03-18 03:03 ./usr/lib/mime/packages/man-db  
       0 2022-03-18 03:03 ./usr/lib/tmpfiles.d/  
      33 2022-03-18 03:03 ./usr/lib/tmpfiles.d/man-db.conf  
       0 2022-03-18 03:03 ./usr/libexec/  
       0 2022-03-18 03:03 ./usr/libexec/man-db/  
   23320 2022-03-18 03:03 ./usr/libexec/man-db/globbing  
   28248 2022-03-18 03:03 ./usr/libexec/man-db/manconv  
   52048 2022-03-18 03:03 ./usr/libexec/man-db/zsoelim  
       0 2022-03-18 03:03 ./usr/sbin/  
   14904 2022-03-18 03:03 ./usr/sbin/accessdb  
       0 2022-03-18 03:03 ./usr/share/  
       0 2022-03-18 03:03 ./usr/share/bug/  
       0 2022-03-18 03:03 ./usr/share/bug/man-db/  
     369 2022-03-18 03:03 ./usr/share/bug/man-db/presubj  
       0 2022-03-18 03:03 ./usr/share/doc/  
       0 2022-03-18 03:03 ./usr/share/doc/man-db/  
  141531 2022-03-18 02:41 ./usr/share/doc/man-db/ChangeLog-2013.gz  
    3276 2022-03-18 02:41 ./usr/share/doc/man-db/FAQ  
   25504 2022-03-18 02:41 ./usr/share/doc/man-db/NEWS.md.gz  
    4907 2022-03-18 02:41 ./usr/share/doc/man-db/README.md.gz  
    3271 2022-03-18 02:41 ./usr/share/doc/man-db/THANKS  
     646 2022-03-18 02:41 ./usr/share/doc/man-db/TODO  
    1898 2022-03-18 03:03 ./usr/share/doc/man-db/changelog.Debian.gz  
    2191 2022-03-18 03:03 ./usr/share/doc/man-db/copyright  
……
```

deb保内的目录层次结构和 我们unpack出的rootdir内的文件列表一致。

那么上述第二步 # dpkg --configure man-db 的底层层做了什么呢？由于这个参数不支持 与 --root=rootdir 同用，而且--configure 要求软件文件已部署到/目录下，所以只能使用其他方式验证--configure 的效果。

这里采用一种特殊的方式检测dpkg --configure man-db底层做了什么。思路如下：

1. 使用debootstrap 创建一个干净的ubuntu 22.04（jammy）纯净系统的目录，debootstrap命令可以从网上下载必要的文件，在当前系统下构造出符合要求的可执行的系统，就像刚安装好的ubuntu server版本的效果。新系统在myfancyinstall 目录下。
```sh
debootstrap jammy myfancyinstall
```
2. 提前复制 man-db_2.9.4-2_amd64.deb 文件到 myfancyinstall/root/目录下，将作为纯净系统的man-db软件安装测试。
    
3. 使用chroot 命令切换到该目录，即可模拟运行里面的ubuntu系统。
```
chroot myfancyinstall
```
4. 在纯净系统里 使用dpkg --unpack 我们的man-db安装包文件，注意不指定  --root=rootdir  参数，这样文件会安装到纯净系统的/下的标准路径内。
```
# cd /root/  
# dpkg --unpack man-db_2.10.2-1_amd64.deb    
Selecting previously unselected package man-db.  
(Reading database ... 16791 files and directories currently installed.)  
Preparing to unpack man-db_2.10.2-1_amd64.deb ...  
Unpacking man-db (2.10.2-1) ...
```
5. apt安装git版本管理工具，将/整个目录的文件做一次版本记录：
```
# apt install -y git  
# cd / ;   
# git config --global user.name "Your Name"  
# git config --global user.email "youremail@yourdomain.com"  
# git init .  
# git add *;   
# git commit . -m "init status of / all files";
```
6. 使用dpkg --configure man-db 配置man-db
```
# dpkg --configure man-db
```
7. 最后通过 git status / 查看`dpkg --configure man-db`执行后，哪些文件发生了哪些变化；
```
# cd /  
# git status   
# git diff
```
由于 man-db 软件没有需要configure的，所以 git status 显示--configure后，没有任何文件发生变化。

再以 vim 的deb包作为对比：
```
# apt-get download vim  
# dpkg --unpack vim_2%3a8.2.3995-1ubuntu2_amd64.deb  
# cd / ;   
#  git add *;  
# git commit . -m "after dpkg unpack vim package";  
[master 74646e41] after dpkg unpack vim package  
 18 files changed, 855 insertions(+)  
 create mode 100644 root/vim_2%3a8.2.3995-1ubuntu2_amd64.deb  
 create mode 100755 usr/bin/vim.basic  
 create mode 100644 usr/share/bug/vim/presubj  
 create mode 100755 usr/share/bug/vim/script  
 create mode 100644 usr/share/doc/vim/NEWS.Debian.gz  
 create mode 100644 usr/share/doc/vim/changelog.Debian.gz  
 create mode 100644 usr/share/doc/vim/copyright  
 create mode 100644 usr/share/lintian/overrides/vim  
 create mode 100644 var/lib/dpkg/info/vim.list  
 create mode 100644 var/lib/dpkg/info/vim.md5sums  
 create mode 100755 var/lib/dpkg/info/vim.postinst  
 create mode 100755 var/lib/dpkg/info/vim.postrm  
 create mode 100755 var/lib/dpkg/info/vim.preinst  
 create mode 100755 var/lib/dpkg/info/vim.prerm
```
这里列出的`create mode 100644` 状态的文件，是vim包经过`--unpack`后，新增到系统路径下的文件。

继续：dpkg --configure vim，会遇到报错
```
# dpkg --configure vim  
dpkg: dependency problems prevent configuration of vim:  
 vim depends on vim-runtime (= 2:8.2.3995-1ubuntu2); however:  
  Package vim-runtime is not installed.  
 vim depends on libgpm2 (>= 1.20.7); however:  
  Package libgpm2 is not installed.  
 vim depends on libpython3.10 (>= 3.10.0); however:  
  Package libpython3.10 is not installed.  
 vim depends on libsodium23 (>= 1.0.14); however:  
  Package libsodium23 is not installed.  
  
dpkg: error processing package vim (--configure):  
 dependency problems - leaving unconfigured  
Errors were encountered while processing:  
 vim
```
这些vim-runtime等软件包，可以通过apt方式先安装：
```
# apt install vim-runtime   libgpm2 libpython3.10 libsodium23  
# cd / ;   
# git add *;  
# git commit . -m "after apt install vim-runtime   libgpm2 libpython3.10 libsodium23";
```
再次 执行`dpkg --configure vim`
```
# dpkg --configure vim  
dpkg: error processing package vim (--configure):  
 package vim is already installed and configured  
Errors were encountered while processing:  
 vim  
# dpkg --list | grep vim  
ii  vim                         2:8.2.3995-1ubuntu2                     amd64        Vi IMproved - enhanced vi editor  
ii  vim-common                  2:8.2.3995-1ubuntu2                     all          Vi IMproved - Common files  
ii  vim-runtime                 2:8.2.3995-1ubuntu2                     all          Vi IMproved - Runtime files  
ii  vim-tiny                    2:8.2.3995-1ubuntu2                     amd64        Vi IMproved - enhanced vi editor -
```
说明 vim 包自身在configure阶段，没有需要的操作。

同样过程，对nano包做一下`--configure`测试：
```sh
# apt-get download nano  
# dpkg --unpack nano_6.2-1_amd64.deb  
# cd /  
# git add *  
# git commit  -m "after unpack nano"  
#  dpkg --configure nano  
Setting up nano (6.2-1) ...  
update-alternatives: using /bin/nano to provide /usr/bin/editor (editor) in auto mode  
update-alternatives: using /bin/nano to provide /usr/bin/pico (pico) in auto mode
```
此处最后显示的就是 Settings 阶段做的事情：
![](../../readme.assets/Pasted%20image%2020240111212457.png)
说明 dpkg 安装的第二阶段，确实会执行配置过程。

通过 `git stauts /` 可以看出配置阶段修改了Linux系统的一些文件：
```
# git status /  
On branch master  
Changes not staged for commit:  
  (use "git add/rm <file>..." to update what will be committed)  
  (use "git restore <file>..." to discard changes in working directory)  
        modified:   etc/alternatives/editor  
        modified:   etc/alternatives/editor.1.gz  
        deleted:    etc/alternatives/editor.da.1.gz  
        deleted:    etc/alternatives/editor.de.1.gz  
        deleted:    etc/alternatives/editor.fr.1.gz  
        deleted:    etc/alternatives/editor.it.1.gz  
        deleted:    etc/alternatives/editor.ja.1.gz  
        deleted:    etc/alternatives/editor.pl.1.gz  
        deleted:    etc/alternatives/editor.ru.1.gz  
        deleted:    etc/nanorc.dpkg-new  
        deleted:    usr/share/man/da/man1/editor.1.gz  
        deleted:    usr/share/man/de/man1/editor.1.gz  
        deleted:    usr/share/man/fr/man1/editor.1.gz  
        deleted:    usr/share/man/it/man1/editor.1.gz  
        deleted:    usr/share/man/ja/man1/editor.1.gz  
        deleted:    usr/share/man/pl/man1/editor.1.gz  
        deleted:    usr/share/man/ru/man1/editor.1.gz  
        modified:   var/lib/dpkg/alternatives/editor  
        modified:   var/lib/dpkg/status  
        modified:   var/lib/dpkg/status-old  
        modified:   var/log/alternatives.log  
        modified:   var/log/dpkg.log  
  
Untracked files:  
  (use "git add <file>..." to include in what will be committed)  
        etc/alternatives/pico  
        etc/alternatives/pico.1.gz  
        etc/nanorc  
        usr/bin/pico  
        usr/share/man/man1/pico.1.gz  
        var/lib/dpkg/alternatives/pico
```

