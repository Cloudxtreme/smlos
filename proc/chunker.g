package proc

type chunker struct {
	h          *exec.Header
	sectionEnd uint

	first bool
	start uint
	page  uint
	end   uint
	size  uint
}

func (c *chunker) setEndAndSize() {
	c.end = vm.PageStart(c.page + 1)
	if c.end > c.sectionEnd {
		c.end = c.sectionEnd
	}
	c.size = c.end - c.start
}

func (c *chunker) init(h *exec.Header) {
	c.h = h
	c.sectionEnd = h.Addr + h.Size

	c.start = h.Addr
	c.page = vm.PageID(c.start)
	c.setEndAndSize()
	c.first = true
}

func (c *chunker) scan() bool {
	if c.first {
		c.first = false
		return c.size > 0
	}

	// iterate
	c.page++
	c.start = vm.PageStart(c.page)
	if c.start >= c.sectionEnd {
		c.end = c.start
		c.size = 0
		return false
	}

	c.setEndAndSize()
	if c.size == 0 {
		panic() // should not happen
	}
	return true
}

func (c *chunker) pos() uint        { return c.start - c.h.Addr }
func (c *chunker) pageOffset() uint { return c.start & vm.PageOffsetMask }
func (c *chunker) fileOffset() uint { return c.pos() + c.h.Offset }
