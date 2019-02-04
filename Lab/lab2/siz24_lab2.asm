.data
	small: .byte 200
	medium: .half 400
	large: .word 0
	
	.eqv NUM_ITEMS 5
	values: .word 0:NUM_ITEMS
.text

.globl main
main: 
	lbu t0, small
	lh t1, medium
	lw a0, large
	mul a0, t0, t1
	li v0, 1
	syscall
	li a0, '\n'
	li v0, 11
	syscall
	
	push s0
	li s0, 0
ask_loop_top:
	blt s0, NUM_ITEMS, ask_loop_body
	j ask_loop_exit
ask_loop_body:
	la t0, values
	li t2, 4
	mul t1, s0, t2
	add t0, t0, t1
	
	li v0, 5
	syscall
		
	sw v0, (t0)
		
	add s0, s0, 1
	j ask_loop_top
ask_loop_exit:
	pop s0
