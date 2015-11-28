package fmt

// PrintStr prints a string out.
func PrintStr(s string) {
	os.Write(os.Stdout, s)
}
