# Macos cmd&Skill


## 跟linux指令不同的地方

其他的都类似了。
以下是 macOS 和 Linux 常用指令的区别对比表：

| 功能        | macOS 指令                             | Linux 指令                                  | 说明                                                     |
| --------- | ------------------------------------ | ----------------------------------------- | ------------------------------------------------------ |
| 包管理       | `brew install`（Homebrew）             | `apt-get install` / `yum install`         | macOS 使用 Homebrew，而 Linux 根据发行版使用 APT、YUM 等包管理工具。      |
| 文件查看权限    | `ls -l`                              | `ls -l`                                   | macOS 和 Linux 这点相同。                                    |
| 文件系统挂载    | `diskutil mount`                     | `mount`                                   | macOS 使用 `diskutil` 来管理磁盘和分区。                          |
| 查看磁盘信息    | `diskutil list`                      | `lsblk` / `fdisk -l`                      | macOS 使用 `diskutil list`，Linux 使用 `lsblk` 或 `fdisk`。   |
| 修改文件权限    | `chmod`                              | `chmod`                                   | 两者相同。                                                  |
| 修改文件属主    | `chown`                              | `chown`                                   | 两者相同。                                                  |
| 设置文件扩展属性  | `xattr`                              | 不适用                                       | macOS 支持扩展属性管理，Linux 无此命令。                             |
| 网络设置      | `networksetup`                       | `nmcli` / `ifconfig`                      | macOS 使用 `networksetup`，Linux 使用 NetworkManager 或其他工具。 |
| 进程管理      | `ps` / `kill` / `Activity Monitor`   | `ps` / `kill` / `htop`                    | 命令类似，但 macOS 提供图形化的 Activity Monitor。                  |
| 查看系统信息    | `system_profiler`                    | `uname -a` / `lscpu`                      | macOS 使用 `system_profiler`，Linux 有更多工具如 `lscpu`。       |
| 软件安装路径查找  | `which` / `where`                    | `which`                                   | macOS 使用 `which` 和 `where`，Linux 通常只用 `which`。         |
| 查看内存使用    | `vm_stat`                            | `free -m`                                 | macOS 使用 `vm_stat`，Linux 使用 `free`。                    |
| 清理缓存      | `purge`                              | `sync; echo 3 > /proc/sys/vm/drop_caches` | macOS 使用 `purge` 清理缓存，Linux 用 `sync` 命令刷新缓存。           |
| 查看 CPU 信息 | `sysctl -n machdep.cpu.brand_string` | `lscpu`                                   | macOS 使用 `sysctl` 查看 CPU 信息。                           |
| 软件卸载      | 手动删除 `.app`                          | 使用包管理器如 `apt-get remove`                  | macOS 软件通常通过 Finder 或 `rm -rf` 删除，Linux 用包管理器卸载。       |

## 专用包管理
macOS 上有几个常用的包管理工具，主要用来安装、更新和管理软件和工具，以下是一些推荐的专用包管理工具：

### **Homebrew**

最受欢迎的 macOS 包管理器，支持安装 CLI 工具和 GUI 应用。

- **官网**: [https://brew.sh](https://brew.sh/)
- **安装命令**:
    
    bash
    
    Copy code
    
    `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
    
- **常用命令**:
    - 搜索包：`brew search <package_name>`
    - 安装包：`brew install <package_name>`
    - 更新包：`brew upgrade <package_name>`
    - 查看已安装包：`brew list`

> Homebrew 附带一个 **Cask** 子工具，可以用于安装 macOS 的 GUI 应用程序：

bash

Copy code

`brew install --cask <app_name>`

示例：`brew install --cask google-chrome`




## ⭐️安装三方软件遇到的坑

### picgo 图床

遇到
![](https://raw.githubusercontent.com/LeroyK111/pictureBed/master/04193854.png)

```
安装后打开 picgo 报错：xxx 已损坏，无法打开。您应该将它移到废纸篓
```
当从非 Mac App Store 或未经苹果认证的来源（比如直接从网络下载）安装应用时，macOS 会自动给这些文件加上 `com.apple.quarantine` 属性，以标记其为“不信任的软件”。运行这些软件时，可能会提示“无法打开”或“开发者未验证”等警告。

你就需要解除限制
```sh
sudo xattr -r -d com.apple.quarantine /Applications/PicGo.app
```

