package vm

// StackPageID returns the page number of stack #i
func StackPageID(no uint) uint { return 256 + 1 + 2*no }
