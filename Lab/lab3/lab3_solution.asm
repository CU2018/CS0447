# Solution to lab 3

.data

.eqv ARRAY_LENGTH 10
array: .word 100 200 300 400 500 600 700 800 900 1000

.text
# -----------------------------------------------
.globl main
main:
	###################################################################
	# SOLUTION 1: should use a0, not a1.

	# print_int(45)
	li	a0, 45
	jal	print_int

	###################################################################
	# SOLUTION 2: the value needs to be copied from v0 to a0.

	# print_int(read_int())
	jal	read_int
	move	a0, v0
	jal	print_int

	###################################################################
	# SOLUTION 3: read_int_plus_one needs to push/pop ra.

	# read_int_plus_one()
	jal	read_int_plus_one

	###################################################################
	# SOLUTION 4: 'a' registers do not keep their values across a jal.

	# print_int_plus_one(4)
	# print_int_plus_one(4)
	li	a0, 4
	jal	print_int_plus_one
	li	a0, 4 # MUST reload a0 with the value we want to print.
	jal	print_int_plus_one

	###################################################################
	# SOLUTION 5: change_array forgot to add the address to the index.

	# change_array()
	jal	change_array

	###################################################################
	# SOLUTION 6: print_array used a 't' register as its loop counter.

	# print_array()
	jal	print_array

	###################################################################
	# exit()
	li	v0, 10
	syscall

# -----------------------------------------------
# void print_int(int x)
print_int:
	li	v0, 1
	syscall
	li	a0, '\n'
	li	v0, 11
	syscall
	jr	ra

# -----------------------------------------------
# int read_int()
read_int:
	li	v0, 5
	syscall
	jr	ra

# -----------------------------------------------
# int read_int_plus_one()
read_int_plus_one:
	push	ra # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< oops, forgot this
	jal	read_int
	add	v0, v0, 1
	pop	ra # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< oops, forgot this
	jr	ra

# -----------------------------------------------
# int print_int_plus_one()
print_int_plus_one:
	push	ra

	add	a0, a0, 1
	jal	print_int

	pop	ra
	jr	ra

# -----------------------------------------------
# void change_array()
change_array:
	# i = t0
	# for(i = 0; i < ARRAY_LENGTH; i++) {
	li	t0, 0
_change_array_loop:
	bge	t0, ARRAY_LENGTH, _change_array_loop_exit

		# array[i]++
		la	t1, array # array + (i * 4)
		mul	t2, t0, 4
		add	t2, t2, t1 # <<<<<<<<<<<<<<<<<<<< oops, forgot this
		lw	t1, (t2)
		add	t1, t1, 1
		sw	t1, (t2)

	# }
	add	t0, t0, 1
	j	_change_array_loop
_change_array_loop_exit:
	jr	ra

# -----------------------------------------------
# void print_array()
print_array:
	push	ra
	push	s0 # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< must do this!

	# i = s0 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< we're using s0 for i instead.
	# for(i = 0; i < ARRAY_LENGTH; i++) {
	li	s0, 0
_print_array_loop:
	bge	s0, ARRAY_LENGTH, _print_array_loop_exit

		# print_array_item(i)
		move	a0, s0
		jal	print_array_item

	# }
	add	s0, s0, 1
	j	_print_array_loop
_print_array_loop_exit:
	pop	s0 # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< must do this!
	pop	ra
	jr	ra

# -----------------------------------------------
# void print_array_item(int i)
print_array_item:
	push	ra

	# print_int(array[i])
	la	t0, array
	mul	a0, a0, 4
	add	t0, t0, a0
	lw	a0, (t0)
	jal	print_int

	pop	ra
	jr	ra