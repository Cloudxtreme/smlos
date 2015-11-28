# System calls

```
// For testing
0: func putc(v int) (err int)

// Process
1: func exit(ret int)
2: func exec(cmd *string, c *execConfig) (pid int, err int)
3: func join(pid int) (ret int, err int) // optional

type execConfig struct {
    args []string
    joinable bool
}

// IO (0 is stdin, 1 is stdout)
4: func write(fd int, buf *[]byte) (n int, err int)
5: func read(fd int, buf *[]byte) (n int, err int)
6: func close(fd int) // optional

// (optional) IPC
7: func ipcConnect(pid int, port int) (fd int, err int)
8: func ipcListen(port int) (fd int, err int)
9: func ipcAccept(fd int) (fd int, err int)

// (optional) Fork and pipe
10: func fork() (pid int, err int)
11: func pipe() (in, out int, err int)

// (optional) Threading
12: func threadStart(f func(arg uint), arg uint) (tid int, err int)
13: func threadJoin(tid int) (ret int, err int)
14: func yield()

```
