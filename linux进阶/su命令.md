#  用户切换

Linux 中的 su 命令 当你用一个用户登录到终端 Shell 时，可能需要切换到另一个用户。

例如，你以 root 身份登录，进行了维护工作，但之后你想切换到别的用户账户。

你可以用 su 命令来完成：

su <用户名>
例如：su tom
如果你以用户身份登录，且不带参数运行 su 命令，它会遵从默认行为——提示你输入 root 用户的密码。

```sh
~$ su 
Password:
```
su 会以另一个用户的身份，开启新的 Shell。

当你完成操作，执行 exit即可关闭新开的 Shell，并回到当前用户的 Shell。

下面是 linux的man page帮助页面对su命令的完整说明：



命令名
su - 

用于切换到新用户和新组 ID 运行命令



命令格式

su [选项] [-] [用户 [参数...]]



命令描述

su 允许命令在切换为其他用户后运行。

在未指定用户的情况下调用时，su 默认为 以 root 身份运行交互式 shell。指定 user 时， 可以提供额外的参数，在这种情况下，这些参数会被传递 到shell。

为了向后兼容，su 默认不更改 当前目录，并仅设置环境变量 HOME 和 SHELL（如果目标用户不是 root，则会加上 USER 和 LOGNAME环境变量）。建议始终使用 --login 选项 （而不是它的快捷方式-），以避免环境混合引起的副作用。

此版本的 su 使用 PAM 进行身份验证、帐户和 会话管理。其他版本的 su 实现，还支持某些特殊配置选项，例如通过 PAM 配置来支持“wheel”组。

su 主要为非特权用户设计。对于特权用户推荐的解决方案（例如，由 root 执行的脚本） 是使用无需身份验证的 runuser(1) 命令，它支持单独设置PAM。如果 PAM 会话 完全不需要，那么推荐的解决方案是使用命令 setpriv(1)。

请注意，su 在所有情况下都用到 PAM （pam_getenvlist（3）） 进行最终的环境修改。命令行选项（如 --login 和 --preserve-environment）会在环境被PAM修改之前生效 。

从版本 2.38 开始，su 重置了进程资源限制值 RLIMIT_NICE、RLIMIT_RTPRIO、RLIMIT_FSIZE、RLIMIT_AS和RLIMIT_NOFILE。
```

命令选项
-c， --command=命令

        使用 -c 选项将命令传递给 shell。

-f， --fast

        将 -f 传递给 shell，它可能有用也可能用不动，具体取决于shell。

-g， --group=组

        指定主组。此选项可用于 仅限 root 用户。

-G， --supp-group=组

        指定补充组。此选项仅对 root 用户生效。如果未指定选项 --group，则第一个指定的补充组将默认作为主要组。

-， -l， --login

        以真实登录的环境值运行 shell，与用户真实登录类似：

            •清除除了 TERM 和 --whitelist-environment 指定的环境变量之外的所有环境变量

            •初始化环境变量 HOME、SHELL、USER、LOGNAME 和 PATH

            •切换到目标用户的家目录（如果存在）

            •将 shell 的 argv[0] 设置为“-”，以使 shell 成为login shell

-m、-p、--preserve-environment

    保留整个环境，即，不设置 HOME、SHELL、USER 或 LOGNAME。但如果指定了选项 --login，则本选项(-m, -p --preserve-environment)将被忽略而不生效。

-P， --pty

    为会话创建伪终端。独立的终端提供了更好的安全性，因为用户不与终端共享终端 原始会话。这可用于避免 TIOCSTI ioctl 终端 针对终端文件描述符的注入和其他安全攻击。这 整个会话也可以移动到后台（例如，su --pty - username -c application &）。如果 伪终端启用，则 su 会作为 会话之间的代理（同步 stdin 和 stdout）。

    此功能主要用于交互式会话。如果 标准输入不是终端，而是例如管道（例如，echo “date” |su --pty），那么伪终端的ECHO功能将被禁用以避免混乱的输出。

-s， --shell=指定的shell

        运行指定的 shell，而不是默认的 shell。根据以下规则选择要运行的 shell，顺序如下：

            •使用 --shell 指定的 shell

            •环境变量 SHELL 中指定的 shell值（如果su带有 --preserve-environment 选项）

            •在 /etc/passwd 中列出的 shell 目标用户

            •/bin/sh

    如果目标用户具有受限制的 shell（即未在 /etc/shells 文件中列出。/etc/shells文件内容在本文末尾有展示），则忽略 --shell 选项和 SHELL 环境变量，除非调用用户是 root。

--session-command=命令

        与 -c 相同，但不创建新会话。（不建议使用）

-w， --whitelist-environment=列表

        通过-w指定哪些些环境在带有 --login 时被不要被重置。列表形式为逗号分隔的环境变量列表。 HOME、SHELL、USER、LOGNAME 和 PATH 的白名单将被忽略。

-h， --帮助

        显示帮助文本并退出。

-V， --版本

        打印版本并退出。

```

信号

在收到 SIGINT、SIGQUIT 或 SIGTERM 信号后，su 终止其子进程，然后终止自身。若对信号的响应的再次尝试失败 且 2 秒延迟后，子进程将 SIGKILL 杀死。


配置文件
su 读取 /etc/default/su 和 /etc/login.defs 配置文件。文件中的下列配置项 与 su 相关：

FAIL_DELAY（数字）

    身份验证失败时的延迟（以秒为单位）。该数字必须是非负整数。

ENV_PATH（字符串）

    为普通用户定义 PATH 环境变量。PATH环境变量的默认值为 /usr/local/bin:/bin:/usr/bin。

ENV_ROOTPATH（字符串）、ENV_SUPATH（字符串）

    定义 root 用户的 PATH 环境变量。ENV_SUPATH优先起作用。默认值为   /usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin。

ALWAYS_SET_PATH（布尔值）

    如果设置为 yes 且未指定 --login 和 --preserve-environment 选项，则 su 会初始化 PATH 的值。

    环境变量 PATH 在不同Linux系统上可能不同，因为有的Linux发行版把 /bin 和 /sbin 作为软链接，指向到 /usr 中的/usr/bin/和 /usr/sbin/；本变量也受 --login 命令行选项和 PAM 系统设置的影响（例如，pam_env（8））。



退出状态
su 通常的退出值是它执行的命令的退出值。如果命令被信号终止，则 su 返回值等于 信号值加 128。

su 本身的退出值有3种：

1

    执行请求之前的一般错误 命令

126

    无法执行请求的命令

127

    未找到请求的命令


文件
/etc/pam.d/su

    su 的默认 PAM 配置文件

/etc/pam.d/su-l

    PAM 配置文件，如果 su 的选项带有--login 

/etc/default/su

    特定于命令的 logindef 配置文件

/etc/login.defs

    全局 logindef 配置文件


提醒
出于安全原因，su 始终会把失败的登录尝试 记录到 btmp 文件，但它不会写入 lastlog 文件。可通过 PAM 控制 su 行为 配置来解决。如果要使用 pam_lastlog（8） 模块打印 关于登录尝试失败的警告消息，那么 pam_lastlog（8） 要被配置，以更新 lastlog 文件。例如，包含配置内容：

   session required pam_lastlog.so nowtmp


历史
这个 su 命令派生自 coreutils ， 它基于 David MacKenzie 的实现。util-linux 版本已由 Karel Zak 重构。


另请参阅
setpriv（1）、login.defs（5）、shells（5）、pam（8）、runuser（1）


报告错误
错误报告可通过 https://github.com/util-linux/util-linux/issues 。


可用性
su 命令是 util-linux 软件包的一部分，它可以 从 Linux Kernel Archive https://www.kernel.org/pub/linux/utils/util-linux/ 下载。



su 的 man 帮助页英文原文，可点击左下角【阅读原文】查看。

备注：ubuntu的/etc/shells 文件的内容为：

# /etc/shells: valid login shells

/bin/sh

/bin/bash

/usr/bin/bash

/bin/rbash

/usr/bin/rbash

/usr/bin/sh

/bin/dash

/usr/bin/dash

/usr/bin/tmux

/usr/bin/screen