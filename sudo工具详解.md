# sudo工具详解

sudo 绝非仅仅只是一条命令，sudo 是一款你可以根据需求和偏好去定制的工具。

Ubuntu、Debian 以及其他的发行版在默认的配置下，赋予了 sudo 以 root 用户的身份执行任意命令的权限。这让很多用户误以为 sudo 就像一个魔法开关，瞬间可以获取到 root 权限。

比如说，系统管理员可以设置成只有属于特定的 dev 组的部分用户才能用 sudo 来执行 nginx 命令。这些用户将无法用 sudo 执行任何其他命令或切换到 root 用户。


## 配置sudo
sudo 命令是通过 /etc/sudoers 文件进行配置的。

虽然你可以用你最喜欢的 终端文本编辑器itsfoss.com 编辑这个文件，比如 Micro、NeoVim 等，但你千万不要这么做。

为什么这么说呢？因为该文件中的任何语法错误都会让你的系统出问题，导致 sudo 无法工作。这可能会使得你的 Linux 系统无法正常使用。

```shell
# backup sudo cp /etc/sudoers /etc/sudoers.bak
sudo visudo
```

传统上，visudo 命令会在 Vi 编辑器中打开 /etc/sudoers 文件。如果你用的是 Ubuntu，那么会在 Nano 中打开。

这么做的好处在于，visudo 会在你试图保存更改时执行语法检查。这能确保你不会因为语法错误而误改 sudo 配置。

### 密码显示星号

如果想让 sudo 输入密码时显示星号，运行 sudo visudo 并找到以下行：

在某些发行版中，比如 Arch，你可能找不到 Defaults env_reset 这一行。如果这样的话，只需新增一行 Defaults env_reset, pwfeedback 就可以了。

```shell
# Defaults env_reset
Defaults env_reset,pwfeedback
```


### sudo密码超时时限

当你首次使用 sudo 时，它会要求输入密码。但在随后相当一段时间里，你使用 sudo 执行命令就无需再次输入密码。

我们将这个时间间隔称为 sudo 密码超时 （暂且称为 SPT，这是我刚刚编的说法，请不要真的这样称呼 😁）。

不同的发行版有不同的超时时间。可能是 5 分钟，也可能是 15 分钟。

你可以根据自己的喜好来改变这个设置，设定一个新的 sudo 密码超时时限。

像你之前看到的，编辑 sudoers 文件，找到含有 Defaults env_reset 的行，并在此行添加 timestamp_timeout=XX，使其变成如下形式：

```shell
#  timestamp_timeout=100min passwd_tries=3次重试
Defaults env_reset, timestamp_timeout=100, passwd_tries=3
```

如果你还有其他参数，例如你在上一节中看到的星号反馈，它们都可以在一行中组合起来：
```shell
Defaults  env_reset, timestamp_timeout=XX, pwfeedback
```


### sudo无密码

从安全角度来看，这听起来似乎很冒险，对吧？的确如此，但在某些实际情况下，你确实会更青睐无密码的 sudo。

例如，如果你需要远程管理多台 Linux 服务器，并为了避免总是使用 root，你在这些服务器上创建了一些 sudo 用户。辛酸的是，你会有太多的密码。而你又不想对所有的服务器使用同一的 sudo 密码。

在这种情况下，你可以仅设置基于密钥的 SSH 访问方式，并允许使用无需密码的 sudo。这样，只有获得授权的用户才能访问远程服务器，也不用再记住 sudo 密码。

```sh
# 当然，你需要将行中的 user_name 替换为实际的用户名。
user_name ALL=(ALL) NOPASSWD:ALL
```

### 配置独立的 sudo 日志文件

但若需要单独针对 sudo 的记录，可以专门创建一个自定义的日志文件。例如，选择 /var/sudo.log 文件来存储日志。这个新的日志文件无需手动创建，如果不存在，系统会自动生成。

```sh
Defaults  logfile="/var/log/sudo.log"
```



### 限制特定用户组使用 sudo 执行特定命令
这是一种高级解决方案，系统管理员在需要跨部门共享服务器的多用户环境中会使用。

开发者可能会需要以 root 权限运行 Web 服务器或其他程序，但全权给予他们 sudo 权限会带来安全风险。我建议在群组级别进行此项操作。例如，创建命名为 coders 的群组，并允许它们运行在 /var/www 和 /opt/bin/coders 目录下的命令（或可执行文件），以及 inxi 命令itsfoss.com（路径是 /usr/bin/inxi 的二进制文件）。这是一个假想情景，实际操作请谨慎对待。

接下来，用 sudo visudo 编辑 sudoer 文件，再添加以下行:
```sh
%coders   ALL=(ALL:ALL) /var/www,/opt/bin/coders,/usr/bin/inxi
```
如有需要，可以添加 NOPASSWD 参数，这样允许使用 sudo 运行的命令就不再需要密码了。


### 检查用户的 sudo 权限

如何确认一个用户是否具有 sudo 权限呢？可能有人会说，查看他们是否是 sudo 组的成员。但这并不一定准确，因为有些发行版用的是 wheel 代替 sudo 分组。

更佳的方法是利用 sudo 内建的功能，看看用户具有哪种 sudo 权限：

```sh
sudo -l -U user_name
```
这将显示出用户具有执行部分命令或所有命令的 sudo 权限。

如果一个用户完全没有 sudo 权限，你将看到如下提示：
```sh
User prakash is not allowed to run sudo on this-that-server.
```

### 输错彩蛋

用 sudo visudo 修改 sudo 配置文件，然后添加以下行：
```sh
Defaults   insults
```