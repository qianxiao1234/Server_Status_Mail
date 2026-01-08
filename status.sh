#!/bin/bash

# 设置基础变量
MAIL_DIRECTORY="./status" # 邮件内容目录
LOG_DIRECTORY="./log" # 日志目录
MAIL_SUBJECT="$MAIL_DIRECTORY/subject.txt" # 邮件标题
MAIL_CONTENT="$MAIL_DIRECTORY/content.txt" # 邮件正文
LOG_FILE="$LOG_DIRECTORY/log.txt" # 日志文件
MAIL_SEND="python3 ./send_mail.py" # 调用外部脚本发送邮件

# 判断MAIL_DIRECTORY是否存在
if [ ! -d "$MAIL_DIRECTORY" ]; then # 如果MAIL_DIRECTORY不存在
  mkdir "$MAIL_DIRECTORY" # 创建MAIL_DIRECTORY
fi # 结束

# 判断LOG_DIRECTORY是否存在
if [ ! -d "$LOG_DIRECTORY" ]; then # 如果LOG_DIRECTORY不存在
  mkdir "$LOG_DIRECTORY" # 创建LOG_DIRECTORY
fi # 结束

# 获取服务器操作系统名称并写入邮件标题
echo "服务器状态：$(awk -F'=' '/^NAME=/ {print $2}' /etc/os-release | tr -d '"')" | tee "$MAIL_SUBJECT"

# 获取硬件信息并设置为变量
CPU_MODEL=$(awk '/model name/ {for(i=4;i<=NF;i++) printf "%s ", $i; print ""}' /proc/cpuinfo | awk 'NR==1') # 获取CPU信息
CPU_PROCESSOR=$(grep -c "processor" /proc/cpuinfo) # 获取CPU核心数
MEM_TOTAL_GB=$(awk '/MemTotal/ {printf "%.0f",$2/1024/1024}' /proc/meminfo) # 获取内存大小的值保留整数
RUNNING_TIME=$(uptime -p | sed 's/up //; s/weeks/周/;s/week/周/; s/days/天/; s/day/天/; s/hours/小时/; s/hour/小时/; s/minutes/分钟/;') # 获取服务器运行时间
CPU_USAGE=$(top -bn1 | grep Cpu | awk '{print $2}') # 获取CPU占用百分比
MEM_USAGE=$(free | awk 'NR==2 {printf "%.2f", $3/$2 * 100}') # 获取内存占用百分比

# 判断当前负载值
# 判断CPU占用百分比
CPU_USAGE_1=$(echo "$CPU_USAGE" | cut -d '.' -f1) # 舍去小数点及后面的数
if [ "$CPU_USAGE_1" -gt 80 ]; then
  CPU_STATUS="负载过高！！！"
elif [ "$CPU_USAGE_1" -gt 50 ]; then
  CPU_STATUS="负载较高"
else
  CPU_STATUS="负载正常"
fi

# 判断MEM占用百分比
MEM_USAGE_1=$(echo "$MEM_USAGE" | cut -d '.' -f1) # 舍去小数点及后面的数
if [ "$MEM_USAGE_1" -gt 80 ]; then
  MEM_STATUS="负载过高！！！"
elif [ "$MEM_USAGE_1" -gt 50 ]; then
  MEM_STATUS="负载较高"
else
  MEM_STATUS="负载正常"
fi

# 输出
echo "CPU: $CPU_MODEL  核心: $CPU_PROCESSOR" | tee "$MAIL_CONTENT"
echo "MEM: $MEM_TOTAL_GB GB" | tee -a "$MAIL_CONTENT"
echo "服务器已经运行 $RUNNING_TIME 啦！" | tee -a "$MAIL_CONTENT"
echo "当前:" | tee -a "$MAIL_CONTENT"
echo "CPU占用：$CPU_USAGE%，$CPU_STATUS" | tee -a "$MAIL_CONTENT"
echo "MEM占用：$MEM_USAGE%，$MEM_STATUS" | tee -a "$MAIL_CONTENT"
echo "脚本运行时间：$(date '+%Y年%m月%d日%H时%M分%S秒')" | tee -a "$MAIL_CONTENT" "$LOG_FILE"

# 发送邮件
$MAIL_SEND
