// Ientry saves the function pointer that points to the interrupt handler.
var Ientry {
    u32 0
}

// Sysentry save the function pointer that points to the system call handler.
var SysEntry {
    u32 0
}

// Syscall handler
func SysEnter {
    // sp is saved at sp[-4]
    addi sp sp -8
    sw ret sp 0 // save user ret
    addui r4 r0 SysEntry
    ori r4 r4 SysEntry
    lw r4 r4 0
    xor r0 r0 r0 // clear r0
	addi ret pc 4
    mov pc r4 // jump to the syscall function pointer now

    lw ret sp 0 // restore user ret
    lw sp sp 4 // restore user sp

    jruser ret // switch back to usermod and return
}

// Ustart starts a usermod process.
//  r1 - the start PC of the user program
//  r2 - the initial stack pointer of the user program
func Ustart {
    mov sp r2 // set the stack pointer to r2
    // hide our traces
    mov r3 r0
    mov r4 r0
    mov ret r0
    jruser r1 // switch to usermod and jump to r1
}

// Interrupt handler
func Ienter {
    // sp is saved at sp[-16]
    // ret is saved at sp[-12]
    // pc is saved in ret
    // the interrupt arg (fault addr) is saved at sp[-8]
    // the interrupt code is saved at sp[-4]
    // the ring is saved at sp[-3]

    // save the other registers
    addi sp sp -40
    sw r0 sp 0
    sw r1 sp 4
    sw r2 sp 8
    sw r3 sp 12
    sw r4 sp 16
    sw ret sp 20 // the return pc
    
    xor r0 r0 r0 // set r0 to zero
    mov r1 sp // first arg, the interrupt frame
    
    // load the function pointer
    addui r2 r0 Ientry
    ori r2 r2 Ientry
    lw r2 r2 0
    addi ret pc 4 // the return position, since not using jal
    mov pc r2 // jump to the function pointer now

    mov sp r1 // the return value is the iframe
    
    // restore the registers
    lw r0 sp 0
    lw r1 sp 4
    lw r2 sp 8
    lw r3 sp 12
    lw r4 sp 16
    lw ret sp 20
    addi sp sp 40
    iret
}

// Vtable sets the virtual machine table.
func Vtable {
	vtable r1
	mov pc ret
}

// Syscall performs a system call.
func Syscall {
	syscall
	mov pc ret
}

// Halt halts the system with halt exception
func Halt {
	halt
}
