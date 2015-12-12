package os8

func thHello() {
	total := uint(0)

	_, err := syscall.Execute("hello.e8", nil)
	if err != 0 {
		fmt.PrintStr("process loading failed\n")
	}
}

func main() {
	_sysentry = uint(syscall.Syscall)

	sync.Run(thHello)
}
