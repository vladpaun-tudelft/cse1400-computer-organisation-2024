.global brainfuck

format_str: .asciz "We should be executing the following code:\n%s\n\n"
output: .asciz "%ld"
input: .asciz "%ld"
end: .asciz "\n\n"

reg12: .quad 0
reg13: .quad 0

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
        incb (%r12)
        jmp instruction_loop
    case1Scan:
		movq $input, %rdi
		movq %r12, %rsi
		call scanf
        jmp instruction_loop
    case2Sub:
        decb (%r12)
        jmp instruction_loop
    case3Print:

        movq $0, %rax
        movb (%r12), %al
        movq %rax, %rsi
        movq $output, %rdi
        call printf
        
        jmp instruction_loop
    case17Left:
        inc %r12
        jmp instruction_loop
    case19Right:
        dec %r12
        jmp instruction_loop
    case48OpenLoop:
		cmpb $0, (%r12)
		je skip
		jmp instruction_loop
	case50CloseLoop:
		cmpb $0, (%r12)
		jne go_back
		jmp instruction_loop
	caseInvalid:
		jmp instruction_loop

	
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
		endif1:
		jmp skip_loop

go_back:
	movq $-1, %r8
	go_back_loop:
		cmpq $0, %r8
		je instruction_loop

		decq %r13
		cmpb $91, (%r13)
		je ifcode2
		je elifcode2
		endif2:
		jmp go_back_loop

ifcode1:
	incq %r8
	jmp endif1
elifcode1:
	decq %r8
	jmp endif1

ifcode2:
	incq %r8
	jmp endif2
elifcode2:
	decq %r8
	jmp endif2


# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

    # Save callee-saved registers into memory
    # movq %r12, reg12
    # movq %r13, reg13

    # Save instruction pointer into r13
    movq %rdi, %r13

    # Print the initial message
	movq %rdi, %rsi
	movq $format_str, %rdi
	call printf
	movq $0, %rax

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

    # If nnull cgharacter, end
    cmpb $0, (%r13)
    je instruction_loop_end

    # Move current instruction into rax
    movq $0, %rax
    movb (%r13), %al

    # Treat the instruction in excess 43
    subq $43, %rax

    # Call the different cases for instructions using a jumptable
	shlq $3, %rax
	movq jumptable(%rax), %rax
	jmp *%rax


    instruction_loop_end:

    movq $end, %rdi
	call printf

    # Reload callee-saved registers from memory
    # movq reg12, %r12
    # movq reg13, %r13

	movq %rbp, %rsp
	popq %rbp
	ret


