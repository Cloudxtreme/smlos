package sync

// Lock is an object that creates simple mutual exclusion.
type Lock struct {
	holder *Thread
	q      queue

	holderPriority int
}

// Locked checks if the lock is current held by a holder.
func (l *Lock) Locked() bool {
	return l.holder != nil
}

// Lock tries to grab the lock. It blocks until the lock is
// grabbed by the thread. It panics if the lock is already held
// by the calling thread.
func (l *Lock) Lock() {
	cur := CurThread()
	assert(l.holder != cur)

	hold := intr.Disable()

	for l.Locked() {
		l.q.push(cur)
		headPriority := l.q.head.priority
		if headPriority < l.holder.priority {
			l.holder.SetPriority(headPriority)
		}
		Sleep()
	}

	assert(!l.Locked())
	l.holder = cur
	l.holderPriority = cur.priority // save original priority
	l.holder.nlock++

	intr.Restore(hold)
}

// Unlock releases the holding of the lock, allowing other
// threads to grab the lock. It panics if the lock is not held
// by the calling thread.
func (l *Lock) Unlock() {
	cur := CurThread()
	assert(l.Locked())
	assert(l.holder == cur)

	hold := intr.Disable()

	assert(l.holder.nlock > 0)
	l.holder.nlock--
	l.holder = nil                    // unlocked now
	cur.SetPriority(l.holderPriority) // restore priority

	t := l.q.pop()
	if t != nil {
		Ready(t)
	}

	intr.Restore(hold)
}
