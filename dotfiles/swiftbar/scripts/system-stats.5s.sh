#!/usr/bin/env bash

# <swiftbar.title>System Stats</swiftbar.title>
# <swiftbar.version>v1.0</swiftbar.version>
# <swiftbar.author>Jiaqi Wang</swiftbar.author>
# <swiftbar.author.github>jiaqiwang969</swiftbar.author.github>
# <swiftbar.desc>Display CPU, Memory and Network stats</swiftbar.desc>
# <swiftbar.dependencies>bash,top,vm_stat,netstat</swiftbar.dependencies>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>

# Base64 encoded system icon
icon='iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAAdgAAAHYBTnsmCAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAGUSURBVDiNlZK9ThtBFIW/M7P2YhsLKXIRKUARkCi1RJEiJQV0wBvwBEgU6XkF3oCGB0BBScEPBVAhKoQUkJCQhSIrGP/tzu6dFN61vXgxkE812nPPPTpzZ0Zk+2xkAzu2Z2Z6lmSZLJVUxJnpXJItkyQRVQURQERQUSEk8szrq7HhKFinCFJYmLr0NZhrSNJYmLrCENlcj3m5PKsRiTbZyO1fTZSM9MzEWWpqCqq1eRqjXOOOI4xxhBFEcYYnHPEcYxzjiiKUFWstTjncc5jrcUYgzGG0DlPkkSICM45qqrCe4/3nqqqKMuS+XxOURTM53PKsqSqKrz3VFWFqtYkxpgfwHtPkiSICNZarLV476mqirIsWSwWLBYLyrKkqiqstTjnMMbgnCMMQ0QEY0wNKMsSVWU6nTKbzfDeU1UV3nvKsmSxWDCfz1kul0ynU0II9Ho9kiTBGPO9Qb/fp9PpEMcxQRBQFAXT6ZQwDGm1WrRaLcIwZDKZMBgMaLfbdLtdut0urVaL4BP4F/jXeAO2t1xzxrOK5QAAAABJRU5ErkJggg=='

export PATH=/usr/local/bin:/opt/homebrew/bin:$PATH

# 获取系统状态
get_stats() {
    # CPU
    cpu_usage=$(top -l 1 | grep -E "^CPU" | grep -Eo '[^[:space:]]+%' | head -1)
    
    # Memory
    total_memory=$(sysctl -n hw.memsize)
    used_memory=$(vm_stat | awk '
        /Pages active/ {active=$3};
        /Pages wired/ {wired=$4};
        /Pages occupied/ {occupied=$3};
        END {print (active+wired+occupied)*4096}
    ')
    memory_used=$((used_memory * 100 / total_memory))
    
    # Network
    rx_bytes=$(netstat -ib | grep -m1 'en0' | awk '{print $7}')
    tx_bytes=$(netstat -ib | grep -m1 'en0' | awk '{print $10}')
    sleep 1
    rx_bytes_new=$(netstat -ib | grep -m1 'en0' | awk '{print $7}')
    tx_bytes_new=$(netstat -ib | grep -m1 'en0' | awk '{print $10}')
    
    rx_speed=$((($rx_bytes_new - $rx_bytes) / 1024))
    tx_speed=$((($tx_bytes_new - $tx_bytes) / 1024))
}

# 主菜单显示
show_menu() {
    echo "| templateImage=$icon"
    echo "---"
    echo "CPU Usage: ${cpu_usage} | color=#00a4ef sfsize=12"
    echo "Memory Used: ${memory_used}% | color=#7fba00 sfsize=12"
    echo "Download: ${rx_speed} KB/s | color=#f25022 sfsize=12"
    echo "Upload: ${tx_speed} KB/s | color=#ffb900 sfsize=12"
    echo "---"
    echo "Open Activity Monitor | bash=/usr/bin/open param0=-a param1=\"Activity Monitor\" terminal=false"
    echo "Open Network Utility | bash=/usr/bin/open param0=-a param1=\"Network Utility\" terminal=false"
}

# 主程序
main() {
    get_stats
    show_menu
}

main 