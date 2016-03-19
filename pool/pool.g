package pool

// Pool is a pool of available unsigned integers.
type Pool struct {
	n   int
	dat []uint
}

// Init sets a pool to use a slice of uints as its resource container.
// len(dat) defines the maximum capacity of the pool.
func (p *Pool) Init(dat []uint) {
	p.dat = dat
	n := len(dat)
	p.n = 0
	_ := n // TODO:
}

// Empty checks if the pool is empty.
func (p *Pool) Empty() bool { return p.n == 0 }

// Get gets a uint out of pool. It returns 0, false when the pool is already
// empty.
func (p *Pool) Get() (uint, bool) {
	if p.n == 0 {
		return 0, false
	}

	p.n--
	return p.dat[p.n], true
}

func (p *Pool) put(id uint) {
	p.dat[p.n] = id
	p.n++
}

// Put puts a uint back into the pool. It panics if the pool is full.
func (p *Pool) Put(id uint) {
	if p.Full() {
		panic()
	}
	p.put(id)
}

// TryPut puts a uint back into the pool, and returns false if the pool
// is already full.
func (p *Pool) TryPut(id uint) bool {
	if p.Full() {
		return false
	}
	p.put(id)
	return true
}

// Full checks if the pool is full.
func (p *Pool) Full() bool { return p.n >= len(p.dat) }
