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

    ### Base Case Check

    # If n = 0; go to basecase
    cmpq $0, %rdi
    je basecase # Jump over all the steps in which you push and multiply

    ### Recursive case

    recursivecase:

    # Push n, 16-align stack, dec n, call factorial
    pushq %rdi
    subq $8, %rsp

    dec %rdi
    call factorial

    # When Returning from the function, multiply the last value on the stack into our running total in rax 

    ### Multiplication
    addq $8, %rsp # Keep stack aligned
    popq %rdi # Pop the last value on the stack into rdi
    mul %rdi # multiply that with the total on rax and leave it there
    jmp factorialend # jump over the initialization of the total in rax


    ### Base Case

    basecase:
    # When n = 0, only start the total and return
    movq $1, %rax # start the total into %rax

    factorialend:
    ### Epilogue
    mov %rbp, %rsp
    pop %rbp

    ### Return
    ret

