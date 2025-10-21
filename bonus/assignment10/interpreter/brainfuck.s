.global brainfuck

put: .asciz "%c"

jumptable:
	#43 invalid cases:
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
    .quad case43Add
	.quad case44Scan
	.quad case45Sub
	.quad case46Print
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
    .quad case60Left
	.quad caseInvalid
	.quad case62Right
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
    .quad case91OpenLoop
	.quad caseInvalid
	.quad case93CloseLoop
	#28 invalid cases:
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

cases:
    case43Add:
        incb (%r12)
        jmp instruction_loop
    case44Scan:
		# Syscall number (0 for read)
		mov $0, %rax

		# File descriptor (0 for stdin)
		mov $0, %rdi

		# Address to store the byte (for example, %r12)
		mov %r12, %rsi

		# Read 1 byte
		mov $1, %rdx

		# Make the syscall
		syscall

        jmp instruction_loop
    case45Sub:
        decb (%r12)
        jmp instruction_loop
    case46Print:

		# Syscall number (1 for write)
		movq $1, %rax

		# File descriptor (1 for stdout)
		movq $1, %rdi

		# Address of the character to print
		movq %r12, %rsi

		# Length (1 byte)
		movq $1, %rdx

		# Make the syscall
		syscall
        
        jmp instruction_loop
    case60Left:
        inc %r12
        jmp instruction_loop
    case62Right:
        dec %r12
        jmp instruction_loop
    case91OpenLoop:
		cmpb $0, (%r12)
		je skip
		jmp instruction_loop
	case93CloseLoop:
		cmpb $0, (%r12)
		jne go_back
		jmp instruction_loop
	caseInvalid:
		jmp instruction_loop
	
looping:
	skip:
		movq $1, %r8
		skip_loop:
			cmpq $0, %r8
			je instruction_loop

			incq %r13
			cmpb $91, (%r13)
			je ifcode1
			cmpb $93, (%r13)
			je elifcode1
			
			jmp skip_loop

	go_back:
		movq $-1, %r8
		go_back_loop:
			cmpq $0, %r8
			je instruction_loop

			decq %r13
			cmpb $91, (%r13)
			je ifcode2
			cmpb $93, (%r13)
			je elifcode2
			
			jmp go_back_loop

	ifcode1:
		incq %r8
		jmp skip_loop
	elifcode1:
		decq %r8
		jmp skip_loop

	ifcode2:
		incq %r8
		jmp go_back_loop
	elifcode2:
		decq %r8
		jmp go_back_loop


# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

    # Save callee-saved registers into stack
    pushq %r12
	pushq %r13

    # Save instruction pointer into r13
    movq %rdi, %r13

    pushq $0
    pushq $0

    # Save our tape pointer into %r12
    movq %rsp, %r12

    # Create the 30000 byte tape
        movq $0, %r8
        loop1:
            cmpq $3750, %r8
            je loop1_end

            pushq $0

            inc %r8
        jmp loop1
        loop1_end:
    

    subq $1, %r13
    instruction_loop:
    # Increment instruction pointer
    addq $1, %r13

    # If null cgharacter, end
    cmpb $0, (%r13)
    je instruction_loop_end


    # Move current instruction into rax
    movq $0, %rax
    movb (%r13), %al


    # Call the different cases for instructions using a jumptable
	shlq $3, %rax
	movq jumptable(%rax), %rax
	jmp *%rax


    instruction_loop_end:

    # Reload callee-saved registers from stack
    movq -8(%rbp), %r12
    movq -16(%rbp), %r13

	movq %rbp, %rsp
	popq %rbp
	ret


