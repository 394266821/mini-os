[ORG 0x500]  

[SECTION .data]
KERNEL_ADDR equ 0x1200

[SECTION .gdt]
SEG_BASE equ 0
SEG_LIMIT equ 0xfffff

CODE_SELECTOR equ (1 << 3)
DATA_SELECTOR equ (2 << 3)

gdt_base:
    dd 0, 0

gdt_code:
    dw SEG_LIMIT & 0xffff
    dw SEG_BASE & 0xffff
    db SEG_BASE >> 16 & 0xff
    db 0b1_00_1_1000
    db 0b0_1_00_0000 | (SEG_LIMIT >> 16 & 0xf)
    db SEG_BASE >> 24 & 0xf

gdt_data:
    dw SEG_LIMIT & 0xffff
    dw SEG_BASE & 0xffff
    db SEG_BASE >> 16 & 0xff
    db 0b1_00_1_0010
    db 0b1_1_00_0000 | (SEG_LIMIT >> 16 & 0xf)
    db SEG_BASE >> 24 & 0xf

gdt_ptr:
    dw $ - gdt_base
    dd gdt_base

[SECTION .text]
[BITS 16]
global setup_start
setup_start:
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov si, ax

    mov si, prepare_enter_protected_mode_msg
    call print

enter_protected_mode:
    cli
    
    lgdt [gdt_ptr]

    in al, 92h
    or al, 00000010b
    out 92h, al

    mov eax, cr0
    or eax, 1
    mov cr0, eax


    jmp CODE_SELECTOR:protected_mode

print:
    mov ah, 0x0e
    mov bh, 0
    mov bl, 0x01

.loop:
    mov al, [si]
    cmp al, 0
    jz .done
    int 0x10

    inc si
    jmp .loop

.done:
    ret

[BITS 32]
VIDEO_RAM equ 0xb8000
CHAR_ATTR equ 0x07
print_32:
    push edi
    push eax
    push edx
    mov edi, VIDEO_RAM
.print_loop:
    mov al, [esi]
    cmp al, 0
    je .print_done
    mov ah, CHAR_ATTR
    mov [edi], ax
    add edi, 2
    inc esi
    jmp .print_done
.print_done:
    pop edx
    pop eax
    pop edi
    ret

protected_mode:
    mov ax, DATA_SELECTOR
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov esp, 0x9fbff

    mov edi, KERNEL_ADDR
    mov ecx, 3
    mov bl, 60
     
    call read_hd


read_hd:
    mov dx, 0x1f2
    mov al, bl
    out dx, al

    inc dx
    mov al, cl
    out dx, al

    inc dx
    mov al, ch
    out dx, al

    inc dx 
    shr ecx, 16
    mov al, cl
    out dx, al

    inc dx
    mov al, ch
    or al, 0b1110_0000
    and al, 0b1110_1111
    out dx, al

    inc dx
    mov al, 0x20
    out dx, al

    mov bl, 60

.read_check:
    mov dx, 0x1f7
    in al, dx
    and al, 0b1000_1000
    cmp al, 0b0000_1000
    jnz .read_check    
    mov ecx, 256
     
.read_data:
    mov dx, 0x1f0
    in ax, dx
    mov [edi], ax
    add edi, 2
    loop .read_data
    dec bl
    jnz .read_check
    jmp KERNEL_ADDR

prepare_enter_protected_mode_msg: 
    db 'Enter Protected Mode...', 10, 13, 0