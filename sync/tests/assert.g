package tests

func printStr(s string) {
	for i := 0; i < len(s); i++ {
		printChar(s[i])
	}
}

func assert(b bool) {
	if !b {
		panic()
	}
}
