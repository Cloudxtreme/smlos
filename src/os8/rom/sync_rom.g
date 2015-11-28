package rom

type syncROM struct {
	rom       *rom
	lock      sync.Lock
	thPending *sync.Thread
}

const romBaseAddr = 0x2100

var theROM syncROM

func (r *syncROM) init() {
	r.rom = (*rom)(uint(romBaseAddr))
}

func (r *syncROM) read(
	f string, offset, addr, size uint32,
) (n uint, err byte) {
	r.lock.Lock()

	r.rom.read(f, offset, addr, size)

	hold := intr.Disable()
	for !r.rom.idle() {
		r.thPending = sync.CurThread()
		sync.Sleep()
	}
	r.thPending = nil
	intr.Restore(hold)

	n, err = r.rom.readResult()
	r.lock.Unlock()

	return n, err
}

// Init initializes the ROM.
func Init() {
	theROM.init()
	sync.IntrHandlers[intr.ROM] = romHandler
	intr.EnableLine(intr.ROM)
}

// ReadRom reads the rom. It is a blocking call. Because the ROM uses
// DMA, so the address is physical address.
func ReadAt(f string, offset, paddr, size uint) (n uint, err byte) {
	return theROM.read(f, offset, paddr, size)
}

func romHandler(frame *intr.Frame) {
	if theROM.thPending != nil {
		sync.Ready(theROM.thPending)
	}
}
