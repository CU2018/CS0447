.data
hello_message: .asciiz "Hello World"
.text

print_int:
     li v0, 1
     syscall
     li a0, '\n'
     li v0, 11
     syscall
     jr ra
     
print_string:
    li v0, 4
    syscall
    li a0, '\n'
    li v0, 11
    syscall
    jr ra
    
print_123:
    push ra
    li a0, 1
    jal print_int
    li a0, 2
    jal print_int
    li a0, 3
    jal print_int
    pop ra
    jr ra

.globl main
main:
    jal print_123
    la a0, hello_message
    jal print_string
    li a0, 1234
    jal print_int
    li a0, 5678
    jal print_int
    
