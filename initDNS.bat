@echo off;
ipconfig /flushdns
:: �޸� ip mask getaway
:: netsh interface ip set address "��̫�� 2" static 10.102.220.223 255.255.254.0 10.102.220.1
:: �޸� dns
netsh interface ip add dns name = "��̫�� 2" addr = 162.252.172.57
netsh interface ip add dns name = "��̫�� 2" addr = 149.154.159.92
netsh interface ip add dns name = "��̫�� 2" addr = 8.8.8.8
netsh interface ip add dns name = "��̫�� 2" addr = 8.8.4.4
netsh interface ip add dns name = "��̫�� 2" addr = 1.0.0.1
netsh interface ip add dns name = "��̫�� 2" addr = 1.1.1.1
netsh interface ip add dns name = "WLAN" addr = 162.252.172.57
netsh interface ip add dns name = "WLAN" addr = 149.154.159.92
netsh interface ip add dns name = "WLAN" addr = 8.8.8.8
netsh interface ip add dns name = "WLAN" addr = 8.8.4.4
netsh interface ip add dns name = "WLAN" addr = 1.0.0.1
netsh interface ip add dns name = "WLAN" addr = 1.1.1.1
@REM pause