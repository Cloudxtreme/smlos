package sync

func TestQueue() {
	var threads [5]Thread
	for i := 0; i < 5; i++ {
		threads[i].id = i
	}

	var q queue
	assert(q.Empty())

	q.push(&threads[1])
	assert(!q.Empty())
	assert(q.head == q.tail)
	assert(q.head == &threads[1])
	assert(q.head.id == 1)

	q.push(&threads[2])
	assert(!q.Empty())
	assert(q.head == &threads[1])
	assert(q.tail == &threads[2])

	q.push(&threads[3])
	assert(!q.Empty())
	assert(q.head == &threads[1])
	assert(q.tail == &threads[3])

	t := q.pop()
	assert(!q.Empty())
	assert(q.head == &threads[2])
	assert(q.tail == &threads[3])
	assert(t == &threads[1])

	t = q.pop()
	assert(!q.Empty())
	assert(q.head == &threads[3])
	assert(q.tail == &threads[3])
	assert(t == &threads[2])

	t = q.pop()
	assert(q.Empty())
	assert(q.head == nil)
	assert(q.tail == nil)
	assert(t == &threads[3])
}

func testPriorityQueue(off, n int) {
	var threads [16]Thread
	for i := 0; i < n; i++ {
		threads[i].id = i
		threads[i].priority = (n - 1 - i + off) % n
	}

	var q queue
	assert(q.Empty())

	for i := 0; i < n; i++ {
		q.push(&threads[i])
	}

	for i := 0; i < n; i++ {
		t := q.pop()
		assert(t.priority == i)
	}

	for i := 0; i < n; i++ {
		q.push(&threads[i])
	}

	for i := 0; i < n; i++ {
		t := q.pop()
		assert(t.priority == i)
	}
}

func TestPriorityQueue() {
	for i := 0; i < 4; i++ {
		testPriorityQueue(i, 5)
	}
}
