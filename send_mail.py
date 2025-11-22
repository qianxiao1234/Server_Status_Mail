#!/usr/bin/python
# -*- coding: UTF-8 -*-

import smtplib
import configparser
from email.mime.text import MIMEText
from email.header import Header
from email.utils import formataddr

# 读取配置文件
config = configparser.ConfigParser()
config.read('config.ini', encoding='utf-8')

# 邮件配置
mail_host = config.get('mail', 'smtp_host')
mail_port = config.getint('mail', 'smtp_port')
mail_user = config.get('mail', 'user')
mail_pass = config.get('mail', 'pass')
sender_name = config.get('mail', 'sender_name')
sender = mail_user
receivers = eval(config.get('mail', 'receivers'))  # 解析列表
receiver_name = config.get('mail', 'receiver_name')
mail_dir = config.get('path', 'mail_dir')

# 读取邮件内容
try:
    with open(f'{mail_dir}/subject.txt', 'r', encoding='utf-8') as f:
        subject = f.read().strip()
    with open(f'{mail_dir}/content.txt', 'r', encoding='utf-8') as f:
        content = f.read()
except FileNotFoundError as e:
    print(f"Error: 邮件内容文件缺失 - {e}")
    exit(1)

# 构建邮件
message = MIMEText(content, 'plain', 'utf-8')
message['From'] = formataddr([sender_name, sender])
message['To'] = formataddr([receiver_name, ', '.join(receivers)])  # 显示所有收件人
message['Subject'] = Header(subject, 'utf-8')

# 发送邮件
smtpObj = None
try:
    smtpObj = smtplib.SMTP_SSL(mail_host, mail_port)
    smtpObj.login(mail_user, mail_pass)
    smtpObj.sendmail(sender, receivers, message.as_string())
    print("邮件发送成功")
except smtplib.SMTPException as e:
    print(f"Error: 无法发送邮件 - {e}")
finally:
    if smtpObj:
        try:
            smtpObj.quit()
        except Exception as e:
            print(f"关闭连接失败: {e}")
