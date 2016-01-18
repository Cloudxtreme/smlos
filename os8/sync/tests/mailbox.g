package tests

type _mailboxTest struct {
	box      sync.Mailbox
	lock     sync.Lock
	condDone sync.Cond

	n     uint
	mask  uint
	nrecv uint
}

func (t *_mailboxTest) markRecv(v uint) bool {
	assert(v < t.n)
	b := uint(1) << v
	assert((t.mask & b) == 0)
	t.mask |= b
	t.nrecv++
	assert(t.nrecv <= t.n)

	return t.nrecv == t.n
}

func (t *_mailboxTest) recv1() {
	v := t.box.Recv()

	t.lock.Lock()
	if t.markRecv(v) {
		t.condDone.Notify(&t.lock)
	}
	t.lock.Unlock()
}

func (t *_mailboxTest) recvAll() {
	for {
		v := t.box.Recv()
		if t.markRecv(v) {
			return
		}
	}
}

func (t *_mailboxTest) wait() {
	t.lock.Lock()
	for t.nrecv < t.n {
		t.condDone.Wait(&t.lock)
	}
	assert(t.nrecv == t.n)
	assert(t.mask == (uint(1)<<t.n)-1)
	t.lock.Unlock()
}

var mailboxTest _mailboxTest

func thMailboxRecv1()        { mailboxTest.recv1() }
func thMailboxSend(arg uint) { mailboxTest.box.Send(arg) }

func TestMailbox1() {
	n := uint(10)
	mailboxTest.n = n
	for i := uint(0); i < n; i++ {
		startArg(thMailboxSend, uint(i))
	}
	for i := uint(0); i < n; i++ {
		start(thMailboxRecv1)
	}
	mailboxTest.wait()
}

func TestMailbox2() {
	n := uint(3)
	mailboxTest.n = n
	for i := uint(0); i < n; i++ {
		startArg(thMailboxSend, uint(i))
	}
	mailboxTest.recvAll()
}
