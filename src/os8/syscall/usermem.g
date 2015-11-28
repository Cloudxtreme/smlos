package syscall

func userMem(addr uint, size uint) bool {
	if addr < vm.PageStart(vm.UserBase) {
		return false
	}
	rest := 0 - addr
	return size <= rest
}

func userSlice(addr uint, elementSize uint) bool {
	if !memAlign(addr) {
		return false
	}

	const sliceSize = 8
	if !userMem(addr, sliceSize) {
		return false
	}

	startAddr := *(*uint)(addr)
	n := *(*int)(addr + 4)
	if n < 0 {
		return false // invalid slice
	}

	return userMem(startAddr, uint(n)*elementSize)
}

func userString(addr uint) bool { return userSlice(addr, 1) }

func memAlign(addr uint) bool { return addr%4 == 0 }

func checkUserMem(addr uint, size uint) {
	if !userMem(addr, size) {
		syscallPanic()
	}
}

func checkUserSlice(addr uint, elementSize uint) {
	if !userSlice(addr, elementSize) {
		syscallPanic()
	}
}

func checkUserBuf(addr uint) {
	if !userString(addr) {
		syscallPanic()
	}
}
