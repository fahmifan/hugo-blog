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

Yang akan kita jadikan kasus adalah order barang dan pyament pada sebuah **Online shop**. Ketika user membuat sebuah order maka akan dibuat sebuah payment.
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

Di package model ini, kita membuat tiga buah `struct`, yaitu `Product`, `Order`, dan `Payment`. 
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

Selanjutnya, kita akan buat membuat package `service`. Ada tiga buat service yang dibuat yaitu `ProductService`, `OrderService` dan `PaymentService` yang semuanya merupakan `interface`.

`ProductService` akan memiliki dua method yaitu `List` dan `FindProductByID`. Lalu, `OrderService` memiliki dua method yaitu `CreateOrder` dan `FindOrderByID`. Dan terkahir, `PaymentService` akan memiliki dua method juga yaitu `CreatePayment` dan `PayBills`.
Ketikkan kode berikut pada `service/service.go`
```
└── service
    └── service.go
```

```go
package service

import "shop/model"

type (
	ProductService interface {
		List() []model.Product
		FindProductByID(id int64) *model.Product
	}

	OrderService interface {
		CreateOrder(productIDs []int64) *model.Order
		FindOrderByID(id int64) *model.Order
	}

	PaymentService interface {
		CreatePayment(orderID int64) *model.Payment
		PayBills(payment *model.Payment) bool
	}
)
```

Selanjutnya kita perlu melakukan implementasi dari `interface` tersebut dengan `struct`.
Pada package `service` buat file `product_service` dengan isi sebagai berikuta
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
			model.Product{ID: time.Now().UnixNano(), Price: 100.0},
			model.Product{ID: time.Now().UnixNano(), Price: 200.0},
			model.Product{ID: time.Now().UnixNano(), Price: 300.0},
		},
	}
}

func (ps *productService) List() []model.Product {
	return ps.products
}

func (ps *productService) FindProductByID(id int64) *model.Product {
	for _, product := range ps.products {
		if product.ID == id {
			return &product
		}
	}

	return nil
}
```

Lalu, buat file `order_service` pada package service dengan isi seperti di bawah ini. Pada kodingan terdapat field `bus` dengan tipe `*bus.Bus` yang digunakan sebagai event bus untuk publish event. pacakge yang diguanakn adalah `github.com/mustafaturan/bus`. 
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

    orders []model.Order
}

func NewOrderService(ps ProductService, bus *bus.Bus) OrderService {
	return &orderService{
		productService: ps,
		bus:            bus,
	}
}

func (o *orderService) CreateOrder(productIDs []int64) *model.Order {
	for _, id := range productIDs {
		if product := o.productService.FindProductByID(id); product == nil {
			return nil
		}
	}

	order := &model.Order{
		ID:         time.Now().UnixNano(),
		ProductIDs: productIDs,
	}

	go func() {
		ev, err := o.bus.Emit(context.Background(), eventbus.OrderCreated, *order)
		if err != nil {
			log.Error(err)
			return
		}

		log.Info(ev.Topic, " ", ev.TxID)
	}()

	return order
}

func (o *orderService) FindOrderByID(id int64) *model.Order {
	for _, order := range o.orders {
		if order.ID == id {
			return &order
		}
	}

	return nil
}
```
