.section .data
file1: .asciz "abca\n11\n123"
file2: .asciz "12345\n11\n456"

null_flag: .byte 0


.text
.global main

usage_format: .asciz "usage: %s <flag 1> <flag 2>\n"

# Format for printing the thing
    # Param1: addres of format string
    # Param2: line 1 no
    # Param3: line 2 no
    # Param4: pointer of line1
    # Param5: pointer of line2
print_format: .asciz "%uc%u\n< %s\n---\n> %s\n"



# Our main function will be called with two arguments:
# main(int argc, char * * argv)
#   - argc holds the number of command line arguments.
#   - argv holds the address of an array of strings.
#
# Keep in mind that strings themselves are the address of their first character.
# So argv[0] holds the address of the first character of the first argument
# and argv[1] holds the address of the first character of the second argument.
#
# You always get a free argument that holds the name used to invoke the executable.
# This argument is always argv[0] and it counts for argc (which is thus always 1 or greater).
# If you are expecting exactly one additional command line argument,
# argc should be 1,2 or 3 and the argument in question will be at argv[1].
main:
	pushq %rbp
	movq %rsp, %rbp

	# Make sure we got one argument.
	# The first argument is always the name of our program, so we want a second argument.
	cmp $1, %rdi
	jl wrong_argc

    # Clear the flags
    movq $0, %rdx
    movq $0, %rcx

    # If there are exactly 3 arguments, set both flags
    cmpq $3, %rdi
    jg wrong_argc
    je set_both_flags

    # If there are exactly 2 arguments, parse the flag 
    cmpq $2, %rdi
    je parse_flag

    call_diff:
    # move the two files into the first 2 arguments and call diff
    movq $file1, %rdi
    movq $file2, %rsi
    call diff


	# Return success.
	# Unless of course you made us segfault?
	mov $0, %rax
	movq %rbp, %rsp
	popq %rbp
	ret

parse_flag:
    

    # See which flag is at the second char of the second argument, if it is i, or b, set their respective flag to true
    movq 8(%rsi), %rax
    incq %rax
    cmpb $'i', (%rax)
    je set_case
    cmpb $'B', (%rax)
    je set_line

    jmp wrong_argc

set_case:
    # Set case flag to 1 and call diff
    movq $1, %rdx
    jmp call_diff

set_line:
    # Set line flag to 1 and call diff
    movq $1, %rcx
    jmp call_diff
set_both_flags:
    # Set both flags and call diff
    movq $1, %rdx
    movq $1, %rcx
    jmp call_diff


wrong_argc:
	movq $usage_format, %rdi
	movq (%rsi), %rsi # %rsi still hold argv up to this point
	call printf

failed:
	movq $1, %rax

	movq %rbp, %rsp
	popq %rbp
	ret

diff:
    # Prologue
    pushq %rbp
    movq %rsp, %rbp

    pushq %rbx
    subq $8, %rsp

    # deal with flags ...

    # Copy pointers of files into 2 registers
    movq %rdi, %r10
    movq %rsi, %r11

    # Flag for if there is a difference in lines is in memory
    # Counter for line number
    movq $0, %rbx

    lines_loop:
        cmpb $1, null_flag
        je end_lines_loop
        # New line, increment rbx
        incq %rbx
        # get the new start pointers of the start of the next line
        movq %r10, %rdi
        movq %r11, %rsi


        string_loop:
            # Compare the 2 characters and set flag accordingly
            movq $0, %rax
            movb (%r10), %al
            cmpb %al, (%r11)
            jne print_stuff

            # Increment the pointers
            incq %r10
            incq %r11

            # If the characters are equal and they are \n, go to the next line
            cmpb $'\n', %al
            je lines_loop
            cmpb $0, %al
            je end_lines_loop
            jmp string_loop
        end_string_loop:
        # Search for diff
        # If diff set a flag for printing
        # Keep going untill you reach a '\n'
        # let the other pointer also reach a '\n'
        # If flag, print from rdi and rsi
        # Set rdi and rsi to be r10 and r11
        
    end_lines_loop:

    addq $8, %rsp
    popq %rbx

    # Epilogue
    movq %rbp, %rsp
    popq %rbp

    ret

print_stuff:
    # Go through line 1, find the first \n, replace it with a null character, give the initial address of it to printf and save the first char of the next line in r10
    movq %rdi, %r10
    l1:
        cmpb $'\n', (%r10)
        je end_l1
        cmpb $0, (%r10)
        jne continue1
            movq $1, null_flag
            jmp end_l1
        continue1:
        incq %r10
        jmp l1
    end_l1:
        movb $0, (%r10) 
        incq %r10
        pushq %r10
        # Param4: Pointer of line 1 into rcx
        movq %rdi, %rcx

    # Go through line 2, find the first \n, replace it with a null character, give the initial address of it to printf and save the first char of the next line in r11
    movq %rsi, %r11
    l2:
        cmpb $'\n', (%r11)
        je end_l2
        cmpb $0, (%r11)
        jne continue2
            movq $1, null_flag
            jmp end_l2
        continue2:
        incq %r11
        jmp l2
    end_l2:
        
        movb $0, (%r11)
        incq %r11
        pushq %r11
        # Param5: Pointer of line 2 into r8
        movq %rsi, %r8
    # Param1
    movq $print_format, %rdi
    # Param 2
    movq %rbx, %rsi
    # param 3
    movq %rbx, %rdx
    
    call printf

    popq %r11
    popq %r10
    
    jmp lines_loop

