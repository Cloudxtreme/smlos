package smlos

func thHello() {
	_, err := syscall.Execute("hello.e8", nil)
	if err != 0 {
		fmt.PrintStr("process loading failed\n")
	}
}

func main() {
	*(*uint)(smlos.SysEntry) = uint(syscall.Syscall)

	sync.Run(thHello)
}
