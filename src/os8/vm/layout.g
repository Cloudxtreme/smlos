package vm

// Layout related consts
const (
	TempBase  = 256 // temp slots start at 1M
	StackIntr = 256 + 2

	TempBegin = 300
	TempEnd   = 400

	Stack0 = 511 // first stack

	HeapBase   = 512  // heap starts at 2M
	StacksBase = 1024 // base of stack mapping space

	// [0-Nremap) is mapped to [RemapBase, UserBase)
	RemapBase = 1024 * 2 // base of high memory
	UserBase  = 1024 * 4 // base of user memory

	Nremap = UserBase - RemapBase

	UserTempBase = UserBase + TempBase
	UserStack0   = UserBase + Stack0

	NpageMin = 1024      // at least 4MB
	NpageMax = 16 * 1024 // possible max number of pages
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
