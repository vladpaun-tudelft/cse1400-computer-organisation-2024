.text

succes_out: .asciz "valid"
fail_out: .asciz "invalid"

.include "basic.s"

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

	pushq $9000				# Push a control value to check if we ve closed all brackets at the end
	subq $8, %rsp			# Keep stack 16-aligned

	subq $1, %rdi			# the loop increments rdi at the beginning, so subtract one now so it d fine

	start:
	addq $1, %rdi			# Increment rdi, which means move to the next character

	movq $0, %rax			# Clear rax
	movb (%rdi), %al		# Move the current character at rdi, into the least segnificant byte of rax. Our characters ascii is now in rax

	# Case for null character
	cmpq $0, %rax			# If it's the null character, we've reached the end of the string, end the loop		
	je end_loop

	# Cases for open brackets
	cmpq $40, %rax			# If it's '(', push it
	je push_case

	cmpq $60, %rax			# If it's '<', push it
	je push_case

	cmpq $91, %rax			# If it's '[', push it
	je push_case

	cmpq $123, %rax			# If it's '{', push it
	je push_case

	# Cases for closed brackets
	cmpq $41, %rax			# If it's ')', pop the last pushed thing and compare
	je pop_case

	cmpq $62, %rax			# If it's '>', pop the last pushed thing and compare
	je pop_case

	cmpq $93, %rax			# If it's ']', pop the last pushed thing and compare
	je pop_case

	cmpq $125, %rax			# If it's '}', pop the last pushed thing and compare
	je pop_case

	# If it's not an open or closed bracket, just move to next itieration
	jmp start

	push_case:				# Push the character, keep stack aligned, then continue to next iteration
		pushq %rax
		subq $8, %rsp
		jmp start

	pop_case:				# Compare the current character with the last pushed open bracked. Check if they are a valid pair
		addq $8, %rsp
		popq %rcx

		subq %rcx, %rax		# Subtract the ASCII values of the 2 characters

		cmpq $2, %rax		# If the difference between them is larger than 2, it is an invalid pair, return invalid
		jg error

		cmp $0, %rax		# If the difference between them is negative, it is an invalid pair, return invalid
		jl error

		jmp start

	end_loop:
	
	# At the start we pushed a control value.
		# Pop one more time and check if we are back at the control value. If we are not, there are still unclosed brackets.
	addq $8, %rsp			
	popq %rcx
	cmpq $9000, %rcx
	jne error

	# return 'valid'
	movq $succes_out, %rax

	jmp return

	error:

	# Return 'invalid'
	movq $fail_out, %rax

	jmp return

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

