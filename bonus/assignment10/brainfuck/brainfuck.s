.global brainfuck

format_str: .asciz "We should be executing the following code:\n%s\n\n"
output: .asciz "%c"
end: .asciz "\n\n"

jumptable:
	.quad case0Add
	.quad case1Scan
	.quad case2Sub
	.quad case3Print
	#13 invalid cases:
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
	.quad case17Left
	.quad caseInvalid
	.quad case19Right
	#another 28 invalid cases:
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
		.quad caseInvalid
	.quad case48OpenLoop
	.quad caseInvalid
	.quad case50CloseLoop
cases:
	case0Add:
		movq $0, %rax
		movb (%r12), %al
		inc %rax
		movb %al, (%r12)

		jmp instruction_done

	case1Scan:
		jmp instruction_done

	case2Sub:
		movq $0, %rax
		movb (%r12), %al
		dec %rax
		movb %al, (%r12)

		jmp instruction_done

	case3Print:

		movq $0, %rax
		movb (%r12), %al
		mov %rax, %rsi
		mov $output, %rdi
		call printf

		jmp instruction_done

	case17Left:
		
		addq $1, %r12
		jmp instruction_done

	case19Right:
		
		
		subq $1, %r12
		jmp instruction_done

	case48OpenLoop:
		
	
		jmp instruction_done

	case50CloseLoop:
		
	
		jmp instruction_done

	caseInvalid:
		jmp instruction_done

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	# Save instruction pointer into rbx
	movq %rdi, %rbx

	# Print the initial message
	movq %rdi, %rsi
	movq $format_str, %rdi
	call printf
	movq $0, %rax

	pushq $0
	pushq $0

	movq %rsp, %r12 	# Tape pointer will be r12
	jmp make_space	# Move rsp down 30000 bytes
	make_space_end:

	subq $1, %rbx	# decrement this bc we are incrementing it in the beginning of loop

	insruction_loop:
		# If tape pointer has reached rsp, allocate more tape

		# Increment instruction pointer
		addq $1, %rbx

		# If null character, end loop
		cmpb $0, (%rbx)
		je instruction_loop_end

		# Get the character into rax and subtract 43 from it
		movq $0, %rax
		movb (%rbx), %al
		subq $43, %rax

		# Call the different cases for instructions
		shlq $3, %rax
		movq jumptable(%rax), %rax
		jmp *%rax

		instruction_done:
		jmp insruction_loop
	instruction_loop_end:

	movq $end, %rdi
	call printf

	movq %rbp, %rsp
	popq %rbp
	ret



/*extend_tape:
	# counter
	movq $0, %r9
	loop:
		cmpq $16, %r9
		je extend_tape_end

		subq $1, %rsp
		movb $0, (%rsp)

		inc %r9
	jmp loop */


make_space:
	movq $0, %r9
	loop1:
		cmpq $3750, %r9
		je make_space_end

		pushq $0

		inc %r9
	jmp loop1
