---
title: Make resume from html-css-js.md
date: 2018-07-11T20:29:18.000Z
author: fahmi irfan
draft: false
tags:
    - Tool
    - Tips
    - Resume
    - HTML
    - CSS
    - JS
    - Wkhtmltopdf
slug: resume-html-css-js-md
---

this is the command that does the job. Well for now it only ouput properly in image format. I am still looking for solution to output in pdf format. This is using [Wkhtmltopdf](https://wkhtmltopdf.org/) : 

    wkhtmltoimage --images --javascript-delay 5000 http://localhost:5500/ testcv2.png

I'm using local server for this and code in vscode :D
