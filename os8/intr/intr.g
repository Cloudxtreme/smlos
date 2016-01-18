package intr

const Nintr = 256

const (
	Halt         = 1
	Timer        = 2
	InvalidInst  = 3
	OutOfRange   = 4
	Misalign     = 5
	PageFault    = 6
	PageReadOnly = 7
	Panic        = 8
)

const (
	Serial = 16
	ROM    = 17
)

// Exception frame.
type Frame struct {
	R0     uint
	R1, R2 uint
	R3, R4 uint
	PC     uint
	SP     uint
	RET    uint
	Arg    uint // e.g. page fault address
	Intr   byte // the interrupt code
	Ring   byte
	_      [2]byte // padding
}

// Clears the interrupt frame
func (f *Frame) Clear() {
	var empty Frame
	*f = empty
}
