package tests

type _noopNotifyTest struct {
	lock        sync.Lock
	condStart   sync.Cond
	condStarted sync.Cond
	condWait    sync.Cond
	start       bool
	started     bool
	notified    bool
}

func (t *_noopNotifyTest) thRecv() {
	t.lock.Lock()
	for !t.start {
		t.condStart.Wait(&t.lock)
	}

	t.started = true
	t.condStarted.Notify(&t.lock)

	for !t.notified {
		t.condWait.Wait(&t.lock)
		assert(t.notified) // must be waken by the second notify
	}

	t.lock.Unlock()
}

func (t *_noopNotifyTest) testNotify(all bool) {
	t.lock.Lock()
	// do two notifies, should be noops.
	if !all {
		t.condWait.Notify(&t.lock)
		t.condWait.Notify(&t.lock)
	} else {
		t.condWait.NotifyAll(&t.lock)
		t.condWait.NotifyAll(&t.lock)
	}

	t.start = true
	t.condStart.Notify(&t.lock)

	// wait until started the real waiting
	for !t.started {
		t.condStarted.Wait(&t.lock)
	}

	t.notified = true
	if !all {
		t.condWait.Notify(&t.lock)
	} else {
		t.condWait.NotifyAll(&t.lock)
	}

	t.lock.Unlock()
}

var noopNotifyTest _noopNotifyTest

func thNoopNotifyRecv() { noopNotifyTest.thRecv() }

func TestNoopNotify() {
	start(thNoopNotifyRecv)
	noopNotifyTest.testNotify(false)
}

func TestNoopNotifyAll() {
	start(thNoopNotifyRecv)
	noopNotifyTest.testNotify(true)
}
