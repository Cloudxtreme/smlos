package sync

// root0 is the root page table that is used for the first thread, or the
// idle thread. No user process uses this table as the root, but this root
// server as a template for all process root tables.
var root0 *vm.Root

// copyKernelEntries populate the kernel space of the page table to be
// the same as the kernel's default page table. This will make sure
// that the threading works properly even when switching among different
// page tables.
func copyKernelEntries(pt *vm.Root) {
	for i := uint(0); i < vm.UserBase>>vm.EntryShift; i++ {
		pt.CopySub(root0, i)
	}
}

func checkTemp(vid uint) {
	if !(vid >= vm.TempBegin && vid < vm.TempEnd) {
		panic()
	}
}

// MapTemp maps a page at temp slot vid.
func MapTemp(vid, pid uint) {
	checkTemp(vid)
	hold := intr.Disable()
	root0.Map(vid, pid, 0)
	intr.Restore(hold)
}

// UnmapTemp unmaps a page at temp slot vid.
func UnmapTemp(vid uint) {
	checkTemp(vid)
	hold := intr.Disable()
	root0.Unmap(vid)
	intr.Restore(hold)
}

// UseRoot0 as current page table.
func UseRoot0() { root0.Use() }
