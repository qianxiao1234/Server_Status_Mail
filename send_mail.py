#!/usr/bin/python
# -*- coding: UTF-8 -*-

import smtplib
from email.mime.text import MIMEText
from email.header import Header
from email.utils import formataddr

# QQ邮箱的SMTP服务器地址和端口
mail_host = "smtp.qq.com"  # 设置服务器
mail_user = "xxx@qq.com"  # 用户名，即你的QQ邮箱地址
mail_pass = "xxx"  # 口令，即SMTP授权码

sender_name = "浅笑科技"  # 发件人名称
sender = mail_user  # 发件人邮箱地址
receivers = ['xxx@qq.com']  # 接收邮件，可设置为你的QQ邮箱或者其他邮箱
receiver_name = "浅笑"  # 收件人名称

# 获取邮件主题和内容
with open('./status/subject.txt', 'r', encoding='utf-8') as f:
    subject = f.read().strip()

with open('./status/content.txt', 'r', encoding='utf-8') as f:
    content = f.read()

# 发送邮件内容
message = MIMEText(content, 'plain', 'utf-8')
message['From'] = formataddr([sender_name, sender])  # 发件人名称和邮箱地址
message['To'] = formataddr([receiver_name, receivers[0]])  # 收件人名称和邮箱地址
# subject = f'服务器状态: {system_name}'
message['Subject'] = Header(subject, 'utf-8')  # 邮件主题

try:
    smtpObj = smtplib.SMTP_SSL(mail_host, 465)  # 使用SSL加密，端口为465
    smtpObj.login(mail_user, mail_pass)
    smtpObj.sendmail(sender, receivers, message.as_string())
    print("邮件发送成功")
except smtplib.SMTPException as e:
    print("Error: 无法发送邮件", e)
finally:
    smtpObj.quit()
