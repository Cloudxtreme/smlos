package sync

const Nthread = 64

type scheduler struct {
	threads [Nthread]Thread

	// need to disable interrupt (enter critical sections)
	// when accessing these fields
	avail queue
	waits queue
	cur   *Thread
	idle  *Thread // the idle thread
}

// dead checks if the idle thread is the only thread
// that is still alive.
func (s *scheduler) dead() bool {
	hold := intr.Disable()
	navail := s.avail.Size()
	intr.Restore(hold)
	return navail == len(s.threads)-1
}

func (s *scheduler) init() {
	n := len(s.threads)
	for i := 1; i < n; i++ {
		s.threads[i].id = i
		s.avail.push(&s.threads[i])
	}

	s.idle = &s.threads[0]
	s.cur = s.idle
	s.cur.alive = true
}

func (s *scheduler) alloc() *Thread {
	stack := vm.AllocPage()
	if stack == nil {
		return nil
	}

	hold := intr.Disable()
	ret := s.avail.pop()
	intr.Restore(hold)

	if ret == nil {
		vm.FreePage(stack)
		return nil
	}

	ret.stack = stack
	root0.Map(ret.StackPageID(), stack.ID(), 0)

	return ret
}

// free puts a thread back to the available thread pool. the caller can use
// this to return a thread that it allocates from alloc() but do not want
// schedule it with ready().
func (s *scheduler) free(t *Thread) {
	// unmap and free the stack
	root0.Unmap(t.StackPageID())
	vm.FreePage(t.stack)

	s.avail.push(t)
}

func (s *scheduler) ready(t *Thread) {
	assert(t != s.idle)
	assert(t != s.cur)

	hold := intr.Disable()
	s.waits.push(t)
	intr.Restore(hold)
}

// cswtich is the context switching function
// that should be called at the tail of the interrupt handler
func (s *scheduler) cswitch(frame *intr.Frame) *intr.Frame {
	if s.cur == nil {
		panic()
	}

	if s.cur == s.idle {
		// current is idle thread, we do not need to push
		// it into the schedule queue.
		s.idle.context = *frame
	} else {
		// not idle thread
		s.cur.context = *frame // copy in
		if !s.cur.alive {
			s.free(s.cur)
		} else if !s.cur.sleeping {
			s.waits.push(s.cur)
		}
	}

	next := s.waits.pop()
	if next == nil {
		next = s.idle
	}
	s.cur = next

	intr.SetSyscallSP(s.cur.StackBase())
	pt := s.cur.ptable
	if pt == nil {
		pt = root0
	}
	pt.Use()

	return &next.context // the frame to restore
}

var theScheduler scheduler

// CurThread returns the current thread.
func CurThread() *Thread {
	ret := theScheduler.cur
	if ret == nil {
		return theScheduler.idle
	}
	return ret
}

// Sleep puts the current thread into sleep state, and forcedly
// issues a schedule interrupt.
func Sleep() {
	CurThread().sleeping = true
	schedNow()
}

// Yield issues a schedule interrupt which might put the current
// thread on the waiting queue.
func Yield() {
	CurThread().sleeping = false
	sched() // will be scheduled once the interrupt is enabled again
}

func schedExit() {
	cur := CurThread()
	assert(cur.nlock == 0)
	cur.alive = false
	schedNow()
}

// Ready puts a thread on the waiting queue.
func Ready(t *Thread) {
	t.alive = true
	t.sleeping = false
	theScheduler.ready(t)

	if intr.IsEnabled() {
		if CurThread().priority > t.priority {
			Yield()
		}
	}
}

// schedNow issues and dispatches a soft timer interrupt
func schedNow() {
	sched()
	intr.Dispatch()
}

// sched issues a soft timer interrupt
func sched() { intr.Issue(intr.Timer) }
