; string copy/compare routines

; copy string from source pointer to destination pointer
; if the source and destination overlap, the behavior is undefined
; inputs:
; r0: pointer to source
; r1: pointer to destination
; outputs:
; none
copy_string:
    push r0
    push r1
    push r2

copy_string_loop:
    mov.8 r2, [r0]
    mov.8 [r1], r2
    inc r0
    inc r1
    cmp.8 r2, 0
    ifnz jmp copy_string_loop

    pop r2
    pop r1
    pop r0
    ret

; compare string from source pointer with destination pointer
; inputs:
; r0: pointer to source
; r1: pointer to destination
; outputs:
; Z flag
compare_string:
    push r0
    push r1
compare_string_loop:
    ; check if the strings match
    cmp.8 [r0], [r1]
    ifnz jmp compare_string_not_equal

    ; if this is the end of string 1, then this must also be the end of string 2
    ; the cmp above already ensured that both strings have a null-terminator here
    cmp.8 [r0], 0
    ifz jmp compare_string_equal

    inc r0
    inc r1
    jmp compare_string_loop
compare_string_not_equal:
    ; Z flag is already cleared at this point
    pop r1
    pop r0
    ret
compare_string_equal:
    ; set Z flag
    mov r0, 0
    cmp r0, 0
    pop r1
    pop r0
    ret

; get the length of a string
; inputs:
; r0: pointer to null-terminated string
; outputs:
; r0: length of the string, not including the null-terminator
string_length:
    push r1
    mov r1, 0
string_length_loop:
    ; check if this is the end of the string
    cmp.8 [r0], 0
    ifz jmp string_length_end
    inc r0
    inc r1
    jmp string_length_loop
string_length_end:
    mov r0, r1
    pop r1
    ret

