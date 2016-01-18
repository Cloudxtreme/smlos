package exec

type Header struct {
	Type   byte
	Flag   byte
	_      [2]byte
	Addr   uint
	Size   uint
	Offset uint
}

const HeaderSize = 16

const (
	None      = 0
	Code      = 1
	Data      = 2
	Zeros     = 3 // BSS
	Symbols   = 4
	DebugInfo = 5
	Comment   = 6
)
