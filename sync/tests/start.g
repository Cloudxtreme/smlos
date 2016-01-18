package tests

func start(f func()) {
	th := sync.Start(f)
	assert(th != nil)
}

func startArg(f func(uint), arg uint) {
	th := sync.StartArg(f, arg)
	assert(th != nil)
}
