package sync

// Mailbox is a simple pipe of integers but logically has zero buffer size.
type Mailbox struct {
	v     uint
	valid bool
	nrecv int

	lock       Lock
	condRecved Cond
	condFull   Cond
	condEmpty  Cond
}

// Recv receives a value via the mailbox. It blocks until
// a value is delivered by a concurrent Send() call, and
// it returns the exact value that the Send() sends.
func (mb *Mailbox) Recv() uint {
	mb.lock.Lock()
	for !mb.valid {
		mb.condFull.Wait(&mb.lock)
	}

	assert(mb.valid)

	ret := mb.v // copy out
	mb.valid = false
	mb.v = uint(0) // clear the trace

	// Should be exactly one thread
	// waiting for this condition.
	mb.condRecved.Notify(&mb.lock)

	// Next sender, if any.
	mb.condEmpty.Notify(&mb.lock)

	mb.lock.Unlock()

	return ret
}

// Send sends a value via the mailbox. It blocks until
// the value is received by a concurrent Recv() call which
// returns the value it sends.
func (mb *Mailbox) Send(v uint) {
	mb.lock.Lock()

	for mb.valid {
		mb.condEmpty.Wait(&mb.lock)
	}
	assert(!mb.valid)

	mb.v = v
	mb.valid = true
	mb.condFull.Notify(&mb.lock)

	mb.condRecved.Wait(&mb.lock)

	mb.lock.Unlock()
}
