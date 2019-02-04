.data  #data segment
hello_message: .asciiz "Hello World!"

.text #.data and .text == switch to the data and text(code) segment, must switch back after to write more
#----------------------------------------------------
print_int:
    li v0, 1  #print integer, == System.out.print() in java
    syscall
    li a0, '\n'
    li v0, 11
    syscall
    jr ra #"return" instruction; == "jump register"
#----------------------------------------------------
print_string:
    li v0, 4
    syscall
    li a0, '\n'
    li v0, 11
    syscall
    jr ra
#----------------------------------------------------
print_123: #nested function calls
    push ra
    li, a0, 1
    jal print_int
    li, a0, 2
    jal print_int
    li, a0, 3
    jal print_int
    pop ra
    jr ra
#----------------------------------------------------
.globl main #the .globl directive is only needed for main. Most of our functions won't need it
main: #main is a label
    jal print_123
    la a0, hello_message #la == "load address", cannot use (li)load immediate
    jal print_string
    li a0, 1234 #li = loading immediate(a constant that is written inside the instruction), 
                #put a constant variable into a register; a0, arguement register,a function call is about to happen, print_int(1234)
    jal print_int #"jump and link"
    li a0, 5678 #since print_int take one arguement from a0
    jal print_int #call the function

    
