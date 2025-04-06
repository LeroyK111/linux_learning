@echo off
ipconfig /flushdns
:: IPv4 有线 DNS 设置
netsh interface ipv4 set dns name="以太网" static 8.8.8.8 primary
netsh interface ipv4 add dns name="以太网" addr=162.158.165.137 index=2
netsh interface ipv4 add dns name="以太网" addr=162.158.165.136 index=3
netsh interface ipv4 add dns name="以太网" addr=103.219.21.115 index=4
netsh interface ipv4 add dns name="以太网" addr=74.125.179.158 index=5
netsh interface ipv4 add dns name="以太网" addr=172.253.237.22 index=6
netsh interface ipv4 add dns name="以太网" addr=74.125.179.146 index=7
netsh interface ipv4 add dns name="以太网" addr=172.253.5.18 index=8
netsh interface ipv4 add dns name="以太网" addr=172.253.5.26 index=9
netsh interface ipv4 add dns name="以太网" addr=74.125.179.152 index=10
netsh interface ipv4 add dns name="以太网" addr=192.178.36.145 index=11
netsh interface ipv4 add dns name="以太网" addr=74.125.179.156 index=12
netsh interface ipv4 add dns name="以太网" addr=1.1.1.1 index=13
netsh interface ipv4 add dns name="以太网" addr=149.112.112.112 index=14
netsh interface ipv4 add dns name="以太网" addr=208.67.220.220 index=15
netsh interface ipv4 add dns name="以太网" addr=8.20.247.20 index=16

:: IPv6 有线 DNS 设置
netsh interface ipv6 set dns name="以太网" static 2400:cb00:464:1024::a29e:a589 primary
netsh interface ipv6 add dns name="以太网" addr=2400:cb00:464:1024::a29e:a588 index=2
netsh interface ipv6 add dns name="以太网" addr=2404:6800:4005:c08::121 index=3
netsh interface ipv6 add dns name="以太网" addr=2404:6800:4005:c03::12a index=4
netsh interface ipv6 add dns name="以太网" addr=2404:6800:4005:c02::128 index=5
netsh interface ipv6 add dns name="以太网" addr=2404:6800:4005:c02::12e index=6
netsh interface ipv6 add dns name="以太网" addr=2404:6800:4005:c03::12b index=7
netsh interface ipv6 add dns name="以太网" addr=2404:6800:4005:c00::129 index=8
netsh interface ipv6 add dns name="以太网" addr=2404:6800:4008:c05::122 index=9
netsh interface ipv6 add dns name="以太网" addr=2404:6800:4008:c05::124 index=10
netsh interface ipv6 add dns name="以太网" addr=2606:4700:4700::1111 index=11
netsh interface ipv6 add dns name="以太网" addr=2001:4860:4860::8888 index=12
netsh interface ipv6 add dns name="以太网" addr=2620:fe::fe index=13
netsh interface ipv6 add dns name="以太网" addr=2620:119:35::35 index=14
netsh interface ipv6 add dns name="以太网" addr=2606:4700:4700::1001 index=15

:: IPv4 WLAN DNS 设置（与以太网保持一致）
netsh interface ipv4 set dns name="WLAN" static 8.8.8.8 primary
netsh interface ipv4 add dns name="WLAN" addr=162.158.165.137 index=2
netsh interface ipv4 add dns name="WLAN" addr=162.158.165.136 index=3
netsh interface ipv4 add dns name="WLAN" addr=103.219.21.115 index=4
netsh interface ipv4 add dns name="WLAN" addr=74.125.179.158 index=5
netsh interface ipv4 add dns name="WLAN" addr=172.253.237.22 index=6
netsh interface ipv4 add dns name="WLAN" addr=74.125.179.146 index=7
netsh interface ipv4 add dns name="WLAN" addr=172.253.5.18 index=8
netsh interface ipv4 add dns name="WLAN" addr=172.253.5.26 index=9
netsh interface ipv4 add dns name="WLAN" addr=74.125.179.152 index=10
netsh interface ipv4 add dns name="WLAN" addr=192.178.36.145 index=11
netsh interface ipv4 add dns name="WLAN" addr=74.125.179.156 index=12
netsh interface ipv4 add dns name="WLAN" addr=1.1.1.1 index=13
netsh interface ipv4 add dns name="WLAN" addr=149.112.112.112 index=14
netsh interface ipv4 add dns name="WLAN" addr=208.67.220.220 index=15
netsh interface ipv4 add dns name="WLAN" addr=8.20.247.20 index=16

:: IPv6 WLAN DNS 设置（与以太网保持一致）
netsh interface ipv6 set dns name="WLAN" static 2400:cb00:464:1024::a29e:a589 primary
netsh interface ipv6 add dns name="WLAN" addr=2400:cb00:464:1024::a29e:a588 index=2
netsh interface ipv6 add dns name="WLAN" addr=2404:6800:4005:c08::121 index=3
netsh interface ipv6 add dns name="WLAN" addr=2404:6800:4005:c03::12a index=4
netsh interface ipv6 add dns name="WLAN" addr=2404:6800:4005:c02::128 index=5
netsh interface ipv6 add dns name="WLAN" addr=2404:6800:4005:c02::12e index=6
netsh interface ipv6 add dns name="WLAN" addr=2404:6800:4005:c03::12b index=7
netsh interface ipv6 add dns name="WLAN" addr=2404:6800:4005:c00::129 index=8
netsh interface ipv6 add dns name="WLAN" addr=2404:6800:4008:c05::122 index=9
netsh interface ipv6 add dns name="WLAN" addr=2404:6800:4008:c05::124 index=10
netsh interface ipv6 add dns name="WLAN" addr=2606:4700:4700::1111 index=11
netsh interface ipv6 add dns name="WLAN" addr=2001:4860:4860::8888 index=12
netsh interface ipv6 add dns name="WLAN" addr=2620:fe::fe index=13
netsh interface ipv6 add dns name="WLAN" addr=2620:119:35::35 index=14
netsh interface ipv6 add dns name="WLAN" addr=2606:4700:4700::1001 index=15

:: 可选暂停（调试用）
:: pause
