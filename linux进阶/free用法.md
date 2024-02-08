# free 查看内存

现在，让我分享一些 `free` 命令常用的选项：

| 选项 | 描述 |
| ---- | ---- |
| `-h` | 通过调整 KB、GB 等数据单位，以人类可读的形式打印信息。 |
| `-s` | 在给定的时间间隔后更新 `free` 输出。 |
| `-t` | 显示系统和交换内存的总量。 |
| `-g` | 以 GB 为单位显示数据。 |
| `-m` | 以 MB 为单位打印信息。 |
| `-k` | 以 KB 为单位显示输出。 |

但是如果执行不带选项的 `free` 命令会怎样呢？你可以看到下面的内容：
![](../README.assets/Pasted%20image%2020240121182318.png)


这里，

◈ `total`：表示存储总量。

◈ `used`：显示系统已使用的存储空间。

◈ `free`：可用于新进程的可用内存量。

◈ `shared`：tmpfs（临时文件系统）使用的内存量。

◈ `buff/cache`: 表示缓冲区和缓存使用的内存总和。

◈ `available`：它估计有多少内存可用于启动新应用而无需交换。它是`free` 内存和可以立即使用的 `buff/cache` 的一部分的总和。

因此，如果你想要各种信息，只需输入不带选项的命令即可。

一旦执行 `free` 命令，它只会显示执行该命令时的统计信息。例如，如果我在 `12:45` 执行 `free` 命令，那么它只会显示该时间的统计信息。

所以问题是：如何实现类似的行为，如显示实时统计数据的 [htop](https://mp.weixin.qq.com/s?__biz=MjM5NjQ4MjYwMQ==&mid=2664695949&idx=2&sn=d3ed8b6b18079242c6404ec636c2acc0&chksm=bc05c5270ac7b3f4eb19f7d1591eedf0bab1177e138651e93a7e26d8d254f67e344d146d3293&scene=126&sessionid=1705757262&key=7cedef53c5f4beed98dc6d80ff54c7713d43c7a1190978c942d04fb549196a8eff9b6bb6804ee67011a7500a908de8ccd8ed6fd52022e43867310591c343b848323d9224d63998612b89b76d9ac90a28d2e628964120ff0809bd03a3e83d42a8fcc4d39a4b6c8d66a6ea30f34c08df6e89d99e2d0e5a8e341eafb3764ca73e19&ascene=0&uin=MTg2NTA5OTQ3Nw%3D%3D&devicetype=Windows+11+x64&version=6309091b&lang=zh_CN&countrycode=CN&exportkey=n_ChQIAhIQk6uxfJXH3lg4RmZ6YkmHRRLgAQIE97dBBAEAAAAAAAHqBXeVJ8IAAAAOpnltbLcz9gKNyK89dVj0ZWezWzOZGDWNEWlFzHeBn7XcQCurB5lk%2FY%2BsS6UlMZfYNfGFa6xQrSefxbCK%2BRXiDgzXACDoMqdKITTG2%2BsIdt7rMHXfwMWV1ftVDtGaso1FON3fYhU%2BChacwaXMyPUZ53oBZTdrWTWFmwjq3UIKkiitsv9xE%2FmU%2B%2FYflwqr7VmU8cZ9F8GeqO%2BY2dIA%2FkBd7eTox4Y5pAijxtVmLLeo1i7ze6E62kg66UP6C96rPHd25te3JB4d5k0r&acctmode=0&pass_ticket=dFRygnFPx%2FfgouAJfZEQIXrORdxhdFacUz4NRBqktfwPYw8RRV8GOzyqIjLU%2BMZNt2PJo2W9Ad4TgZ2PBVFWww%3D%3D&wx_header=1&fasttmpl_type=0&fasttmpl_fullversion=7038836-zh_CN-zip&fasttmpl_flag=1)itsfoss.com？这不完全相同，但你可以使用 `-s` 标志以特定时间间隔刷新统计信息，如下所示：

![](../README.assets/Pasted%20image%2020240121182428.png)


## 定义显示统计数据的次数

在前面的示例中，我解释了如何使用 `free` 命令连续显示统计信息，但你可能不希望它无休止地刷新，而只刷新几次。

为此，你可以使用 `-c` 标志，如下所示：
![](../README.assets/Pasted%20image%2020240121182502.png)

<img src="https://mmbiz.qpic.cn/sz_mmbiz_gif/W9DqKgFsc68jKNJtLK6EdcCuzWoWrv938fEib2l9hMpib3nA7wdA2aA9RjQ7ZURAOLLxPa0iaaUJ6L7xbiawdXicpqg/640?wx_fmt=gif&from=appmsg&wxfrom=5&wx_lazy=1&wx_co=1"/>
默认情况下，它将每秒刷新一次数据，但你可以使用 `-s` 标志来指定间隔时间：
![](../README.assets/Pasted%20image%2020240121182549.png)

## 指定输出数据类型

虽然对于大多数用户来说，使用 `-h` 标志以人类可读的形式显示数据就可以完成工作，但是如果你想自己指定数据类型怎么办？

那么，你可以使用以下标志指定数据类型：

|标志|描述|
|---|---|
|`--kilo` 或 `-k`|以 KB 为单位显示内存。|
|`--mega` 或 `-m`|以 MB 节为单位显示内存。|
|`--giga` 或 `-g`|以 GB 为单位显示内存。|
|`--tera`|以 TB 为单位显示内存。|


![](../README.assets/Pasted%20image%2020240121182637.png)


## 获取物理内存和交换内存的总和
![](../README.assets/Pasted%20image%2020240121182701.png)

