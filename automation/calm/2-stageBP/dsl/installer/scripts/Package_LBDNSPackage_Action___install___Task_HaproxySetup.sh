#!/bin/bash -xe

echo """#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global

    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # utilize system-wide crypto-policies
    ssl-default-bind-ciphers PROFILE=SYSTEM
    ssl-default-server-ciphers PROFILE=SYSTEM


    stats socket ipv4@0.0.0.0:9999 level admin
    stats socket /var/run/haproxy.sock mode 666 level admin
    stats timeout 2m
    server-state-file /etc/haproxy/server_state

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------

defaults
    load-server-state-from-file global
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000


#---------------------------------------------------------------------
# Openshift config
#---------------------------------------------------------------------

listen stats
    bind :9000
    mode http
    stats enable
    stats uri /
    monitor-uri /healthz


frontend openshift-api-server
    bind *:6443
    default_backend openshift-api-server
    mode tcp
    option tcplog

backend openshift-api-server
    mode tcp
    server-template controlplane 0-2 localhost:6443 check disabled
    server bootstrap localhost:6443 check

frontend machine-config-server
    bind *:22623
    default_backend machine-config-server
    mode tcp
    option tcplog

backend machine-config-server
    balance source
    mode tcp
    server-template controlplane 0-2 localhost:22623 check disabled
    server bootstrap localhost:22623 check

frontend ingress-http
    bind *:80
    default_backend ingress-http
    mode tcp
    option tcplog

backend ingress-http
    balance source
    mode tcp
    server-template compute 0-99 localhost:80 check disabled
    server-template controlplane 0-2 localhost:443 check disabled
    
frontend ingress-https
    bind *:443
    default_backend ingress-https
    mode tcp
    option tcplog

backend ingress-https
    balance source
    mode tcp
    server-template compute 0-99 localhost:443 check disabled
    server-template controlplane 0-2 localhost:443 check disabled
    """ | sudo tee /etc/haproxy/haproxy.cfg

sudo systemctl enable haproxy
sudo systemctl start haproxy