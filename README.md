# webvirtcloud in Docker

[webvirtcloud](https://github.com/retspen/webvirtcloud)是一个用来管理KVM（其实是virsh）的基于浏览器的管理界面，但是安装配置步骤较多，不太方便，这里用Docker来简化安装配置。

两个版本：
1. allinone
2. standalone with nginx, postgresql

配置中经常提到两个服务器，需要区分一下：
1. webvirtcloud服务器，用于安装运行webvirtcloud管理平台的服务器
2. virsh服务器，运行virsh的服务器，被webvirtcloud服务器所管理


[project](https://github.com/retspen/webvirtcloud) (Thanks to Anatoliy Guskov)
[wiki](https://github.com/retspen/webvirtmgr/wiki)

