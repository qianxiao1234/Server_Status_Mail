# Server_Status_Mail
自动将服务器状态信息通过电子邮件发送到邮箱
- 仓库里的send_mail.py为发送邮件的python脚本，内部包含QQ邮箱的模板，请按需修改
- status.sh为服务器信息生成脚本，无需额外配置，可按需修改

## 使用方法
要使用本项目，首先需要克隆仓库到本地。

```sh
git clone https://github.com/qianxiao1234/Server_Status_Mail.git
```

请修改send_mail.py文件后再执行发送邮件的指令

```sh
sh status.sh
```
