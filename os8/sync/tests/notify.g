package tests

type _notifyTest struct {
	lock        sync.Lock
	condWaiting sync.Cond
	condWake    sync.Cond
	condDone    sync.Cond
	waiting     int
	done        int
	notified    bool
}

func (t *_notifyTest) thRecv() {
	t.lock.Lock()
	t.waiting++
	t.condWaiting.Notify(&t.lock)

	for !t.notified {
		t.condWake.Wait(&t.lock)
	}

	t.done++
	t.condDone.Notify(&t.lock)

	t.lock.Unlock()
}

func (t *_notifyTest) testNotify(n int) {
	t.lock.Lock()
	for t.waiting < n {
		t.condWaiting.Wait(&t.lock)
	}

	t.notified = true
	for i := 0; i < n; i++ {
		t.condWake.Notify(&t.lock)

		spin(20) // spin for a while

		for t.done <= i {
			t.condDone.Wait(&t.lock)
		}
		assert(t.done == i+1)
	}

	t.lock.Unlock()
}

func (t *_notifyTest) testNotifyAll(n int) {
	t.lock.Lock()
	for t.waiting < n {
		t.condWaiting.Wait(&t.lock)
	}

	t.notified = true
	t.condWake.NotifyAll(&t.lock)

	for t.done < n {
		t.condDone.Wait(&t.lock)
	}
	assert(t.done == n)
	t.lock.Unlock()
}

var notifyTest _notifyTest

func thNotifyRecv() { notifyTest.thRecv() }

func TestNotify() {
	n := 5
	for i := 0; i < n; i++ {
		start(thNotifyRecv)
	}
	notifyTest.testNotify(n)
}

func TestNotifyAll() {
	n := 5
	for i := 0; i < n; i++ {
		start(thNotifyRecv)
	}
	notifyTest.testNotifyAll(n)
}
