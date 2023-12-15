# macos 清除缓存，刷新dns
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder