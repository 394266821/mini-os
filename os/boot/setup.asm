[ORG 0X500]
[SECTION .text]
[BITS 16]
global _start
_start:
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov si, ax

    mov si, msg
    call print

    jmp $

print:
    mov ah, 0x0e
    mov bh, 0
    mov bl, 0x01

.loop
    mov al, [si]
    cmp al, 0
    jz .done
    int 0x10

    inc si
    jmp .loop

.done
    ret

msg: 
    db 'hello world', 10, 13, 0