# rust进入linux

## 首次引入
自 Linux 6.1 将最初的 Rust 基础架构添加到 Linux 内核以来，已经合并了许多其他设施和内部修改，以便能够用 Rust 编程语言编写内核驱动程序。

## 重写驱动
在即将到来的 Linux 6.8 内核中，第一个 Rust 网络驱动程序将被引入。这个用 Rust 重写的 ASIX PHY 驱动程序约有 135 行 Rust 代码，该驱动已有 C 语言驱动。PHY 驱动程序是指网卡收发器的物理层驱动。