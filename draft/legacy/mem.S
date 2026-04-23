  .code16

__start:

        mov $0x0, %si

        mov $0xb800, %ax
        mov %ax, %es               

        movb msg, %al
        movb %al, %es:(%si)        
        movb $0x20, %es:1(%si)

halt:
        hlt
        jmp halt

msg:
        .string "Hello World"
