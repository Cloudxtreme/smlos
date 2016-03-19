package os8

func thHello() {
	_, err := syscall.Execute("hello.e8", nil)
	if err != 0 {
		fmt.PrintStr("process loading failed\n")
	}
}

func main() {
	*(*uint)(os8.SysEntry) = uint(syscall.Syscall)

	sync.Run(thHello)
}
