package tests

func testMain(f func()) {
	sync.Run(f)
}

func main() {
	sync.Run(TestMailbox1)
}
