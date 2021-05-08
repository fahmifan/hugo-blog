---
title: "Initial Ubuntu Vps Setup"
date: 2021-05-08T06:52:16+07:00
draft: true
---

Goal:
- setup user untuk `deployr`
- referensi: [Initial Server Setup with Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-20-04)

## Setup User
Steps:
- buat instance di vps provider
    - kalau pakai linode tambahkan ssh laptop biar ga perlu input password pas ssh as `root`
- ssh as root `ssh root@IP`
- create new `deployr` with sudo access
    - `adduser deployr` 
    - input password
    - untuk user info, bisa pakai default, tekan enter aja
- grant admin privileges
    - `usermod -aG admin deployr`
- setup basic firewall
    - `ufw app list`, harusnya cuma ada OpenSSH
    - `ufw enable`, aktifkan ufw
    - cek status sudah nyala atau belum `ufw status`
- tambah ssh untuk user `deployr`
    - kalau laptop nya sama saat buat instance, bisa pakai ssh user `root`, tinggal pakai rsync
    - masih login sebagi `root` di vps
    - `rsync --archive --chown=deployr:deployr ~/.ssh /home/deployr`
