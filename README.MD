# Server_Status_Mail

自动将服务器状态信息通过电子邮件发送到指定邮箱，支持多维度监控和自定义配置。

# 该分支为未经测试的AI优化版本，禁止使用！！！
# 该分支为未经测试的AI优化版本，禁止使用！！！
# 该分支为未经测试的AI优化版本，禁止使用！！！

## 功能特点
- 监控CPU、内存、磁盘、系统负载等关键指标
- 支持多收件人配置和邮件内容自定义
- 阈值告警（负载过高/较高/正常）
- 完善的日志记录和错误处理

## 监控指标
- 操作系统名称
- CPU型号及核心数
- 内存总容量及使用率
- 服务器运行时间
- 磁盘使用率（根目录）
- 系统1/5/15分钟负载值

## 使用步骤

### 1. 克隆仓库
```bash
git clone https://github.com/qianxiao1234/Server_Status_Mail.git
cd Server_Status_Mail
```

### 2. 复制并修改配置文件（必做！）：
```bash
# 复制示例配置（若不存在config.ini）
cp config.ini.example config.ini
```
编辑config.ini配置项：
```ini
[mail]
smtp_host = smtp.qq.com       # 邮箱SMTP服务器（QQ邮箱默认smtp.qq.com）
smtp_port = 465               # SMTP端口（QQ邮箱默认465）
user = your_email@qq.com      # 发件人邮箱
pass = your_smtp_auth_code    # SMTP授权码（非邮箱密码，需在邮箱设置中获取）
receivers = ["a@qq.com", "b@example.com"]  # 收件人列表
sender_name = 服务器监控      # 发件人显示名称
receiver_name = 管理员        # 收件人显示名称

[path]
mail_dir = ./status           # 邮件内容存储目录
log_dir = ./log               # 日志存储目录

[threshold]
cpu_high = 80                 # CPU高负载阈值（%）
cpu_medium = 50               # CPU中负载阈值（%）
mem_high = 80                 # 内存高负载阈值（%）
mem_medium = 50               # 内存中负载阈值（%）
```

### 3. 手动执行测试
```bash
chmod +x status.sh
./status.sh
```
执行成功后，收件邮箱会收到服务器状态邮件，日志会记录在./log/log.txt。

### 4. 设置定时任务（推荐）
通过crontab设置定时发送（例如每天 8 点执行）：
```bash
# 编辑定时任务
crontab -e

# 添加以下内容（路径替换为实际仓库路径）
0 8 * * * cd /path/to/Server_Status_Mail && sh status.sh >> ./log/cron.log 2>&1
```

### 注意事项

- 确保服务器已安装python3和awk（通常 Linux 系统默认安装）
- SMTP 授权码获取方式：
    - QQ 邮箱：设置 → 账户 → 开启 POP3/SMTP 服务 → 获取授权码
    - 163 邮箱：设置 → POP3/SMTP/IMAP → 开启服务 → 获取授权码
- 若发送失败，检查log.txt和cron.log排查错误（常见原因：授权码错误、SMTP 端口被封）

### 优化说明
```plaintext
1. **配置集中化**：通过`config.ini`统一管理所有参数，避免修改代码
2. **功能增强**：新增磁盘使用率、系统负载监控，支持多收件人
3. **稳定性提升**：增加错误处理（文件缺失、命令失败时终止执行），完善资源释放
4. **易用性优化**：README补充详细配置步骤和定时任务说明，邮件内容格式化更清晰
5. **可扩展性**：阈值参数化，后续可轻松添加更多监控指标

使用时只需修改`config.ini`中的邮箱信息和阈值，无需修改脚本代码，大幅降低使用门槛。
```