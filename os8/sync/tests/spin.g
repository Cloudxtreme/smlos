package tests

func spin(n int) {
	for i := 0; i < n; i++ {
		sync.Yield()
	}
}
