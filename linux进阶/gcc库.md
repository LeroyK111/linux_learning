# Linux下的可执行文件

为什么要盯住gcc呢？因为Linux的软件生态中，C/C++开发的软件，特别是基础型软件、需要高性能的软件，往往历史原因都以这两种语言为主，在此不赘述。

总之，因为C/C++开发的软件占比很大，即使开发业务中不直接使用，也会在运行中依赖到C/C++的库或可执行文件的功能。搞懂动态库的特性，对于解决一些软件依赖问题、开发编译链接失败问题，都有帮助。所以开发者和运维仍然有必要增进这方面的理解。

1. 动态链接适合`插件化开发、插件化升级、希望打包发布的可执行文件尽量小`的场景；而静态链接方式适合`易部署、不想处理第三方动态库依赖问题`的场景。
    
2. gcc/g++ 作为Linux下主要的编译器，支持动态链接、静态链接方式。如最基本的main.c 代码可通过`gcc -o main_dynamic_link main.c` 和 `gcc -static -o main_static main.c` 分别得到两类可执行文件。这是大学生在学校初学Linux下的gcc C/C++编程的时候就了解的。
    
3. gcc 动态链接生成的可执行文件，因为代码必然使用到c/c++的标准库提供的函数，那么可执行文件必然要与`libc.so`库动态库链接（如下图）。

![](../README.assets/Pasted%20image%2020231218211348.png)

4. gcc编译得到的可执行文件，运行时会以进程方式在用户态、内核态的内存中布局。如果可执行文件是动态链接方式的，则运行时由 Linux内核负责载入ELF格式的可执行文件后，内核通过 ld-linux.so (64位系统下则为 ld-linux-x86-64.so ) 分析可执行文件依赖的其他动态库信息，由ld-linux.so 负责逐个载入其他动态库到该进程的虚拟内存的代码段位置中。这里就发挥了动态库和虚拟内存的优势：热门的动态库被很多其他进程依赖，那么这种可执行文件实际只占用物理内存的一块空间，无论被多少个进程依赖。所以达到了提高内存利用率的效果，这对于需要运行大量软件的场景（如Linux桌面），收益还是可观的。可执行文件从被调起到执行完毕，我们可以用 `strace` 命令看到全过程，包括需要读取的其他库文件的过程。比如下面的可执行文件可以用strace 看到执行全流程（功能只调用printf函数打印字符串）。

## 编译动态链接库

```sh
root@localhost:~# file  ./main  
./main: ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, BuildID[sha1]=82e7afc31da1cdbdd374658c2724dce983ccedab, for GNU/Linux 3.2.0, not stripped  
  
  
root@localhost:~# ldd  ./main  
        not a dynamic executable   #说明当前是静态链接的  
          
          
root@localhost:~# strace ./main  
execve("./main", ["./main"], 0x7ffe6fd2a090 /* 25 vars */) = 0  
arch_prctl(0x3001 /* ARCH_??? */, 0x7ffe7ada0370) = -1 EINVAL (Invalid argument)  
brk(NULL)                               = 0x1a12000  
brk(0x1a12dc0)                          = 0x1a12dc0  
arch_prctl(ARCH_SET_FS, 0x1a123c0)      = 0  
set_tid_address(0x1a12690)              = 27080  
set_robust_list(0x1a126a0, 24)          = 0  
rseq(0x1a12d60, 0x20, 0, 0x53053053)    = 0  
uname({sysname="Linux", nodename="localhost", ...}) = 0  
prlimit64(0, RLIMIT_STACK, NULL, {rlim_cur=8192*1024, rlim_max=RLIM64_INFINITY}) = 0  
readlink("/proc/self/exe", "/root/main", 4096) = 10  
getrandom("\xa1\xe6\x48\xa4\x1d\x32\xef\x0e", 8, GRND_NONBLOCK) = 8  
brk(0x1a33dc0)                          = 0x1a33dc0  
brk(0x1a34000)                          = 0x1a34000  
mprotect(0x4c1000, 16384, PROT_READ)    = 0  
newfstatat(1, "", {st_mode=S_IFCHR|0600, st_rdev=makedev(0x88, 0), ...}, AT_EMPTY_PATH) = 0  
write(1, "111", 3111)                      = 3  
exit_group(3)                           = ?  
+++ exited with 3 +++  
  
## 下面按动态链接生成可执行文件  
root@localhost:~# gcc  -o main main.c  
  
  
## strace 显示可执行文件 执行时需要加载 `/lib/x86_64-linux-gnu/libc.so.6` 文件。  
root@localhost:~# strace ./main  
execve("./main", ["./main"], 0x7ffec2fb69c0 /* 25 vars */) = 0  
brk(NULL)                               = 0x55fd3f1bc000  
root@localhost:~#  
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa3491dd000  
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)  
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3  
newfstatat(3, "", {st_mode=S_IFREG|0644, st_size=87359, ...}, AT_EMPTY_PATH) = 0  
mmap(NULL, 87359, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fa3491c7000  
close(3)                                = 0  
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3  
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P\237\2\0\0\0\0\0"..., 832) = 832  
pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784  
pread64(3, "\4\0\0\0 \0\0\0\5\0\0\0GNU\0\2\0\0\300\4\0\0\0\3\0\0\0\0\0\0\0"..., 48, 848) = 48  
pread64(3, "\4\0\0\0\24\0\0\0\3\0\0\0GNU\0 =\340\2563\265?\356\25x\261\27\313A#\350"..., 68, 896) = 68  
newfstatat(3, "", {st_mode=S_IFREG|0755, st_size=2216304, ...}, AT_EMPTY_PATH) = 0  
pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784  
mmap(NULL, 2260560, PROT_READ, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fa348f9f000  
mmap(0x7fa348fc7000, 1658880, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x28000) = 0x7fa348fc7000  
mmap(0x7fa34915c000, 360448, PROT_READ, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1bd000) = 0x7fa34915c000  
mmap(0x7fa3491b4000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x214000) = 0x7fa3491b4000  
mmap(0x7fa3491ba000, 52816, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fa3491ba000  
close(3)                                = 0  
mmap(NULL, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa348f9c000  
arch_prctl(ARCH_SET_FS, 0x7fa348f9c740) = 0  
set_tid_address(0x7fa348f9ca10)         = 27089  
set_robust_list(0x7fa348f9ca20, 24)     = 0  
rseq(0x7fa348f9d0e0, 0x20, 0, 0x53053053) = 0  
mprotect(0x7fa3491b4000, 16384, PROT_READ) = 0  
mprotect(0x55fd3e9e1000, 4096, PROT_READ) = 0  
mprotect(0x7fa34921d000, 8192, PROT_READ) = 0  
prlimit64(0, RLIMIT_STACK, NULL, {rlim_cur=8192*1024, rlim_max=RLIM64_INFINITY}) = 0  
munmap(0x7fa3491c7000, 87359)           = 0  
newfstatat(1, "", {st_mode=S_IFCHR|0600, st_rdev=makedev(0x88, 0), ...}, AT_EMPTY_PATH) = 0  
getrandom("\x84\x8c\x06\x16\x25\xe5\x97\x97", 8, GRND_NONBLOCK) = 8  
brk(NULL)                               = 0x55fd3f1bc000  
brk(0x55fd3f1dd000)                     = 0x55fd3f1dd000  
write(1, "111", 3111)                      = 3  
exit_group(3)                           = ?  
+++ exited with 3 +++  
root@localhost:~#
```

可以看到 动态链接的C可执行文件运行时确实需要加载 `/lib/x86_64-linux-gnu/libc.so.6` 文件。而静态链接的可执行文件没有加载任何`.so`文件，包括`libc.so`也不需要。
## 编译静态链接库

```sh
root@localhost:~# gcc --version  
gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0  
Copyright (C) 2021 Free Software Foundation, Inc.  
This is free software; see the source for copying conditions.  There is NO  
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
  
  
root@localhost:~# gcc -static -o main_static main.c  # 静态链接  
root@localhost:~# gcc  -o main_shared_link main.c    # 动态链接  
root@localhost:~# ls -lht  
total 1.8M  
-rwxr-xr-x 1 root root  16K Dec 17 23:58 main_shared_link  
-rwxr-xr-x 1 root root 880K Dec 17 23:58 main_static  
-rw-r--r-- 1 root root   54 Dec 17 22:30 main.c  
  
root@localhost:~# file main_static   # 查看静态链接文件的属性  
main_static:      ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, BuildID[sha1]=82e7afc31da1cdbdd374658c2724dce983ccedab, for GNU/Linux 3.2.0, not stripped  
  
root@localhost:~# main_shared_link  # 查看动态链接文件的属性  
main_shared_link: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=f14401e673b52624535874f2e1a8488a0edbc891, for GNU/Linux 3.2.0, not stripped  
  
root@localhost:~# ls -lht /lib/x86_64-linux-gnu/libc.so.6  
-rwxr-xr-x 1 root root 2.2M Nov 22 21:18 /lib/x86_64-linux-gnu/libc.so.6
```
这里看到：`880K Dec 17 23:58 main_static`静态文件大小880K，而`libc.so`大小`2.2M` 。静态文件大小比C标准库动态文件的大小还小很多。

说明gcc并不只是把`libc.so`的所有函数完全包含进静态可执行文件，而这是我之前对gcc的误解。

实际gcc对静态的链接是做了精简优化的，只保留了有被调用的函数代码到最终可执行文件内。

5. 所以本文最初提到的《为什么不建议交付静态链接的可执行文件给用户？》 中的不建议，是只从静态文件的分发方式降低了系统基础库的重用率的角度出发的。当然随着技术的进步，也许以后`内核的可执行文件加载器`能做到识别出静态文件中的某些可替代的公共部分就自动剔除对物理内存的占用，而借助系统已有的已载入内存的公共代码实现替代，而不影响软件功能，就结合了动态和静态的两种优势。这只是一个猜想，并非合理完美的方案。
    
6. 而《为什么Golang开发的软件单文件直接丢到各种Linux系统就能运行？》中golang能做到的，gcc也能做到，所以C/C++静态链接的可执行文件的跨系统版本兼容性没有那么差，跟Golang生成的静态可执行文件是一样能丢到各种Linux发行版的运行的。
    
7. 但跨系统兼容性的前提是32位、64位系统和软件的数位，要匹配。除非32位的系统内核支持`PAE`特性或Linux系统额外安装了 `multilib` 库，以实现32位系统下运行64位的软件，或64位系统下运行32位的软件。

