---
title: "What is LRU Cache And How It Works ?"
date: 2021-06-13T10:24:35+07:00
draft: false
tags:
    - lru
    - go
    - cache
    - concurrent
---

# What is LRU cache
A cache is a way to store data that accessed frequently and needs to be fast. We can use cache to store a result from computation or result of SQL query. A cache is usually stored in memory with a key-value style to make sure it fast to store item and access.

One of the cache algorithms is LRU or *Least Recently Used*. LRU will limit the memory usage by gives maximum items that can be stored. When there is a new item to be store and it already reached the limit, it discards the least used item.

# How to make LRU Cache in GO

> TLDR
>
> Check the full code in this repo 
> - [lrucache (non concurrent)](https://github.com/fahmifan/lrucache/tree/lru-no-concurrency)
> - [lrucache (concurrent)](https://github.com/fahmifan/lrucache)

There are two main components in LRU cache, those are `Queue` and `Hash Map`. The `Queue` is used to store the items that implemented in a linked list, while the `Hash Map` is used to make the complexity `O(1)` when accessed.

![Queue & Hash Map](/photos/lru-cache/queue-and-hash.png)

## Creating Queue
> Disclaimer
>
> The queue I implemented is based on my opinion, it may not be the "right" one :)

We need to create a struct for the cache item, a linked list node, and the queue.

```go
type Queue struct {
	head *Node
	tail *Node
}

type Node struct {
	item Item
	next *Node
	prev *Node
}

type Item struct {
	Key   string
    // Value is used to store an item
	Value interface{}
}
```

We will create three methods for the queue `InsertFirst`, `RemoveLast`, and `RemoveNode`. 

The structure of the Node. It has three parts, `prev`, `value`, and `next`. The `prev` and `next` are pointers to an adjacent node. The `value` is an `interface{}` that can hold any data type.
![a node](/photos/lru-cache/node.png)

These are algorithm and code for `InsertFirst`
![insert first algorithm](/photos/lru-cache/insert-first-algo.png)

```go
// insert a node into the first of the queue
func (q *Queue) InsertFirst(newHead *Node) {
	if q.isEmpty() {
		q.head = newHead
		q.tail = newHead
		return
	}

	oldHead := q.head
	newHead.next = oldHead
	oldHead.prev = newHead
	q.head = newHead
}
```

These are algorithm and code for `RemoveLast`
![remove last](/photos/lru-cache/remove-last-algo.png)

```go
// remove a node from the last queue
func (q *Queue) RemoveLast() *Node {
	if q.isEmpty() {
		return nil
	}

	if q.isOne() {
		last := q.tail
		q.tail = nil
		q.head = nil
		last.breakLinks()
		return last
	}

	oldLast := q.tail
	newLast := q.tail.prev
	q.tail = newLast
	oldLast.breakLinks()
	return oldLast
}
```

These are algorithm and code for `RemoveNode`
![remove node 0](/photos/lru-cache/remove-node-0.png)
![remove node 2](/photos/lru-cache/remove-node-1.png)

```go
// remove a node from any position in the queue
func (q *Queue) RemoveNode(node *Node) {
	if q.isEmpty() {
		return
	}

	if q.isOne() {
		q.head.breakLinks()
		q.tail.breakLinks()
		node.breakLinks()
		return
	}

	// node is first in the queue with following N-nodes
	if node == q.head {
		// new head is the next in the queue
		q.head = node.next
		node.breakLinks()
		return
	}

	// node is the last in the queue with previos N-nodes
	if node == q.tail {
		// new tail is the one before the node
		q.tail = node.prev
		node.breakLinks()
		return
	}

	// node is in the middle of the queue
	after := node.next
	before := node.prev
	// link the before & after
	before.next = after
	after.prev = before
	node.breakLinks()
}
```

Helper methods for the `Queue`
```go
func (q *Queue) isEmpty() bool {
	return q.head == nil && q.tail == nil
}

func (q *Queue) isOne() bool {
	return q.head != nil && q.head.next == nil
}
```

The `breakLinks` method is implemented as follows
```go
// set next & prev to nil
func (n *Node) breakLinks() {
	if n == nil {
		return
	}

	n.next = nil
	n.prev = nil
}
```

## Creating LRUCacher

```go
// LRUCacher not concurrent safe
type LRUCacher struct {
	queue       *Queue
	hash        map[string]*Node
	MaxSize     int
	count int
}
```

Codes for Put
```go
// Put set new or replace existing item
func (l *LRUCacher) Put(key string, value interface{}) {
	if l.MaxSize < 1 {
		l.MaxSize = DefaultMaxSize
	}

	if l.queue == nil {
		l.queue = NewQueue()
	}

	if l.hash == nil {
		l.hash = make(map[string]*Node)
	}

	item := Item{
		Key:   key,
		Value: value,
	}

	// if key already exist just replace the cache item
	oldNode, ok := l.hash[key]
	if ok {
		oldNode.item = item
		return
	}

	node := &Node{item: item}
	if l.queueIsFull() {
		last := l.queue.RemoveLast()
		l.removeItem(last.item)

		l.hash[key] = node
		l.queue.InsertFirst(node)
		return
	}

	l.hash[key] = node
	l.queue.InsertFirst(node)
	l.count++
}
```

Codes for Get
```go
func (l *LRUCacher) Get(key string) interface{} {
	if l.hash == nil {
		return nil
	}

	val, ok := l.hash[key]
	if !ok {
		return nil
	}

	return val.item.Value
}
```

Codes for Del
```go
func (l *LRUCacher) Del(key string) interface{} {
	node, ok := l.hash[key]
	if !ok {
		return nil
	}

	l.queue.RemoveNode(node)
	l.removeItem(node.item)
    l.count--
	return node.item.Value
}
```

# Notes on Implement Synchronization for Concurrency
The previous codes work for non-concurrent usage because when accessing & writing to the hash map or queue, there are needs for lock and synchronization. Also keep in mind, that adding synchronization will impact the performance.

We can use a `mutex` for synchronization. In Go, there are two types of mutex, a `Mutex` and  a `RWMutex`. The `Mutex` is general purpose for locking only one goroutine that has access to a resource. The `RWMutex` has two locking mechanisms. The first is a `RLock` that can behold by multiple gorutines and is used for reading. The Second is a `Lock` that can only behold by one goroutine and is used for writing.

I use two mutexes for `LRUCacher`, `hashMutex` for access & mutating `hash`, and `countMutex` when mutating the `count`. Also, to help to detects race condition, I use `-race` flag when running the go test
```
go test -race ./...
```

The rest of the code can be checked in this repo [lrucache](https://github.com/fahmifan/lrucache)
```go
type LRUCacher struct {
	maxSize int64

	queue      *Queue
	count      int64
	countMutex sync.RWMutex

	hash      map[string]*Node
	hashMutex sync.RWMutex
}
```

The benchmark
```
go test -benchmem -run=^$ -bench ^(BenchmarkLRUCacher)$ github.com/fahmifan/lrucache

goos: linux
goarch: amd64
pkg: github.com/fahmifan/lrucache
cpu: Intel(R) Core(TM) i5-7400 CPU @ 3.00GHz
BenchmarkLRUCacher/Put-4         	 2777412	       415.7 ns/op	      89 B/op	       4 allocs/op
BenchmarkLRUCacher/Get-4         	 9061254	       130.3 ns/op	      16 B/op	       1 allocs/op
BenchmarkLRUCacher/Del-4         	11411762	       105.7 ns/op	      12 B/op	       1 allocs/op
PASS
ok  	github.com/fahmifan/lrucache	4.228s
```

That's the LRU Cache on how you can implement it in Go :)