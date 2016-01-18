package proc

type procs struct {
	ps    [Nprocess]Process
	avail procStack
	lock  sync.Lock
	pmap  [sync.Nthread]*Process
}

func (ps *procs) init() {
	for i := 0; i < Nprocess; i++ {
		ps.ps[i].id = i
		ps.avail.push(&ps.ps[i])
	}
}

func (ps *procs) alloc() *Process {
	ps.lock.Lock()
	ret := ps.avail.pop()
	ps.lock.Unlock()

	if ret == nil {
		return nil
	}
	ret.ptable = nil
	ret.next = nil

	fmt.PrintStr("alloc proc #")
	fmt.PrintInt(ret.id)
	fmt.Println()

	return ret
}

func (ps *procs) free(p *Process) {
	fmt.PrintStr("free proc #")
	fmt.PrintInt(p.id)
	fmt.Println()

	ps.lock.Lock()
	ps.avail.push(p)
	ps.lock.Unlock()
}

var theProcs procs

// Alloc allocates a process from the process pool. Returns nil when
// there is no process resource.
func Alloc() *Process { return theProcs.alloc() }

// Free unmaps all pages allocated for the process, and
// returns the process back to the pool.
func Free(p *Process) {
	p.freePages() // free all the allocated pages

	theProcs.pmap[p.th.ID()] = nil
	p.th = nil
	theProcs.free(p)
}

// Current returns the pointer to the process that
// is bind to the current kernel thread.
func Current() *Process {
	id := sync.CurThread().ID()
	return theProcs.pmap[id]
}
