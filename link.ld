OUTPUT_FORMAT(elf32-i386)
ENTRY(_start)

SECTIONS {
    . = 0x1000;        /* Load the kernel starting at 0x1000 */
    .text : { *(.text) }
    .data : { *(.data) }
    .bss  : { *(.bss) }
}
