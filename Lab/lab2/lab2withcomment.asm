.data 
	small: .byte 200
	medium: .half 400
	large: .word 0
	
	.eqv NUM_ITEMS 5 #like #define in C, name a constant
	values: .word 0:NUM_ITEMS #make an array containing 5 0's
.text

.globl main
main:
	lbu t0, small  #zero extension: lbu vs. signed extension: lb
	lh t1, medium
	lw a0, large
	mul a0, t0, t1
	li v0, 1
	syscall
	
	li a0, '\n'
	li v0, 11
	syscall
	
	push s0 #when using s0 as a counter, push it before the loop
	li s0, 0 #the comparing variable and the offset of the arr
ask_loop_top:  #while(...)
	blt s0, NUM_ITEMS, ask_loop_body  #if(s0 < NUM_ITEMS)->body
	j ask_loop_exit #if(s0 >= NUM_ITEMS)->exit
ask_loop_body:
	la t0, values #load address of an array; t0 is A in A+B*i
	li t2, 4 #a word is 4 bytes; t2 is B in A+B*i 
	mul t1, s0, t2 #s0 i in A + B*i; t1 is B*i
	add t0, t0, t1 #now t0 is at the first address of an element
	
	li v0, 5 #get the number from user
	syscall
		
	sw v0, (t0) #put user's input(vo) into the t0 position, sw is left-->right
		
	add s0, s0, 1  #s0++
	j ask_loop_top
ask_loop_exit:  #codes after the loop
	pop s0 #pop the s0 back and next time it will still be 0 when being used as a counter