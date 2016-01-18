package sync

// ThreadConfig has the config parameters for starting a new thread.
type ThreadConfig struct {
	Arg      uint
	Priority int
	Joinable bool
	Ptable   *vm.Root
}

func newThread(f uint, conf *ThreadConfig, hasArg bool) *Thread {
	assert(conf != nil)

	ret := theScheduler.alloc()
	if ret == nil {
		return nil
	}

	frame := &ret.context
	frame.Clear()
	frame.R1 = uint(f)
	if hasArg {
		frame.PC = uint(threadBodyArg)
		frame.R2 = conf.Arg
	} else {
		frame.PC = uint(threadBody)
	}

	frame.SP = ret.StackBase()

	ret.priority = conf.Priority

	ret.ptable = conf.Ptable
	if ret.ptable != nil {
		copyKernelEntries(ret.ptable)
	}

	joinInit(ret, conf.Joinable)

	return ret
}

// NewThreadArg creates a new thread that starts with f and an argument.
func NewThreadArg(f func(uint), conf *ThreadConfig) *Thread {
	return newThread(uint(f), conf, true)
}

// NewThread creates a new thread that starts with function f.
func NewThread(f func(), conf *ThreadConfig) *Thread {
	return newThread(uint(f), conf, false)
}

// StartConfigArg creates and starts a new thread that starts with
// function f and an argument, using the specific config.
func StartConfigArg(f func(uint), conf *ThreadConfig) *Thread {
	th := NewThreadArg(f, conf)
	if th == nil {
		return nil
	}

	Ready(th)
	return th
}

// StartConfig creates and starts a new thread that starts with
// function f and with the specific config
func StartConfig(f func(), conf *ThreadConfig) *Thread {
	th := NewThread(f, conf)
	if th == nil {
		return nil
	}

	Ready(th)
	return th
}

// Start creates and starts a new thread with empty config.
func Start(f func()) *Thread {
	var empty ThreadConfig // An empty config for default.
	return StartConfig(f, &empty)
}

// StartArg creates and starts a new thread that starts with f and
// an argument, using an empty config.
func StartArg(f func(uint), arg uint) *Thread {
	var conf ThreadConfig
	conf.Arg = arg
	return StartConfigArg(f, &conf)
}

func threadBodyArg(f func(uint), arg uint) {
	f(arg)
	Exit(0)
}

func threadBody(f func()) {
	f()
	Exit(0)
}

// Exit exits the current thread. This function does not return.
// It is automatically called whe the thread function ends it execution.
func Exit(v int) {
	joinExit(v)
	schedExit()
}
