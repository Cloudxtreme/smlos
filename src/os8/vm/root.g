package vm

type Root struct {
	entries [Nentry]uint
}

func NewRoot(addr uint) *Root {
	ret := (*Root)(addr)
	ret.Clear()
	return ret
}

func (r *Root) Clear() {
	for i := 0; i < Nentry; i++ {
		r.entries[i] = 0
	}
}

func (r *Root) Entry(i uint) uint { return r.entries[i] }

// CopySub copies the particular sub entry from another page table.
func (r *Root) CopySub(from *Root, i uint) {
	r.entries[i] = from.entries[i]
}

func (r *Root) phySub(i uint) *PageTable {
	entry := r.entries[i]
	if entry&PteValid == 0 {
		return nil
	}
	return (*PageTable)(entry & PageNumMask)
}

func (r *Root) setSub(i, addr, flags uint) {
	if addr&PageOffsetMask != 0 {
		panic()
	}
	r.entries[i] = addr | (flags & PageOffsetMask) | PteValid
}

func (r *Root) setPhySub(i uint, t *PageTable, flags uint) {
	r.setSub(i, uint(t), flags)
}

func (r *Root) Valid(i uint) bool {
	return r.entries[i]&PteValid != 0
}

func (r *Root) phyMap(vid, pid, flags uint) {
	pt := r.phySub(vid >> EntryShift)
	pt.Map(vid&EntryMask, pid, flags)
}

func (r *Root) phyUnmap(vid uint) {
	pt := r.phySub(vid >> EntryShift)
	pt.Unmap(vid & EntryMask)
}

func (r *Root) phyDirectMap(id, flags uint) { r.phyMap(id, id, flags) }

// SetSub maps a pagetable to the particular position.
func (r *Root) SetSub(i uint, t *PageTable, flags uint) {
	r.setSub(i, LowPagePaddr(uint(t)), flags)
}

// Sub fetches the sub page table at a particular index.
func (r *Root) Sub(i uint) *PageTable {
	pt := r.phySub(i)
	if pt == nil {
		return nil
	}
	return (*PageTable)(LowPageVaddr(uint(pt)))
}

// Map maps page vid to page pid with flags.
func (r *Root) Map(vid, pid, flags uint) {
	pt := r.Sub(vid >> EntryShift)
	pt.Map(vid&EntryMask, pid, flags)
}

// Unmap unmaps page vid.
func (r *Root) Unmap(vid uint) {
	pt := r.Sub(vid >> EntryShift)
	pt.Unmap(vid & EntryMask)
}

// Walk reads the entry for a particular page vid.
func (r *Root) Walk(vid uint) uint {
	pt := r.Sub(vid >> EntryShift)
	return pt.Entry(vid & EntryMask)
}

// Use applies the page table.
func (r *Root) Use() {
	vtable(LowPagePaddr(uint(r)))
}
