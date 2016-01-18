package vm

// Layout related consts
const (
	TempBase  = 256 // temp slots start at 1M
	StackIntr = 256 + 2

	TempBegin = 300
	TempEnd   = 400

	Stack0 = 511 // first stack

	HeapBase   = 512    // heap, from 2M to 4M
	StacksBase = Nentry // base of stack mapping space

	// [0-Nremap) is mapped to [RemapBase, UserBase)
	RemapBase = Nentry * 2 // base of high memory
	UserBase  = Nentry * 4 // base of user memory

	Nremap = UserBase - RemapBase

	UserTempBase = UserBase + TempBase
	UserStack0   = UserBase + Stack0

	NpageMin = Nentry      // at least 4MB
	NpageMax = 16 * Nentry // possible max number of pages
)

// LowPageVaddr converts a physical address into the direct mapped virtual
// address for a low memory page.
func LowPageVaddr(paddr uint) uint {
	if (paddr >> PageShift) >= Nremap {
		panic()
	}
	return paddr + (RemapBase << PageShift)
}

// LowPagePaddr converts a direct mapped virtual address into the physical
// address for a low memory page.
func LowPagePaddr(vaddr uint) uint {
	vid := vaddr >> PageShift
	if !(vid >= RemapBase && vid < UserBase) {
		panic()
	}
	return vaddr - (RemapBase << PageShift)
}
