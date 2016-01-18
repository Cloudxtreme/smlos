package syscall

type execConfig struct {
	args     []string
	joinable bool
}

const sizeOfExecConfig = 9

func _exec(arg2, arg3 uint) (r1, r2, r3 uint) {
	pid, err := exec(arg2, arg3)
	return uint(pid), uint(err), 0
}

func exec(arg2, arg3 uint) (pid int, err int) {
	checkUserBuf(arg2)
	cmd := *(*string)(arg2)

	var config *execConfig
	if arg3 != 0 {
		config = (*execConfig)(arg3)

		checkUserMem(arg3, sizeOfExecConfig)
		checkUserSlice(uint(&config.args), 8) // a slice of slice
		for i := 0; i < len(config.args); i++ {
			checkUserBuf(uint(&config.args[i]))
		}
	}

	// all the checks passed, proceed on the loading.
	return Execute(cmd, config)
}

// Execute loads the process and starts it.
func Execute(cmd string, c *execConfig) (pid int, err int) {
	p := proc.Alloc()
	if !p.Load(cmd) {
		proc.Free(p)
		return 0, ErrFailed
	}

	// TODO: handle the configs, load the args.

	if !proc.Start(p) {
		return 0, ErrFailed
		proc.Free(p)
	}

	return p.ID(), 0
}
