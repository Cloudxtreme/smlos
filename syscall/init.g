package syscall

func init() {
	syscalls[Putc] = _putc
	syscalls[Exit] = _exit
	syscalls[Exec] = _exec
	// syscalls[Join] = _join
	syscalls[Write] = _write
	// syscalls[Read] = _read
	// syscalls[Close] = _close
}
