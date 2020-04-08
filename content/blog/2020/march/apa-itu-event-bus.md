---
title: "Apa Itu Event Bus ?"
date: 2020-04-05T15:43:31+07:00
draft: true
---

Event bus adalah sebuah mekanisme yg bisa dipakai untuk berkomunikasi antar komponen tanpa saling tahu satu sama lain. Kalau bisa saya bilang ini juga bagian *pub-sub* pattern. Lalu, apa kegunaan dari event bus ini? 
Kegunaanya adalah untuk *decoupled* antar komponen sehingga tidak saling bergantung secara langsung.
Keuntungan lainnya adalah, kita bisa membuat *monolith* rasa *microservice*.
Dalam arsitektur *microservice*, salah satu pattern yg sering dipakai adalah *pubsub*, dan kita bisa menerapkan pubsub ini dalam arsitektur *monolith* melalui *event bus*. 

Jika digambarkan event bus itu berbentuk seperti gambar berikut
![event bus](/photos/1586077919152-event-bus.png)
Dimana ada *publisher* yang dapat mengirim sebuah pesan ke *Event Bus* dan pesan ini dapat didapatkan oleh banyak *subscriber*. 

## Menggunakan event bus
Kita akan coba menggunakan event bus dalam program yang akan kita buat. Dan kita akan membuatnya menggunakan bahasa Go atau Golang.

> Jika kalian belum tahu tentang bahasa Golang, bisa cek [Dasar Pemrograman Golang](https://dasarpemrogramangolang.novalagung.com/). 

Yang akan kita jadikan kasus adalah order barang dan payment pada sebuah **Online shop**. Ketika user membuat sebuah order maka akan dibuat sebuah payment.
```

+-------------+
|create order +----------+
+-------------+          |
                    +----v----+
                    |         |
                    |   BUS   |
                    |         |
                    +----^----+
                         |
                         |
+--------------+         |
|create payment+---------+
+--------------+

```

## Init project
Oke, pertama kita perlu melakukan ini project. Buat folder project kalian, lalu init module dengan mengetikkan command `go mod init shop` di folder project. Untuk mempersingkat, saya akan namai module ini sebagai `shop`.

> Versi Go yang digunakan pada saat pembuatan artikel ini adalah `go1.12.17`. 

Selanjutnya kita akan buat model nya terlebih dahulu. Buat package `model`, lalu buat file `model.go`.
```
├── model
│   └── model.go
```

Di package model ini, kita membuat tiga buah `struct` yaitu `Product`, `Order`, dan `Payment`. 
Sebuah Order dapat memiliki banyak product di dalam nya. 
```go
package model

import "fmt"

type Product struct {
	ID    int64
	Price float64
}

type Order struct {
	ID         int64
	ProductIDs []int64
}
```
Lalu sebuah Payment akan memiliki OrderID berikut `PaymentStatus` nya.
`PaymentStatus` ini bisa dibilang adalah sebuah "enum", yang memiliki tiga tipe yaitu `pending`, `paid` dan `canceled`.
```go
type Payment struct {
	ID      int64
	OrderID int64
	Status  PaymentStatus
}

type PaymentStatus int

// PaymentStatus enum
const (
	PaymentStatusPending  = PaymentStatus(1)
	PaymentStatusPaid     = PaymentStatus(2)
	PaymentStatusCanceled = PaymentStatus(3)
)
```

Selanjutnya, kita akan membuat package `service`. Ada tiga buah service yang dibuat yaitu `ProductService`, `OrderService` dan `PaymentService` yang semuanya merupakan `interface`.
```
└── service
    └── service.go
```

`ProductService` akan memiliki method yaitu `List`. Lalu, `OrderService` memiliki method `CreateOrder`. Terkahir, `PaymentService` akan memiliki method `CreatePayment`.

```go
package service

import "shop/model"

type (
	ProductService interface {
		List() []model.Product
	}

	OrderService interface {
		CreateOrder(productIDs []int64) *model.Order
	}

	PaymentService interface {
		CreatePayment(orderID int64) *model.Payment
	}
)
```

Selanjutnya kita perlu melakukan implementasi dari `interface` tersebut dengan `struct`.
Pada package `service` buat file `product_service`. 
```
└── service
    ├── product_service.go
```

Untuk mempersingkat, data product akan kita simpan di dalam field `products`. Lalu, dengan fungsi `NewProductService` kita melakukan instansiasi `productService` sekaligus mengisi field `products` dengan data dummy.

```go
package service

import (
	"shop/model"
	"time"
)

type productService struct {
    products []model.Product
)

func NewProductService() ProductService {
	return &productService{
		products: []model.Product{
			model.Product{ID: 111, Price: 100.0},
			model.Product{ID: 112, Price: 200.0},
			model.Product{ID: 113, Price: 300.0},
		},
	}
}

func (ps *productService) List() []model.Product {
	return ps.products
}
```

Lalu, buat file `order_service` pada package `service`. 
```
└── service
    ├── order_service.go
```

Pada kode ini, terdapat field `bus` dengan tipe `*bus.Bus` yang digunakan untuk mempublish event/topic. pacakge yang digunakan adalah `github.com/mustafaturan/bus`. Argumen ke dua pada fungsi `Emit` adalah nama topic yg dipublish, di sini kita gunakan nama `order.created`.

```go
package service

import (
	"context"
	"time"

	"shop/eventbus"
	"shop/model"

	"github.com/mustafaturan/bus"
	log "github.com/sirupsen/logrus"
)

type orderService struct {
    bus            *bus.Bus
    productService ProductService
}

func NewOrderService(ps ProductService, bus *bus.Bus) OrderService {
	return &orderService{
		productService: ps,
		bus:            bus,
	}
}

func (o *orderService) CreateOrder(productIDs []int64) *model.Order {
	order := &model.Order{
		ID:         time.Now().UnixNano(),
		ProductIDs: productIDs,
	}

	log.Info("create order, productIDs: ", productIDs)

	// kita publish atau emit "order.created"
	event, err := o.bus.Emit(context.Background(), "order.created", *order)
	if err != nil {
		log.Error(err)
		return
	}

	return order
}

```

Service yang dibuat selanjutnya adalah `payment_service`. Pada service ini, terdapat satu method `CreatePayment`.
```go
package service

import (
	"shop/model"
	"time"
)

type (
	paymentService struct {
		orderService OrderService
	}
)

func NewPaymentService(os OrderService) PaymentService {
	return &paymentService{
		orderService: os,
	}
}

func (ps *paymentService) CreatePayment(orderID int64) *model.Payment {
	return &model.Payment{
		ID:      time.Now().UnixNano(),
		OrderID: orderID,
		Status:  model.PaymentStatusPending,
	}
}
```

Kemudian, kita akan membuat instansiasi pacakge `bus`. Fungsi constructor ini saya ambil dari contoh yang diberikan di repo `github.com/mustafaturan/bus`.
```go
package eventbus

import (
	"github.com/mustafaturan/bus"
	"github.com/mustafaturan/monoton"
	"github.com/mustafaturan/monoton/sequencer"
)

func NewBus() *bus.Bus {
	// configure id generator (it doesn't have to be monoton)
	node := uint64(1)
	initialTime := uint64(1577865600000) // set 2020-01-01 PST as initial time
	m, err := monoton.New(sequencer.NewMillisecond(), node, initialTime)
	if err != nil {
		log.Fatal(err)
	}

	// init an id generator
	var idGenerator bus.Next = (*m).Next

	// create a new bus instance
	b, err := bus.NewBus(idGenerator)
	if err != nil {
		log.Fatal(err)
	}

	return b
}
```

Oke, selanjutnya kita akan membuat package `eventhandler`. 
```
├── eventhandler
│   └── handler.go
```

Event bus ini memiliki sebuah handler yg berupa fungsi. Handler ini gunanya untuk menerima event-event yang diemit ke dalam event bus. Dari event yang diterima kita dapat mengecek jenis topic-nya.
```go
package eventhandler

import (
	"shop/eventbus"
	"shop/model"
	"shop/service"

	"github.com/mustafaturan/bus"
	log "github.com/sirupsen/logrus"
)

type EventHandler struct {
	PaymentService service.PaymentService
}

func (e *EventHandler) HandleOrder(event *bus.Event) {
	switch event.Topic {
	case "order.created":
		log.Infof("recieved event %v", event.ID)
		order, ok := event.Data.(model.Order)
		if !ok {
			return
		}

		payment := e.PaymentService.CreatePayment(order.ID)
		log.Info("create payment", payment)
	}
}
```

Sekarang kita akan buat fungsi main, di sini kita akan melakukan wiring service-service yang sudah dibuat.
```go
package main

import (
	"os"
	"os/signal"
	"syscall"

	"shop/eventbus"
	"shop/eventhandler"
	"shop/service"

	"github.com/mustafaturan/bus"
	log "github.com/sirupsen/logrus"
)

func main() {
	handler := &eventhandler.EventHandler{}

	bbus := eventbus.NewBus()
	bbus.RegisterTopics([]string{"order.created"})
	bbus.RegisterHandler("order-channel", &bus.Handler{
		Matcher: "order.*", // match untuk semua order
		Handle:  handler.HandleOrder,
	})

	productService := service.NewProductService()
	orderService := service.NewOrderService(productService, bbus)
	paymentSerivce := service.NewPaymentService(orderService)

	handler.PaymentService = paymentSerivce

	products := productService.List()
	orderService.CreateOrder([]int64{products[0].ID})

	// kode berikut untuk memblok goroutine utama
	sigCh := make(chan os.Signal)
	done := make(chan bool)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-sigCh
		log.Info("exiting...")
		done <- true
	}()
	<-done
}
```

Ketika dijalankan maka output dari program akan seperti ini
```
INFO[0000] create order, productIDs: [1586206522725414000] 
INFO[0000] recieved event 0096Tf1h00000001              
INFO[0000] create payment{id: 1586206522725562000, order_id: 1586206522725417000, status: pending} 
^CINFO[0001] exiting...                                   
```

`0096Tf1h00000001` merupakan id dari event yang diemit, dari urutan log yg muncul.

Jadi, begitulah cara kerja dan penggunaan event bus. Mungkin, di artikel selanjutnya akan dibahas implementasi event bus pada sebuah web service.