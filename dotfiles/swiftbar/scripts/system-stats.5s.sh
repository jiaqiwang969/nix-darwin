#!/bin/bash

# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>

# 获取 CPU 使用率
cpu_usage=$(top -l 1 | grep -E "^CPU" | grep -Eo '[^[:space:]]+%' | head -1)

# 获取内存信息
memory_stats=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print $5}')
memory_free=$((memory_stats))
memory_used=$((100 - memory_free))

# 获取网络速度
network_stats=$(nload -u K -t 500 en0 -c 1 | grep "Curr:" | awk '{print $2" "$3}' | tr '\n' ' ')
incoming=$(echo $network_stats | cut -d' ' -f1)
outgoing=$(echo $network_stats | cut -d' ' -f2)

# 显示在菜单栏上
echo "CPU: $cpu_usage MEM: ${memory_used}% ↑${outgoing}KB/s ↓${incoming}KB/s"

# 下拉菜单显示详细信息
echo "---"
echo "CPU Usage: $cpu_usage | color=#00a4ef"
echo "Memory Used: ${memory_used}% | color=#7fba00"
echo "Memory Free: ${memory_free}% | color=#7fba00"
echo "Network Upload: ${outgoing} KB/s | color=#ffb900"
echo "Network Download: ${incoming} KB/s | color=#f25022"

echo "---"
echo "Open Activity Monitor | bash=/usr/bin/open param0=-a param1=\"Activity Monitor\" terminal=false"
echo "Open Network Utility | bash=/usr/bin/open param0=-a param1=\"Network Utility\" terminal=false" 