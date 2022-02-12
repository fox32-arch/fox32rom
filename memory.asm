; memory copy routines

; copy specified number of bytes from source pointer to destination pointer
; if the source and destination overlap, the behavior is undefined
; inputs:
; r0: pointer to source
; r1: pointer to destinaton
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
; r1: pointer to destinaton
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