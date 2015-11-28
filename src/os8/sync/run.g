package sync

// IdleSpin spins until all threads exits and the idle thread is the
// only remaining thread
func IdleSpin() {
	for !theScheduler.dead() {
		Yield()
	}
}

// Run starts the kernel with a particular function as the entry
// of the first non-idle thread
func Run(f func()) {
	intr.Enable() // start the interrupts

	if f != nil {
		th := Start(f)
		assert(th != nil)
	} else {
		fmt.PrintStr("Hello, world.\n")
	}

	// Never return until nothing to schedule.
	IdleSpin()
	Exit(0)
}
