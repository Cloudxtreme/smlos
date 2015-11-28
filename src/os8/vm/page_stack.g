package vm

// PageStack is a stack container that stores a list of pages;
// first in last out.
type PageStack struct {
	top  *Page  // a linked list
	pool []Page // and a pool of idle ones
}

// Push pushes a page into the stack.
func (s *PageStack) Push(p *Page) {
	if p.next != nil {
		panic()
	}

	p.next = s.top
	s.top = p
}

func (s *PageStack) pushPages(pages []Page) {
	for i := 0; i < len(pages); i++ {
		s.Push(&pages[i])
	}
}

// setPool sets a page pool into the page stack, which is a continuous slice of
// Page's. When the linked list is empty, the page stack can allocate a page
// from the pool. This saves initializtion time for adding a set of pages into
// the PageStack. This method is not exported because external entities should
// never allocate pages.
func (s *PageStack) setPool(pages []Page) { s.pool = pages }

// Empty checks if the stack is empty.
func (s *PageStack) Empty() bool {
	return s.top == nil && len(s.pool) == 0
}

// Pop pops out the top of the stack.
func (s *PageStack) Pop() *Page {
	if s.top == nil {
		if len(s.pool) == 0 {
			return nil
		}

		ret := &s.pool[0]
		ret.next = nil
		s.pool = s.pool[1:]
		return ret
	}

	ret := s.top
	s.top = s.top.next
	ret.next = nil
	return ret
}
