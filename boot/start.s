# start.s - "entry" point of the OS
# Requirement: Bootloader that follows Multiboot standard (GRUB most likely)

.extern kernel_main

.global start
.type start, @function

.set MAGIC, 0x1BADB002
.set FLAGS, (1 << 0) | (1 << 1)
.set CHECKSUM, -(MAGIC + FLAGS)

.section .multiboot
    .align 4
    .long MAGIC
    .long FLAGS
    .long CHECKSUM

.section .bss
    .align 16
    st_bottom:
    .skip 16384 # 16 KiB stack space
    st_top:

.section .text
    start:
        mov $st_top, %esp

        call kernel_main

        loop:
            cli
            hlt
            jmp loop

