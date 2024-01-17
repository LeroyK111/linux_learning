# Linux制作一个deb包

deb 文件是包含数据的存档。标有扩展名，用于轻松分发和安装 Linux Debian 及其衍生发行版适合的程序。当您的应用程序需要处理其他依赖项、将自身与桌面集成、运行安装前和安装后脚本等时，Deb 文件非常方便。（与deb格式功能类似的另一种包格式是Fedora系列发行版常用的rpm文件。）

本文通过实例演示了如何制作一个简单的deb包，讲解了deb包的内部各个文件的作用，以及安装后在系统中如何生效、如何维护。

## deb 包剖析

deb 是一个标准的 Unix ar 存档格式[1]，其中包含应用程序和其他实用程序文件。最重要的一个是控制文件（control），它存储了有关 deb 包及其安装的程序的信息。

1. 在内部，deb包 包含了模拟 Linux 的典型文件系统目录结构的文件集合，例如 /usr 、/usr/bin 、/opt等 。在安装过程中，放置在其中一个目录中的文件将被复制到实际文件系统中的同一位置。例如 软件包内的`<.deb>/usr/bin/binaryfile` 这样的二进制文件将安装到系统的 `/usr/bin/binaryfile`。
    
2. 在外部，所有 deb 包文件都遵循特定的命名约定：

```shell
<软件名称>_<主版本号>-<修订版本号>_<硬件架构>.deb
```

假设您要发布名为 mynano 的程序，版本 1.0，该程序是为 64 位处理器(AMD64)构建的。您的 deb 文件名将类似于 mynano_1.0-0_amd64.deb
## 制作 deb 包

现在，我们已准备好生成包。确保您的系统中安装了 dpkg-deb 工具（来自 dpkg 软件包，可通过`sudo apt install dpkg 安装`）：稍后将使用`dpkg-deb` 生成最终deb包。

1. 创建工作目录 创建一个临时工作目录以将包放入其中。遵循我们之前看到的相同命名约定。例如：
```sh
cd ~  
mkdir mynano_1.0-1_amd64/
```
2. 创建内部结构 将程序文件放在目标系统上应安装的位置。假设您希望将可执行文件安装到：/usr/bin/
    

首先创建目录：
```sh
mkdir -p mynano_1.0-1_amd64/usr/bin/
```
mkdir命令的-p标志将创建嵌套目录，如果其中任意目录不存在则自动创建。然后将可执行文件复制到其中：
```sh
# 假设你开发的程序可执行文件为 ~/YourProjects/mynano/src/targets/release/mynano  
cp ~/YourProjects/mynano/src/targets/release/mynano  mynano_1.0-1_amd64/usr/bin/
```
3. 创建文件control 该文件位于DEBIAN目录中（注意目录名为大写字母）
    

先创建文件夹：DEBIAN
```sh
mkdir mynano_1.0-1_amd64/DEBIAN
```
然后创建空文件：control
```sh
touch mynano_1.0-1_amd64/DEBIAN/control
```
4. 填写control文件内容：
```sh
Package: mynano  
Version: 1.0  
Architecture: amd64  
Maintainer: linuxlibs <info@linuxlibs.com>  
Description: 基于nano的自定义编辑器  
Depends: nano (>= 5.0)
```
其中

- Package– 程序名称;
    
- Version– 程序版本;
    
- Architecture— 目标架构;
    
- Maintainer– 包裹维护负责人的姓名和电子邮件地址;
    
- Description– 程序的简要说明。
    
- Depends- 本软件包依赖的其他软件包。
    

该文件可能包含其他有用的字段，例如Depends指出deb包的依赖项列表。那么如果借助 apt 命令安装 deb包的时候，就会先安装上 nano>=5.0版本的软件包，再安装 mynano。

5. 最后一步：构建 deb 包 按如下方式调用dpkg-deb：
```sh
dpkg-deb --build --root-owner-group <package-dir>
dpkg-deb --build --root-owner-group <mynano_1.0-1_amd64>
```
这里的 `--root-owner-group` 标志使所有 deb 包内容都归 root 用户所有，这是标准方法。如果没有这样的标志，所有文件和文件夹的`属主`都为您当前的用户，但考虑到 deb 软件包将安装到的系统中并不一定存在与你同名账号，所以使用`--root-owner-group` 更合理。

上面的命令将在工作目录旁边生成一个.deb的文件，或者如果包内有错误或丢失，则打印错误。如果操作成功，就可以分发这个生成的 deb 包给他人了。

6. 使用deb包安装到系统：可以看到，通过apt方式安装我们制作的deb包的时候，会自动安装上依赖项：`nano` 软件包

```sh
# apt install ./mynano_1.0-1_amd64.deb  
正在读取软件包列表... 完成  
正在分析软件包的依赖关系树... 完成  
正在读取状态信息... 完成  
注意，选中 'mynano' 而非 './mynano_1.0-1_amd64.deb'  
将会同时安装下列软件：  
  nano  
建议安装：  
  hunspell  
下列【新】软件包将被安装：  
  mynano nano  
升级了 0 个软件包，新安装了 2 个软件包，要卸载 0 个软件包，有 79 个软件包未被升级。  
需要下载 280 kB/1,135 kB 的归档。  
解压缩后会消耗 881 kB 的额外空间。  
您希望继续执行吗？ [Y/n] y  
获取:1 /root/my-nano-editor-src/mynano_1.0-1_amd64.deb mynano amd64 1.0.0 [855 kB]  
获取:2 https://mirrors.ustc.edu.cn/ubuntu jammy/main amd64 nano amd64 6.2-1 [280 kB]  
已下载 280 kB，耗时 1秒 (422 kB/s)  
正在选中未选择的软件包 nano。  
(正在读取数据库 ... 系统当前共安装有 231799 个文件和目录。)  
准备解压 .../archives/nano_6.2-1_amd64.deb  ...  
正在解压 nano (6.2-1) ...  
正在选中未选择的软件包 mynano。  
准备解压 .../mynano_1.0-1_amd64.deb  ...  
正在解压 mynano (1.0.0) ...  
正在设置 nano (6.2-1) ...  
update-alternatives: 使用 /bin/nano 来在自动模式中提供 /usr/bin/editor (editor)  
update-alternatives: 使用 /bin/nano 来在自动模式中提供 /usr/bin/pico (pico)  
正在设置 mynano (1.0.0) ...  
正在处理用于 install-info (6.8-4build1) 的触发器 ...  
正在处理用于 man-db (2.10.2-1) 的触发器 ...  
Scanning processes...  
Scanning processor microcode...  
Scanning linux images...
```

7. 【非必须】卸载安装的软件 mynano：
```sh
# apt remove mynamo -y  
正在读取软件包列表... 完成  
正在分析软件包的依赖关系树... 完成  
正在读取状态信息... 完成  
下列软件包将被【卸载】：  
  mynano  
升级了 0 个软件包，新安装了 0 个软件包，要卸载 1 个软件包，有 79 个软件包未被升级。  
解压缩后会消耗 0 B 的额外空间。  
您希望继续执行吗？ [Y/n] y  
(正在读取数据库 ... 系统当前共安装有 231872 个文件和目录。)  
正在卸载 mynano (1.0.0) ...
```
8. 【非必须】查询 mynano_0.1-1_amd64.deb 的依赖关系：dpkg -I ./mynano*deb

## 以上制作deb包的方式，还有哪些可改进的地方：

以上并没有加入文件安装后的额外处理脚本，而实际的deb软件包，很多在安装前、安装后还要执行一些初始化服务配置脚本；或执行测试命令验证安装效果是否正常；安装后通过脚本启动后台服务。

如何实现？

deb的规范支持添加 preinst、postinst、prerm 和 postrm 这4个脚本。置于/DEBIAN/目录下。注意，这4个文件对于制作deb包来说，不是必须的，有需要的时候才添加。

例如我们为mynano在`mynano_1.0-1_amd64/DEBIAN/` 目录下添加4个文件：

![](../README.assets/Pasted%20image%2020240118010948.png)
![](../README.assets/Pasted%20image%2020240118011000.png)
![](../README.assets/Pasted%20image%2020240118011037.png)
下面分别介绍每个脚本文件的作用：

1. preinst 安装前做一些初始化工作，如目录创建，文件创建，配置文件初始化等。
    
2. postInst 安装后做一些服务设置的处理。
    
3. prerm 此脚本通常会停止与包关联的任何守护程序。它在删除与包关联的文件之前执行。
    
4. postrm 此脚本用于修改链接或相关文件，然后删除安装包对应的系统文件。
