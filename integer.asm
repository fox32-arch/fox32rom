; integer routines

; convert ASCII string into an integer
; thanks to lua for helping with this :3
; inputs:
; r0: pointer to null-terminated string
; r1: radix (i.e. 10 for decimal, 16 for hexadecimal)
; outputs:
; r0: integer
string_to_int:
    push r2
    push r3
    mov r3, 0
string_to_int_loop:
    movz.8 r2, [r0]
    inc r0

    cmp r2, 0
    ifz jmp string_to_int_end

    ; if (digit >= '0' && digit <= '9') {
    ;     digit -= '0';
    ; } else if (digit >= 'A' && digit <= 'Z') {
    ;     digit -= 'A' - 10
    ; } else if (digit >= 'a' && digit <= 'z') {
    ;     digit -= 'a' - 10
    ; } else {
    ;     continue;
    ; }

    cmp r2, '0'
    iflt jmp string_to_int_loop_2
    cmp r2, '9'
    ifgt jmp string_to_int_loop_2

    sub r2, '0'
    jmp string_to_int_loop_end
string_to_int_loop_2:
    cmp r2, 'A'
    iflt jmp string_to_int_loop_3
    cmp r2, 'Z'
    ifgt jmp string_to_int_loop_3

    sub r2, 0x37 ; 'A' - 10
    jmp string_to_int_loop_end
string_to_int_loop_3:
    cmp r2, 'a'
    iflt jmp string_to_int_loop
    cmp r2, 'z'
    ifgt jmp string_to_int_loop

    sub r2, 0x57 ; 'a' - 10
string_to_int_loop_end:
    mul r3, r1
    add r3, r2
    jmp string_to_int_loop
string_to_int_end:
    mov r0, r3

    pop r3
    pop r2
    ret

