package proc

// procStart is the wrapper function that starts the process.
func procStart(arg uint) {
	cur := sync.CurThread()
	if cur.ID() == 0 {
		panic() // Cannot use idle thread to start a process.
	}
	p := (*Process)(arg)

	// Start the process, will never return back.
	// The kernel stack we run on now will be used for handling
	// system calls from now on.
	ustart(p.initPC, vm.StackBase(vm.UserStack0))
}

// Start spawns the process.
func Start(p *Process) bool {
	if p.initPC == 0 {
		return false
	}

	if p.preparePage(vm.UserStack0) == 0 {
		return false // map the stack page
	}

	var conf sync.ThreadConfig
	conf.Arg = uint(p)
	conf.Ptable = p.ptable

	th := sync.NewThreadArg(procStart, &conf)
	if th == nil {
		return false
	}

	// Bind the process and the thread together.
	p.th = th
	theProcs.pmap[th.ID()] = p

	sync.Ready(th)
	return true
}
