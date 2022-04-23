; copy string from source pointer to destination pointer
; if the source and destination overlap, the behavior is undefined
; inputs:
; r0: pointer to source
; r1: pointer to destinaton
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
