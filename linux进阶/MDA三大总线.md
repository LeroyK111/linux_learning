# DMA三大总线

Direct Memory Access : 向CPU申请 临时接管系统总线

![](https://raw.githubusercontent.com/LeroyK111/pictureBed/master/20250314170859.png)

## system bus 系统总线

![](https://raw.githubusercontent.com/LeroyK111/pictureBed/master/20250314170535.png)
![](https://raw.githubusercontent.com/LeroyK111/pictureBed/master/20250314170606.png)
控制总线: 操作命令
地址总线: 内存地址
数据总线: 数据传递
![](https://raw.githubusercontent.com/LeroyK111/pictureBed/master/20250314170733.png)

## DMA三种接管模式

### 硬盘读取数据到内存.

![](https://raw.githubusercontent.com/LeroyK111/pictureBed/master/20250314171014.png)

### 周期窃取模式

多路复用.

![](../../Container_Cluster/assets/Pasted%20image%2020250314171047.png)

### 透明模式
后台下执行

![](https://raw.githubusercontent.com/LeroyK111/pictureBed/master/20250314171139.png)


## 兼容万物
![](https://raw.githubusercontent.com/LeroyK111/pictureBed/master/20250314171241.png)

### rust for linux
不碰内核, 先从驱动开始.

![](https://raw.githubusercontent.com/LeroyK111/pictureBed/master/20250314171510.png)




