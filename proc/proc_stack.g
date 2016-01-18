package proc

type procStack struct {
	top *Process
}

func (s *procStack) push(p *Process) {
	p.next = s.top
	s.top = p
}

func (s *procStack) pop() *Process {
	ret := s.top
	if ret != nil {
		s.top = s.top.next
	}

	ret.next = nil
	return ret
}
