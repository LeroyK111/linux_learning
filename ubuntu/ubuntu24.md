# Ubuntu 24.04 LTS正式发布：集成最新LTS版Java和.NET、引入低延迟内核功能、UI更现代化

Ubuntu 24.04 LTS 已正式发布，代号 “Noble Numbat”。

Canonical 首席执行官 Mark Shuttleworth 称 Ubuntu 24.04 LTS 会提供至少 12 年的支持，并在性能工程和机密计算方面提升明显，还集成了通过 TCK 认证的 LTS 版本 Java、.NET 和最新的 Rust 工具链。

## Ubuntu 24.04 LTS 包含多项新功能，包括改进的 Ubuntu 桌面安装程序、新的 ZFS 和 TPM 支持等。

新版本使用 Linux 6.8 内核，可利用 Netplan 在桌面上配置网络连接，还配备了现代化的桌面操作系统安装程序，还带来了新版 Ubuntu 字体以及各种性能优化以及大量新功能。

此外，Ubuntu 24.04 LTS 还配备了名为 Firmware Updater 的全新图形化固件更新工具、原生支持 Raspberry Pi 5、用于最先进网络管理的 Netplan 1.0 以及默认 Snap 功能 Mozilla Thunderbird。

### 预启用和预加载的性能工程工具

Ubuntu 24.04 LTS 使用最新的 Linux 6.8 内核，具有改进的系统调用性能、ppc64el 上的嵌套 KVM 支持，以及对新 bcachefs 文件系统的支持。除了上游改进之外，Ubuntu 24.04 LTS 还将低延迟内核功能合并到默认内核中，减少了内核任务调度延迟。

Ubuntu 24.04 LTS 还在所有 64 位架构上默认启用帧指针 (frame pointers)，以便性能工程师在分析系统以进行故障排除和优化时可以随时访问准确且完整的火焰图。

英特尔计算机性能专家兼研究员 Brendan Gregg 表示：“帧指针可用于进行更完整的 CPU 分析和 off-CPU 分析。他们可以提供的性能优势远远超过相对较小的性能损失。Ubuntu 默认启用帧指针为性能工程和默认开发者体验带来巨大提升。”

使用 bpftrace 进行跟踪现在已成为 Ubuntu 24.04 LTS 中的标准配置，此外还有预加载的分析工具，可让站点可靠性工程师立即访问重要资源。

### 提升开发者工作效率的工具链

Ubuntu 24.04 LTS 包括 Python 3.12、Ruby 3.2、PHP 8.3 和 Go 1.22，并特别关注 .NET、Java 和 Rust 的开发者体验。

随着 .NET 8 的推出，Ubuntu 在支持 .NET 社区方面向前迈出了重要一步。NET 8 将在 Ubuntu 24.04 LTS 和 22.04 LTS 的整个生命周期中得到完全支持，使开发者能够在升级 Ubuntu 版本之前将其应用程序升级到更新的 .NET 版本。这种 .NET 支持也已扩展到 IBM System Z 平台。

对于 Java 开发者来说，OpenJDK 21 是 Ubuntu 24.04 LTS 中的默认版本，同时保持对版本 17、11 和 8 的支持。OpenJDK 17 和 21 还经过了 TCK 认证，这意味着它们遵守 Java 标准并确保与其他 Java 平台的互操作性。Ubuntu Pro 用户还可以使用符合 FIPS 的特殊 OpenJDK 11 软件包。

Ubuntu 24.04 LTS 附带 Rust 1.75 和更简单的 Rust 工具链 snap 框架。这将支持内核和火狐等关键 Ubuntu 软件包越来越多地使用 Rust，并使未来的 Rust 版本能在 24.04 LTS 上交付给开发者。

### 适用于 Ubuntu 桌面版和 WSL 的新管理工具

Ubuntu 桌面版现在首次在 LTS 中使用与 Ubuntu Server 相同的安装程序技术。因此桌面版管理员现在可以使用自动安装和 cloud-init 等映像自定义工具为其开发者创建量身定制的体验。此外用户界面也进行了重构，采用 Flutter 构建的现代设计。

对于管理 Windows 和 Ubuntu 混合环境的用户来说，通过 Ubuntu Pro 提供的 Active Directory 组策略客户端现在支持企业代理配置、权限管理和远程脚本执行。

Canonical 表示会继续为 Ubuntu on Windows Subsystem for Linux (WSL) 投入资源开发，内部已将其视作面向开发者和数据科学家的一流平台。

从 Ubuntu 24.04 LTS 开始，WSL 上的 Ubuntu 现在支持 cloud-init，以实现跨开发者领域的映像定制和标准化。

