package proc

// Nprocess is the maximum number of processes.
const Nprocess = 16

// Process represents a process in the operating system
type Process struct {
	id     int
	ptable *vm.Root     // root page table
	pages  vm.PageStack // allocated pages

	temp    []byte
	tempVid uint
	initPC  uint
	th      *sync.Thread

	// allocate header in process so that it is always direct mapped because
	// all processes are statically allocated. This saves the effort of
	// converting virtual address to physical address when reading the
	// header from the ROM.
	header exec.Header

	next *Process // for linking in a stack
}

func (p *Process) ID() int { return p.id }

// initPtable allocates a page table for
func (p *Process) initPtable() bool {
	if p.ptable != nil {
		panic() // already set
	}

	page := vm.AllocLowPage()
	if page == nil {
		return false
	}

	p.ptable = vm.NewRoot(page.VirtAddr())
	p.pages.Push(page)

	return true
}

func (p *Process) prepareEntry(vid uint) (*vm.PageTable, uint) {
	index := vid >> vm.EntryShift
	pt := p.ptable.Sub(index)

	if pt == nil {
		page := vm.AllocLowPage()
		if page == nil {
			return nil, 0
		}

		p.pages.Push(page)
		pt = vm.NewPageTable(page.VirtAddr())
		p.ptable.SetSub(index, pt, vm.PteUser)

		return pt, 0
	}

	entry := pt.Entry(vid & vm.EntryMask)
	if entry&vm.PteValid != 0 {
		pid := entry >> vm.PageShift
		if pid == 0 {
			panic()
		}

		return pt, pid
	}

	return pt, 0
}

func (p *Process) preparePage(vid uint) uint {
	if vid < vm.UserBase {
		return 0 // we do not prepare in kernel space
	}

	pt, pid := p.prepareEntry(vid)
	if pt == nil {
		return 0
	}

	if pid != 0 {
		sync.MapTemp(p.tempVid, pid)
		return pid
	}

	// the page for vid is not mapped yet
	page := vm.AllocPage()
	if page == nil { // no page left
		return 0
	}
	p.pages.Push(page)

	pid = page.ID()
	pt.Map(vid&vm.EntryMask, pid, vm.PteUser)

	sync.MapTemp(p.tempVid, pid)
	bzero(p.temp) // clear the page content

	return pid
}

func (p *Process) loadSection(file string, h *exec.Header) bool {
	var c chunker
	c.init(h)

	for c.scan() {
		pid := p.preparePage(c.page)
		if pid == 0 {
			return false
		}

		paddr := vm.PageStart(pid) + c.pageOffset()
		n, err := rom.ReadAt(file, c.fileOffset(), paddr, c.size)
		if err != 0 || n != c.size {
			return false
		}
	}

	return true
}

func bzero(bs []byte) {
	n := len(bs)
	for i := 0; i < n; i++ {
		bs[i] = 0
	}
}

func (p *Process) loadZeros(h *exec.Header) bool {
	var c chunker
	c.init(h)

	for c.scan() {
		if p.preparePage(c.page) == 0 {
			return false
		}
	}
	return true
}

func (p *Process) load(file string) bool {
	if p.ptable == nil {
		if !p.initPtable() {
			return false
		}
	}

	h := &p.header

	for offset := uint(0); ; offset += exec.HeaderSize {
		n, err := rom.ReadAt(file, offset, uint(h), exec.HeaderSize)
		if err != 0 {
			return false
		}
		if n != exec.HeaderSize {
			return false
		}

		if h.Type == exec.None {
			break
		} else if h.Type == exec.Code || h.Type == exec.Data {
			if !p.loadSection(file, h) {
				return false
			}
		} else if h.Type == exec.Zeros {
			if !p.loadZeros(h) {
				return false
			}
		} else {
			// ignore the other ones
		}

		// First code section is the init PC location.
		if p.initPC == 0 && h.Type == exec.Code {
			p.initPC = h.Addr
		}
	}

	return true
}

// Load loads in an executable file into a process's memory space.
func (p *Process) Load(file string) bool {
	p.tempVid = temps.AllocSlot()
	p.temp = (*(*[vm.PageSize]byte)(vm.PageStart(p.tempVid)))[:]
	ret := p.load(file)
	temps.FreeSlot(p.tempVid)
	return ret
}

// freePage frees all the allocated user pages and page table pages. This
// does not include the kernel thread stack page, which might be the stack we
// are running on right now. The kernel thread stack page is freed by the
// scheduler on destructing the thread.
func (p *Process) freePages() {
	for !p.pages.Empty() {
		page := p.pages.Pop()
		vm.FreePage(page)
	}
}
