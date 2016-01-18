package tests

var mbPriority sync.Mailbox

func thWait(t uint) {
	spin(int(t))
	mbPriority.Send(t)
}

func startWaitThread(t uint, p int) {
	var conf sync.ThreadConfig
	conf.Arg = t
	conf.Priority = p
	th := sync.StartConfigArg(thWait, &conf)
	assert(th != nil)
}

func TestPriority() {
	startWaitThread(50, 1)
	startWaitThread(20, 2)
	startWaitThread(3, 3)

	assert(mbPriority.Recv() == 50)
	assert(mbPriority.Recv() == 20)
	assert(mbPriority.Recv() == 3)
}

func TestNoPriority(uint) {
	startWaitThread(50, 0)
	startWaitThread(20, 0)
	startWaitThread(3, 0)

	assert(mbPriority.Recv() == 3)
	assert(mbPriority.Recv() == 20)
	assert(mbPriority.Recv() == 50)
}
