package tests

type _testPriorityInv struct {
	lock sync.Lock
	mb   sync.Mailbox
	mb2  sync.Mailbox
	mb3  sync.Mailbox

	doneLock sync.Lock
	done     bool

	thToJoin *sync.Thread
}

func (t *_testPriorityInv) low() {
	t.lock.Lock()
	t.mb.Send(0) // can start the thread now
	t.mb2.Recv() // threads started
	spin(10)     // do some work
	t.lock.Unlock()
}

// a busy mid priority thread that will
// be busy blocking the low priority thread
// until the high priority thread get through
func (t *_testPriorityInv) mid() {
	// busy wait until done is set
	// this will starve the low priority thread
	// and hence keep grabbing t.lock and block
	// high()
	for {
		t.doneLock.Lock()
		done := t.done
		t.doneLock.Unlock()
		if done {
			break
		}
	}
}

func (t *_testPriorityInv) highLock() {
	t.lock.Lock()
	t.lock.Unlock()

	t.doneLock.Lock()
	t.done = true
	t.doneLock.Unlock()
}

func (t *_testPriorityInv) highJoin() {
	t.thToJoin = startPriority(thLowPriority, 3, true)
	t.mb3.Send(0)

	sync.Join(t.thToJoin)

	t.doneLock.Lock()
	t.done = true
	t.doneLock.Unlock()
}

var testPriorityInv _testPriorityInv

func thLowPriority()      { testPriorityInv.low() }
func thMidPriority()      { testPriorityInv.mid() }
func thHighLockPriority() { testPriorityInv.highLock() }
func thHighJoinPriority() { testPriorityInv.highJoin() }

func startPriority(f func(), p int, joinable bool) *sync.Thread {
	var conf sync.ThreadConfig
	conf.Priority = p
	conf.Joinable = joinable
	th := sync.StartConfig(f, &conf)
	assert(th != nil)
	return th
}

func TestPriorityInversion() {
	startPriority(thLowPriority, 3, false)
	testPriorityInv.mb.Recv()
	// low priority thread is not grabing the lock and going to
	// do some stuff for a while
	startPriority(thMidPriority, 2, false)
	startPriority(thHighLockPriority, 1, false)
	testPriorityInv.mb2.Send(0)
}

func TestPriorityJoinInversion() {
	startPriority(thHighJoinPriority, 1, false)
	testPriorityInv.mb3.Recv()             // low priority started
	testPriorityInv.mb.Recv()              // low priority grabbed the lock
	startPriority(thMidPriority, 2, false) // start a thread to starve it
	testPriorityInv.mb2.Send(0)            // low priority thread go on

	// mid will now be busy pulling on done, which starves low priority
	// thread in normal conditions. However the high priority one
	// joining the low one should increase the low priority to finish,
	// which allows high to continue and stops the mid priority thread.
}
