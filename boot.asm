; disk booting routines
; these are only used during booting, they are not exposed via the jump table

; load the boot sector of disk 0 to 0x00000800 and jump to it
; inputs:
; none
; outputs:
; none (doesn't return)
start_boot_process:
    mov r0, 0x80003000 ; command to read a sector from disk 0 into memory
    mov r1, 0x80002000 ; command to set the location of the buffer

    ; read sector 0 to 0x800
    out r1, 0x00000800
    out r0, 0

    ; now clean up and jump to the loaded binary
    call boot_cleanup
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

    ret
