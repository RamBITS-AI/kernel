[BITS 16]
[ORG 0x7C00]

start:
    ; Set up a basic 16-bit stack
    cli                 ; Disable interrupts
    xor ax, ax
    mov ds, ax          ; Zero out data segment
    mov ss, ax          ; Set the stack segment to 0
    mov sp, 0x7C00      ; Set the stack pointer above the bootloader

    ; Load the kernel from hard disk
    call load_kernel

    ; Switch to protected mode
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump to 32-bit protected mode kernel (address 0x1000)
    jmp 0x08:0x1000

; Load kernel from hard disk (starting from sector 2) into memory at 0x1000
load_kernel:
    mov bx, 0x1000      ; Load address (0x1000)
    mov dh, 2           ; Number of sectors to load
    mov dl, 0x80        ; First hard disk
    mov ah, 0x02        ; BIOS function to read sectors
    mov al, dh          ; Number of sectors to read
    mov ch, 0x00        ; Cylinder number
    mov cl, 0x02        ; Sector number (kernel starts at sector 2)
    mov dh, 0x00        ; Head number
    int 0x13            ; BIOS interrupt to read disk sectors
    jc load_kernel      ; Retry if read failed
    ret

[BITS 32]
kernel_entry:
    ; Set up segment registers for 32-bit protected mode
    mov ax, 0x10        ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x9000     ; Set up stack pointer for 32-bit mode

    ; Halt the CPU if we ever return here
    hlt

gdt_start:
    ; Null descriptor
    dd 0x0
    dd 0x0

    ; Code Segment descriptor: base=0x0, limit=0xFFFFF, type=0x9A (execute, read, accessed)
    dd 0x0000FFFF
    dd 0x00CF9A00

    ; Data Segment descriptor: base=0x0, limit=0xFFFFF, type=0x92 (read/write, accessed)
    dd 0x0000FFFF
    dd 0x00CF9200

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

gdt_end:

times 510 - ($ - $$) db 0
dw 0xAA55                   ; Boot signature (required by BIOS)
