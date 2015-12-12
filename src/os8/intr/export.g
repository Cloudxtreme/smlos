package intr

func Dispatch()           { intr.dispatch() }
func Issue(x byte)        { intr.issue(x) }
func Disable() bool       { return intr.disable() }
func Enable() bool        { return intr.enable() }
func Swap(b bool) bool    { return intr.swap(b) }
func IsEnabled() bool     { return intr.isEnabled() }
func Restore(b bool) bool { return intr.swap(b) }

func EnableLine(x byte) {
	intr.enableLine(x)
}

func DisableLine(x byte) { intr.disableLine(x) }

func SetHandler(sp, pc uint) {
	intr.handlerSP = sp
	intr.handlerPC = pc
}

func SetSyscallPC(pc uint) { intr.syscallPC = pc }

func SetSyscallSP(sp uint) { intr.syscallSP = sp }

func init() { intr = (*control)(uint(4096)) }
