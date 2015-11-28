package tests

func TestBadWaitWithoutLock() {
	var cond sync.Cond
	var lock sync.Lock
	cond.Wait(&lock)
}

func TestBadNotifyWithoutLock() {
	var cond sync.Cond
	var lock sync.Lock
	cond.Notify(&lock)
}

func TestBadNotifyAllWithoutLock() {
	var cond sync.Cond
	var lock sync.Lock
	cond.NotifyAll(&lock)
}
