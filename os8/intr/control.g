package intr

func lineLocate(x byte) (pos, shift byte) {
	return x / 8, x % 8
}

// control describes the memory structure of the
// memory mapped interrupt controller.
type control struct {
	flag       byte
	_          [3]byte // padding
	handlerSP  uint
	handlerPC  uint
	syscallSP  uint
	syscallPC  uint
	_          [3]int // padding
	intMask    [32]byte
	intPending [32]byte
}

func (c *control) swap(b bool) bool {
	ret := (c.flag & 0x1) > 0

	if b {
		c.flag |= 0x1
	} else {
		c.flag &= ^byte(0x1)
	}
	return ret
}

func (c *control) isEnabled() bool { return (c.flag & 0x1) > 0 }
func (c *control) enable() bool    { return c.swap(true) }
func (c *control) disable() bool   { return c.swap(false) }

func lineCheck(line byte) {
	if line >= 32 {
		panic()
	}
}

func (c *control) enableLine(x byte) {
	lineCheck(x)

	pos, shift := lineLocate(x)
	c.intMask[pos] |= byte(0x1) << shift
}

func (c *control) disableLine(x byte) {
	lineCheck(x)

	pos, shift := lineLocate(x)
	c.intMask[pos] &= ^(byte(0x1) << shift)
}

func (c *control) issue(x byte) {
	lineCheck(x)

	pos, shift := lineLocate(x)
	c.intPending[pos] |= byte(0x1) << shift
}

func (c *control) dispatch() {
	if c.isEnabled() {
		return
	}
	// temporarily enable the interrupt and disable it again
	// this will dispatch all the pending interrupts
	hold := c.enable()
	c.swap(hold)
}

var intr *control
