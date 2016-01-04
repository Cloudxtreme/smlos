package fmt

// PrintStr prints a string out.
func PrintStr(s string) {
	_, err := os.Write(os.Stdout, s)
	if err != 0 {
		panic()
	}
}

// PrintChar prints a single char out.
func PrintChar(c char) {
	var buf [1]char
	buf[0] = c
	PrintStr(buf[:])
}

// PrintInt prints out an integer
func PrintInt(i int) {
	if i < 0 {
		PrintChar('-')
		PrintInt(-i)
	} else {
		PrintUint(uint(i))
	}
}

// PrintUint prints out an unsigned integer.
func PrintUint(i uint) {
	if i == 0 {
		PrintChar('0')
		return
	}

	var buf [10]char
	n := 0
	for i > 0 {
		buf[n] = char(i%10) + '0'
		i /= 10
		n++
	}
	for i := 0; i < n/2; i++ {
		c := buf[i]
		buf[i] = buf[n-1-i]
		buf[n-1-i] = c
	}
	PrintStr(buf[:n])
}

// Println prints an endline.
func Println() { PrintChar('\n') }
