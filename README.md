# wechat-windows-versions
收集 Windows 微信版本并保存

相关项目: 
* [Mac微信收集](https://github.com/zsbai/wechat-versions)
* [WindowsX86 版本收集(目前仅含23年6月12日后的)](https://github.com/tom-snow/wechat-windows-versions-x86)

## 目录结构
```shell
├── README.md # 自述文件
├── WeChatSetup # 微信安装包临时目录
│   └── temp # 临时目录
└── scripts   # 脚本目录
    ├── destVersionRelease.sh # 获取安装包及取得版本号与 hash 值的脚本
    └── notify.sh # 新release 时调用通知的脚本
```

## 说明
项目使用 Github Action 自动下载微信最新版本安装包计算 Hash 值并推送至仓库。

**注意： 3.5.0.46 版本以下（不包含 3.5.0.46 版， 仅下载了一部分）均下载自 [web.archive.org](https://web.archive.org/web/*/https://pc.weixin.qq.com/)**

各版本更新日志可参见 [changelog](https://weixin.qq.com/cgi-bin/readtemplate?lang=zh_CN&t=weixin_faq_list&head=true)

*如有问题/侵权，请直接提交 issue 告知。*
