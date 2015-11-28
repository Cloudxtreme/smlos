package proc

// ihandler is the interrupt/exception handler for user space
// programs.
func ihandler(frame *intr.Frame) {
	if frame.Intr == intr.Halt {
		routeExit(frame, 0)
		return
	}

	routeExit(frame, -1)
}

// routeFunc setups the interrupt frame so that it will be routed to a
// kernel space function on the kernel stack. This terminates the user
// level program, and switch the thread back to a kernel thread.
func routeFunc(f *intr.Frame, fn func(arg int), arg int) {
	cur := sync.CurThread()
	if cur.ID() == 0 {
		panic() // must not be idle thread
	}

	f.R0 = 0
	f.R1 = uint(arg)
	f.PC = uint(fn)
	f.SP = cur.StackBase()
	f.Ring = 0

	cur.UseRoot0() // switch to use common kernel page table.
}

// routeExit route to kernel thread starting with Exit function
// with an argument as the exit return value.
func routeExit(f *intr.Frame, v int) {
	routeFunc(f, exit, v)
}
