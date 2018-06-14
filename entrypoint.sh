#!/bin/sh
/usr/sbin/sshd -D -f /home/ubuntu/sshd/ssh_config &
apache2ctl start
