package vm

// PTE flags
const (
	PteValid    = 0x1
	PteReadOnly = 0x2
	PteUse      = 0x4
	PteDirty    = 0x8
	PteUser     = 0x10
)

// Page size and entry size consts
const (
	PageSize  = 0x1000
	PageShift = 12

	PageOffsetMask = PageSize - 1
	PageNumMask    = 0xffffffff ^ PageOffsetMask

	Nentry     = 1024
	EntryShift = 10
	EntryMask  = Nentry - 1
)

// PageStart maps a page id to the starting address of the page.
func PageStart(p uint) uint { return p << PageShift }

// StackBase returns the base stack pointer of a stack page
func StackBase(p uint) uint { return (p + 1) << PageShift }

// PageID returns the page id of an address.
func PageID(addr uint) uint { return addr >> PageShift }

// NpageFor returns the number of pages required to save size bytes.
func NpageFor(size uint) uint {
	ret := size >> PageShift
	if size%PageSize != 0 {
		ret++
	}
	return ret
}
