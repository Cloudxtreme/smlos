package tests

var thJoinLock sync.Lock
var thJoinDone bool

func thToJoin() {
	spin(5)

	thJoinLock.Lock()
	thJoinDone = true
	thJoinLock.Unlock()
}

func checkJoined() {
	thJoinLock.Lock()
	assert(thJoinDone == true)
	thJoinLock.Unlock()
}

func startThToJoin() *sync.Thread {
	thJoinDone = false
	var conf sync.ThreadConfig
	conf.Joinable = true
	return sync.StartConfig(thToJoin, &conf)
}

func TestJoin() {
	th := startThToJoin()
	assert(th != nil)
	sync.Join(th)

	checkJoined()
}

func TestJoin2() {
	th := startThToJoin()
	assert(th != nil)
	spin(20)
	sync.Join(th)

	checkJoined()
}

func TestBadJoinUnjoinable() {
	th := sync.Start(thToJoin)
	sync.Join(th)
}

func TestBadJoinSelf() { start(thJoinSelf) }
func thJoinSelf()      { sync.Join(sync.CurThread()) }

func TestBadJoinTwice() {
	th := startThToJoin()
	sync.Join(th)
	sync.Join(th)
}

func TestBadJoinPoint() {
	th := startThToJoin()
	sync.StartArg(thBadJoiner, uint(th))
}
func thBadJoiner(arg uint) {
	th := (*sync.Thread)(arg)
	sync.Join(th)
}
