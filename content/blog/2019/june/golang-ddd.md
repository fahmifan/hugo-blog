---
title: "Domain Driven Design (1)"
date: 2019-06-24T08:06:30+07:00
author: "fahmi irfan"
draft: false
tags: [DDD, Konsep]
---

Dalam kehidupan, manusia tidak lepas dari pekerjaan. Pekerjaan yang dilakukan pun terkadang berulang dan memiliki pola tersendiri. Ada kalanya bertemu masalah kecepatan dan kapasitas dalam bekerja. Pekerjaan atau proses yang berulang dapat dilakukan otomasi menggunakan software. Selain itu, software dapat digunakan dalam pemecahan masalah. 

Dalam membuat software, harus mengerti dulu apa yang dibutuhkan oleh suatu bisnis atau pekerjaan. Untuk dapat membuat software yang tepat guna, diperlukan kolaborasi antara engineer dan stake holder. Kunci dari kolaborasi yang apik adalah komunikasi yang dapat saling dipahami. DDD atau _Domain Driven Design_, sebuah prinsip pembuatan software dari tahap desain sampai development yang berkolaborasi dengan _domain expert_ (ahli). Tanpa penguasaan yang mendalam tentang suatu permasalahan, maka sulit untuk mengatakan solusi yang dibuat dapat tepat guna. Di sini lah peran seorang domain expert menjadi penting.

# Prinsip DDD

## Ubiquitous Language
_Ubiquitous Language_, bahasa yang dapat dimengerti oleh semua orang. Memadukan antara bahasa teknis dengan jargon-jargon di dunia bisnis. Dapat dikatakan juga, membuat desain software yang dimengerti oleh domain expert, jika perlu sampai ke level abstraksi kodingnya. 

## Model Driven Design
Dari permasalahan yang sudah dipahami, perlu dibuat permodelan yang dapat diimplementasikan oleh developer. Beberapa pondasi dari pembuatan model ini adalah:

### Layered Architecture
Memisahkan bagian-bagian dalam software sesuai dengan peruntukannya. Jika pernah membuat sebuah aplikasi website dinamis, tak jarang berjumpa dengan konsep MVC atau Model View Controller yang merupakan sebuah arsitektur software. Berbeda dengan MVC, Layered Architecture ini lebih kepada mengisolasi kode logik bisnis yang inti dari dependensi luar. Dependensi ini dapat berupa akses ke database, user interface (API), pustaka pihak ketiga, dsb. Bagian yang diisolasi ini disebut sebagai layer aplikasi.

## Refactoring berkelanjutan
Dalam membuat kodingan, sering kali solusi pertama yang dibuat kurang bagus. Baik dari segi efektif nya atau kejelasan maksud kodingan. Untuk itu, refactoring berkelanjutan menjadi hal yang sering dan perlu dilakukan.

## Bounded Context
Bagian ini belum penulis baca dan pahami dan akan diupdate di kesempatan berikutnya

# Kesimpulan
Dari tulisan pendek ini, semoga dapat memicu sedikit rasa penasaran pembaca tentang membuat Software yang andal melalui DDD ini. Ini merupakan bagian satu, selanjutnya penulis akan coba praktik langsung pada proses pembuatan sebuah aplikasi. 

Thanks for reading