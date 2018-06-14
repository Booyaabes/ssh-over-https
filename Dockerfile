FROM ubuntu:18.04

LABEL maintainer="Booyaabes"

RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    inetutils-traceroute \
    ssh \
    netcat \
    socat \
    nmap \
    apache2 \
    iproute2 \
    curl \
    bash-completion \
    proxytunnel \
    git \
    python \
    python-pip \
    python-dev \
    nano \
    build-essential \
    libcap2-bin

RUN useradd --shell /bin/bash -u 1000 --create-home imnoroot && \
    usermod -aG sudo imnoroot && \
    echo "imnoroot ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo 'imnoroot:Rafob-tywyWuc6'|chpasswd

RUN mkdir /var/run/sshd && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN mkdir /home/imnoroot/sshd && mkdir -p /home/imnoroot/var/run/ && \
    cp /etc/ssh/ssh_config /home/imnoroot/sshd/. && \
    sed -i 's/#   Port 22/Port 2222/' /home/imnoroot/sshd/ssh_config && \
    sed -i 's/Host \*//' /home/imnoroot/sshd/ssh_config && \
    sed -i 's/SendEnv LANG LC_\*//' /home/imnoroot/sshd/ssh_config && \
    sed -i 's/HashKnownHosts yes//' /home/imnoroot/sshd/ssh_config && \
    echo "HostKey /home/imnoroot/sshd/ssh_host_rsa_key" >> /home/imnoroot/sshd/ssh_config && \
    echo "PidFile /home/imnoroot/var/run/sshd.pid" >> /home/imnoroot/sshd/ssh_config && \
    echo "PubkeyAuthentication yes" >> /home/imnoroot/sshd/ssh_config && \
    ssh-keygen -t rsa -f /home/imnoroot/sshd/ssh_host_rsa_key -N '' && \
    setcap cap_setpcap,cap_setfcap+ep /sbin/setcap && \
    chown -R imnoroot:imnoroot /home/imnoroot

COPY default-ssl.conf /etc/apache2/sites-available/.
COPY proxytunnel    /etc/apache2/proxytunnel

COPY entrypoint.sh /entrypoint.sh

RUN a2ensite default-ssl.conf && \
    a2enmod ssl && \
    a2enmod proxy && \
    a2enmod proxy_connect && \
    sudo setcap 'cap_net_bind_service=+ep' /usr/sbin/apache2 && \
    chown -R imnoroot:imnoroot /
    
USER 1000

EXPOSE 8443
CMD ["/entrypoint.sh"]