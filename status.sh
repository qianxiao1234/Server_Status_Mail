#!/bin/bash
set -e  # 命令失败时立即退出

# 读取配置文件
if [ ! -f "config.ini" ]; then
    echo "Error: 配置文件 config.ini 不存在"
    exit 1
fi

# 解析配置（使用awk提取配置值）
MAIL_DIR=$(awk -F '=' '/^mail_dir/ {print $2}' config.ini | sed 's/ //g')
LOG_DIR=$(awk -F '=' '/^log_dir/ {print $2}' config.ini | sed 's/ //g')
CPU_HIGH=$(awk -F '=' '/^cpu_high/ {print $2}' config.ini | sed 's/ //g')
CPU_MEDIUM=$(awk -F '=' '/^cpu_medium/ {print $2}' config.ini | sed 's/ //g')
MEM_HIGH=$(awk -F '=' '/^mem_high/ {print $2}' config.ini | sed 's/ //g')
MEM_MEDIUM=$(awk -F '=' '/^mem_medium/ {print $2}' config.ini | sed 's/ //g')

# 定义路径
MAIL_SUBJECT="$MAIL_DIR/subject.txt"
MAIL_CONTENT="$MAIL_DIR/content.txt"
LOG_FILE="$LOG_DIR/log.txt"
MAIL_SEND="python3 ./send_mail.py"

# 创建目录（若不存在）
mkdir -p "$MAIL_DIR" "$LOG_DIR"

# 获取系统信息
OS_NAME=$(awk -F'=' '/^NAME=/ {print $2}' /etc/os-release | tr -d '"')
CPU_MODEL=$(awk '/model name/ {for(i=4;i<=NF;i++) printf "%s ", $i; print ""}' /proc/cpuinfo | awk 'NR==1')
CPU_CORES=$(grep -c "processor" /proc/cpuinfo)
MEM_TOTAL_GB=$(awk '/MemTotal/ {printf "%.0f",$2/1024/1024}' /proc/meminfo)
UPTIME=$(uptime -p | sed 's/up //; s/days/天/; s/day/天/; s/hours/小时/; s/minutes/分钟/; s/,//')
CPU_USAGE=$(top -bn1 | grep Cpu | awk '{print $2}')
MEM_USAGE=$(free | awk 'NR==2 {printf "%.2f", $3/$2 * 100}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')  # 根目录磁盘使用率
LOAD_AVG=$(uptime | awk -F 'load average: ' '{print $2}')  # 系统负载

# 判断负载状态
CPU_USAGE_INT=$(echo "$CPU_USAGE" | cut -d '.' -f1)
if [ "$CPU_USAGE_INT" -gt "$CPU_HIGH" ]; then
    CPU_STATUS="负载过高！！！"
elif [ "$CPU_USAGE_INT" -gt "$CPU_MEDIUM" ]; then
    CPU_STATUS="负载较高"
else
    CPU_STATUS="负载正常"
fi

MEM_USAGE_INT=$(echo "$MEM_USAGE" | cut -d '.' -f1)
if [ "$MEM_USAGE_INT" -gt "$MEM_HIGH" ]; then
    MEM_STATUS="负载过高！！！"
elif [ "$MEM_USAGE_INT" -gt "$MEM_MEDIUM" ]; then
    MEM_STATUS="负载较高"
else
    MEM_STATUS="负载正常"
fi

# 生成邮件内容
echo "服务器状态：$OS_NAME" > "$MAIL_SUBJECT"

{
    echo "📊 硬件信息"
    echo "CPU: $CPU_MODEL（核心数: $CPU_CORES）"
    echo "内存总容量: $MEM_TOTAL_GB GB"
    echo "----------------------------------------"
    echo "⏱️ 运行时间: $UPTIME"
    echo "----------------------------------------"
    echo "📈 当前状态"
    echo "CPU占用：$CPU_USAGE%（$CPU_STATUS）"
    echo "内存占用：$MEM_USAGE%（$MEM_STATUS）"
    echo "磁盘使用率（/）：$DISK_USAGE"
    echo "系统负载（1/5/15分钟）：$LOAD_AVG"
    echo "----------------------------------------"
    echo "脚本运行时间：$(date '+%Y年%m月%d日%H时%M分%S秒')"
} > "$MAIL_CONTENT"

# 记录日志
echo "$(date '+%Y-%m-%d %H:%M:%S') - 脚本执行成功" >> "$LOG_FILE"

# 发送邮件
$MAIL_SEND
