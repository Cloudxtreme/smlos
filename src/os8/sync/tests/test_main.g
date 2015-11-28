package tests

func testMain(f func()) {
	intr.Init()
	vm.Init()
	sync.Init()

	sync.Run(f)
}

func main() {
	intr.Init()
	vm.Init()
	sync.Init()

	sync.Run(TestMailbox1)
}
