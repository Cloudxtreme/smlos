package sync

// Whale is a whale matcher, basically a three-way mailbox but with
// no message to pass.
type Whale struct {
	lock    Lock
	cond    Cond
	nmale   uint
	nfemale uint

	condMaleProceed Cond
	maleProceed     bool

	condFemaleProceed Cond
	femaleProceed     bool
}

// Male registers a male whale for matching. It blocks
// until a Female() and a Matchmaker() is called.
func (w *Whale) Male() {
	w.lock.Lock()

	w.nmale++
	assert(w.nmale > 0)
	w.cond.Notify(&w.lock)

	for !w.maleProceed {
		w.condMaleProceed.Wait(&w.lock)
	}
	w.maleProceed = false

	w.lock.Unlock()
}

// Female registers a female whale for matching. It blocks
// until a Male() and a Matchmaker() is called.
func (w *Whale) Female() {
	w.lock.Lock()

	w.nfemale++
	assert(w.nfemale > 0)
	w.cond.Notify(&w.lock)
	for !w.femaleProceed {
		w.condFemaleProceed.Wait(&w.lock)
	}
	w.femaleProceed = false

	w.lock.Unlock()
}

// Matcher registers a whale matcher. It blocks
// until a Male() and a Female() is called.
func (w *Whale) Matcher() {
	w.lock.Lock()
	for w.nfemale == 0 || w.nmale == 0 {
		w.cond.Wait(&w.lock)
	}

	assert(w.nfemale > 0 && w.nmale > 0)
	w.nfemale--
	w.nmale--

	w.maleProceed = true
	w.femaleProceed = true
	w.condFemaleProceed.Notify(&w.lock)
	w.condMaleProceed.Notify(&w.lock)

	w.lock.Unlock()
}
