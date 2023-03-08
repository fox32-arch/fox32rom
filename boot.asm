; disk booting routines

; load the boot sector of disk 0 to 0x00000800 and jump to it
; inputs:
; none
; outputs:
; none (returns if disk 0 is not bootable)
start_boot_process:
    ; read sector 0 to 0x800
    mov r0, 0
    mov r1, 0
    mov r2, 0x00000800
    call read_sector

    ; check for the bootable magic bytes
    cmp [0x000009FC], 0x523C334C
    ifnz ret

    ; now clean up and jump to the loaded binary
    call boot_cleanup
    mov rsp, SYSTEM_STACK ; reset stack pointer
    mov r0, 0             ; booting from disk id 0
    jmp 0x00000800

; load the boot sector of the romdisk and jump to it
; inputs:
; none
; outputs:
; none (returns if romdisk is not bootable)
start_boot_process_from_romdisk:
    ; read sector 0 to 0x800
    mov r0, 0
    mov r1, 4
    mov r2, 0x00000800
    call read_sector

    ; check for the bootable magic bytes
    cmp [0x000009FC], 0x523C334C
    ifnz ret

    ; now clean up and jump to the loaded binary
    call boot_cleanup
    mov rsp, SYSTEM_STACK ; reset stack pointer
    mov r0, 4             ; booting from disk id 4
    jmp 0x00000800

; clean up the system's state before jumping to the loaded binary
; inputs:
; none
; outputs:
; none
boot_cleanup:
    ; clear the background
    mov r0, BACKGROUND_COLOR
    call fill_background

    ; disable the blinking disk icon
    call cleanup_icon

    movz.8 r0, 0
    movz.8 r1, 0
    movz.8 r2, 0
    movz.8 r3, 0
    movz.8 r4, 0
    movz.8 r5, 0
    movz.8 r6, 0
    movz.8 r7, 0
    movz.8 r8, 0
    movz.8 r9, 0
    movz.8 r10, 0
    movz.8 r11, 0
    movz.8 r12, 0
    movz.8 r13, 0
    movz.8 r14, 0
    movz.8 r15, 0
    movz.8 r16, 0
    movz.8 r17, 0
    movz.8 r18, 0
    movz.8 r19, 0
    movz.8 r20, 0
    movz.8 r21, 0
    movz.8 r22, 0
    movz.8 r23, 0
    movz.8 r24, 0
    movz.8 r25, 0
    movz.8 r26, 0
    movz.8 r27, 0
    movz.8 r28, 0
    movz.8 r29, 0
    movz.8 r30, 0
    movz.8 r31, 0

    ret
