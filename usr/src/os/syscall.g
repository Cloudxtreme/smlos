package os

const (
	ErrInvalid = 1
	ErrFailed  = 2
)

const (
	Stdin  = 0
	Stdout = 1
)

const (
	putc = 0

	exit = 1
	exec = 2
	join = 3

	write = 4
	read  = 5
	close = 6

	ipcConnect = 7
	ipcListen  = 8
	ipcAccept  = 9

	fork = 10
	pipe = 11

	threadStart = 12
	threadJoin  = 13
	yield       = 14
)

func syscall(a, b, c uint) (x, y, z uint) {
	f := (func(a, b, c uint) (x, y, z uint))(uint(builtin.Syscall))
	f(a, b, c)
}

// Putc puts a char to the console.
func Putc(v char) int {
	ret, _, _ := syscall(putc, uint(v), 0)
	return int(ret)
}

// Exit exits the process.
func Exit(v int) { syscall(exit, uint(v), 0) }

// ExecConfig is the optional configuration for starting
// a process with exec system call.
type ExecConfig struct {
	Args     []string
	Joinable bool
}

// ExecWithConfig starts a new process with a particular config.
// It returns the process ID and an error code.
func ExecWithConfig(cmd string, c *ExecConfig) (int, int) {
	pid, err, _ := syscall(exec, uint(&cmd), uint(c))
	return int(pid), int(err)
}

// Exec starts a new process. It is a short cut for
// ExecWithConfig(cmd, nil)
func Exec(cmd string) (pid int, err int) {
	return ExecWithConfig(cmd, nil)
}

// Join joins a child process.
func Join(pid int) (int, int) {
	ret, err, _ := syscall(join, uint(pid), 0)
	return int(ret), int(err)
}

// Read reads a file into a buffer. Returns the number of bytes read, and an
// error code.
func Read(fd int, buf []char) (int, int) {
	n, err, _ := syscall(read, uint(fd), uint(&buf))
	return int(n), int(err)
}

// Write writes a char buffer into a file. Returns the number of bytes written,
// and an error code.
func Write(fd int, buf []char) (int, int) {
	n, err, _ := syscall(write, uint(fd), uint(&buf))
	return int(n), int(err)
}

// Close closes a file, returns an error code
func Close(fd int) int {
	err, _, _ := syscall(close, uint(fd), 0)
	return int(err)
}
