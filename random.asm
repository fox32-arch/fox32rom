; random number generation routines
; by lua :3 - 2022 https://foxgirl.dev/

const RANDOM_STATE: 0x0228218E ; 4 bytes

; generate a random number
; inputs:
; none
; outputs:
; r0: random number
random:
    push r1
    mov r0, [RANDOM_STATE]

    mov r1, r0
    sla r1, 13
    xor r0, r1
    mov r1, r0
    srl r1, 17
    xor r0, r1
    mov r1, r0
    sla r1, 5
    xor r0, r1

    mov [RANDOM_STATE], r0
    pop r1
    ret

; generate a random number in the range [r1, r2)
; inputs:
; r1: minimum value, inclusive
; r2: maximum value, exclusive
; outputs:
; r0: random number
random_range:
    call random
    sub r2, r1
    rem r0, r2
    add r0, r1
    ret
