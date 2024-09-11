# *******************************************************************
# * Program: Factorial                                              *
# * Description: This program prints n factorial if n was the input *
# *******************************************************************

.data
n: .quad 0

.text
welcome: .asciz "\nWelcome to our exponentiator!\n"
prompt: .asciz "\nPlease enter one non negative number:\n\n"
input: .asciz "%ld"
output: .asciz "\n%ld\n\n"
error: .asciz "\nPlease give a valid input\n\n"

.global main

main:
    ### Prologue
    push %rbp
    mov %rsp, %rbp

    
    ### Get inputs

    # Display welcome message
    mov $welcome, %rdi
    call printf

    # Display message asking for an input
    mov $prompt, %rdi
    call printf

    # Get inputs with scanf
    mov $input, %rdi # Move formatted string into first argument
    lea n, %rsi # Load the first input provided into the 'n' label
    call scanf


    ### Edge cases for inputs

    # Check for negative number
    cmpq $0, n
    jl errorcode


    ### Call the factorial subroutine

    mov n, %rdi # Load the base into the first paramater register
    call factorial


    end:
    ### Print the result

    mov $output, %rdi # Load formatted string into first argument of printf
    mov %rax, %rsi # Load total (the return of the pow subroutine) into fourth argument of printf
    
    call printf


    ### Epilogue
    mov %rbp, %rsp
    pop %rbp

    ### Exit program

    mov $0, %rdi # exit code
    call exit

errorcode:
    ### Display error message and exit program with error code 1

    mov $error, %rdi
    call printf

    ### Epilogue
    mov %rbp, %rsp
    pop %rbp

    mov $1, %rdi
    call exit


# **********************************************************************************
# * Subroutine: factorial                                                          *
# * Description: this subroutine takes the one paramater and returns its factorial *
# * Parameters: (number) n                                                         *
# * Return value: n!                                                               *
# **********************************************************************************
/**
int factorial(int n) {
    if n == 0:
        return 1;
    return factorial(n-1) * n;
}
**/

factorial:
    ### Prologue

    push %rbp
    mov %rsp, %rbp

    # Always push n
    pushq %rdi
    subq $8, %rsp


    # If n is equal to zero, pop it back and replace it with a 1
    # Also, prepare to exit recursion by starting a running total in %rax  
    cmpq $0, %rdi
    je ifcode
    continue:

    # If n > 0; go to recursive case; else go to basecase
    cmpq $0, %rdi
    jg recursivecase
    jmp basecase

    # We already pushed n onto the stack, so now just decrement it and call the function again
    recursivecase:
    dec %rdi
    call factorial

    # Once n is 0, multiply the last thing on the stack with rax and leave it on rax, then return
    # This is why we changed the 0 to a 1 on the stack and why we set rax to 1
    # This part runs for every instance of the subroutine after the innermost one returns
    basecase:

    ### Multiplication
    addq $8, %rsp
    popq %rdi # Pop the last value on the stack into rbx
    mul %rdi # multiply that with the total on rax and leave it there

    ### Epilogue
    mov %rbp, %rsp
    pop %rbp

    ### Return
    ret

    ifcode:
    # If n = 0
    movq $1, -8(%rbp)
    movq $1, %rax # start the total into %rax
    jmp continue

