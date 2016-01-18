package tests

type _testWhale struct {
	w sync.Whale

	matched   int
	lock      sync.Lock
	matchCond sync.Cond
}

var testWhale _testWhale

func (t *_testWhale) count() {
	t.lock.Lock()
	t.matched++
	t.matchCond.Notify(&testWhale.lock)
	t.lock.Unlock()
}

func thMale() {
	testWhale.w.Male()
	testWhale.count()
}
func thFemale() {
	testWhale.w.Female()
	testWhale.count()
}

func thMatcher() {
	testWhale.w.Matcher()
	testWhale.count()
}

func TestWhale() {
	n := 3
	for i := 0; i < n; i++ {
		start(thMale)
		start(thFemale)
		start(thMatcher)
	}

	testWhale.lock.Lock()
	for testWhale.matched < n*3 {
		testWhale.matchCond.Wait(&testWhale.lock)
	}
	assert(testWhale.matched == n*3)
	testWhale.lock.Unlock()
}
