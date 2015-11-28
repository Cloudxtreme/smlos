package proc

// Exit switches to kernel thread page table for current thread.
// and then exit with the process return value.
func Exit(v int) {
	cur := sync.CurThread()
	cur.UseRoot0()
	sync.UseRoot0()
	exit(v)

	panic() // unreachable
}

// exit exits with the process return value and frees the process.
func exit(v int) {
	// live on the kernel thread and preparing to exit.

	p := Current()

	// TODO: if this process is joinable, we need to wait until
	// join is called and then free the process, because join
	// will need to map the pid to thread id.
	// Or we can save the pid->tid mapping in the fature process.

	Free(p) // return the process to the pool.

	sync.Exit(0) // Must call this.
}
