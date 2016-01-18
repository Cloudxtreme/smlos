package syscall

const (
	Putc = 0

	Exit = 1
	Exec = 2
	Join = 3

	Write = 4
	Read  = 5
	Close = 6

	IPCConnect = 7
	IPCListen  = 8
	IPCAccept  = 9

	Fork = 10
	Pipe = 11

	ThreadStart = 12
	ThreadJoin  = 13
	Yield       = 14
)

const (
	ErrInvalid = 1
	ErrFailed  = 2
)

const (
	Nsyscall = 32
)

const (
	Stdin  = 0
	Stdout = 1
)

var syscalls [Nsyscall]func(arg2, arg3 uint) (r1, r2, r3 uint)

func Syscall(arg1, arg2, arg3 uint) (r1, r2, r3 uint) {
	if arg1 < uint(len(syscalls)) {
		f := syscalls[arg1]
		if f != nil {
			return f(arg2, arg3)
		}
	}

	syscallPanic()
}

// syscallPanic kills the process with error code -1.
func syscallPanic() {
	proc.Exit(-1)
	panic() // unreachable
}
