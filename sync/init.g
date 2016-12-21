package sync

func init() {
	root0 = vm.MakeRoot0()

	theScheduler.init()

	// Assembly wrappers for setting up interrupt contexts
	intr.SetHandler(vm.StackBase(vm.StackIntr), uint(smlos.Ienter))
	intr.SetSyscallPC(uint(smlos.SysEnter))

	// Enable time interrupt.
	intr.EnableLine(intr.Timer)

	// Hook up the interrupt entry function in G language.
	*(*uint)(smlos.Ientry) = uint(ihandler)
}
