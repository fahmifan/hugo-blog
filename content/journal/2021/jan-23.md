---
title: "January 23"
date: 2022-01-23T19:28:06+07:00
draft: false
---

# TIL
- [PGTune - calculate configuration for PostgreSQL based on the maximum performance for a given hardware configuration](https://pgtune.leopard.in.ua/?utm_source=pocket_mylist)
  - We input our server spec and then it will tell what the configuration we can use as starter
- [Jitsu : Open Source Data Integration Platform](https://jitsu.com/?ref=producthunt)
  - It was a realtime data pipeline tools that has scripting capability
  - It has a feature to track events that is emitted from an app
  - It support JS to do data transformation
  - built in Go
- [What is dbt? | dbt Docs](https://docs.getdbt.com/docs/introduction)
  - DBT is a tool that can transform data from an SQL source
  - DBT has a Jinja template compiler, so we can add some Jinja logic into our SQL query. Example taken from the blog
    - Ref: https://blog.getdbt.com/what-exactly-is-dbt/
    ```jinja
    select * from {{ref('really_big_table')}}

    {% if incremental and target.schema == 'prod' %}         

        where timestamp >= (select max(timestamp) from {{this}})     

    {% else %}         

        where timestamp >= dateadd(day, -3, current_date)     

    {% endif %}
    ```
- [Gerrit Code Review | Gerrit Code Review](https://www.gerritcodereview.com/index.html)
  - This is a code review tool used by Google
  - Quite interesting, have many features
  - One of them are Go: [status:open -is:wip · Gerrit Code Review](https://go-review.googlesource.com/q/status:open+-is:wip)