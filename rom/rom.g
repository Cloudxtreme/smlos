package rom

const maxFilename = 100

const (
	cmdIdle    = 0
	cmdRequest = 1
)

const (
	stateIdle = 0
	stateBusy = 1
)

const (
	ErrNone     = 0
	ErrEOF      = 1
	ErrNotFound = 2
	ErrOpen     = 3
	ErrRead     = 4
	ErrMemory   = 5
)

type rom struct {
	cmd     byte
	nameLen byte
	state   byte
	err     byte

	offset uint
	addr   uint
	size   uint
	nread  uint

	filename [maxFilename]int8
}

func (r *rom) idle() bool {
	return r.cmd == cmdIdle && r.state == stateIdle
}

func (r *rom) read(file string, offset, paddr, size uint32) {
	if !r.idle() {
		panic()
	}

	nameLen := len(file)
	if nameLen > maxFilename {
		file = file[:maxFilename]
		nameLen = maxFilename
	}
	r.nameLen = byte(nameLen)
	r.err = ErrNone // clear the error

	r.offset = offset
	r.addr = paddr
	r.size = size
	r.nread = 0

	for i := 0; i < nameLen; i++ {
		r.filename[i] = file[i]
	}

	r.cmd = cmdRequest // issue the request
}

func (r *rom) readResult() (nread uint, err byte) {
	if !r.idle() {
		panic()
	}

	return r.nread, r.err
}
