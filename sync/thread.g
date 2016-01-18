package sync

// Thread is a kernel thread.
type Thread struct {
	id       int
	alive    bool
	sleeping bool
	q        *queue

	priority int

	// number of locks acquired by this thread
	nlock int

	ptable     *vm.Root
	context    intr.Frame
	stack      *vm.Page
	last, next *Thread // to form a linked list.
}

func (t *Thread) isOrphan() bool { return t.last == nil && t.next == nil }

// ID returns the thread id.
func (t *Thread) ID() int { return t.id }

func (t *Thread) StackPageID() uint {
	if t.id == 0 {
		return vm.Stack0
	}
	return uint(t.id)*2 + vm.StacksBase
}

func (t *Thread) StackBase() uint {
	return vm.StackBase(t.StackPageID())
}

// SetPriority adjusts the priority of the thread.
func (t *Thread) SetPriority(p int) {
	t.priority = p
	if t.q == nil {
		return
	}

	t.q.adjust(t)
}

// UseRoot0 sets the thread to be a kernel only thread
// that uses the kernel page table.
func (t *Thread) UseRoot0() { t.ptable = nil }

// queue is a thread queue that links threads
// a thread can only be queued in one queue.
type queue struct {
	head, tail *Thread
	n          int
}

func (q *queue) Empty() bool { return q.n == 0 }
func (q *queue) Size() int   { return q.n }

// Push appends a thread to the tail of the queue.
// It panics if the threads is already in a queue.
func (q *queue) push(t *Thread) {
	assert(t.isOrphan())
	assert(t.q == nil)

	q.n++
	t.q = q

	if q.head == nil {
		q.head = t
		q.tail = t
		return
	}

	assert(q.tail.next == nil)

	q.tail.next = t
	t.last = q.tail
	q.tail = t

	q.adjust(t)
}

// adjust compares the given thread t with its surrounding threads
// and swaps the thread t to its position so that the queue is in
// ascendent order, where smaller priority threads are queued at
// the front of the queue.
func (q *queue) adjust(t *Thread) {
	assert(t.q == q)
	p := t.priority
	for t.last != nil && t.last.priority > p {
		q.popUp(t)
	}
	for t.next != nil && t.next.priority < p {
		q.dropDown(t)
	}
}

// popUp swaps t with t.last in the queue.
func (q *queue) popUp(t *Thread) {
	last := t.last
	assert(last != nil)
	lastLast := last.last
	if lastLast != nil {
		lastLast.next = t
	} else {
		assert(q.head == last)
		q.head = t
	}

	next := t.next
	if next != nil {
		next.last = last
	} else {
		assert(q.tail == t)
		q.tail = last
	}

	t.last = lastLast
	t.next = last
	last.last = t
	last.next = next
}

// dropDown swaps t with t.next in the queue.
func (q *queue) dropDown(t *Thread) {
	next := t.next
	assert(next != nil)
	nextNext := next.next
	if nextNext != nil {
		nextNext.last = t
	} else {
		assert(q.tail == next)
		q.tail = t
	}

	last := t.last
	if last != nil {
		last.next = next
	} else {
		assert(q.head == t)
		q.head = next
	}

	t.next = nextNext
	t.last = next
	next.next = t
	next.last = last
}

// pop fetches out the head of the thread queue.
// It returns nil if the queue is empty.
func (q *queue) pop() *Thread {
	if q.Empty() {
		return nil
	}

	q.n--

	var ret *Thread
	if q.head == q.tail {
		assert(q.head.isOrphan())

		ret = q.head
		q.head = nil
		q.tail = nil
	} else {
		ret = q.head
		q.head = q.head.next
		q.head.last = nil
		ret.next = nil
	}

	assert(ret.q == q)
	ret.q = nil
	return ret
}
