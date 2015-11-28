package vm

type manager struct {
	freeLowPages  PageStack
	freeHighPages PageStack
	reserved      PageStack // pages used on startup

	staticFrozen  bool
	nDirectMapped uint
}

var theManager manager

func (m *manager) init(npage uint) {
	if npage > NpageMax {
		npage = NpageMax
	}

	pagesBase := PageStart(m.allocStatic(NpageFor(npage * sizeOfPage)))
	pages = (*(*[NpageMax]Page)(pagesBase))[:npage]

	m.staticFrozen = true

	if m.dynamicBase() > npage {
		panic()
	}

	m.reserved.setPool(pages[:TempBase])
	m.freeLowPages.pushPages(pages[TempBase:Stack0])
	m.reserved.Push(&pages[Stack0])

	dbase := m.dynamicBase()
	if dbase < Nremap {
		// has something in low pages range
		if npage <= Nremap {
			m.freeLowPages.setPool(pages[dbase:])
		} else {
			m.freeLowPages.setPool(pages[dbase:Nremap])
			m.freeHighPages.setPool(pages[Nremap:])
		}
	} else {
		m.freeHighPages.setPool(pages[dbase:])
	}
}

func (m *manager) allocStatic(n uint) uint {
	if m.staticFrozen {
		panic()
	}

	ret := HeapBase + m.nDirectMapped
	m.nDirectMapped += n
	return ret
}

func (m *manager) dynamicBase() uint {
	return theManager.nDirectMapped + HeapBase
}

func (m *manager) alloc() *Page {
	if !m.freeHighPages.Empty() {
		return m.freeHighPages.Pop()
	}

	return m.allocLow()
}

func (m *manager) allocLow() *Page {
	return m.freeLowPages.Pop()
}

func (m *manager) free(p *Page) {
	id := p.ID()

	if id < Nremap {
		m.freeLowPages.Push(p)
	} else {
		m.freeHighPages.Push(p)
	}
}

// shortcut functions for init procedure.
func allocPage() *Page    { return theManager.alloc() }
func allocLowPage() *Page { return theManager.allocLow() }
func freePage(p *Page)    { theManager.free(p) }

// AllocPage allocates a new page.
func AllocPage() *Page {
	hold := intr.Disable()
	ret := allocPage()
	intr.Restore(hold)
	return ret
}

// AllocLowPage allocates a new low memory page.
func AllocLowPage() *Page {
	hold := intr.Disable()
	ret := allocLowPage()
	intr.Restore(hold)
	return ret
}

// FreePage puts back an allocated page.
func FreePage(p *Page) {
	hold := intr.Disable()
	freePage(p)
	intr.Restore(hold)
}
