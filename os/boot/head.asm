[SECTION .data]
global my_var
my_var db 'E'

[SECTION .text]
[BITS 32]

extern kernel_main
extern kernel_test
extern kernel_test_char
extern kernel_test_my_var
extern my_var1
extern kernel_change_var

global _start
_start:
    call kernel_main
    call kernel_test
    push 'B'
    call kernel_test_char
    add esp, 4
    call kernel_test_my_var
    push [my_var1]
    call kernel_test_char
    add esp, 4
    call kernel_change_var
    jmp $

global change_char_to_Z
change_char_to_Z:
    mov [my_var], 'Z'