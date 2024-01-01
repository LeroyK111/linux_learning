# ldconfig 详解

ldconfig 是Linux下管理动态链接库是否生效的命令，ldconfig的缓存文件 /etc/ld.so.cache 非常重要，Linux下的动态链接后的可执行文件的运行离不开ldconfig及其缓存文件。正式基于ldconfig指明了动态库信息，Linux启动后其他普通才能通过ldconfig的工作成果——ldconfig缓存文件，来使用共享动态库。

## 使用说明

```shell
# ldconfig的使用说明：
# ldconfig缓存文件默认路径为/etc/ld.so.cache，该文件保存了已排好序的动态链接库名字列表。
# ldconfig命令选项说明：
-v或--verbose：用此选项时，ldconfig将显示正在扫描的目录及搜索到的动态链接库，还有它所创建的连接的名字.
-n :用此选项时，ldconfig仅扫描命令行指定的目录，不扫描默认目录(/lib，/usr/lib)，也不扫描配置文件/etc/ld.so.conf所列的目录.
-N :此选项指示ldconfig不重建缓存文件(/etc/ld.so.cache).若未用-X选项，ldconfig照常更新文件的连接.
-X : 此选项指示ldconfig不更新文件的连接.若未用-N选项，则缓存文件正常更新.
-f CONF : 此选项指定动态链接库的配置文件为CONF，系统默认为/etc/ld.so.conf.
-C CACHE :此选项指定生成的缓存文件为CACHE，系统默认的是/etc/ld.so.cache，此文件存放已排好序的可共享的动态链接库的列表.
-r ROOT :此选项改变应用程序的根目录为ROOT(是调用chroot函数实现的).选择此项时，系统默认的配置文件/etc/ld.so.conf，实际对应的为ROOT/etc/ld.so.conf.如用-r/usr/zzz时，打开配置文件/etc/ld.so.conf时，实际打开的是/usr/zzz/etc/ld.so.conf文件.用此选项，可以大大增加动态链接库管理的灵活性.
-l :通常情况下，ldconfig搜索动态链接库时将自动建立动态链接库的连接.选择此项时，将进入专家模式，需要手工设置连接.一般用户不用此项.
-p或--print-cache :此选项指示ldconfig打印出当前缓存文件所保存的所有共享库的名字.
-c FORMAT 或--format=FORMAT :此选项用于指定缓存文件所使用的格式，共有三种:ld(老格式)，new(新格式)和compat(兼容格式，此为默认格式).
-V : 此选项打印出ldconfig的版本信息，而后退出.
-? 或 --help 或--usage : 这三个选项作用相同，都是让ldconfig打印出其帮助信息，而后退出。
```

## Linux的ldconfig -p命令可打印出系统缓存已记录的所有动态库的信息。那么这个功能是如何实现的？

本文主要通过解读Linux的ldconfig命令的关键代码，分析了ldconfig命令是如何实现读取缓存文件 `/etc/ld.so.cache` 的内容的。本文涉及到的ldconfig的cache.c 代码文件网址[1]，在参考资料里。

  
ldconfig 使用的 /etc/ld.so.cache 文件，曾出现过2个版本：

1. 老版本的缓存文件格式 老版本指libc5 格式的动态库，在glibc 2.0/2.1版本时采用的格式。缓存文件内容由`cache_file`类型的数据结构填充，其定义为
    

`struct cache_file   {     char magic[sizeof CACHEMAGIC - 1];     unsigned int nlibs; /* 记录的条数*/     struct file_entry libs[0];   };   `

2. 新版本的的缓存文件格式 新版本指glibc 2.2及之后版本的。缓存文件内容由`cache_file_new`数据结构填充。定义为：
    

`struct cache_file_new   {     char magic[sizeof CACHEMAGIC_NEW - 1];     char version[sizeof CACHE_VERSION - 1];     uint32_t nlibs;  /* 记录的条数 */     uint32_t len_strings;  /* Size of string table. */        /* flags & cache_file_new_flags_endian_mask is one of the values        cache_file_new_flags_endian_unset, cache_file_new_flags_endian_invalid,        cache_file_new_flags_endian_little, cache_file_new_flags_endian_big.           The remaining bits are unused and should be generated as zero and        ignored by readers.  */     uint8_t flags;        uint8_t padding_unsed[3]; /* Not used, for future extensions.  */        /* File offset of the extension directory.  See struct        cache_extension below.  Must be a multiple of four.  */     uint32_t extension_offset;        uint32_t unused[3];  /* Leave space for future extensions          and align to 8 byte boundary.  */     struct file_entry_new libs[0]; /* Entries describing libraries.  */     /* After this the string table of size len_strings is found. */   };   `

在glibc-2.35的代码中已用英文说明了，glibc2.2格式的，能兼容glibc2.2之前的缓存文件内容。这里说的兼容，是依赖于代码检测实现的：由于两种结构体都以magic作为第一个项目，来识别缓存文件类型。再根据magic值的不同，对后续数据段采用不同的处理方式。老magic的定义为`#define CACHEMAGIC "ld.so-1.7.0"`，新magic的定义为`#define CACHEMAGIC_NEW "glibc-ld.so.cache"`。也就是老版本 cache_file 的文件头部以字符串`ld.so-1.7.0`开始，新版本cache_file_new 的文件头部以字符串`glibc-ld.so.cache`开始。这点我们可以用head -c 命令查看下/etc/ld.so.cache文件的头部30个字符串旧可以验证了：

`# head -c 30  /etc/ld.so.cache   glibc-ld.so.cache1.1���   `

以上输出信息确实以`glibc-ld.so.cache`开始，所以我用的Ubuntu22.04系统的ldconfig的缓存文件内容是新格式的。

ldconfig代码的cache.c 文件里是这样根据magic的不同用`if(){} else{}`处理的：

`if (memcmp (cache->magic, CACHEMAGIC, sizeof CACHEMAGIC - 1))       {///当属于老版本时，按这里的方式处理         /* This can only be the new format without the old one.  */         cache_new = (struct cache_file_new *) cache;            if (memcmp (cache_new->magic, CACHEMAGIC_NEW, sizeof CACHEMAGIC_NEW - 1)      || memcmp (cache_new->version, CACHE_VERSION,           sizeof CACHE_VERSION - 1))    error (EXIT_FAILURE, 0, _("File is not a cache file.\n"));         check_new_cache (cache_new);         format = 1;         /* This is where the strings start.  */         cache_data = (const char *) cache_new;       }     else       {//当属于新版本缓存文件的时候，按下面内容处理         ……省略       }   `

在知道了 缓存文件类型（magic标记）后，就可以开始根据格式标准，逐条读/写每条记录了，这是ldconfig的重头戏。

先看对cache文件的读取效果，以 `ldconfig -p`命令打印出缓存文件的所有记录的结果为例：

``# ldconfig -p   1525 libs found in cache `/etc/ld.so.cache   ……     libGLESv1_CM.so (libc6,x86-64) => /lib/x86_64-linux-gnu/libGLESv1_CM.so     libGL.so.1 (libc6,x86-64) => /lib/x86_64-linux-gnu/libGL.so.1     libGL.so (libc6,x86-64) => /lib/x86_64-linux-gnu/libGL.so   ……   ``

这里每条都是一个动态库的名称、格式(libc6等格式)、CPU架构、所在路径的记录。

缓存文件中的这么一条记录，对应的结构体，旧版本的为`file_entry`，新版本的为`file_entry_new`。它们的定义分别为：

`struct file_entry   {     int32_t flags;  /* This is 1 for an ELF library.  */     uint32_t key, value;  /* String table indices.  */   };   `

以及新版本的 file_entry格式：

`struct file_entry_new ///文件记录的新格式，增加了OS版本、硬件信息   {     union     {       /* Fields shared with struct file_entry.  */       struct file_entry entry;       /* Also expose these fields directly.  */       struct       {         int32_t flags;  /* This is 1 for an ELF library.  */         uint32_t key, value; /* String table indices.  */       };     };     uint32_t osversion;  /* Required OS version.  */     uint64_t hwcap;  /* Hwcap entry.  */   };   `

继续分析【读缓存文件】的简要流程：

1. 使用了 mmap() 函数，将 /etc/ld.so.cache 缓存文件整体读入内存，
    

`struct cache_file *cache       = mmap (NULL, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);   `

这是通过mmap()函数，将打开的缓存文件（`open(/etc/ld.so.cache)`的句柄fd）的数据映射到内存，由于文件数据就是按`struct cache_file_new`结构体格式填充的，所以mmap()后，就可以按这个结构体去解析各个条目。2. 判断magic，新老magic分流处理。3. 如果是新的magic，则按`struct cache_file_new`数据结构解析。4. 对于新格式，遍历读取数据、打印：

`……   else{         struct cache_extension_all_loaded ext;         if (……)错误处理;            /* Print everything.  */         for (unsigned int i = 0; i < cache_new->nlibs; i++)    {      const char *hwcaps_string        = glibc_hwcaps_string (&ext, cache, cache_size,          &cache_new->libs[i]);             print_entry (cache_data + cache_new->libs[i].key,            cache_new->libs[i].flags,            cache_new->libs[i].osversion,            cache_new->libs[i].hwcap, hwcaps_string,            cache_data + cache_new->libs[i].value);    }         print_extensions (&ext);   }   `

这里关键内容是:

1. cache_data，代表了mmap()读取到的缓存文件内容；以cache_data的地址为初始地址，按偏移量`cache_new->libs[i].key` 相加后，可得到每条file_entry_new的入口，然后分别打印出记录内容，就实现了 ldconfig -p 的代码功能。
    
2. 动态库的条数，等于 cache_new->nlibs 这个变量的值。作为for循环遍历时的条件。
    
3. cache_new->libs[i].key 这里的key，在`struct file_entry_new`中的定义是
    

`uint32_t key, value;  /* String table indices.  */   `

key相当于第i条动态库记录的目录索引。通过索引可以查到value。在实现时，key和value都是数字，这个数字代表字符串相对于cache_data这个首地址的字节偏移量，例如`key->value 即 cache_new->libs[i].key, cache_new->libs[i].value 43256 -> 43234`

![](../README.assets/Pasted%20image%2020231225214908.png)

总之，通过对结构体的合理使用，将缓存文件内容解析后，可打印出缓存文件中记录的所有已知动态库文件的信息。

`void print_cache (const char *cache_name)` 的函数代码结束之前，还做了一下内存回收工作：

  `/* Cleanup.  */     munmap (cache, cache_size);     close (fd);`

首先使用munmap()函数，将之前已映射内存数据做一下清除；然后关闭打开的cache缓存文件描述符。

本文主要通过解读Linux的ldconfig命令的关键代码，分析了ldconfig命令是如何实现读取缓存文件 `/etc/ld.so.cache` 的内容的。本文涉及到的ldconfig的cache.c 代码文件网址[1]，在参考资料里。

## 动态连接库

Linux通过使用动态库的方式使得多个程序可以共享一个动态库，节省了很多的存储空间和运行空间。那么这个是如何实现的呢？我之前也一直比较疑惑，通过一段时间的研究算是搞懂了一些。

我们可以想一下，链接是要干什么事情？其实链接最重要的一件事情就是确定好代码的运行地址，不管是变量还是函数都要把地址确定好这样才能够正确的执行。静态链接就是把所有用到的函数和变量都聚合到一个文件中，然后把地址确定好，最后就形成了一个可执行文件。但是动态链接不是这样，除了可执行文件还有一块是作为一个动态库独立的存在，只能在运行的时候才能重新把地址排布好，专业术语叫做重定位。

下面我们看如果要实现在运行的时候动态重定位，对可执行文件和动态库都有什么要求。对于动态库来说，就得要求它的代码里面不能有绝对地址存在，必须都是相对地址访问，因为如果是绝对地址的话那么一旦重定位那么这个绝对地址就会出错。对于可执行文件来说，就得有个地方记住哪些函数或者变量是来自于动态库中，还得有个地方能够用来保存重定位后的这些函数或者变量的真实地址。前面这个要求容易做到，只要在可执行文件中拿出一部分空间，在gcc编译的时候写入进去就可以了。但是后面这个要求就不是那么好做，要知道程序的代码段是只读的，肯定不能在运行的时候修改代码段，那么能修改的只能是数据段，但是数据段虽然可写但是不能执行，所以中间还得有个跳板才行。基本思想就是这样，下面看看代码要如何实现。

首先看看如何让动态库的程序实现相对地址访问，可以在编译的时候采取下面的方式：

gcc -fPIC --shared test_lib.c -g -o libtest_lib.so  
#这里的-fPIC就是让gcc生成相对地址访问的程序，也叫做位置无关
我们可以反汇编看下代码
首先可以看到，程序的执行地址都很小是从0地址开始的（这个程序是x86体系）而正常x86上面的程序都是从0x804xxxxx开始的。另外就是看下红框部分的指令：e8 28 00 00，其中e8是相对地址调用，相对地址大小就是后面的0x28加上它的下一条指令地址也就是0x578所以0x28+0x578=0x5a0。可以看到这里都是用的这种相对地址访问，就是为了避免使用绝对地址导致重定位后程序执行出问题。

![](../../readme.assets/Pasted%20image%2020240101125546.png)
动态库的问题解决了，下面来看可执行文件这边如何来实现跳板以及修改重定位后的地址，这个相对会复杂一些不过也很有意思，里面的思想也可以迁移到其它地方来作为解决问题的办法。为了实现上面所说的，可执行文件中保存了两个表：PLT和GOT。其中PLT位于代码段可读可执行但是不可写，它起到跳板的作用。GOT位于数据段可读可写但是不可执行，它作为最终动态库函数真实地址存放的地方。我们通过代码来具体分析一下是如何实现的。

可执行文件的测试代码：
```sh
test_main.c
#include <stdio.h>
#include <unistd.h>

extern int b;

int main(void)
{
    //func1();

    b = 5;

    func2();

    while(1) sleep(2);

    return 0;
}


动态库的代码：
test_lib.c
#include <stdio.h>

int b = 1;

void func1(void)
{
    b = 2;
}

void func2(void)
{
    printf("func2 b=%d\n", b);
}


进行编译，生成可执行文件
gcc -fPIC --shared test_lib.c -g -o libtest_lib.so
gcc -g -o test_main test_main.c ./libtest_lib.so
接下来就要反汇编可执行文件：test_main来看看里面的细节了
可以看到main函数中调用func1的地方是调用了func1@plt
```
![](../../readme.assets/Pasted%20image%2020240101125911.png)
下面看看func1@plt。可以看到这个就是PLT表了，我们的func1@plt就在这里。上面我有说这个是跳板，我们继续看下是怎么个跳法。这个函数的第一条指令就是一个跳转指令，它是要跳到0x804a00c这个内存地址保存的值的位置，注意它不是跳到0x804a00c哦，因为前面带了一个"*"表示取地址。
![](../../readme.assets/Pasted%20image%2020240101125927.png)
接下就要看这个0x804a00c保存了什么内容。可以看到0x804a00c就是在GOT表中，GOT表是从0x804a000地址开始的，那么0x804a00c地址里面保存的值就是56840408，但是要注意x86是小端地址所以56840408真实值就是：0x08048456，可以发现这个地址就是PLT表中func1@plt的第二条指令地址，就是又跳回去了。
![](../../readme.assets/Pasted%20image%2020240101125944.png)
看到这里的时候就估计会很困惑，前面讲了GOT表中不是应该保存的是func1的真实地址吗？为什么又跳回来了？我刚开始的时候也是很不理解，后来通过看一些资料后才终于搞明白是怎么回事。而且这个正是动态连接的其中一个精髓。我们先想一个问题，如果我们要执行一个动态链接的可执行程序，为了确保正常它在运行前就会查找所有在动态库中的函数和变量，然后把它们都填到程序的GOT表中。想象一下，如果这个程序使用的动态库中函数和变量比较多，动态库也比较大的话，整个过程是不是就会需要耗费不少时间，直观的感觉就是程序运行会比较慢。为了解决这个问题，Linux就使用了一种叫做用时加载的方法。这个思想在Linux中被很多地方应用到，比如分配内存的时候，只有当向这块内存里面写数据的时候，才会真正分配内存。所以我们就看到了，第一次调用func1函数的时候，GOT表中并没有保存它的真实地址。那么继续往下看是什么时候以及怎么把真实地址保存进来的。

跳转到0x8048456后执行的是一条压栈指令，然后接下来又是一条跳转指令，转到了func1@plt-0x10。这里首先是一条压栈指令，接着就是一个跳转到0x804a008内存地址处保存的值，同样要注意这里不是跳转到0x804a008。
![](../../readme.assets/Pasted%20image%2020240101130011.png)
这个地址同样是在GOT表中，可以看下它里面的值是0xb7ff0000
![](../../readme.assets/Pasted%20image%2020240101130028.png)
看下0xb7ff0000这个地址是什么东西。可以看到这是一个函数地址，这个函数是：_dl_runtime_resolve。这个是glibc中的一个函数，作用就是查找动态库中函数的位置并将其写入到程序的GOT表中。这个函数比较复杂，下次找机会再来分析。
![](../../readme.assets/Pasted%20image%2020240101130039.png)
到这里整个过程基本就清晰了，中间涉及到不少汇编代码的分析。下面用一幅图来描述这个过程
![](../../readme.assets/Pasted%20image%2020240101130053.png)
当第一次执行完后，再次执行func1这个函数的时候就不用再反复跳转跑到_dl_runtime_resolve这里来了，因为GOT表中已经保存了func1的真实地址。可以看下执行了第一次调用后再GOT表里面的信息：、
![](../../readme.assets/Pasted%20image%2020240101130111.png)
里面的值变成了0xb7fd4550，不再是0x08048456了。
看下0xb7fd4550这个地址是什么东西。发现就是func1函数的地址。
![](../../readme.assets/Pasted%20image%2020240101130126.png)
这基本就是动态链接的大致过程了，还是花了不少时间来盘它。主要是很多背景知识自己还是缺乏，比如汇编、ELF文件格式等等。技术一条无底洞越学越觉得要学习的东西太多，不过当把背景知识补齐然后搞通了一个技术点后，还是非常有成就感的。








































