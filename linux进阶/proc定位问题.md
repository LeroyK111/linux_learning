# /proc 文件系统暴露的内核的的全方位的线索

```
本文通过一个例子展示了，在分析进程运行缓慢的问题时，strace和pstack都束手无策的情况下，不要忘了还有/proc 文件系统暴露的内核的的全方位的线索，善用可达到巧妙快速定位问题的效果。特别是 /proc/<PID>/syscall 和 /proc/<PID>/stack 这两个文件。
```
定位一个程序“运行缓慢”的问题

下面要举的这个例子是这样的：一个DBA反映说他们的find命令一直运行缓慢，半天都没有什么输出，他们想知道这是为什么。听到这个问题的时候我就大概有直觉造成这个问题的原因，但是他们还是想知道怎么系统地追踪这类问题，并找到解决方案。刚好出问题的现场还在……

还好，系统是运行在OEL6上的，内核比较新，确切地说是2.6.39 UEK2。

首先，让我们看看find进程是否还在：
```sh
[root@oel6 ~]# ps -ef | grep find  
root 27288 27245 4 11:57 pts/0 00:00:01 find . -type f  
root 27334 27315 0 11:57 pts/1 00:00:00 grep find
```
跑的好好的，PID是27288（请记好这个将会伴随整篇博客的数字）。

那么，我们就从最基础的开始分析它的瓶颈：如果它不是被什么操作卡住了（例如从cache中加载它所需要的内容），它应该是100%的CPU占用率；如果它的瓶颈在IO或者资源竞争，那么它应该是很低的CPU占用率，或者是%0。

我们先看下top：
```sh
[root@oel6 ~]# top -cbp 27288  
top - 11:58:15 up 7 days, 3:38, 2 users, load average: 1.21, 0.65, 0.47  
Tasks: 1 total, 0 running, 1 sleeping, 0 stopped, 0 zombie  
Cpu(s): 0.1%us, 0.1%sy, 0.0%ni, 99.8%id, 0.0%wa, 0.0%hi, 0.0%si, 0.0%st  
Mem: 2026460k total, 1935780k used, 90680k free, 64416k buffers  
Swap: 4128764k total, 251004k used, 3877760k free, 662280k cached  
  
PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ COMMAND  
27288 root 20 0 109m 1160 844 D 0.0 0.1 0:01.11 find . -type f
```
结果很清楚：这个进程的CPU占用率很低，几乎为零。但是CPU占用低也分情况：一种是进程完全卡住了，根本没有机会获得时间片；另一种是进程在不停进入等待的状态（例如poll动作就是时不时超时后，进程进入休眠状态）。虽然这剩下的细节top还不足以完全给我们展示，但是至少我们知道了这个进程没有在烧CPU时间。

通常情况下，如果进程处于这种状态（%0的CPU占用一般说明进程是卡在了某个系统调用，因为这个系统调用阻塞了，内核需要把进程放到休眠状态），我都会用strace跟踪一下这个进程具体卡在了哪个系统调用。而且，如果进程不是完全卡住了，那进程中的系统调用情况也会在strace的输出中有所展示（因为一般阻塞的系统调用会在超时返回后，过一段时间再进入阻塞等待的状态）。

让我们试试strace：
```sh
[root@oel6 ~]# strace -cp 27288
Process 27288 attached - interrupt to quit

^C
^Z
[1]+  Stopped                 strace -cp 27288

[root@oel6 ~]# kill -9 %%
[1]+  Stopped                 strace -cp 27288
[root@oel6 ~]# 
[1]+  Killed                  strace -cp 27288

```
尴尬，strace自己也卡住了！半天没有输出，也不响应Ctrl-C，我不得不通过Ctrl-Z把它扔到后台再杀掉它。想简单处理还真是不容易啊。

那只好再试试pstack了（Linux上的pstack只是用shell脚本包了一下GDB）。尽管pstack看不到内核态的内容，但是至少它能告诉我们是哪个系统调用最后执行的（通常pstack输出的用户态调用栈最顶部是一个libc库的系统调用）：
```sh
[root@oel6 ~]# pstack 27288  
  
^C  
^Z  
[1]+ Stopped pstack 27288  
  
[root@oel6 ~]# kill %%  
[1]+ Stopped pstack 27288  
[root@oel6 ~]#  
[1]+ Terminated pstack 27288
```
呵呵，pstack也卡住了，什么输出都没有！

至此，我们还是不知道我们的程序是怎么卡住了，卡在哪里了。

好吧，还怎么进行下去呢？还有一些常用的信息可以搜集——进程的status字段和WCHAN字段，这些使用古老的ps就能查看（或许最开始就应该用ps看看这个进程是不是已经成僵尸进程了）：
```sh
[root@oel6 ~]# ps -flp 27288  
F S UID PID PPID C PRI NI ADDR SZ WCHAN STIME TTY TIME CMD  
0 D root 27288 27245 0 80 0 - 28070 rpc_wa 11:57 pts/0
```
需要注意的是，你要多运行几次ps以确保进程还在同一个状态（不然在不凑巧的时候获取了一个错误的状态就麻烦了），我这里为了简短就只贴一次输出了。

进程此时正处于D状态，按照man手册的说法，这通常是因为磁盘IO导致的。而WCHAN字段（表示导致程序处于休眠/等待状态的函数调用）则有点儿被切掉了。显然我可以翻一下ps的man手册，看看怎么把这个字段调宽一点好完整打印出来，不过既然我都知道了这个信息来自于proc文件系统，就没这个必要了。

直接从它的源头读一下看看（再次说明一下，多试几次看看，毕竟我们还不知道这个进程到底是不是完全卡死了呢）：
```sh
[root@oel6 ~]# cat /proc/27288/wchan  
rpc_wait_bit_killable
```
额……这个进程居然在等待某些RPC调用。RPC调用通常意味着这个程序在跟其他进程通信（不管是本地还是远程）。总归，我们还是不知道为什么会卡住。
先搞清楚这个进程到底是不是完全卡住了。
其实，在新一点的Linux内核中，/proc/PID/status 这个文件可以告诉我们这点：
```sh
[root@oel6 ~]# cat /proc/27288/status  
Name: find  
State: D (disk sleep)  
Tgid: 27288  
Pid: 27288  
PPid: 27245  
TracerPid: 0  
Uid: 0 0 0 0  
Gid: 0 0 0 0  
FDSize: 256  
Groups: 0 1 2 3 4 6 10  
VmPeak: 112628 kB  
VmSize: 112280 kB  
VmLck: 0 kB  
VmHWM: 1508 kB  
VmRSS: 1160 kB  
VmData: 260 kB  
VmStk: 136 kB  
VmExe: 224 kB  
VmLib: 2468 kB  
VmPTE: 88 kB  
VmSwap: 0 kB  
Threads: 1  
SigQ: 4/15831  
SigPnd: 0000000000040000  
ShdPnd: 0000000000000000  
SigBlk: 0000000000000000  
SigIgn: 0000000000000000  
SigCgt: 0000000180000000  
CapInh: 0000000000000000  
CapPrm: ffffffffffffffff  
CapEff: ffffffffffffffff  
CapBnd: ffffffffffffffff  
Cpus_allowed: ffffffff,ffffffff  
Cpus_allowed_list: 0-63  
Mems_allowed: 00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000001  
Mems_allowed_list: 0  
voluntary_ctxt_switches: 9950  
nonvoluntary_ctxt_switches: 17104
```

(主要看State字段和最后两行：voluntary_ctxt_switches和 nonvoluntary_ctxt_switches)

进程处于D——Disk Sleep（不可打断休眠状态），voluntary_ctxt_switches 和 nonvoluntary_ctxt_switches的数量则能告诉我们这个进程被分给时间片的次数。过几秒再看看这些数字有没有增加，如果没有增加，则说明这个进程是完全卡死的，目前我在追踪的例子就是这个情况，反之，则说明进程不是完全卡住的状态。

顺便提一下，还有两种办法也可以获取进程的上下文切换数量（第二种在老旧的内核上也能工作）：
```sh
[root@oel6 ~]# cat /proc/27288/sched
find (27288, #threads: 1)
---------------------------------------------------------
se.exec_start                      :     617547410.689282
se.vruntime                        :       2471987.542895
se.sum_exec_runtime                :          1119.480311
se.statistics.wait_start           :             0.000000
se.statistics.sleep_start          :             0.000000
se.statistics.block_start          :     617547410.689282
se.statistics.sleep_max            :             0.089192
se.statistics.block_max            :         60082.951331
se.statistics.exec_max             :             1.110465
se.statistics.slice_max            :             0.334211
se.statistics.wait_max             :             0.812834
se.statistics.wait_sum             :           724.745506
se.statistics.wait_count           :                27211
se.statistics.iowait_sum           :             0.000000
se.statistics.iowait_count         :                    0
se.nr_migrations                   :                  312
se.statistics.nr_migrations_cold   :                    0
se.statistics.nr_failed_migrations_affine:                    0
se.statistics.nr_failed_migrations_running:                   96
se.statistics.nr_failed_migrations_hot:                 1794
se.statistics.nr_forced_migrations :                  150
se.statistics.nr_wakeups           :                18507
se.statistics.nr_wakeups_sync      :                    1
se.statistics.nr_wakeups_migrate   :                  155
se.statistics.nr_wakeups_local     :                18504
se.statistics.nr_wakeups_remote    :                    3
se.statistics.nr_wakeups_affine    :                  155
se.statistics.nr_wakeups_affine_attempts:                  158
se.statistics.nr_wakeups_passive   :                    0
se.statistics.nr_wakeups_idle      :                    0
avg_atom                           :             0.041379
avg_per_cpu                        :             3.588077
nr_switches                        :                27054
nr_voluntary_switches              :                 9950
nr_involuntary_switches            :                17104
se.load.weight                     :                 1024
policy                             :                    0
prio                               :                  120
clock-delta                        :                   72
```
我们要的就是输出中的nr_switches字段（等于 nr_voluntary_switches + nr_involuntary_switches），值是27054，跟/proc/PID/schedstat 中的第三个字段是一致的：
```sh
[root@oel6 ~]# cat /proc/27288/schedstat  
1119480311 724745506 27054
```
看情况我们的程序是卡死无疑了，strace和pstack这些使用ptrace系统调用来attach到进程上来进行跟踪的调试器也没啥用，因为进程已经完全卡住了，那么ptrace这种系统调用估计也会把自己卡住。（顺便说一下，我曾经用strace来跟踪attach到其他进程上的strace，结果strace把那个进程搞挂了。别说我没警告过你）！

没了strace和pstack，我们还能怎么查程序卡在了哪个系统调用呢？当然是 /proc/PID/syscall 了！
```sh
[root@oel6 ~]# cat /proc/27288/syscall  
262 0xffffffffffffff9c 0x20cf6c8 0x7fff97c52710 0x100 0x100 0x676e776f645f616d 0x7fff97c52658 0x390e2da8ea
```
这鬼输出怎么看呢？很简单，0x加很大的数字一般就是内存地址（使用pmap类似的工具可以看具体他们指向了什么内容），如果是很小的数字的话，很可能就是一些索引号（例如打开的文件描述符，就像/proc/PID/fd的内容一样）。在这个例子中，因为是syscall文件，你可以”合理猜测“这是一个系统调用号：进程卡在了262号系统调用！

需要注意的是系统调用号在不同的系统上可能是不一致的，所以你必须从一个合适的.h文件中去查看它具体指向了哪个调用。通常情况下，在/usr/include中搜索 syscall* 是个很好的切入点。在我的系统上，这个系统调用是在 /usr/include/asm/unistd_64.h中定义的：
```sh
[root@oel6 ~]# grep 262 /usr/include/asm/unistd_64.h  
#define __NR_newfstatat 262
```
根据上面显示的结果可以看到这个系统调用叫 newfstatat，我们只需要man newfstatat就可以知道这是干啥的了。针对系统调用有一个实用小技巧分享：如果man手册中没有发现一个系统调用，那么请尝试删除一些特定的前缀或者后缀（例如man pread64不行就尝试man pread）。还或者，干脆google之……

总之，这个叫“new-fstat-at”的系统调用的作用就是让你可以像 stat 系统调用一样读取文件的属性，我们的程序就是卡在这个操作上，终于在调试这个程序的道路上迈出了一大步，不容易！但是为啥会卡在这个调用呢？

好吧，终于要亮真本事了。隆重介绍：/proc/PID/stack，能让你看到一个进程内核态的调用栈信息的神器，而且只是通过cat一个proc文件！！！
```sh
[root@oel6 ~]# cat /proc/27288/stack  
[] rpc_wait_bit_killable+0x24/0x40 [sunrpc]  
[] __rpc_execute+0xf5/0x1d0 [sunrpc]  
[] rpc_execute+0x43/0x50 [sunrpc]  
[] rpc_run_task+0x75/0x90 [sunrpc]  
[] rpc_call_sync+0x42/0x70 [sunrpc]  
[] nfs3_rpc_wrapper.clone.0+0x35/0x80 [nfs]  
[] nfs3_proc_getattr+0x47/0x90 [nfs]  
[] __nfs_revalidate_inode+0xcc/0x1f0 [nfs]  
[] nfs_revalidate_inode+0x36/0x60 [nfs]  
[] nfs_getattr+0x5f/0x110 [nfs]  
[] vfs_getattr+0x4e/0x80  
[] vfs_fstatat+0x70/0x90  
[] sys_newfstatat+0x24/0x50  
[] system_call_fastpath+0x16/0x1b  
[] 0xffffffffffffffff
```
可以看到最顶部的函数就是我们现在卡在的地方，正是上面WCHAN字段显示的内容：rpc_wait_bit_killable。（注意：实际上不一定最顶部的函数就是我们想要的，因为内核可能也执行了 schedule 之类的函数来让程序进入休眠或者运行。这里没有显示可能是因为卡主是因为其他调用卡主了才进入睡眠状态，而不是相反的逻辑）。

多亏了这个神器，我们现在可以从头到尾推导出程序卡主的整个过程和造成最终 rpc_wait_bit_killable 函数卡主的原因了：

最底部的 system_call_fastpath 是一个非常常见的系统调用处理函数，正是它调用了我们刚才一直有疑问的 newfstatat 系统调用。然后，再往上可以看到一堆nfs相关的子函数调用，这样我们基本可以断定正nfs相关的下层代码导致了程序卡住。我没有推断说问题是出在nfs的代码里是因为继续往上可以看到rpc相关的函数，可以推断是nfs为了跟其他进程进行通信又调用了rpc相关的函数——在这个例子中，可能是`[kworker/N:N]`，`[nfsiod]`， `[lockd]` or`[rpciod]`

等内核的IO线程，但是这个进程因为某些原因（猜测是网络链接断开之类的问题）再也没有收到响应的回复。

同样的，我们可以利用以上的方法来查看哪些辅助IO的内核线程为什么会卡在网络相关的操作上，尽管kworkers就不简简单单是NFS的RPC通信了。在另外一次问题重现的尝试（通过NFS拷贝大文件）中，我刚好捕捉到一次kwrokers等待网络的情况：
```sh
[root@oel6 proc]# for i in `pgrep worker` ; do ps -fp $i ; cat /proc/$i/stack ; done  
UID PID PPID C STIME TTY TIME CMD  
root 53 2 0 Feb14 ? 00:04:34 [kworker/1:1]  
  
[] __cond_resched+0x2a/0x40  
[] lock_sock_nested+0x35/0x70  
[] tcp_sendmsg+0x29/0xbe0  
[] inet_sendmsg+0x48/0xb0  
[] sock_sendmsg+0xef/0x120  
[] kernel_sendmsg+0x41/0x60  
[] xs_send_kvec+0x8e/0xa0 [sunrpc]  
[] xs_sendpages+0x173/0x220 [sunrpc]  
[] xs_tcp_send_request+0x5d/0x160 [sunrpc]  
[] xprt_transmit+0x83/0x2e0 [sunrpc]  
[] call_transmit+0xa8/0x130 [sunrpc]  
[] __rpc_execute+0x66/0x1d0 [sunrpc]  
[] rpc_async_schedule+0x15/0x20 [sunrpc]  
[] process_one_work+0x13e/0x460  
[] worker_thread+0x17c/0x3b0  
[] kthread+0x96/0xa0  
[] kernel_thread_helper+0x4/0x10
```
通过开启内核的tracing肯定可以确切找到是内核的哪两个线程之间再通信，不过限于文章篇幅，这里就不展开了，毕竟这只是一个实用（且简单）的问题追踪定位练习。

## 修复
多亏了现代内核提供的栈信息存样，我们得以系统地追踪到我们的find命令卡在了哪里——内核中的NFS代码。而且一般情况下，NFS相关卡死，最需要怀疑的就是网络问题。你猜我是怎么重现上面的这个问题的？其实就是在功过NFS挂在虚拟中的一块磁盘，执行find命令，然后让虚拟机休眠……这样就可以重现类似网络（配置或者防火墙）导致的链接默默断掉但是并没有通知TCP另一端的进程的情况。

因为 rpc_wait_bit_killable 是可以直接被安全干掉的函数，这里我们选择通过 kill -9直接干掉它：
```sh
[root@oel6 ~]# ps -fp 27288  
UID PID PPID C STIME TTY TIME CMD  
root 27288 27245 0 11:57 pts/0 00:00:01 find . -type f  
[root@oel6 ~]# kill -9 27288  
  
[root@oel6 ~]# ls -l /proc/27288/stack  
ls: cannot access /proc/27288/stack: No such file or directory  
  
[root@oel6 ~]# ps -fp 27288  
UID PID PPID C STIME TTY TIME CMD  
[root@oel6 ~]#
```

进程被杀掉了，好了，问题解决 :)


## 详解

linux的/proc文件系统提供了系统各方面的运行状态信息。如`cat /proc/28207/status` 命令，可以查看pid=28207的进程的状态。

```sh
# cat /proc/28207/status  
Name:   sh  
Umask:  0022  
State:  S (sleeping)  
Tgid:   28207  
Ngid:   0  
Pid:    28207  
PPid:   27952  
TracerPid:      0  
Uid:    0       0       0       0  
Gid:    0       0       0       0  
FDSize: 64  
Groups: 0   
NStgid: 28207  
NSpid:  28207  
NSpgid: 27953  
NSsid:  27953  
VmPeak:     2892 kB  
VmSize:     2892 kB  
VmLck:         0 kB  
VmPin:         0 kB  
VmHWM:       952 kB  
VmRSS:       952 kB  
RssAnon:              96 kB  
RssFile:             856 kB  
RssShmem:              0 kB  
VmData:      232 kB  
VmStk:       136 kB  
VmExe:        80 kB  
VmLib:      1796 kB  
VmPTE:        44 kB  
VmSwap:        0 kB  
HugetlbPages:          0 kB  
CoreDumping:    0  
THP_enabled:    1  
Threads:        1  
SigQ:   0/127823  
SigPnd: 0000000000000000  
ShdPnd: 0000000000000000  
SigBlk: 0000000000000000  
SigIgn: 0000000000000000  
SigCgt: 0000000000010002  
CapInh: 0000000000000000  
CapPrm: 000001ffffffffff  
CapEff: 000001ffffffffff  
CapBnd: 000001ffffffffff  
CapAmb: 0000000000000000  
NoNewPrivs:     0  
Seccomp:        0  
Seccomp_filters:        0  
Speculation_Store_Bypass:       thread vulnerable  
SpeculationIndirectBranch:      conditional enabled  
Cpus_allowed:   ffff  
Cpus_allowed_list:      0-15  
Mems_allowed:   1  
Mems_allowed_list:      0  
voluntary_ctxt_switches:        4  
nonvoluntary_ctxt_switches:     0
```

下表汇总了Linux的/proc/ 的所有目录和文件的作用

|proc文件路径|作用|
|---|---|
|/proc/[pid]/|这是一个目录，其中包含了与特定进程 ID 相关的信息。通过访问这个目录，你可以查看和获取关于特定进程的各种信息，例如进程状态、内存使用情况、打开文件等。|
|/proc/[pid]/attr/|这是一个目录， 其中包含了与特定进程 ID 相关的属性。|
|/proc/[pid]/attr/current|包含当前任务的属性。|
|/proc/[pid]/attr/exec|包含执行文件的路径。|
|/proc/[pid]/attr/fscreate|包含文件系统创建标志。|
|/proc/[pid]/attr/keycreate|包含键创建标志。|
|/proc/[pid]/attr/prev|包含前一个任务的属性。|
|/proc/[pid]/attr/socketcreate|包含套接字创建标志。|
|/proc/[pid]/autogroup|包含自动组信息。|
|/proc/[pid]/auxv|包含辅助向量信息。|
|/proc/[pid]/cgroup|包含控制组信息。|
|/proc/[pid]/clear_refs|用于清除进程的引用计数。|
|/proc/[pid]/cmdline|包含进程的命令行参数。|
|/proc/[pid]/comm|包含进程的命令名。|
|/proc/[pid]/coredump_filter|包含核心转储过滤器的设置。|
|/proc/[pid]/cpuset|包含进程在 CPU 集上的分配信息。|
|/proc/[pid]/cwd|包含进程的当前工作目录。|
|/proc/[pid]/environ|包含进程的环境变量。|
|/proc/[pid]/exe|包含进程的可执行文件路径。|
|/proc/[pid]/fd/|这是一个目录，其中包含了进程打开的文件描述符的信息。|
|/proc/[pid]/fdinfo/|这是一个目录，其中包含了文件描述符的信息。|
|/proc/[pid]/gid_map|包含进程的 GID 映射信息。|
|/proc/[pid]/io|包含进程的 I/O 信息。|
|/proc/[pid]/limits|包含进程的资源限制信息。|
|/proc/[pid]/map_files/|这是一个目录，其中包含了进程的内存映射文件的信息。|
|/proc/[pid]/maps|包含进程的内存映射信息。|
|/proc/[pid]/mem|包含进程的内存使用情况信息。|
|/proc/[pid]/mountinfo|包含进程的挂载信息。|
|/proc/[pid]/mounts|包含系统的挂载信息。|
|/proc/[pid]/mountstats|包含挂载统计信息。|
|/proc/[pid]/ns/|这是一个目录，其中包含了进程的命名空间信息。|
|/proc/[pid]/numa_maps|包含进程的 NUMA 内存映射信息。|
|/proc/[pid]/oom_adj|包含进程的 OOM 调整级别。|
|/proc/[pid]/oom_score|包含进程的 OOM 得分。|
|/proc/[pid]/oom_score_adj|包含进程的 OOM 得分调整。|
|/proc/[pid]/pagemap|包含进程的页面映射信息。|
|/proc/[pid]/personality|包含进程的个性信息。|
|/proc/[pid]/root|包含进程的根目录。|
|/proc/[pid]/seccomp|包含进程的安全计算信息。|
|/proc/[pid]/setgroups|包含进程的组设置信息。|
|/proc/[pid]/sched_autogroup_enabled|包含自动组调度的启用状态。|
|/proc/[pid]/sched_group|包含调度组信息。|
|/proc/[pid]/smaps|包含进程的内存映射信息的汇总。|
|/proc/[pid]/smaps_rollup|包含进程的内存映射信息的汇总。|
|/proc/[pid]/stack|包含进程的堆栈信息。|
|/proc/[pid]/stat|包含进程的状态信息。|
|/proc/[pid]/statm|包含进程的内存状态信息。|
|/proc/[pid]/status|包含进程的状态信息。|
|/proc/[pid]/syscall|包含进程的系统调用信息。|
|/proc/[pid]/task|包含进程的任务信息。|
|/proc/[pid]/task/[tid]/stat|包含特定任务的状态信息。|
|/proc/[pid]/task/[tid]/status|包含特定任务的状态信息。|
|/proc/[pid]/task/[tid]/io|包含特定任务的 I/O 信息。|
|/proc/[pid]/task/[tid]/children|包含特定任务的子任务信息。|
|/proc/[pid]/ timers|包含进程的定时器信息。|
|/proc/[pid]/timerslack_ns|包含进程的定时器松弛时间（以纳秒为单位）。|
|/proc/[pid]/uid_map|包含进程的用户 ID 映射信息。|
|/proc/[pid]/gid_map|包含进程的组 ID 映射信息。|
|/proc/[pid]/wchan|包含进程等待的通道信息。|
|/proc/apm|包含高级电源管理信息。|
|/proc/buddyinfo|包含内存伙伴系统的信息。|
|/proc/bus|包含总线设备信息。|
|/proc/bus/pccard|包含 PC 卡设备信息。|
|/proc/bus/pccard/drivers|包含 PC 卡驱动程序信息。|
|/proc/bus/pci|包含 PCI 设备信息。|
|/proc/bus/pci/devices|包含 PCI 设备信息。|
|/proc/cmdline|包含引导时传递给内核的命令行参数。|
|/proc/config.gz|包含内核配置信息。|
|/proc/crypto|包含加密模块信息。|
|/proc/cpuinfo|包含 CPU 信息。|
|/proc/devices|包含设备信息。|
|/proc/diskstats|包含磁盘统计信息。|
|/proc/dma|包含直接内存访问信息。|
|/proc/driver|包含设备驱动程序信息。|
|/proc/execdomains|包含执行域信息。|
|/proc/fb|包含帧缓冲设备信息。|
|/proc/filesystems|包含文件系统信息。|
|/proc/fs|包含文件系统信息。|
|/proc/ide|包含 IDE 设备信息。|
|/proc/interrupts|包含中断信息。|
|/proc/iomem|包含 I/O 内存信息。|
|/proc/ioports|包含 I/O 端口信息。|
|/proc/kallsyms|包含内核符号表信息。|
|/proc/kcore|包含内核核心转储信息。|
|/proc/keys|包含键信息。|
|/proc/key-users|包含键用户信息。|
|/proc/kmsg|包含内核消息。|
|/proc/kpagecgroup|包含页面控制组信息。|
|/proc/kpageflags|包含页面标志信息|
|/proc/kpagecount|包含页面计数信息|
|/proc/ksyms|包含内核符号信息|
|/proc/loadavg|包含系统负载平均值信息|
|/proc/locks|包含锁信息|
|/proc/malloc|包含内存分配信息|
|/proc/meminfo|包含内存信息|
|/proc/modules|包含模块信息|
|/proc/mounts|包含挂载点信息|
|/proc/mtrr|这个文件指的是当前系统中正在使用的内存类型范围寄存器（MTRR）|
|/proc/net|包含网络设备信息|
|/proc/net/arp|ARP|
|/proc/net/dev|有关网络设备（如网卡）的实时统计信息。通过读取和解析|
|/proc/net/dev_mcast|用于列出二层（数据链路层）组播包统计信息。该文件的内容包括网络设备名称、组播包数量、组播包接收字节数等信息。|
|/proc/net/igmp|IGM|
|/proc/net/ipv6_route|IPv|
|/proc/net/rarp|RAR|
|/proc/net/raw|用于提供有关网络原始套接字（raw socket）的信息。|
|/proc/net/snmp|SNMP（简单网络管理协议）信息|
|/proc/net/sctp|SCTP（流控制传输协议）信息|
|/proc/net/npf|NPF（网络协议过滤|
|/proc/net/route|包含了路由表信息。|
|/proc/net/snmp|用于网络管理的 SNMP（简单网络管理协议）信息。|
|/proc/net/snmp6|用于 IPv6 的 SNMP 信息。|
|/proc/net/tcp|包含了 TCP 协议的相关信息。|
|/proc/net/udp|包含了 UDP 协议的相关信息。|
|/proc/net/unix|包含了 Unix 域套接字的信息。|
|/proc/net/netfilter/nfnetlink_queue|与网络过滤器相关的信息。|
|/proc/partitions|提供了有关系统的分区信息。|
|/proc/pci|包含了 PCI 设备的信息。|
|/proc/pressure|提供了系统资源使用压力的信息，包括 CPU、IO 和内存。|
|/proc/profile|与性能分析相关的信息。|
|/proc/scsi|包含了 SCSI 设备的信息。|
|/proc/scsi/scsi|特定 SCSI 设备的详细信息。|
|/proc/scsi/[drivername]|特定 SCSI 驱动程序的信息。|
|/proc/self|指向当前正在运行的进程的信息。|
|/proc/slabinfo|提供了关于内核内存 slab 分配的信息。|
|/proc/stat|包含了系统统计信息，如 CPU 使用情况、进程数量等。|
|/proc/swaps|提供了交换空间的信息。|
|/proc/sys|包含了可配置的系统参数。|
|/proc/sys/abi|与体系结构相关的信息。|
|/proc/sys/debug|用于调试目的的信息。|
|/proc/sys/dev|与设备相关的配置信息。|
|/proc/sys/fs|文件系统相关的配置信息。|
|/proc/sys/fs/binfmt_misc|与二进制格式无关文件系统的信息。|
|/proc/sys/fs/dentry-state|目录项状态的信息。|
|/proc/sys/fs/dir-notify-enable|目录通知启用的信息。|
|/proc/sys/fs/dquot-max|最大磁盘配额数的信息。|
|/proc/sys/fs/dquot-nr|当前使用的磁盘配额数的信息。|
|/proc/sys/fs/epoll|与 epoll 系统调用相关的信息。|
|/proc/sys/fs/file-max|系统允许的最大文件数量的信息。|
|/proc/sys/fs/file-nr|当前打开文件的数量的信息。|
|/proc/sys/fs/inode-max|系统允许的最大 inode 数量的信息。|
|/proc/sys/fs/inode-nr|当前使用的 inode 数量的信息。|
|/proc/sys/fs/inotify|与 inotify 系统调用相关的信息。|
|/proc/sys/fs/lease-break-time|文件租约中断时间的信息。|
|/proc/sys/fs/leases-enable|启用文件租约的信息。|
|/proc/sys/fs/mount-max|系统允许的最大挂载数量的信息。|
|/proc/sys/fs/mqueue|与消息队列相关的信息。|
|/proc/sys/fs/nr_open|系统允许的最大打开文件描述符数量的信息。|
|/proc/sys/fs/overflowgid|溢出文件的默认组 ID 的信息。|
|/proc/sys/fs/overflowuid|溢出文件的默认用户 ID 的信息。|
|/proc/sys/fs/pipe-max-size|管道的最大大小的信息。|
|/proc/sys/fs/pipe-user-pages-hard|管道用户页面的硬限制的信息。|
|/proc/sys/fs/pipe-user-pages-soft|管道用户页面的软限制的信息。|
|/proc/sys/fs/protected_hardlinks|受保护硬链接的信息。|
|/proc/sys/fs/protected_symlinks|受保护符号链接的信息。|
|/proc/sys/fs/suid_dumpable|设置是否可以将 SUID 程序的内存转储到文件的信息。|
|/proc/sys/fs/super-max|系统允许的最大超级块数量的信息。|
|/proc/sys/fs/super-nr|当前使用的超级块数量的信息。|
|/proc/sys/kernel|包含与内核相关的参数设置。|
|/proc/sys/kernel/acct|与审计相关的参数设置。|
|/proc/sys/kernel/auto_msgmni|与消息队列相关的参数设置。|
|/proc/sys/kernel/cap_last_cap|与能力相关的参数设置。|
|/proc/sys/kernel/cap-bound|与能力绑定相关的参数设置。|
|/proc/sys/kernel/core_pattern|与核心转储相关的参数设置。|
|/proc/sys/kernel/core_pipe_limit|与核心管道相关的参数设置。|
|/proc/sys/kernel/core_uses_pid|与核心使用 PID 相关的参数设置。|
|/proc/sys/kernel/ctrl-alt-del|与 Ctrl-Alt-Del 相关的参数设置。|
|/proc/sys/kernel/dmesg_restrict|与 dmesg 限制相关的参数设置。|
|/proc/sys/kernel/domainname|与域名相关的参数设置。|
|/proc/sys/kernel/hostname|与主机名相关的参数设置。|
|/proc/sys/kernel/hotplug|与热插拔相关的参数设置。|
|/proc/sys/kernel/htab-reclaim|与 Htab 回收相关的参数设置。|
|/proc/sys/kernel/keys/*|与密钥相关的参数设置。|
|/proc/sys/kernel/kptr_restrict|与内核指针限制相关的参数设置。|
|/proc/sys/kernel/l2cr|与 L2 缓存相关的参数设置。|
|/proc/sys/kernel/modprobe|与模块装载相关的参数设置。|
|/proc/sys/kernel/modules_disabled|与禁用模块相关的参数设置。|
|/proc/sys/kernel/msgmax|与消息队列大小相关的参数设置。|
|/proc/sys/kernel/Msgmni|与消息队列 mni 相关的参数设置。|
|/proc/sys/kernel/Msgmnb|与消息队列 mnb|
|/proc/sys/kernel/ngroups_max|表示系统支持的最大群组数量。|
|/proc/sys/kernel/ns_last_pid|表示最后一个分配的进程 ID。|
|/proc/sys/kernel/ostype|表示操作系统的类型。|
|/proc/sys/kernel/osrelease|表示操作系统的发布版本。|
|/proc/sys/kernel/overflowgid|表示当用户 ID 溢出时使用的默认群组 ID。|
|/proc/sys/kernel/overflowuid|表示当用户 ID 溢出时使用的默认用户 ID。|
|/proc/sys/kernel/panic|包含控制内核 panic 行为的参数。|
|/proc/sys/kernel/panic_on_oops|控制是否在发生Oops（错误）时触发内核 panic。|
|/proc/sys/kernel/pid_max|表示系统允许创建的最大进程 ID。|
|/proc/sys/kernel/powersave-nap|控制电源管理中的 nap 行为。|
|/proc/sys/kernel/printk|包含控制内核消息打印的参数。|
|/proc/sys/kernel/pty|包含与伪终端（PTY）相关的参数。|
|/proc/sys/kernel/pty/max|表示系统允许创建的最大 PTY 数量。|
|/proc/sys/kernel/pty/nr|表示当前已创建的 PTY 数量。|
|/proc/sys/kernel/random|包含与随机数生成器相关的参数。|
|/proc/sys/kernel/random/entropy_avail|表示可用的熵数量。|
|/proc/sys/kernel/random/poolsize|表示随机数池的大小。|
|/proc/sys/kernel/random/read_wakeup_threshold|控制读取随机数时唤醒线程的阈值。|
|/proc/sys/kernel/random/write_wakeup_threshold|控制写入随机数时唤醒线程的阈值。|
|/proc/sys/kernel/random/uuid|包含生成 UUID 的参数。|
|/proc/sys/kernel/random/boot_id|表示系统的启动 ID。|
|/proc/sys/kernel/randomize_va_space|控制虚拟地址空间的随机化。|
|/proc/sys/kernel/real-root-dev|表示根文件系统所在的设备。|
|/proc/sys/kernel/reboot-cmd|包含重启命令的参数。|
|/proc/sys/kernel/rtsig-max|表示最大实时信号数量。|
|/proc/sys/kernel/rtsig-nr|表示当前已分配的实时信号数量。|
|/proc/sys/kernel/sched_child_runs_first|控制子进程是否优先运行。|
|/proc/sys/kernel/sched_rr_timeslice_ms|表示实时调度器的时间片大小（以毫秒为单位）。|
|/proc/sys/kernel/sched_rt_period_us|表示实时调度器的周期时间（以微秒为单位）。|
|/proc/sys/kernel/sched_rt_runtime_us|表示实时任务的运行时间（以微秒为单位）。|
|/proc/sys/kernel/seccomp|包含与安全计算相关的参数。|
|/proc/sys/kernel/sem|包含与信号量相关的参数。|
|/proc/sys/kernel/sg-big-buff|控制大缓冲区的分配。|
|/proc/sys/kernel/shm_rmid_forced|表示是否强制使用共享内存区域的特定 ID。|
|/proc/sys/kernel/shmall|表示可用的共享内存页面数量。|
|/proc/sys/kernel/shmmax|表示最大允许的共享内存大小。|
|/proc/sys/kernel/shmmni|表示系统允许创建的最大共享内存区域数量。|
|/proc/sys/kernel/sysctl_writes_strict|控制是否严格执行 sysctl 写入限制。|
|/proc/sys/kernel/sysrq|包含与 sysrq 键相关的参数。sysrq是Linux内核提供的紧急操作机制，可用于在系统崩溃或无响应时，强制终止运行中的进程，重启系统或者执行一些其他的救援操作|
|/proc/sys/kernel/version|表示内核的版本信息。|
|/proc/sys/kernel/threads-max|表示系统允许创建的最大线程数量。|
|/proc/sys/kernel/yama/ptrace_scope|控制 ptrace 系统调用的范围。|
|/proc/sys/kernel/zero-paged|包含与零页面相关的参数。|
