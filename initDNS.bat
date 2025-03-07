@echo off
ipconfig /flushdns
:: ĞŞ¸Ä ip mask getaway
:: netsh interface ip set address "ÒÔÌ«Íø 2" static 10.102.220.223 255.255.254.0 10.102.220.1
:: ĞŞ¸Ä dns 92.87.109.134, 170.64.147.31, 118.3.227.163, 58.185.92.216, 8.8.8.8
netsh interface ip add dns name = "ÒÔÌ«Íø" addr = 92.87.109.134
netsh interface ip add dns name = "ÒÔÌ«Íø" addr = 170.64.147.31
netsh interface ip add dns name = "ÒÔÌ«Íø" addr = 118.3.227.163
netsh interface ip add dns name = "ÒÔÌ«Íø" addr = 58.185.92.216
netsh interface ip add dns name = "ÒÔÌ«Íø" addr = 162.252.172.57
netsh interface ip add dns name = "ÒÔÌ«Íø" addr = 149.154.159.92
netsh interface ip add dns name = "ÒÔÌ«Íø" addr = 8.8.8.8
netsh interface ip add dns name = "ÒÔÌ«Íø" addr = 8.8.4.4
netsh interface ip add dns name = "ÒÔÌ«Íø" addr = 1.0.0.1
netsh interface ip add dns name = "ÒÔÌ«Íø" addr = 1.1.1.1
netsh interface ip add dns name = "WLAN" addr = 92.87.109.134
netsh interface ip add dns name = "WLAN" addr = 170.64.147.31
netsh interface ip add dns name = "WLAN" addr = 118.3.227.163
netsh interface ip add dns name = "WLAN" addr = 58.185.92.216
netsh interface ip add dns name = "WLAN" addr = 162.252.172.57
netsh interface ip add dns name = "WLAN" addr = 149.154.159.92
netsh interface ip add dns name = "WLAN" addr = 8.8.8.8
netsh interface ip add dns name = "WLAN" addr = 8.8.4.4
netsh interface ip add dns name = "WLAN" addr = 1.0.0.1
netsh interface ip add dns name = "WLAN" addr = 1.1.1.1
@REM pause