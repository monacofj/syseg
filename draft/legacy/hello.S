.section .data
    # UEFI uses UTF-16 (2 bytes per character)
    # Each character is followed by a null byte
    msg:
        .byte 'H', 0, 'e', 0, 'l', 0, 'l', 0, 'o', 0, ' ', 0
        .byte 'U', 0, 'E', 0, 'F', 0, 'I', 0, 13, 0, 10, 0, 0, 0

.section .text
.globl efi_main

efi_main:
    # UEFI passes arguments via the Microsoft x64 calling convention:
    # %rcx = ImageHandle
    # %rdx = SystemTable (pointer to the main structure)

    # 1. Save the SystemTable pointer
    movq %rdx, %rbx

    # 2. Get the ConOut (ConsoleOut) pointer
    # In the EFI_SYSTEM_TABLE structure, ConOut is at offset 64
    movq 64(%rbx), %rdi

    # 3. Clear the screen
    # In the EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL interface, ClearScreen is at offset 48
    movq %rdi, %rcx          # 1st param: pointer to the ConOut interface (this)
    call *48(%rdi)

    # 4. Prepare the call to OutputString(this, string)
    # Prototype: EFI_STATUS (EFI_TEXT_OUTPUT_PROTOCOL *This, CHAR16 *String)
    movq %rdi, %rcx          # 1st param: pointer to the ConOut interface (this)
    leaq msg(%rip), %rdx     # 2nd param: pointer to our UTF-16 string

    # 5. Call the OutputString function
    # In the EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL interface, OutputString is at offset 8
    call *8(%rdi)

    # 6. Halt execution (infinite loop)
    jmp .
