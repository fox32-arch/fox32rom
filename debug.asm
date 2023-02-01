; debug routines

; print a string to the serial port
; inputs:
; r0: pointer to null-terminated string
; outputs:
; none
debug_print:
    push r0
    push r1
debug_print_loop:
    mov r1, 0x00000000
    out r1, [r0]
    inc r0
    cmp.8 [r0], 0x00
    ifnz jmp debug_print_loop
    pop r1
    pop r0
    ret
