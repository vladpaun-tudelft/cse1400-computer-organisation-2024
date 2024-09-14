.text

succes_out: .asciz "\nProgram terminated succesfully. String is valid\n"
fail_out: .asciz "\nProgram failed. String is invalid\n"
char_out: .asciz "\n We are at char index: %ld. Character is: %c, Number: %ld.\n"
char_out_check: .asciz "\n We are at char index: %ld. Character is: %c, comparing it to: %c.\n"

.data
counter: .quad 0

.include "validParenthesesExamples/basic.s"

.global main

# *******************************************************************************************
# Subroutine: check_validity                                                                *
# Description: checks the validity of a string of parentheses as defined in Assignment 6.   *
# Parameters:                                                                               *
#   first: the string that should be check_validity                                         *
#   return: the result of the check, either "valid" or "invalid"                            *
# *******************************************************************************************
check_validity:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	# When we find an open bracket, push its ascii number to the stack.
	# When we find a closed bracket, pop the latest value from the stack.
	# 	Subtract the popped value from the current characters value.
	#	Check if the difference is 1 or 2. If it is, then we have a correct pair of brackets, keep going
	#	If difference is larger or is negative, we have an invalid pair, break tghe loop, exit the program
	
	loop1:
		movq $0, %rax
		movb (%rdi), %al

		cmpq $0, %rax
		je loop_break		# If char is '\n', end program

		cmpq $40, %rax 		# If char is '(', push '1' to stack
		je push_case

		cmpq $60, %rax		# If char is '<', push '2' to stack
		je push_case

		cmpq $91, %rax		# If char is '[', push '3' to stack
		je push_case

		cmpq $123, %rax		# If char is '{', push '4' to stack
		je push_case

		cmpq $41, %rax 		# If char is ')', go check validity
		je pop_case

		cmpq $62, %rax		# If char is '>', go check validity
		je pop_case

		cmpq $93, %rax		# If char is ']', go check validity
		je pop_case

		cmpq $125, %rax		# If char is '}', go check validity
		je pop_case

		jmp loop_end		# If the char is neither of these go to the next iteration of the loop and the next character

		push_case:
			push %rax
			subq $8, %rsp
			jmp loop_end

		pop_case:
			addq $8, %rsp
			popq %rcx

			subq %rcx, %rax
			cmpq $2, %rax
			jg invalid
			cmpq $0, %rax
			jl invalid
		
	loop_end:
		inc %rdi
		incq counter
		jmp loop1

	loop_break:
		mov $succes_out, %rdi
		call printf
		jmp return

	invalid:
		mov $fail_out, %rdi
		call printf

	return:
	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi		# first parameter: address of the message
	call	check_validity		# call check_validity

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

