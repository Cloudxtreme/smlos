package fmt

// PrintChar prints a char to the console.
func PrintChar(c char) { printChar(c) }

// PrintStr prints a string to the console.
func PrintStr(s string) {
	for i := 0; i < len(s); i++ {
		PrintChar(s[i])
	}
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

	for n > 0 {
		n--
		PrintChar(buf[n])
	}
}

// Println prints an endline.
func Println() { PrintChar('\n') }
