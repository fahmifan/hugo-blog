---
title: "Background Job Worker"
date: 2019-07-09T08:06:42+07:00
author: "miun173"
draft: false
tags: [Worker, App, Programming]
---

Dalam pengembangan web, request yang memerlukan process yang lama (long running) dapat memblokir request lain. Kalo seperti ini, maka web kita tidak responsive dan cepat. Process lama ini dapat kita alihkan ke process lain yang berjalan di samping process utama yang disebut worker.

Salah satu pattern umum untuk menggunakan worker adalah ketika ada request ke web servis, maka akan di-reply langsung, lalu akan dijadawlkan task dari request tersebut ke worker. Misalkan kita mendapat requirement sbb: 

> Ketika user mengupload gambar, resize terlebih dahulu baru simpan ke storage

Dari requirement tersebut dapat dibagi menjadi:

- jalankan worker yang menunggu "tugas" masuk
- tunggu user selesai upload
- balas dengan status "sedang diproses" ke user dan kode http status 2xx
- jadwalkan "tugas" meresize gambar yang diupload ke worker. Bisa dengan memasukkan "tugas" ke dalam process antrian (queue)
- worker mengambil tugas dari antrian
- worker meresize gambar, lalu simpan ke dalam storage

Dengan menggunakan worker aplikasi menjadi lebih cepat dalam memberikan balikan ke user & mengurangi long running request yg menyebabkan bloking.