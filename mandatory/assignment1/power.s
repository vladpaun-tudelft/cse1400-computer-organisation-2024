# **************************************************************************
# * Program: Exponentiator                                                 *
# * Description: This program prints the result of raising the first input *
# * to the power of the second input                                       *
# **************************************************************************

.data
base: .quad 0
exp: .quad 0

.text
welcome: .asciz "\nWelcome to our exponentiator!\n"
prompt: .asciz "\nPlease enter two non-negative numbers. A base and an exponent:\n\n"
input: .asciz "%ld%ld"
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
    lea base, %rsi # Load the first input provided into the 'base' label
    lea exp, %rdx # Load the second input provided into the 'exp' label
    call scanf


    ### Edge cases for inputs

    # Check for negative base
    cmpq $0, base
    jl errorcode

    # Check for negative exp
    cmpq $0, exp
    jl errorcode
    

    ### Call the pow subroutine to exponentiate the numbers

    mov base, %rdi # Load the base into the first paramater register
    mov exp, %rsi # Load the exp into the second paramater register
    call pow


    end:
    ### Print the result

    mov $output, %rdi # Load formatted string into first argument of printf
    mov %rax, %rsi # Load total (the return of the pow subroutine) into fourth argument of printf
    
    call printf


    ### Exit program

    mov $0, %rdi # exit code
    call exit

errorcode:
    ### Display error message and exit program with error code 1

    mov $error, %rdi
    call printf

    mov $1, %rdi
    call exit


# **************************************************************************
# * Subroutine: pow                                                        *
# * Description: this subroutine takes the two paramaters passed to it and *
# * exponentiates the first one to the power of the second                 *
# * Parameters: (number) base, (number) exponent                           *
# * Return value: (base ^ exponent) is saved in r15                        *
# **************************************************************************

pow:
    ### Prologue

    push %rbp
    mov %rsp, %rbp

    mov %rdi, %rax # Load the base into rax for the multiplication;


    ### Check if the exponent is zero and just return 1

    cmpq $0, %rsi
    je zerocode

    ### Loop conditions
    
    powloop:
    cmp $1, %rsi # while condition, comparing exp to 1
    jle powend # if condition is not met, jump to the end


    ### Multiplication of base and total
        ### The Total will stay in rax.

    mul %rdi # Multiply base by total


    ### Decrement the exp

    dec %rsi


    ### Jump to start of loop

    jmp powloop


    powend:

    ### Epilogue
    mov %rbp, %rsp
    pop %rbp

    ### Return
    ret


    zerocode:
    ### If exp is 0 than just return 1 and jump to powend

    mov $1, %rax
    jmp powend

