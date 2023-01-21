; debug monitor keyboard routines

; convert a make scancode to an ASCII character
; inputs:
; r0: make scancode
; outputs:
; r0: ASCII character
scancode_to_ascii:
    push r1

    mov r1, scancode_table
    bts [MODIFIER_BITMAP], 0
    ifnz mov r1, scancode_table_shift
    bts [MODIFIER_BITMAP], 1
    ifnz mov r1, scancode_table_caps
    add r0, r1
    movz.8 r0, [r0]

    pop r1
    ret

; set bit 0 in the modifier bitmap
; inputs:
; none
; outputs:
; none
shift_pressed:
    bse [MODIFIER_BITMAP], 0

    ret

; clear bit 0 in the modifier bitmap
; inputs:
; none
; outputs:
; none
shift_released:
    bcl [MODIFIER_BITMAP], 0

    ret

; toggle bit 1 in the modifier bitmap
; inputs:
; none
; outputs:
; none
caps_pressed:
    bts [MODIFIER_BITMAP], 1
    ifz bse [MODIFIER_BITMAP], 1
    ifnz bcl [MODIFIER_BITMAP], 1

    ret

; scancode set 1:
; https://wiki.osdev.org/PS/2_Keyboard#Scan_Code_Set_1
const CTRL:   0x1D
const LSHIFT: 0x2A
const RSHIFT: 0x36
const CAPS:   0x3A
scancode_table:
    data.8 0 data.8 27 data.str "1234567890-=" data.8 8
    data.8 9 data.str "qwertyuiop[]" data.8 10 data.8 0
    data.str "asdfghjkl;'`" data.8 0 data.8 92
    data.str "zxcvbnm,./" data.8 0 data.str "*" data.8 0 data.str " "
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.str "-" data.8 0 data.8 0 data.8 0 data.str "+"
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0
scancode_table_shift:
    data.8 0 data.8 27 data.str "!@#$%^&*()_+" data.8 8
    data.8 9 data.str "QWERTYUIOP{}" data.8 10 data.8 0
    data.str "ASDFGHJKL:" data.8 34 data.str "~" data.8 0 data.str "|"
    data.str "ZXCVBNM<>?" data.8 0 data.str "*" data.8 0 data.str " "
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.str "-" data.8 0 data.8 0 data.8 0 data.str "+"
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0
scancode_table_caps:
    data.8 0 data.8 27 data.str "1234567890-=" data.8 8
    data.8 9 data.str "QWERTYUIOP[]" data.8 10 data.8 0
    data.str "ASDFGHJKL;'`" data.8 0 data.8 92
    data.str "ZXCVBNM,./" data.8 0 data.str "*" data.8 0 data.str " "
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.str "-" data.8 0 data.8 0 data.8 0 data.str "+"
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0

const MODIFIER_BITMAP: 0x03ED36C9 ; 1 byte
