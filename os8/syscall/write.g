package syscall

func _write(arg2, arg3 uint) (r1, r2, r3 uint) {
	n, err := write(int(arg2), arg3)
	return uint(n), uint(err), 0
}

func write(fd int, arg3 uint) (n, err int) {
	checkUserBuf(arg3)
	buf := *(*[]byte)(arg3)

	if fd != Stdout {
		return 0, ErrInvalid
	}

	for i := 0; i < len(buf); i++ {
		printChar(char(buf[i]))
	}

	return len(buf), 0
}
