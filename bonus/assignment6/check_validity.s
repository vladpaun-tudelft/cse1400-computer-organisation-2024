.text

succes_out: .asciz "\nProgram terminated succesfully. String is valid\n"
fail_out: .asciz "\nProgram failed. String is invalid\n"

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
	#	If difference is larger or is negative, we have an invalid pair, break the loop, exit the program
	
	loop1:
		movq $0, %rax		# Clear rax
		movb (%rdi), %al	# The first byte at the address in rdi is the first character

		cmpq $0, %rax
		je loop_break		# If char is '\n', end program

		cmpq $40, %rax 		# If char is '(', push it to stack
		je push_case

		cmpq $60, %rax		# If char is '<', push it to stack
		je push_case

		cmpq $91, %rax		# If char is '[', push it to stack
		je push_case

		cmpq $123, %rax		# If char is '{', push it to stack
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

		push_case:			# Push the character to the stack then go to the nesxt iteration
			push %rax
			subq $8, %rsp	# Keep stack aligned
			jmp loop_end

		pop_case:			
			addq $8, %rsp	
			popq %rcx		# Pop the value into rcx and keep stack aligned

			subq %rcx, %rax	# Subtract the last open bracket char value from the current char value
			cmpq $2, %rax	# If it's bigger than 2 or negative, it is invalid
			jg invalid
			cmpq $0, %rax
			jl invalid
		
	loop_end:				# Move to next byte of string and loop
		inc %rdi
		jmp loop1

	loop_break:				# Print success message and return from subroutine
		mov $succes_out, %rdi
		call printf
		jmp return

	invalid:				# Print fail message and return from subroutine
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

