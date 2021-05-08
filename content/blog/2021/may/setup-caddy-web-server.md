---
title: "Setup Caddy Web Server"
date: 2021-05-08T21:03:22+07:00
draft: false
---

Goal:
- setup caddy web server as user systemd service

Steps:
- create working directory (workid) 
    ```
    mkdir -p ~/admin/caddy
    ```
- download caddy v2 into workdir
- Allow non root to listen on port 80 & 443 
    ```
    sudo setcap cap_net_bind_service=+ep ./caddy
    ```
- create a `Caddyfile` in `~/admin/caddy`. A simple reverse proxy example
    ```Caddyfile
    example.com {
        reverse_proxy localhost:8000
    }
    ```
- add this systemd unit file into `~/.config/systemd/user/caddy.service`
    ```s
    [Unit]
    Description=Caddy Web Server
    After=network.target

    [Service]
    Type=simple
    Restart=on-failure
    RestartSec=10
    ExecStart=/home/deployr/admin/caddy/caddy run
    WorkingDirectory=/home/deployr/admin/caddy
    LimitNOFILE=4096
    PIDFile=/var/run/caddy/caddy.pid

    [Install]
    WantedBy=default.target
    ```
- make sure your user already `enable linger` to start the service as user on boot. Login as `root` then run 
    ```
    loginctl enable-linger deployr
    ```
- reload systemd 
    ```
    systemctl --user daemon-reload
    ```
- enable caddy on boot 
    ```
    systemctl --user enable caddy.service
    ```
- start it 
    ```
    systemctl --user start caddy.service
    ````
- check if it running well 
    ```
    systemctl --user status caddy.service
    ```
- to check the log use `journalctl`
    ```
    journalctl -f --user-unit=caddy
    ```
