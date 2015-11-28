package sync

// Cond is a condition variable
type Cond struct {
	q queue
}

func (c *Cond) lockCheck(lock *Lock) {
	assert(lock.holder == CurThread())
}

// Wait releases the lock and will wake up when Notify() or NotifyAll()
// is called on the condition.
func (c *Cond) Wait(lock *Lock) {
	c.lockCheck(lock)

	hold := intr.Disable()

	// Need to push CurThread() inside critical section.
	// Otherwise, it might be pushed on to wait queue at the
	// same time upon time interrupt.
	c.q.push(CurThread())

	lock.Unlock()
	Sleep()
	lock.Lock()

	intr.Restore(hold)
}

// Notify wakes up a thread that is waiting on the condition variable.
func (c *Cond) Notify(lock *Lock) {
	c.lockCheck(lock)

	t := c.q.pop() // Access to the queue is protected by lock
	if t == nil {
		return
	}

	hold := intr.Disable()
	Ready(t)
	intr.Restore(hold)
}

// NotifyAll wakes up all threads that are waiting on the condition variable.
func (c *Cond) NotifyAll(lock *Lock) {
	c.lockCheck(lock)

	hold := intr.Disable()
	for {
		t := c.q.pop()
		if t == nil {
			break
		}
		Ready(t)
	}
	intr.Restore(hold)
}
