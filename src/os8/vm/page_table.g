package vm

type PageTable struct {
	entries [Nentry]uint
}

func NewPageTable(addr uint) *PageTable {
	ret := (*PageTable)(addr)
	ret.Clear()
	return ret
}

func (pt *PageTable) Clear() {
	for i := 0; i < Nentry; i++ {
		pt.entries[i] = 0
	}
}

func (pt *PageTable) Entry(i uint) uint {
	return pt.entries[i]
}

func (pt *PageTable) Valid(i uint) bool {
	return pt.entries[i]&PteValid != 0
}

func (pt *PageTable) Page(i uint) uint {
	return pt.entries[i] & PageNumMask
}

func (pt *PageTable) PageID(i uint) uint {
	return pt.entries[i] >> PageShift
}

func (pt *PageTable) Flag(i uint) uint {
	return pt.entries[i] & PageOffsetMask
}

func (pt *PageTable) Unmap(i uint) {
	pt.entries[i] = 0
}

func (pt *PageTable) Map(i, pid, flags uint) {
	pt.entries[i] = PageStart(pid) | (flags & PageOffsetMask) | PteValid
}

func (pt *PageTable) SetEntry(i uint, entry uint) {
	pt.entries[i] = entry
}
