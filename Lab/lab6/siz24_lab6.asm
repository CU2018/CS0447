.include "led_keypad.asm"

.data
	dot_x: .word 32
	dot_y: .word 32
	colors: .byte 4
	.eqv WAIT 15
	.eqv BOUND 0x3F

.text

.globl main
main:

_main_loop:
	#1. wait for a little while (wait for milliseconds)
	li a0, WAIT
	li v0, 32
	syscall
	#2. check for user inputs
	jal check_for_input
	#3. respond to those inputs by updating your program state (“state” means “your variables, data structures, etc.”)
	jal draw_dot
	#4. change the output (screen) to reflect the new state	
	jal display_update_and_clear
	#jal display_update  #--> drawing lines
	#5. loop back to step 1
	j _main_loop
	
	
draw_dot:
	push ra
	#display_set_pixel(dot_x, dot_y, COLOR_WHATEVER);
	
	lw a0, dot_x
	lw a1, dot_y
	
	lbu a2, colors
	jal display_set_pixel
	
	pop ra
	jr ra
	
check_for_input:
	push ra
	#v0 = input_get_keys()
	jal input_get_keys
	
	
	#if((v0 & KEY_L) != 0) // bitwise AND!
	#    dot_x--;
condition_l:
	and t0, v0, KEY_L #(v0 & KEY_L)
	beq t0, 0, condition_r
	jal decrement_x
	#if((v0 & KEY_R) != 0) // KEY_L, KEY_R etc. are constants.
	#    dot_x++;
condition_r:
	and t0, v0, KEY_R #(v0 & KEY_R)
	beq t0, 0, condition_u
	jal increment_x
	#if((v0 & KEY_U) != 0) // use the constant names.
	#    dot_y--;
condition_u:
	and t0, v0, KEY_U #(v0 & KEY_U)
	beq t0, 0, condition_d
	jal decrement_y
	#if((v0 & KEY_D) != 0) // don't hardcode the values.
	#    dot_y++;
condition_d:
	and t0, v0, KEY_D #(v0 & KEY_D)
	beq t0, 0, condition_b
	jal increment_y
	
condition_b:
	and t0, v0, KEY_B
	beq t0, 0, check_bound
	jal change_color

	#dot_x = dot_x & 63; // bitwise AND!
	#dot_y = dot_y & 63;
check_bound:
	lw t0, dot_x
	lw t1, dot_y
	and t0, t0, BOUND
	and t1, t1, BOUND
	sw t0, dot_x
	sw t1, dot_y
	
_check_exit:	
	pop ra
	jr ra
	
increment_x:
	push ra
	
	lw t0, dot_x
	add t0, t0, 1
	sw t0, dot_x
	
	pop ra
	jr ra
	
decrement_x:
	push ra
	
	lw t0, dot_x
	sub t0, t0, 1
	sw t0, dot_x
	
	pop ra
	jr ra

increment_y:
	push ra
	
	lw t0, dot_y
	add t0, t0, 1
	sw t0, dot_y
	
	pop ra
	jr ra
	
decrement_y:
	push ra
	
	lw t0, dot_y
	sub t0, t0, 1
	sw t0, dot_y
	
	pop ra
	jr ra

change_color:
	push ra
	
	#a AND (2^n  -1) = a % 2^n
	#colors = (colors+1)%8
	#if need to the color to change once every time pressing B and following the order in led_keypad
	#have to prolong the WAIT time, since the pressing time might be longer than the update, which makes
	#me change the color several times 
	lbu t0, colors
	add t0, t0, 1
	and t0, t0, 0x7
	sb t0, colors
	
	pop ra
	jr ra