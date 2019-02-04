#siz24_lab4.asm
.data
	opcode: .asciiz "\nopcode = "
	rs: .asciiz "\nrs = "
	rt: .asciiz "\nrt = "
	immediate: .asciiz "\nimmediate = "

.text

encode_instruction:
	push	ra

	sll t0, a0, 26  #opcode: t0 = a0 << 26
	sll t1, a1, 21  #rs: t1 = a1 << 21
	sll t2, a2, 16  #rt: t2 = a2 << 16
	#sll t3, a3, 0 cannot do this
	#no need to shift immediate, it's 0, but need a 
	#16-bit mask to turn off the 16 bits before it
	and t3, a3, 0xFFFF
	#ORING
	or t0, t0, t1  #opcode + rs
	or t1, t2, t3  #rt + immediate
	or a0, t0, t1  #opcode + rs + rt + immediate
	#prints a hex number
	li v0, 34  
	syscall
	#newline
	li a0, '\n' 
	li v0, 11
	syscall

	pop	ra
	jr	ra

decode_instruction:
	push	ra
	push 	s0
	
	move s0, a0  #reuse a0, move it to s0 to store
	
	la a0, opcode
	li v0, 4   #print string
	syscall
	srl t0, s0, 26 #optcode: t0 = s0 >> 26, 6 bits
	and a0, t0, 0x3F  #6-bit mask
	li v0, 1   #print int
	syscall 

	la a0, rs
	li v0, 4   #print string
	syscall
	srl t0, s0, 21 #optcode: t0 = s0 >> 21, 5 bits
	and a0, t0, 0x1F  #5-bit mask
	li v0, 1   #print int
	syscall 
	
	la a0, rt
	li v0, 4   #print string
	syscall
	srl t0, s0, 16 #optcode: t0 = s0 >> 16, 5 bits
	and a0, t0, 0x1F  #5-bit mask
	li v0, 1   #print int
	syscall 
	
	la a0, immediate
	li v0, 4   #print string
	syscall
	and t0, s0, 0xFFFF #immediate, 16-bit mask
	#handle the sign problem
	sll t0, t0, 16
	sra t0, t0, 16
	move a0, t0
	li v0, 1   #print int
	syscall 

	pop 	s0
	pop	ra
	jr	ra

.globl main
main:
	# addi t0, s1, 123
	li	a0, 8
	li	a1, 17
	li	a2, 8
	li	a3, 0x7B # 123 in hex
	jal	encode_instruction

	# beq t0, zero, -8
	li	a0, 4
	li	a1, 8
	li	a2, 0
	li	a3, -8
	jal	encode_instruction

	li	a0, 0x2228007B
	jal	decode_instruction

	li	a0, '\n'
	li	v0, 11
	syscall

	li	a0, 0x1100fff8
	jal	decode_instruction

	# exit the program
	li	v0, 10
	syscall

