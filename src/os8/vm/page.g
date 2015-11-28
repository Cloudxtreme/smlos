package vm

const sizeOfPage = 4

// Page is a physical page that can be stored as a stack.
type Page struct {
	next *Page
}

var pages []Page // slice to all pages.

// ID returns the page id of the page
func (p *Page) ID() uint {
	if p == nil {
		panic()
	}
	ret := (uint(p) - uint(&pages[0])) / sizeOfPage
	if ret >= uint(len(pages)) {
		panic()
	}
	return ret
}

// IsLow checks if the page is a low memory page.
func (p *Page) IsLow() bool { return p.ID() < Nremap }

// PhyAddr returns the physical address of the page.
func (p *Page) PhyAddr() uint { return PageStart(p.ID()) }

// VirtAddr returns the remapped virtual address of a page.
// This only works for low memory pages.
func (p *Page) VirtAddr() uint {
	id := p.ID()
	if id >= Nremap {
		panic()
	}
	return PageStart(RemapBase + id)
}

// PageByID returns the page for a particular ID.
func PageByID(pid uint) *Page { return &pages[pid] }
