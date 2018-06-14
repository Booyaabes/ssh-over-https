# ssh-over-https

## Warning

First of all: __DO NOT USE THIS IN PRODUCTION__: It creates a backdoor in your environment. Use it only if you know what you're doing.

Second point: __Work in progress__

## Purpose

This Docker image was made to test a Kubernetes infrastructure.
You can connect in ssh over https through port 8443 (by default).
The http server and the ssh server run as non-root user.

This image contains lots of tools useful for auditing purposes and to test capabilities allowed to the container by the Kubernetes/Docker engine...

## How to build

```sh
docker build --tag ssh-over-https:1.0 .
```

## Usage

### Direct ssh connection

You can build your own Docker image with authorized keys embedded or you can mount an authorized_keys file when lauching the container.

```sh
docker run -p 8080:8080 -v /home/remote_user/authorized_keys:/home/ubuntu/.ssh/authorized_keys booyaabes/ssh-over-https:1.0
```

Mounting your pub certificate will allow you to logged in as user _imnoroot_ to this container:

```sh
ssh -p 8080 -i /home/local_user/.ssh/id_rsa imnoroot@container_ip
```

### Ssh over http connection

First of all, you need _socat_ to connect to ssh server through http.

```sh
sudo apt install socat
```

Then, you need to tell ssh client to use _socat_ as ProxyCommand. You have to add something similar to this to your ~/.ssh/config file:

```yaml
Host container_url
    ProxyCommand socat TCP-LISTEN:1080 OPENSSL:container_url:8443,verify=0 & sleep 1 && socat - PROXY:127.0.0.1:127.0.0.1:2222,proxyport=1080
    DynamicForward 1080
    ServerAliveInterval 60
    ControlMaster auto
    ControlPath ~/.ssh/tmp/%h_%p_%r
```

In this case, you will only be able to login with a password. Change the password in the Dockerfile et rebuild the image.

## Capabilities

This image contains _/sbin/setcap_ executable with _cap_setpcap,cap_setfcap+ep_ meaning that the regular user can modify capabilities if the right of modifying capabilities has not been drop by the Docker engine.

## TODO List

- An automated build is available on Docker Hub,
- Switch to HAProxy instead of Apache HTTPD,
- Make http server run as non root.

## Credits

Thanks to Ch-M.D. for

- [ssh over http tutorial part1](https://blog.chmd.fr/ssh-over-ssl-a-quick-and-minimal-config.html),
- [ssh over http tutorial part2](https://blog.chmd.fr/ssh-over-ssl-episode-2-replacing-proxytunnel-with-socat.html),
- [ssh over http tutorial part3](https://blog.chmd.fr/ssh-over-ssl-episode-3-avoiding-using-a-patched-apache.html),
- [ssh over http tutorial part4](https://blog.chmd.fr/ssh-over-ssl-episode-4-a-haproxy-based-configuration.html),

Thanks to [Rastasheep](https://github.com/rastasheep/ubuntu-sshd) for the inspiration.