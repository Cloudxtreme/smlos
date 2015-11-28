package sync

// Sem is a semaphore that maintains a non-zero value.
type Sem struct {
	v int
	q queue
}

// Dec decreaes the value by 1.
// If it is zero, it will block until a concurrent Inc() is called.
func (s *Sem) Dec() {
	hold := intr.Disable()

	for s.v == 0 {
		s.q.push(CurThread())
		Sleep()
	}

	assert(s.v > 0)
	s.v--

	intr.Restore(hold)
}

// Inc increase the value by 1. If a value is 0 befor the call,
// and a concurrent Dec() is blocking by this semaphore, this call
// will unblock exactly one blocking thread.
func (s *Sem) Inc() {
	hold := intr.Disable()

	t := s.q.pop()
	if t != nil {
		Ready(t)
	}
	s.v++
	assert(s.v > 0) // overflow check

	intr.Restore(hold)
}
