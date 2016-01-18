package temps

import (
	"pool"

	"sync"
	"vm"
)

var (
	slots pool.Pool
	buf   [vm.TempEnd - vm.TempBegin]uint
	lock  sync.Lock
	cond  sync.Cond
)

func init() {
	slots.Init(buf[:])
	for i := uint(vm.TempBegin); i < vm.TempEnd; i++ {
		slots.Put(i)
	}
}

// AllocSlot allocates a temp page that maps a temp point.
// It returns the page id of the virtual page allocates. Returns 0 when
// allocation failed.
func AllocSlot() uint {
	lock.Lock()
	for slots.Empty() {
		cond.Wait(&lock)
	}

	vid, ok := slots.Get()
	if !ok {
		panic()
	}

	lock.Unlock()

	return vid
}

// FreeSlot frees a temp page that is mapped at a temp point
func FreeSlot(vid uint) {
	lock.Lock()
	slots.Put(vid) // put it back to resource pool
	cond.Notify(&lock)
	lock.Unlock()
}
