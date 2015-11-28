package vm

func nMemPage() uint { return *((*uint)(uint(0x7000))) }

func phyDirectMapRange(root *Root, from, to uint) {
	for i := from; i < to; i++ {
		root.phyDirectMap(i, 0)
	}
}

func Init() {
	npage := nMemPage()
	if npage < NpageMin {
		panic() // memory too small
	}
	if npage > NpageMax {
		npage = NpageMax
	}

	theManager.init(npage) // init phy page pools
}

// MakeRoot0 sets up the basic page table layout and the free physical page
// pool.
func MakeRoot0() *Root {
	root0Page := allocLowPage().ID()
	root0 := NewRoot(PageStart(root0Page))

	// setup kernel space page tables
	if UserBase&EntryMask != 0 {
		panic()
	}
	for i := uint(0); i < UserBase>>EntryShift; i++ {
		p := allocLowPage().ID()
		pt := NewPageTable(PageStart(p))
		root0.setPhySub(i, pt, 0)
	}

	phyDirectMapRange(root0, 1, TempBase)
	root0.phyDirectMap(Stack0, 0) // map stack0
	phyDirectMapRange(root0, HeapBase, theManager.dynamicBase())

	// allocate and map the stack for interrupt handling
	root0.phyMap(StackIntr, allocPage().ID(), 0)

	// remap all low memory
	for i := uint(0); i < Nremap; i++ {
		root0.phyMap(RemapBase+i, i, 0)
	}

	vtable(uint(root0))

	return (*Root)(LowPageVaddr(uint(root0)))
}
