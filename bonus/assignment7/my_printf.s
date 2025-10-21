.section .data
str: .asciz "aufgalidbfi %u, %s, %d, %%, %r"
percent: .asciz "%"
minus: .asciz "-"

str2: .asciz "test"


buffer: .space 20

str_address: .quad 0
next_str_address: .quad 0
specifier_value: .byte 0

.section .text

.global main

main:

    ### Prologue
    push %rbp
    mov %rsp, %rbp

    movq $str, %rdi
    movq $5, %rsi
    movq $str2, %rdx
    movq $-7, %rcx

    call my_printf


    ### Epilogue
    mov %rbp, %rsp
    pop %rbp

    ### Exit call
    movq $60, %rax
    movq $0, %rdi
    syscall


my_printf:

    ### Prologue
    push %rbp
    movq %rsp, %rbp


    movq %rdi, str_address  # Save string address

    # Push all the params to stack in reverse order
    
    pushq %r9
    movq $0, %r9
    
    pushq %r8
    
    pushq %rcx
    
    pushq %rdx
    
    pushq %rsi
    


    # Counter for concatenation
    movq $0, %r8             # This will act as a flag to restart printing

    my_printf_loop:

    cmpq $5, %r9
    jne kys

    addq $16, %rsp
    kys:

    # Initialize counter (for length)
    movq str_address, %rdi
    movq $0, %rax
    l1:
        # Check for null char
        cmpb $0, (%rdi)
        je end_l1
        

        # Check for format specifier ('%')
        cmpb $37, (%rdi)
        je specifier
        specifier_end:

        # Increment counter
        inc %rax

        # Go to next char
        inc %rdi

        jmp l1
    end_l1:

    # Length to print (in %rdx)
    movq %rax, %rdx

    # Address of the character to print (from str_address)
    movq str_address, %rsi
    # Syscall number (1 for write)
    movq $1, %rax
    # File descriptor (1 for stdout)
    movq $1, %rdi
    # Make the syscall
    syscall


    # If the specifier flag was set, continue printing
    cmpq $0, %r8
    jne start_again


    ### Epilogue
    movq %rbp, %rsp
    pop %rbp

    ret

specifier:
    cmpb $37, 1(%rdi)
    je specifier_cont
    cmpb $100, 1(%rdi)
    je specifier_cont
    cmpb $115, 1(%rdi)
    je specifier_cont
    cmpb $117, 1(%rdi)
    je specifier_cont

    inc %rdi
    inc %rax

    jmp l1

    specifier_cont:
    # Place a null character at '%', end the current string
    movb $0, (%rdi)

    # Set flag to indicate specifier was found
    inc %r8

    incq %rdi

    # Current character is the specifier, save it to a label
    movb (%rdi), %r10b
    movb %r10b, specifier_value


    incq %rdi
    movq %rdi, next_str_address

    # Skip the specifier (assuming it's one character long, adjust if needed)
    jmp end_l1

start_again:

    # Clear the number buffer
    movq $19, %r10
    l4:
        movb $0, buffer(%r10)
        decq %r10

        cmpq $0, %r10
        jne l4


    # Deal with specifier
    cmpb $37, specifier_value
    je print_percent
    cmpb $100, specifier_value
    je print_signed_int
    cmpb $115, specifier_value
    je print_string
    cmpb $117, specifier_value
    je print_unsigned_int

    start_again_cont:

    # Prepare to print the rest of the string
    decq %r8                # Reset flag
    movq next_str_address, %rax
    movq %rax, str_address   # Move str_address to the character after '%'
    jmp my_printf_loop

print_percent:
    # Length to print (in %rdx)
    movq $1, %rdx

    # Address of the character to print (from str_address)
    movq $percent, %rsi
    # Syscall number (1 for write)
    movq $1, %rax
    # File descriptor (1 for stdout)
    movq $1, %rdi
    # Make the syscall
    syscall

    jmp start_again_cont

print_signed_int:

    movq (%rsp), %r11

    shr $63, %r11
    cmpq $1, %r11
    jne print_unsigned_int

    # Length to print (in %rdx)
    movq $1, %rdx

    # Address of the character to print (from str_address)
    movq $minus, %rsi
    # Syscall number (1 for write)
    movq $1, %rax
    # File descriptor (1 for stdout)
    movq $1, %rdi
    # Make the syscall
    syscall

    
    popq %r11

    subq $1, %r11
    xor $-1, %r11
    
    pushq %r11
    

print_unsigned_int:
    # Get the number into rax
    popq %rax
    incq %r9

    # Get the last byte of my buffer so i can start populating it
    movq $buffer, %r10
    addq $19, %r10

    # Divisor so i can do n / 10 and n % 10
    movq $10, %rdi

    # Counter for number of bytes to print
    movq $0, %r11

    l3:
        # Do n / 10 and n % 10
        movq $0, %rdx
        div %rdi
        
        # Add n%10 + 48 to the last byte of the buffer
        addb $48, %dl
        movb %dl, (%r10)

        # Move back one byte in the buffer
        decq %r10

        #Increment lnegth by 1 byte
        incq %r11

        # Check if the number is 0
        cmpq $0, %rax
        jne l3
    l3_end:

        # Syscall number (1 for write)
		movq $1, %rax

		# File descriptor (1 for stdout)
		movq $1, %rdi

		# Address of the character to print uis r10 + 1
        incq %r10
		movq %r10, %rsi

		# Length (r11 )
		movq %r11, %rdx

		# Make the syscall
		syscall

    jmp start_again_cont
print_string:
    # Address of the string to print
    
    popq %rsi
    incq %r9

    movq %rsi, %r10
    movq $0, %rdx
    l5:
        cmpb $0, (%r10)
        je l5_end

        inc %rdx
        inc %r10
        jmp l5

    l5_end:

    # Syscall number (1 for write)
    movq $1, %rax
    # File descriptor (1 for stdout)
    movq $1, %rdi
    # Make the syscall
    syscall
    jmp start_again_cont
