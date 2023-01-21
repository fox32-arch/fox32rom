; memory copy/compare routines

; copy specified number of bytes from source pointer to destination pointer
; if the source and destination overlap, the behavior is undefined
; inputs:
; r0: pointer to source
; r1: pointer to destination
; r2: number of bytes to copy
; outputs:
; none
copy_memory_bytes:
    push r0
    push r1
    push r31

    mov r31, r2
copy_memory_bytes_loop:
    mov.8 [r1], [r0]
    inc r0
    inc r1
    loop copy_memory_bytes_loop

    pop r31
    pop r1
    pop r0
    ret

; copy specified number of words from source pointer to destination pointer
; if the source and destination overlap, the behavior is undefined
; inputs:
; r0: pointer to source
; r1: pointer to destination
; r2: number of words to copy
; outputs:
; none
copy_memory_words:
    push r0
    push r1
    push r31

    mov r31, r2
copy_memory_words_loop:
    mov [r1], [r0]
    add r0, 4
    add r1, 4
    loop copy_memory_words_loop

    pop r31
    pop r1
    pop r0
    ret

; compare specified number of bytes from source pointer with destination pointer
; inputs:
; r0: pointer to source
; r1: pointer to destination
; r2: number of bytes to compare
; outputs:
; Z flag
compare_memory_bytes:
    push r0
    push r1
    push r31

    mov r31, r2
compare_memory_bytes_loop:
    cmp.8 [r1], [r0]
    ifnz jmp compare_memory_bytes_not_equal
    inc r0
    inc r1
    loop compare_memory_bytes_loop
    ; set Z flag if we reach this point
    mov r0, 0
    cmp r0, 0
compare_memory_bytes_not_equal:
    pop r31
    pop r1
    pop r0
    ret

; compare specified number of words from source pointer with destination pointer
; inputs:
; r0: pointer to source
; r1: pointer to destination
; r2: number of words to compare
; outputs:
; Z flag
compare_memory_words:
    push r0
    push r1
    push r31

    mov r31, r2
compare_memory_words_loop:
    cmp [r1], [r0]
    ifnz jmp compare_memory_words_not_equal
    add r0, 4
    add r1, 4
    loop compare_memory_words_loop
    ; set Z flag if we reach this point
    mov r0, 0
    cmp r0, 0
compare_memory_words_not_equal:
    pop r31
    pop r1
    pop r0
    ret
