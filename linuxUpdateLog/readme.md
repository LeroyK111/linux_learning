# Linux upgrade log

本文档记录历史，从 6.0 版本开始。😀

## 6.x 版本

### 6.0

Linux 6.0 引入 F2FS 低内存模式，用性能减少内存占用
Linux 6.0 为 LoongArch 架构启用 PCI 和其他功能支持
Linux 6.0 为 Arm64 添加 UEFI 镜像内存和 ACPI PRM 支持
Linux 6.0 将其 H.265/HEVC 用户空间 API 提升到稳定状态
Linux 6.0 合并大量 char/misc 代码，提供 Gaudi2 支持

### 6.1

初始的 Rust 基础设施已被合并到 Linux 6.1
Linux 6.1 内核合并面向 LoongArch 架构的 CPU 特性
Linux 6.1 将迎来 MGLRU 和 Maple Tree 支持
Linux 6.1 迎来 Btrfs 异步缓冲写入补丁，吞吐量翻倍
Linux 6.1 引入新功能，更容易辨认出故障的 CPU
Linux 6.1 引入 VirtIO 块“安全擦除”、vDPA 功能配置
Linux 6.1 Perf 新增 AMD CPU 内存报告和 Cache-To-Cache 功能

### 6.2

Nouveau 中早期的 Nvidia RTX 30/Ampere GPU 支持

更新的 Zstd 压缩代码

其他 Btrfs 性能增强

Squashfs 文件系统的新挂载选项

支持 Wi-Fi 7 和 800 Gbps 网络的基本功能

在 exFAT 驱动程序中更快地创建文件/文件夹

RISC-V 对持久性内存设备的支持

英特尔 IFS 驱动程序现已稳定

Intel Elder Lake N/Raptor Lake P 略有节电

USB 4 连接唤醒/断开支持

支持 ChromeOS 人体存在传感器 (HPS)

Raspberry Pi 4K @ 60Hz 显示支持

### 6.3

```
CPU和GPU更新
最新的内核版本带来了多个CPU和GPU更新。AMD Zen 4服务器处理器现在支持慢速内存带宽分配执行，使其与数据中心工作负载兼容。此外，AMD第四代FPYC和Ryzen产品的性能不断提高，具有自动IBRS Spectre V2修复。

此外，英特尔的x86_64指令LKGS已经合并，从而实现了CPU特权级别之间的低延迟过渡。TPMI驱动程序也已合并，更新了第四代Xeon Scalable“Sapphire Rapids”处理器的Trust Domain Extensions（TDX）。
```

```
ARM和SoC更新
高通骁龙8 Gen 2支持已经在内核6.3中到来，这非常重要，因为许多领先的移动品牌计划发布搭载这款处理器的新设备。其他ARM和SoC更新包括：

高通QDU1000/QRU1000 5G RAN
Rockchips RK3588/RK3588s 用于平板电脑、Chromebook和SBC
TI J784S4 用于商业用途
搭载联发科mt7986a的香蕉派R3路由器
高通MSM8916（骁龙410）
SM6115（骁龙662）
SM8250（骁龙865）
MSM8916 LTE dongles
英特尔的Meteor Lake VPU也在内核6.3中首次亮相，旨在为人工智能计算的Meteor Lake SoC提供支持。此外，英特尔的Meteor Lake GPU显示支持也在这个版本中可用。
```

```
核心更改
内核中的Rust模块自内核6.1以来已经得到了几个改进和支持。一些值得注意的变化包括：

支持Arc、ArcBorrow和UniqueArc类型
支持ForeignOwnable和ScopeGuard类型
对alloc模块的改进
```

```
文件系统和网络
内核6.3引入了针对高通WiFi 7系列芯片组的ath12k驱动程序支持。此外，由于实现了“IPv4 BIG TCP”补丁，IPv4协议的性能有了显著的提升。此外，DisplayPort带宽分配模式为Thunderbolt驱动程序允许GPU和Thunderbolt驱动程序共同工作以实现动态带宽分配。

此外，Tesla FSD SoC现在具有音频支持，旨在减轻Tesla自己维护驱动程序的负担。它还为在Tesla SoC中运行自定义内核打开了可能性。最后，Btrfs和Ext4文件系统接收了一些错误修复和性能改进。
```

### 6.4
Linux Kernel 6.4 的亮点包括 Intel LAM（线性地址掩码）支持、用户跟踪事件、用于存储仅 CA 强制的机器密钥环的机器所有者密钥（MOK）、对 nolibc 库的 LoongArch 支持、F2FS 文件系统的分区块设备支持，以及对 Svnapot 扩展和 RISC-V 架构的休眠支持。

io_uring 子系统改进，能够同时对文件执行多个直接 I/O 写入（目前仅在 EXT4 和 XFS 文件系统上受支持），SCTP（流控制传输协议）协议增加了对公平权重队列（WFQ）调度器的支持，并实现了一个基于 netlink 的 API 来调用用户空间的辅助功能。

s390（IBM System z）架构支持 STACKLEAK 安全特性，NFS服务器实现现在支持 RFC 9289规范，perf 工具进行了许多更改，包括新的引用计数检查基础设施、将默认映射大小更新为16384、在未链接libtraceevent库时在'perf script'中支持Python，更好地报告锁争用情况，以及能够使用BPF来过滤样本。

Rust 语言的支持也有一些新增内容，包括用于包装具有自己的引用计数函数的 C 类型的 "ARef" 类型，几个新的锁原语，用于安全固定初始化结构体的 pin-init API 核心，用于通过锁保护数据的 "LockedBy"，用于镜像创建的 UAPI crate，以及其他函数和绑定。

除此之外，Linux kernel 6.4 还为一些功能增加了支持，其中包括新的 Qualcomm QAIC DRM 加速驱动，用于 Cloud AI；在 x86 AMD 平台上支持虚拟非屏蔽中断 (NMI) 的 KVM 支持；用于 GEM DMA 驱动程序的 fbdev 模拟；Qualcomm Inline Crypto Engine 的支持；支持新的基于 MMIO 的模型 (T2 Macs)；Intel Sierra Forest EDAC 的支持；更好的 BIG TCP 性能；以及新的 BPF netfilter 程序类型。

Linux kernel 6.4 还在 Mediatek 驱动中进行了各种热管理的改进，增强了非常旧的 PCI 声卡的支持，为具有 MAX9809x 和 RT5631 编解码器的 NVIDIA 系统提供了声音支持，为所有 Kye 型号的绘图板提供了通用支持，支持 Logitech G935 无线 7.1 环绕声游戏耳机，以及支持英特尔第五代 Xeon "Emerald Rapids" 服务器处理器的 PPIN 支持。

Linux 6.4 中还新增了一些驱动程序，包括 StarFive JH71x0 温度传感器和 StarFive JH7110 RISC-V SoC、Acbel FSB032 电源、Aquacomputer Aquastream XT 水泵，以及 ROG STRIX Z390-F GAMING 主板。

此外，最新的 Xbox 控制器获得了震动支持，还增加了对 Apple M2 CPU PMU 的支持，Wi-Fi 7 (EHT) mesh 支持，对高通 Snapdragon 平台的改进支持，新增了 Novatek 触控控制器的驱动程序，对联想 Yoga Book X90F 2-in-1 平板的支持，Hyper-V VTL 模式支持，以及对 Apple M1 Pro/Max 设备的 Wi-Fi 支持。

AMDGPU 图形驱动程序获得了初步的 NBIO7.9、GC 9.4.3、GFXHUB 1.2、MMHUB 1.8 支持，初步的 DC FAM 基础设施，用于次要 VCN 时钟的 sysfs 节点，以及对支持的 APU 进行了有限/无限工作负载处理。此外，Mediatek DRM 驱动程序获得了 10 位叠加支持，Rockchip DRM 驱动程序获得了 4K 支持，Collabora 的 Panfrost 驱动程序现在支持 Mali MT81xx 设备。

### 6.5

在这个新发布的 Linux 6.5 版本中， 最值得期待的新奇事物 我们已经在博客中谈到过， 是系统 缓存统计（）， 其目的是查询文件和目录的页面缓存的状态。

#### 新的系统调用 
允许用户空间程序确定文件的哪些页面缓存在主内存中。 与以前可用的 mincore() 系统调用不同，cachestat() 调用允许您查询更详细的统计信息，例如缓存页数、脏页数、逐出页数、最近逐出页数和添加书签的页数以进行重写。

#### 并行运行处理器的工具
Linux 6.5 内核中另一个突出的变化是 并行运行处理器的工具， 这可以改善多插槽服务器上的启动时间。 这一改进对于超大规模企业来说非常重要。

除此之外，我们在Linux 6.5中还可以发现， 支持USB 4.2， 但值得一提的是，支持尚未完成。 我们还可以发现 Wi-Fi 7受到内核更多关注，以及该版本中改进的 Btrfs 文件系统的性能

Linux 6.5引入硬件支持 用于平板电脑联想 Yoga Book yb1-x90f/ly Nextbook Ares 8A，Dell Studio 1569 （ACPI 背光问题）、Lenovo ThinkPad X131e（AMD build 3371）和 Apple iMac11,3 计算机

另一方面，值得注意的是，也许最值得注意的内容是 默认 P 状态启用 在某些 AMD 处理器上，这意味着内核可以更有效地管理内核以平衡性能和功耗。

P 状态默认启用 而不是用于电源管理的 CPUFreq 驱动程序。 添加了参数 X86_AMD_PSTATE_DEFAULT_MODE 以选择默认 P-State 模式：1（禁用）、2（被动电源管理模式）、3（主动模式、EPP）、4（托管模式）。

其他变化 脱颖而出：

ALSA 音频子系统添加了对 MIDI 2.0 设备的支持。
F2FS 文件系统支持“errors=”挂载选项，通过该选项您可以配置在向驱动器读取或写入数据时出现错误时的行为。
任务调度程序通过消除 SMT 区域之间不必要的迁移，改善了 CPU 核心之间的负载平衡
SLAB 内存分配机制已被弃用，并将在未来版本中删除，而内核中将仅使用 SLUB。 引用的原因包括维护问题、代码问题以及更高级的 SLUB 分配器的功能重复。
由于多个CPU的并行激活，将处理器转移到在线状态的过程显着加速（最多10倍）。
Loongarch架构支持同时多线程（SMT，Simultaneous Multithreading）。 它还提供了使用 Clang 编译器构建 Loongarch 内核的能力。
添加了对 ACPI 和 RISC-V 架构的“V”扩展（Vector，矢量指令）的支持。 prctl() 中提供了参数“/proc/sys/abi/riscv_v_default_allow”和标志字符串“PR_RISCV_V_*”来控制扩展。
在具有支持 Armv8.8 扩展的 ARM 处理器的系统上，提供了在用户空间中使用 memcpy/memset 处理器指令的功能。



### 6.6

#### 针对英特尔芯片的优化
Linux 内核 6.6 版本新增了对英特尔的神经处理单元（NPU）的支持，这样的技术原先被称作通用处理器。

这项技术预计将于今年晚些时候，随着英特尔的“Meteor Lake”芯片亮相而首次公开登场。这些 NPU 将被专门用于处理人工智能工作负载。

英特尔甚至已经开始对即将发布的 “Arrow Lake”芯片进行NPU 支持的初步工作了！

此外，还新增了对英特尔的 Shadow Stack 的支持，因为他们的 控制流执行技术（CET）被引入到了内核中。其主要目的是防止现代英特尔 CPU（从 Tiger Lake 起）上的返回导向编程（ROP）攻击。


#### 对笔记本的更佳支持
对于惠普笔记本，现在你可以直接在 Linux 中对 BIOS 进行管理了，这要归功于 “HP-BIOSCFG” 驱动的实现。

根据报道，从 2018 年起出产的惠普笔记本应该都可以支持这个驱动程序。

对于联想笔记本，驱动程序已经更新，为更多的 IdeaPad 笔记本添加了键盘背光控制**。

同样，对于华硕笔记本，现在 ROG Flow X16（2023 年款）游戏笔记本，当屏幕翻转时可以正确地启用平板模式。


#### 网络改进
在网络方面，Linux 内核 6.6 版本带来了对如 Atheros QCA8081、MediaTek MT7988、MediaTek MT7981，NXP TJA1120 PHY 等新型硬件的支持。

同时，各类驱动程序也进行了升级，例如 高通 Wi-Fi 7 （ath12k）驱动程序，它现在支持 Extremely High Throughput（EHT）PHY。

此外，针对各类 Realtek（rtl8xxxu）Wi-Fi 芯片启用了 AP 模式。

关于特定于网络的变动，你可以在这个 拉取请求 中查阅更多的详细信息。

AMD 芯片性能提升


随着 Linux 内核 6.6 的发布，AMD 的开发人员推出了两项尚未正式公开的新技术的支持。

一项技术是对他们即将推出的 “FreeSync Panel Replay” 技术的支持，这一技术只用于游戏笔记本抖动屏，可以自动降低刷新率以节省电力和降低 GPU 工作负载。

另一项技术被称为 “动态提速控制”，这是一项能够提高某些 Ryzen SoC 性能的功能，但关于它的更多细节比较少。

关于它的实施，你可以在这个 补丁序列 中查阅更多的信息。

️ 其他的变化与改进

其他方面，还包括一些值得注意的变动：

针对 龙芯 的大量新特性。
Rust 工具链 升级至 v1.71.1 版本。
对 RISC-V 和 Btrfs 的多项改进。
完全移除了 无线 USB 和 Ultra-Wideband 的代码。
对 英伟达、英特尔 和 AMD 的开源图形驱动程序 的众多优化。

### 6.7
◈ 英特尔的优化
首先要讲的是英特尔的 Meteor Lakeen.wikipedia.org 处理器。Linux 内核 6.7 对于英特尔 Meteor Lake 图形提供了原生支持。在此之前，此项支持还处在 实验性 阶段。但现在，你可以在装备有第一代 Core Ultrawww.intel.com 处理器的笔记本上全面享受到它的优势了。

另外，英特尔即将发布的 Arrow Lakeen.wikipedia.org 和 Lunar Lake 芯片在 Turbostatwww.linux.org（一个用于监测处理器频率、空闲统计等信息的命令行工具）中也做好了规划。

◈ 增强的 RISC-V 支持
RISC-V 的一大亮点是 引入了软件阴影调用堆栈，这旨在保护 CPU 架构免受意外和恶意操作的影响。

此外，在用户空间对 cbo.zero，以及在基于 ACPI 系统中对 CBO 的支持，还有许多其他杂项修复也同样进行了。这个 合并请求git.kernel.org 中有更多信息。

◈ 针对 AMD 的特别增强
AMD 的 无缝启动功能已经扩展到支持 Display Core Next 3.0 及以后版本的 GPU。包括 Radeon RDNA2/RDNA3，以及未来发布的任何 GPU。

此功能使得系统 平滑过渡，避免了通常随着电源按钮压下后会出现的屏幕闪烁现象。之前，这个功能仅对 AMD 的 Van Gogh 系列 APU 开放。

接下来是 错误检测和纠正（EDACen.wikipedia.org）在 Versalwww.xilinx.com SoC 系列中的引入，它添加了一个 EDAC 驱动，支持在集成的 Xilinx DDR 内存控制器上进行 RAS 功能。

◈ 众多存储功能的优化
我们终于在 Linux 内核 6.7 中迎来了 Bcachefsbcachefs.org 文件系统的引入。如果你对它不熟悉，简单来说，它是一种写时复制（COW）文件系统，其重点放在可靠性和稳健表现上。

此外，Btrfs 引入了 新的三项特性，F2FS 现在 支持更大的页面尺寸，甚至 IBM 的日志文件系统（JFS）也有所增强。

◈ 其他
◈ 停止对 MIPS AR7en.wikipedia.org 平台的支持。
◈ x86 CPU 微码加载过程 的改进。
◈ 在 EROFSen.wikipedia.org 上，MicroLZMA 压缩 现在被认为是稳定的。
◈ 更好地支持 采用 RISC-V 的 Milk-V Pioneermilkv.io 板。
◈ 引入 Nouveau GPU 系统处理器（GSP），它为英伟达的 “Turing” 及更新的 GPU 开启了更好的体验途径。


### 6.8

- LAM / 线性地址屏蔽的虚拟化支持
- KVM 的来宾优先内存支持
- 更新 Bcachefs 文件系统的基本在线文件系统检查和修复机制
- 对树莓派 5 使用的博通 BCM2712 芯片提供支持
- 基于 AMD ACPI 的 WiFi 频段 RFI 缓解功能
- zswap、CephFS 等功能优化

### 6.9

- 增强网络相关功能，包括支持 2.5GbE 和 5GbE EEE 链路模式、支持在 IPSec 中转发 ICMP 错误消息等
- 支持 GCC 命名地址空间，增加 FUSE 直通的初始支持
- 在 AArch64 架构上提供 Rust 的支持、将 Rust 更新到 1.76.0 版
- 增加对 ORC 堆栈展开器的支持、对龙芯架构的内核实时修复
- 对休眠映像创建和加载代码的 LZ4 压缩支持
- F2FS 闪存友好文件系统获得了分区块设备支持、在突然断电后增强数据恢复
- exFAT 文件系统获得目录同步性能的改进
- 添加对未来 AMD 硬件的支持
- 更新 Intel Xe 显示驱动程序
- 添加对 Intel i915 显示驱动程序的 DP 隧道支持

### 6.10

- 新的[Panthor 图形直接渲染管理器 (DRM) 驱动程序](https://link.juejin.cn/?target=https%3A%2F%2Fwww.collabora.com%2Fnews-and-blog%2Fnews-and-events%2Frelease-the-panthor.html "https://www.collabora.com/news-and-blog/news-and-events/release-the-panthor.html")。这段延迟的代码应该在 6.9 Linux 内核中发布，它支持更新的 Arm Mali 图形处理器。这一发展对于围绕[基于 Arm 的架构](https://link.juejin.cn/?target=https%3A%2F%2Fthenewstack.io%2Farm-eyes-ai-with-its-latest-neoverse-cores-and-subsystems%2F "https://thenewstack.io/arm-eyes-ai-with-its-latest-neoverse-cores-and-subsystems/")构建的下一代设备来说尤其重要。它将提高它们的图形性能和兼容性。
