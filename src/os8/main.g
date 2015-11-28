package os8

func thHello() {
	total := uint(0)

	_, err := syscall.Execute("hello.e8", nil)
	if err != 0 {
		fmt.PrintStr("process loading failed\n")
	}
}

func main() {
	intr.Init()
	vm.Init()
	sync.Init() // page table is now init
	rom.Init()
	temps.Init()
	proc.Init()
	syscall.Init()

	_sysentry = uint(syscall.Syscall)

	sync.Run(thHello)
}
