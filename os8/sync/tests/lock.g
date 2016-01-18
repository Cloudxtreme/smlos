package tests

func TestBadLockTwice() {
	var lock sync.Lock
	lock.Lock()
	lock.Lock()
}

func TestBadUnlock() {
	var lock sync.Lock
	lock.Unlock()
}

func TestBadMissingUnlock() {
	var lock sync.Lock
	lock.Lock()
}

func TestBadUnlock2() {
	var lock sync.Lock
	lock.Lock()
	lock.Unlock()
	lock.Unlock()
}

func TestLock() {
	var lock sync.Lock
	lock.Lock()
	lock.Unlock()
}
