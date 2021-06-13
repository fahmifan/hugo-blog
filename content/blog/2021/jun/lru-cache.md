---
title: "What is LRU Cache And How It Works ?"
date: 2021-06-13T10:24:35+07:00
draft: true
tags:
    - lru
    - go
    - cache
    - concurrent
---

# What is LRU cache
A cache is a way to store a data that accessed frequetnly and need to be fast. 
We can use cache to store a result from a computation or result of SQL query. Cache usually stored in memory with key-value style to make sure it fast to store item and accessed. 

One of the cache algorithm is LRU or *Least Recently Used*. 
LRU will limit the memory usage by gives maximum items that can be stored. When there is new item to be store and it already reachs the limit, it discards the least used item.

# How to make LRU Cache in GO

There is two main component in LRU cache, those are `Queue` and `Hash Map`. The `Queue` is used to store the items that implemented in linked list, while the `Hash Map` is used to make the complexity `O(1)` when accessed.

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

We will create three methods for the queue `InsertFirst`, `RemoveLast` and `RemoveNode`. 

The structure of the Node. It has three parts, `prev`, `value`, and `next`. The `prev` and `next` are pointers to an adjecent node. The `value` is an `interface{}` that can hold any data types.
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

The `breakLinks` method are implemented as follows
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

# Implement Synchronization for Concurrency