package syscall

func _exit(arg2, arg3 uint) (r1, r2, r3 uint) {
	proc.Exit(int(arg2))
	panic()
}
