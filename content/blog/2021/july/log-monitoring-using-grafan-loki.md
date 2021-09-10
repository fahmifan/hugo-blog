---
title: "Log Monitoring Using Grafan Loki"
date: 2021-07-24T10:30:22+07:00
draft: true
---

In this article, we will cover how to monitor log using Grafana and Loki.

- in the past, when i got an error, i had to SSH to the server and check the log
- but, it's not easy to query the error
- so, i'm looking for a way to monitor the logs
- in my experience you can use ELK stack or Sentry to monitor the log
- but from my case, where i have limited resources, those options are not viable.
- and then i found the Loki projects from Grafana teams.
- it written in Go, so i expect low resource usages
- and it query abiility using LogQL
- i try in local, and these are the tools we need
    - grafana
        - dashboard for loki
    - loki
        - the log processor
    - promtail
        - to collect & forward log from services to Loki