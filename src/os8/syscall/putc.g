package syscall

func _putc(arg2, arg3 uint) (r1, r2, r3 uint) {
	err := putc(char(arg2))
	return uint(err), 0, 0
}

func putc(c char) int {
	printChar(c)
	return 0
}
