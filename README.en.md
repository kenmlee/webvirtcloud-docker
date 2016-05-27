# webvirtcloud in Docker
## [webvirtcloud project](https://github.com/retspen/webvirtcloud) (Thanks to Anatoliy Guskov)

[中文README](REAEME.md)

- There are two type of container：
> 1. all-in-one type: all components (webvirtcloud, novncd, nginx, sqlite ) are running in one container
> 2. standalone type: only webvirtcloud and novncd include in the container. You need run database container ( postgres recommend ) and web container ( nginx recommend ) separately.

- Pay attention to two type of server：
> 1. webvirtcloud server: managing server running webvirtcloud
> 2. virsh server: virtualization server running virsh environment managed by webvirtcloud

--------
## how to use allinone
1. Install  [docker](https://docs.docker.com/engine/installation/#installation) on webvirtcloud server

2. Start webvirtcloud-allinone container

```
$ docker run -d --name webvirtcloud -p 80:80 -p 6080:6080 kenlee/webvirtcloud-docker:allinone
```
Or use `docker-compose`，download docker-compose from allinon folder:
```
$ docker-compose up -d
```

3. Go to http://yourip/

4. Add one or more virsh servers. Check how to config virsh server connection below.

--------
## How to use standalone
1. Install  [docker](https://docs.docker.com/engine/installation/#installation) on webvirtcloud server

2. Use one of following
    - 2a. download `docker-compose.yml` from root folder and run
```
$ docker-compose up -d
```

    Don't forget run initialization script as:
```
$ docker exec -i wvc /init.sh
```

2b. If not want to use docker-compose, you can start containers one by one, **the second command only need run once**
```
$ docker run -d --name postgres \
> -e POSTGRES_PASSWORD your_postgres_password \
> postgres

$ docker run -it --rm --link postgres:db \
> -e DB_PASSWORD=your_wvc_db_password \
> kenlee/webvirtcloud-docker:latest /init.sh
$ docker run -d --name wvc -p 6080:6080 --link postgres:db kenlee/webvirtcloud-docker:latest
$ docker run -d --name web -p 80:80 --link wvc \
> --volumes-from wvc:ro \
> kenlee/webvirtcloud-docker:web
```

The last one `kenlee/webvirtcloud-docker:web` based on official Ngnix image with webvirtcloud configuration. If you want to use offical Nginx image, you need provide your `webvirtcloud.conf` and `nginx.conf`. As:

```
$ docker run -d --name web -p 80:80 --link wvc \
> --volumes-from wvc:ro \
> -v ${PWD}/nginx.conf:/etc/nginx/nginx.conf \
> -v ${PWD}/webvirtcloud.conf:/etc/nginx/conf.d/webvirtcloud.conf \
> nginx
```
    in webvirtcloud.conf, you need keep the name same as "wvc" in --link parameter.
```
server {
    listen 80;

    #server_name webvirtcloud.example.com;
    #access_log /var/log/nginx/webvirtcloud-access_log;

    location /static/ {
        root /srv/webvirtcloud;
        expires max;
    }

    location / {
        proxy_pass http://wvc:8000;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-for $proxy_add_x_forwarded_for;
        proxy_set_header Host $host:$server_port;
        proxy_set_header X-Forwarded-Proto $remote_addr;
        proxy_connect_timeout 600;
        proxy_read_timeout 600;
        proxy_send_timeout 600;
        client_max_body_size 1024M;
    }
}
```

--------
## virsh server configuration
Simply run:
```
$ wget -O - https://clck.ru/9V9fH | sudo sh
```

## Add virsh server by webvirtcloud GUI

There are 4 types of connection. The last one only for virsh and webvirtcloud running on same server.

1. TCP

    Add user
```
$ sudo saslpasswd2 -a libvirt ken
Password: xxxxxx
Again (for verification): xxxxxx
```

    List users
```
$ sudo saslpasswd2 -f /etc/libvirt/passwd.db
```

    Remove user
```
$ sudo saslpasswd2 -a libvirt -d ken
```

    Verify the connection
```
$ virsh -c qemu+tcp://IP_address/system nodeinfo
```

    [More......](https://github.com/retspen/webvirtmgr/wiki/Setup-TCP-authorization)

2. SSH

    You need put your private key into .ssh folder of user www-data of webvirtclud server. Then put public key to authorized_keys file in .ssh of user who can run virsh command.

    I have put a private key file and a public key file in allinon image just for testing. You should replace them with yours.

    Print public key use:
```
$ docker exec -it webvirtcloud cat /var/www/.ssh/webvirtcloud_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7zEEPi7AeG4Luk1nP7faf8KzWmyyMXQmNf7WMZOwJP08Zp9p6QJ727w6OFgTtMbL3miljXjjV7U9TC8mQBIJ9cRZFwFZZfsifFROSYE+OUjsw6IuzUaq3krPOqM71/iKm3jHIqd9JAu5M0MnwTGjd9aVs3aXPJ68PuVmaEXgsBql+4cSu0890GBY9BoOxE6i1Pdjxw6T6ZsxRnyAzx2Q9bBCXtVngjgQhS77vNhFENKlnqL170O17lAW+xHzr+ONULtFVqOveaqdVcZNGlb6KbN3otsUq00dE6ow2jZM9q4OhA7FSzoiQRVgPlr4JNj+soG3AR9fGHh7TwrkEdRad webvirtcloud
```

    or using `docker cp`
```
$ docker cp /var/www/.ssh/id_rsa.pub ./webvirtcloud_rsa.pub
```

    Add content of public key file into ~/.ssh/authorized_keys.

    [More......](https://github.com/retspen/webvirtmgr/wiki/Setup-SSH-Authorization)

3. TLS
(TBD)

4. Unix Socket

    You need one more option to run container to enable using Unix Socket.

    - For allinone：
```
$ docker run -d --name webvirtcloud -p 80:80 -p 6080:6080 \
> -v /var/run/libvirt/libvirt-sock:/var/run/libvirt/libvirt-sock \
> kenlee/webvirtcloud-docker:allinone
```

    - For standalone:
```
$ docker run -d --name wvc -p 6080:6080 --link postgres:db \
> -v /var/run/libvirt/libvirt-sock:/var/run/libvirt/libvirt-sock \
> kenlee/webvirtcloud-docker:latest
```

    If you would like use `docker-compose`, you need update your `docker-compose.yml` file.

    [More......](https://github.com/retspen/webvirtmgr/wiki/Setup-Local-connection)

--------
Still have questions, check [wiki](https://github.com/retspen/webvirtmgr/wiki)
