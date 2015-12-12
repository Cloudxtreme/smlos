package proc

func init() {
	theProcs.init()

	sync.UserIntrHandler = ihandler

	// enable all interrupts that user process might generate
	// the kernel need to handle them properly
	intr.EnableLine(intr.Halt)
	intr.EnableLine(intr.InvalidInst)
	intr.EnableLine(intr.OutOfRange)
	intr.EnableLine(intr.Misalign)
	intr.EnableLine(intr.PageFault)
	intr.EnableLine(intr.PageReadOnly)
	intr.EnableLine(intr.Panic)
}
