@echo off
ipconfig /flushdns
:: ĞŞ¸Ä ip mask getaway
:: netsh interface ip set address "ÒÔÌ«Íø 2" static 10.102.220.223 255.255.254.0 10.102.220.1
:: ĞŞ¸Ä dns 92.87.109.134, 170.64.147.31, 118.3.227.163, 58.185.92.216, 8.8.8.8
netsh interface ipv4 set dns name="ÒÔÌ«Íø" static 103.219.21.115 primary
netsh interface ipv4 add dns name="ÒÔÌ«Íø" addr=162.158.165.137 index=2
netsh interface ipv4 add dns name="ÒÔÌ«Íø" addr=162.158.165.136 index=3
netsh interface ipv4 add dns name="ÒÔÌ«Íø" addr=8.8.8.8 index=4
netsh interface ipv4 add dns name="ÒÔÌ«Íø" addr=74.125.179.158 index=5
netsh interface ipv4 add dns name="ÒÔÌ«Íø" addr=172.253.237.22 index=6
netsh interface ipv4 add dns name="ÒÔÌ«Íø" addr=74.125.179.146 index=7
netsh interface ipv4 add dns name="ÒÔÌ«Íø" addr=172.253.5.18 index=8
netsh interface ipv4 add dns name="ÒÔÌ«Íø" addr=172.253.5.26 index=9
netsh interface ipv4 add dns name="ÒÔÌ«Íø" addr=74.125.179.152 index=10
netsh interface ipv4 add dns name="ÒÔÌ«Íø" addr=192.178.36.145 index=11
netsh interface ipv4 add dns name="ÒÔÌ«Íø" addr=74.125.179.156 index=12
netsh interface ipv6 set dns name="ÒÔÌ«Íø" static 2400:cb00:464:1024::a29e:a589 primary
netsh interface ipv6 add dns name="ÒÔÌ«Íø" addr=2400:cb00:464:1024::a29e:a588 index=2
netsh interface ipv6 add dns name="ÒÔÌ«Íø" addr=2404:6800:4005:c08::121 index=3
netsh interface ipv6 add dns name="ÒÔÌ«Íø" addr=2404:6800:4005:c03::12a index=4
netsh interface ipv6 add dns name="ÒÔÌ«Íø" addr=2404:6800:4005:c02::128 index=5
netsh interface ipv6 add dns name="ÒÔÌ«Íø" addr=2404:6800:4005:c02::12e index=6
netsh interface ipv6 add dns name="ÒÔÌ«Íø" addr=2404:6800:4005:c03::12b index=7
netsh interface ipv6 add dns name="ÒÔÌ«Íø" addr=2404:6800:4005:c00::129 index=8
netsh interface ipv6 add dns name="ÒÔÌ«Íø" addr=2404:6800:4008:c05::122 index=9
netsh interface ipv6 add dns name="ÒÔÌ«Íø" addr=2404:6800:4008:c05::124 index=10
netsh interface ipv4 set dns name="WLAN" static 103.219.21.115 primary
netsh interface ipv4 add dns name="WLAN" addr=162.158.165.137 index=2
netsh interface ipv4 add dns name="WLAN" addr=162.158.165.136 index=3
netsh interface ipv4 add dns name="WLAN" addr=8.8.8.8 index=4
netsh interface ipv4 add dns name="WLAN" addr=74.125.179.158 index=5
netsh interface ipv4 add dns name="WLAN" addr=172.253.237.22 index=6
netsh interface ipv4 add dns name="WLAN" addr=74.125.179.146 index=7
netsh interface ipv4 add dns name="WLAN" addr=172.253.5.18 index=8
netsh interface ipv4 add dns name="WLAN" addr=172.253.5.26 index=9
netsh interface ipv4 add dns name="WLAN" addr=74.125.179.152 index=10
netsh interface ipv4 add dns name="WLAN" addr=192.178.36.145 index=11
netsh interface ipv4 add dns name="WLAN" addr=74.125.179.156 index=12
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
@REM pause

