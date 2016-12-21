// Syscall performs a system call.
func Syscall {
    sw ret sp -4
	syscall
    lw ret sp -4
	mov pc ret
}

