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

## 如何从内存保存入ld.so.cache缓存文件？
首先从整体上看 一下 /etc/ld.so.cache 文件的内容布局：
![](../README.assets/Pasted%20image%2020231230235220.png)
```c
 save_cache() {  
  
 // 先计算 cache_name 里的新/旧格式的 所有动态库（cache_entry_new、cache_entry）的【信息记录】的条数  
   
 // 创建和初始化用于保存到ld.so.cache文件的 内存数据结构  
  
 if (opt_format != opt_format_old)  
    {  
      /* And the list of all entries in the new format.  */  
      file_entries_new_size = sizeof (struct cache_file_new)  
 + cache_entry_count * sizeof (struct file_entry_new);  
      file_entries_new = xmalloc (file_entries_new_size);  
  
      /* Fill in the header.  */  
      memset (file_entries_new, '\0', sizeof (struct cache_file_new));  
      memcpy (file_entries_new->magic, CACHEMAGIC_NEW,  
       sizeof CACHEMAGIC_NEW - 1);  
      memcpy (file_entries_new->version, CACHE_VERSION,  
       sizeof CACHE_VERSION - 1);  
  
      file_entries_new->nlibs = cache_entry_count;  
      file_entries_new->len_strings = strings_finalized.size;  
      file_entries_new->flags = cache_file_new_flags_endian_current;  
    }  
  
    /*  
       以上，是新cache_name内容的结构体的创建过程。重点分析：  
     1. cache 数据在内存中的大小：为 file_entries_new_size ，等于struct cache_file_new 结构体作为头部的大小，加上 所有动态库的信息记录cache_entry_count * sizeof (struct file_entry_new) 的大小）。也就是 ld.so.cache 文件的数据由这两部分组成。  
      2. 初始化头部： 第一部分的magic 值，设置为新格式的代号：CACHEMAGIC_NEW，也就是字符串 "glibc-ld.so.cache"；  
      3. 初始化 动态库信息记录：包括初始化记录条数值 (nlibs)、初始化记录的字符串长度(len_strings)、记录标志位flags。  
    */  
  
    //对于 hwcaps 特新需要特殊处理，本文不讨论。  
    ……
```

准备好了内存数据，然后开始按各部分逐步写入到ld.so.cache文件。
```c
  /* Write out the cache.  */  
  
  /* Write cache first to a temporary file and rename it later.  */  
  char *temp_name = xmalloc (strlen (cache_name) + 2);  
  sprintf (temp_name, "%s~", cache_name);  
  
  
  /* Create file.    
     第一步创建临时文件 /etc/ld.so.cache~ 写完后会重命名为正式文件  
     注意这里的临时文件名以~结尾  
  */  
  int fd = open (temp_name, O_CREAT|O_WRONLY|O_TRUNC|O_NOFOLLOW,  
   S_IRUSR|S_IWUSR);  
  if (fd < 0)  
    error (EXIT_FAILURE, errno, _("Can't create temporary cache file %s"),  
    temp_name);  
  
  /* Write contents.   
     第二步，写入 cache_file */   
  if (opt_format != opt_format_new)  
    {  
      if (write (fd, file_entries, file_entries_size)  
   != (ssize_t) file_entries_size)  
 error (EXIT_FAILURE, errno, _("Writing of cache data failed"));  
    }  
  if (opt_format != opt_format_old)  
    {  
      /* Align cache.  
      第三步：写入兼容性所需的对齐数据，包括pad填充 */  
      if (opt_format != opt_format_new)  
 {  
   char zero[pad];  
   memset (zero, '\0', pad);  
   if (write (fd, zero, pad) != (ssize_t) pad)  
     error (EXIT_FAILURE, errno, _("Writing of cache data failed"));  
 }    
      /* 第四步： 写入 file_entries 动态库文件信息记录*/  
      if (write (fd, file_entries_new, file_entries_new_size)  
   != (ssize_t) file_entries_new_size)  
 error (EXIT_FAILURE, errno, _("Writing of cache data failed"));  
    }  
  
       /* 第五步： 写入 file_entries 的截止标记*/  
  if (write (fd, strings_finalized.strings, strings_finalized.size)  
      != (ssize_t) strings_finalized.size)  
    error (EXIT_FAILURE, errno, _("Writing of cache data failed"));  
  
  if (opt_format != opt_format_old)  
    {  
      /* Align file position to 4.  */  
      off64_t old_offset = lseek64 (fd, extension_offset, SEEK_SET);  
      assert ((unsigned long long int) (extension_offset - old_offset) < 4);  
        
        /* 第六步： 写入 extensions directory 信息*/  
      write_extensions (fd, str_offset, extension_offset);  
    }
```
临时文件写完，内容就是最新的ld.so.cache需要的内容，但临时文件还要改名替换掉ld.so.cache:
```c
/* Make sure user can always read cache file 设置文件权限，允许ld.so.cache 被所有账号读取，且允许被创建者（root）修改。这里涉及到 Linux的glibc 中的 S_IROTH|S_IRGRP|S_IRUSR|S_IWUSR 标记， 其中R代表读，W代表写，OTH代表非创建者也非同组的其他账号权限，USR代表创建者，GRP代表与创建者所在的组账号*/  
  if (chmod (temp_name, S_IROTH|S_IRGRP|S_IRUSR|S_IWUSR))  
    error (EXIT_FAILURE, errno,  
    _("Changing access rights of %s to %#o failed"), temp_name,  
    S_IROTH|S_IRGRP|S_IRUSR|S_IWUSR);  
  
  /* Make sure that data is written to disk.    
     用fsync() 调用，确保文件从内存缓冲落盘到硬盘。  
  */  
  if (fsync (fd) != 0 || close (fd) != 0)  
    error (EXIT_FAILURE, errno, _("Writing of cache data failed"));  
  
  /* Move temporary to its final location.    
     真正开始将 临时文件 /etc/ld.so.cache~ 重命名为 /etc/ld.so.cache  
  */  
  if (rename (temp_name, cache_name))  
    error (EXIT_FAILURE, errno, _("Renaming of %s to %s failed"), temp_name,  
    cache_name);  
    ……
```
以上， ldconfig 可执行文件对 /etc/ld.so.cache 的写入全部完成。

最后做一下内存数据清理：
```c
 /* Free all allocated memory.  */  
  free (file_entries_new);  
  free (file_entries);  
  free (strings_finalized.strings);  
  free (temp_name);  
  
  while (entries)  
    {  
      entry = entries;  
      entries = entries->next;  
      free (entry);  
    }
```

