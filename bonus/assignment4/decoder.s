.data
next: .quad 0
times: .quad 0
character: .quad 0
message_address: .quad 0
bg_color: .quad 0
fg_color: .quad 0

.text
output: .asciz "%c"
bg_fg_color_ansi_code: .asciz "\x1B[48;5;%ldm\x1B[38;5;%ldm"
ansi_reset: .asciz "\x1B[0m"
ansi_special: .asciz "\x1B[%ldm"

.include "final.s"

.global main

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value                                  *
# ************************************************************
decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	#Save the address of the message
	movq %rdi, message_address

	loop:

	# Set the memory address for the next call to get_values_from_address
		# We initialized next as 0 so this should be fine
	movq next, %rdi
	call get_next_address
	
	# Get the next values
	movq %rax, %rdi
	call get_values_from_address

		# Print the next characters 'times' times
		loop_inner:

		# Print using subroutine print_complex. Arguments are the character, the bg color and the fg color
		call print_complex

		decq times

		cmpq $0, times
		jg loop_inner

	
	# Keep following the breadcrumbs untill next is 0
	cmpq $0, next
	jne loop

	# Reset terminal
	movq $ansi_reset, %rdi
	call printf

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

get_values_from_address:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	# Clear labels in memory
	movq $0, character
	movq $0, times
	movq $0, next

	# Move the quad we are interested in into rax
	movq (%rdi), %rax

	# Get the least significant byte and save it into the next character label
	movq $0, %rdx 			# Clear rdx
	movb %al, %dl			# Move least significant byte (next character) into the least significant byte of rdx
	movq %rdx, character	# Save rdx into my character label

	# Get the second least significant byte and save it into the no. of times label
	mov $0, %rdx			# Clear rdx
	movb %ah, %dl			# Move the second least significant byte (no. of times) into the least significant byte of rdx
	movq %rdx, times		# Save rdx into my times label

	# Get Bytes 3-6 and save them to the next address label
	movq $0, %rdx			# Clear rdx
	shr $16, %rax			# Shift rax by 2 bytes, making the least significant 4 bytes the ones holding the next address
	movl %eax, %edx			# Move the least significant 4 bytes into rdx
	movq %rdx, next			# Save rdx into my next label

	# Get Bytes 1 and 2 and save them to the next color labels
	movq $0, %rdx			# Clear rdx
	shr $32, %rax			# Shift by another 4 bytes to now make the initial first 2 bites be the last 2 bytes in rax
	movb %al, %dl
	movq %rdx, fg_color	# Save the character color in label
	movq $0, %rdx			# Clear rdx
	movb %ah, %dl
	movq %rdx, bg_color		# Save background color in label


	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

get_next_address:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	# Set the next address to go to into rdi by doing ((next * 8) + memory_address)
	movq %rdi, %rax 			# Copy the next memory block into rax
	shlq $3, %rax 				# Multiply it by 8 by shifting left 3
	addq message_address, %rax	# Add the base address to this

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

print_complex:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer
	
	# See if the bg and fg values are the same. if they are, special treatment. if not, print the code to set colors
	movq fg_color, %rax
	cmpq %rax, bg_color	
	je special_codes

	movq $bg_fg_color_ansi_code, %rdi	# Print code for setting colors
	movq bg_color, %rsi
	movq fg_color, %rdx
	call printf
	jmp character_print 	# Jump over the special codes in this case

	special_codes:			# 7 cases for the 7 special codes in the specification

	cmpq $0, bg_color		
	je case0
	cmpq $37, bg_color
	je case37
	cmpq $42, bg_color
	je case42
	cmpq $66, bg_color
	je case66
	cmpq $105, bg_color
	je case105
	cmpq $153, bg_color
	je case153
	cmpq $182, bg_color
	je case182

		case0:
		movq $0, %rsi
		jmp print_special

		case37:
		movq $25, %rsi
		jmp print_special

		case42:
		movq $1, %rsi
		jmp print_special

		case66:
		movq $2, %rsi
		jmp print_special

		case105:
		movq $8, %rsi
		jmp print_special

		case153:
		movq $28, %rsi
		jmp print_special

		case182:
		movq $5, %rsi
		jmp print_special

		print_special:
		movq $ansi_special, %rdi
		call printf


	character_print:		# Print the character
	movq $output, %rdi
	movq character, %rsi
	call printf

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

