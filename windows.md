# windows 指令

## Chocolatey windows包管理

官网: https://chocolatey.org/install

### 常用命令

- 安装三方包
```shell
choco install notepadplusplus
```
- 升级三方包
```shell
choco upgrade notepadplusplus
```
```
# 升级自己
choco upgrade chocolatey
```

- 卸载三方包
```
choco uninstall chocolatey
```


## sudo 命令

Sudo for Windows 将允许用户直接从未提权终端窗口运行提权命令。

如何启用 Sudo for Windows
导航至 Settings > For Developers page in Windows Settings and toggle on the “Enable Sudo” 选项：

![](../readme.assets/Pasted%20image%2020240319230932.png)
也可以通过运行以下命令：

```
sudo config --enable <configuration_option>
```

![](../readme.assets/Pasted%20image%2020240319230944.png)

#### **如何配置 Sudo for Windows**

目前支持三种不同的配置选项：

1. **开启新窗口** **(forceNewWindow)**
    
2. **禁用输入** **(disableInput)**
    
3. **内联** **(normal)**
    

要更改配置选项，可使用 Settings > For Developers page in Windows Settings 页面中的下拉菜单：

![](../readme.assets/Pasted%20image%2020240319230955.png)


或运行以下命令：

```
sudo config --enable <configuration_option>
```

**配置选项 1：开启新窗口**

在此配置中，Sudo for Windows 将打开一个新的窗口并运行命令。这是启用 sudo 时的默认配置选项。例如，如果运行：

```
sudo netstat -ab
```

![](../readme.assets/Pasted%20image%2020240319231004.png)

**配置选项 2：禁用输入**

在此配置中，Sudo for Windows 将在当前窗口中运行提权后的进程，但新进程生成时将关闭其 stdin。这意味着新进程将不接受任何用户输入，因此此配置不适用于提权后需要用户进一步输入的进程。

**配置选项 3：内联**

此配置与其他操作系统上 sudo 的行为最相似。在此配置中，Sudo for Windows 将运行提权的进程，其 stdin、stdout 和 stderr 均连接到当前窗口。这意味着新的提权进程可以接收输入并 route output 到当前窗口。

![](../readme.assets/Pasted%20image%2020240319231025.png)

