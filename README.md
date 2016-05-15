# webvirtcloud in Docker
## [webvirtcloud project](https://github.com/retspen/webvirtcloud) (Thanks to Anatoliy Guskov)

>[webvirtcloud](https://github.com/retspen/webvirtcloud)是一个用来管理KVM（实际上是通过libvirt）的基于浏览器的管理界面，但是安装配置步骤较多，不太方便，这里用Docker来简化安装配置。

- 两个版本：
> 1. allinone模式，所有webvirtcloud, nginx, sqlite都运行于一个容器中。以下提到此模式的镜像时，称为allinone镜像。
> 2. standalone模式， 每个组件单独运行在自己的容器中，包括webvirtcloud, nginx, postgresql。以下提到吃模式的镜像时，仅指用于此模式的webvirtcloud镜像，不包括nginx和postgres镜像。

- 配置中经常提到两种服务器，需要区分一下：
> 1. webvirtcloud服务器，用于安装运行webvirtcloud管理平台的服务器
> 2. virsh服务器，运行virsh的服务器，被webvirtcloud服务器所管理的服务器

--------
## 使用allinone版本的步骤
1. 在webvirtcloud服务器上安装配置docker(略)

2. 运行webvirtcloud-allinone容器

```
$ docker run -d --name webvirtcloud -p 80:80 -p 6080:6080 daocloud.io/ken/webvirtcloud
```
或者使用docker-compose，下载allinon目录下的docker-compose.yml文件，然后在同一目录下运行
```
$ docker-compose up -d
```

3. 使用浏览器访问 http://yourip/

4. 添加被管理的virsh服务器，不同的virsh服务器连接方式配置不同，参见下面的virsh服务器配置步骤

--------
## 使用standalone版本的步骤
1. 在webvirtcloud服务器上安装配置docker(略)

2. 下载docker-compose.yml文件，并在同一目录下运行
```
$ docker-compose up -d
```
这个命令会拉起webvirtcloud, nginx和postgresql三个容器，后两个容器采用docker的官方镜像。
如果不想用docker-compose，则需要运行以下命令，**其中第二行是进行初始化，仅需运行一次**
```
$ docker run -d --name postgres \
> -e POSTGRES_PASSWORD your_postgres_password \
> postgres

$ docker run -it --rm --link postgres:db \
> -e DB_PASSWORD=your_wvc_db_password \
> daocloud.io/ken/wvc /init.sh

> daocloud.io/ken/wvc /bin/true
$ docker run -d --name wvc --link postgres:db daocloud.io/ken/wvc
$ docker run -d --name web -p 80:80 --link wvc \
> --volume-from wvc:ro \
> -v ${PWD}/nginx.conf:/etc/nginx/nginx.conf \
> -v ${PWD}/webvirtcloud.conf:/etc/nginx/conf.d/webvirtcloud.conf \
> nginx
```

--------
## virsh服务器的配置
简单处理，运行
```
$ wget -O - https://clck.ru/9V9fH | sudo sh
```
这个自动化脚本里面大致做了三件事
1. 安装软件，包括KVM, libvirt, Linux Bridge, Guestfs, supervisor，以及必要的库
2. 配置软件，安装后修改了libvirt的配置来支持多种连接方式，修改了supervisor和配置
3. 运行软件，启动libvirt服务和supervisor服务

## 从webvirtcloud服务界面配置virsh服务器的连接方式

共有4种连接方式，前三种是网络连接，需要webvirtcloud容器和被管理的virsh服务器网络。最后一种只能运行于webvirtcloud容器和被管理virsh服务器在同一服务器上的场景。

1. TCP连接
virsh服务器需要配置virsh的网络访问，如果你之前按运行了virsh服务器的脚本，此配置已经生效。用户授权需要使用saslpasswd2 -a libvirt *username*命令。

添加用户
```
$ sudo saslpasswd2 -a libvirt ken
Password: xxxxxx
Again (for verification): xxxxxx
```

列出用户
```
$ sudo saslpasswd2 -f /etc/libvirt/passwd.db
```

删除用户
```
$ sudo saslpasswd2 -a libvirt -d ken
```

验证连接
```
$ virsh -c qemu+tcp://IP_address/system nodeinfo
```

[更多内容......](https://github.com/retspen/webvirtmgr/wiki/Setup-TCP-authorization)

2. SSH连接

SSH连接方式使用virsh服务器上的用户和证书来访问virsh服务，那么首先是用ssh-keygen生成证书，然后将私有证书放入webvirtcloud服务器的www-data用户的.ssh目录中，将公有证书导入virsh服务器的用于连接的用户的.ssh目录的authorized_keys文件中。

在allinone和standalone镜像中，都内置了公钥和私钥文件，以方便快速使用和测试，从安全角度考虑，你应该用自己的公钥私钥文件来替换。

- 在allinone和standalone镜像中，缺省用户是www-data，私钥文件为/var/www/.ssh/id_rsa，公钥文件为/var/www/.ssh/id_rsa.pub。webvirtcloud服务器无需配置，可以通过以下命令导出公钥：

```
$ docker exec -it webvirtcloud cat /var/www/.ssh/webvirtcloud_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7zEEPi7AeG4Luk1nP7faf8KzWmyyMXQmNf7WMZOwJP08Zp9p6QJ727w6OFgTtMbL3miljXjjV7U9TC8mQBIJ9cRZFwFZZfsifFROSYE+OUjsw6IuzUaq3krPOqM71/iKm3jHIqd9JAu5M0MnwTGjd9aVs3aXPJ68PuVmaEXgsBql+4cSu0890GBY9BoOxE6i1Pdjxw6T6ZsxRnyAzx2Q9bBCXtVngjgQhS77vNhFENKlnqL170O17lAW+xHzr+ONULtFVqOveaqdVcZNGlb6KbN3otsUq00dE6ow2jZM9q4OhA7FSzoiQRVgPlr4JNj+soG3AR9fGHh7TwrkEdRad webvirtcloud
```

将显示的内容拷贝并添加到被管理virsh服务器的用于SSH连接（并属于libvirt组）的用户的~/.ssh/authorized_keys文件中就可以了。

[更多内容......](https://github.com/retspen/webvirtmgr/wiki/Setup-SSH-Authorization)

3. TLS连接
(TBD)

4. Unix Socket连接
用于连接运行webvirtcloud服务器上的virsh服务，需要在运行webvirtcloud容器时指定/var/run/libvirt/libvirt-sock文件。由于这个文件是归属于root:libvirt的，而容器内没有libvirt组，并且运行用户是www-data而不是root，在容器内需要将www-data用户加入到libvirt组中。这个操作已经由entrypoint.sh脚本自动处理了。

- 对allinone镜像来说，启动容器的命令为：
```
$ docker run -d --name webvirtcloud -p 80:80 -p 6080:6080 \
> -v /var/run/libvirt/libvirt-sock:/var/run/libvirt/libvirt-sock \
> daocloud.io/ken/webvirtcloud
```

- 对standalone镜像来说，启动容器的命令为：
```
$ docker run -d --name wvc -p 8000:8000 --link db \
> --volume-from wvcdata:/srv/webvirtcloud \
> -v /var/run/libvirt/libvirt-sock:/var/run/libvirt-sock \
> daocloud.io/ken/wvc
```

如果你用docker-compose的方式启动，则需要相应修改docker-compose.yml文件。

[更多内容......](https://github.com/retspen/webvirtmgr/wiki/Setup-Local-connection)

--------
如果对以上步骤中还有疑问，请访问[wiki](https://github.com/retspen/webvirtmgr/wiki)
