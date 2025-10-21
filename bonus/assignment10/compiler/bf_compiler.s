.section .data
    filename: .asciz "output.s"      # File to write to
    message:  .asciz "Hello, Assembly!\n" # Message to write

.section .text
    .global main

main:
    # Open file: sys_open (rax = 2)
    mov $2, %rax               # syscall number for sys_open
    lea filename, %rdi    # filename argument
    mov $577, %rsi              # flags: O_WRONLY | O_CREAT | O_TRUNC (write only, create if not exist, truncate)
    mov $0644, %rdx             # mode: read and write permissions for user
    syscall                     # make syscall

    # Save the file descriptor
    mov %rax, %rdi              # save the file descriptor in rdi

    # Write to file: sys_write (rax = 1)
    mov $1, %rax                # syscall number for sys_write
    mov %rdi, %rdi              # file descriptor
    lea message, %rsi     # message to write
    mov $17, %rdx               # number of bytes to write
    syscall                     # make syscall

    # Close file: sys_close (rax = 3)
    mov $3, %rax                # syscall number for sys_close
    syscall                     # make syscall

    # Exit: sys_exit (rax = 60)
    mov $60, %rax               # syscall number for sys_exit
    xor %rdi, %rdi              # exit code 0
    syscall                     # make syscall
