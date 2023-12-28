# curl 用法

Linux curl 命令有哪些常见用法？

curl是最流行的web请求工具，3大主流操作系统带有curl，一些手机移动端系统也提供了curl，通过命令行下载文件和发起网页请求，简单好用YYDS！

> curl 是一种从服务器传输数据或向服务器传输数据的工具，使用的协议包括 协议（DICT、FILE、FTP、FTPS、GOPHER、HTTP、HTTPS、IMAP、 imaps、ldap、ldaps、pop3、pop3s、rtmp、rtsp、scp、sftp、smtp、smtps、 TELNET 和 TFTP）。该命令无需用户干预。

> curl 提供了大量有用的功能，如支持代理、用户授权、访问FTP和TFTP上传下载、HTTP请求、SSL 连接、携带Cookie、文件传输断点续传、Metalink请求等。正如你在下文中看到的，curl支持的功能可谓大而全。

> curl还提供了libcurl，以库的形式封装了所有与传输相关的功能。请参见 libcurl(3) 了解详情。


## curl 的用法规则

curl 命令允许您在 Linux 中通过命令行下载和上传数据。其语法如下：

`curl [options] [URL...]   `

可通过`curl --help` 命令，就像大部分其他命令的--help那样，可以自助查询该命令的常见参数：

```
 -d, --data <data> HTTP POST 数据  
 -f, --fail HTTP错误时安静地失败（完全不打印错误）  
 -h, --help <category> 获取命令帮助  
 -i, --include 在输出中包含协议响应标头  
 -o, --output <file> 输出写入到文件而不是 stdout  
 -O, --remote-name 将输出写入名为远程文件的文件中  
 -s, --安静模式  
 -T，--upload-file <file> 将本地文件传输到目的地  
 -u, --user <user:password> 服务器用户和密码  
 -A、--user-agent <name> 发送 User-Agent <name> 到服务器  
 -v，--verbose 使操的作反馈更加详尽显示  
 -V, --version 显示版本号
```

--help值显示部分参数。curl还支持很多高级功能，Linux下可通过

`man curl   `

命令查看完整的帮助文档对curl所有参数的解释（例如跟随重定向的`-L`参数，只在`man curl` 的完整帮助信息中有显示 ）。

![](../README.assets/Pasted%20image%2020231228205410.png)

![](../README.assets/Pasted%20image%2020231228205424.png)


![](../README.assets/Pasted%20image%2020231228205441.png)