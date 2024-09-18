.global brainfuck

format_str: .asciz "We should be executing the following code:\n%s\n"

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	movq %rdi, %rsi
	movq $format_str, %rdi
	call printf
	movq $0, %rax

	// Make a copy of rsp in r15.
	// Move rsp down 30.000 bytes to create space for our 'tape'
	// We will use r15 as our tape pointer


	// Copy the address of the program string in r14.
	// R14 will now be our instruction pointer
	// loop through the program string, incrementing the instruction pointer by one each iteration
	// If character is null character, terminate the loop
	// Switch case to find the current character
		// if char is '>', subtract one from tape pointer
		// if char is '<', add one to tape pointer
		// if char is '+', move value at tape pointer into rax, increment it, move it back
		// if char is '-', move value at tape pointer into rax, decrement it, move it back
		// if char is '.', move value at tape pointer into rsi, move a format string into rdi, call printf.
		// if char is ',', do cool shit.
		// if char is '[', do cool shit.
		// if char is ']', do cool shit.
	//increment instruction pointer
	//loop

	movq %rbp, %rsp
	popq %rbp
	ret
