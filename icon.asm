; status icon routines
; created by TalonFox for Ry :3

; note to self: icon overlay is overlay 28 (0x1C)

const UPDATE_ICON: 0x0228FFFE
const ICON_TICK:   0x0228FFFF

; change the 32x32 pixel icon to the given icon pointed at the given address
; inputs:
; r0: pointer to icon data
; outputs:
; none
change_icon:
    push r0
    push r1
    push r31

    mov r1, r0
    mov r0, ICON_FRAMEBUFFER_PTR
    mov r31, 1024 ; 32x32
change_icon_loop:
    mov [r0], [r1]
    add r0, 4
    add r1, 4
    loop change_icon_loop

    pop r31
    pop r1
    pop r0
    ret

setup_icon:
    push r0
    push r1

    mov r0, 0x8000001C
    mov r1, ICON_POSITION_Y
    sla r1, 16
    or r1, ICON_POSITION_X
    out r0, r1
    add r0, 0x100
    mov r1, ICON_HEIGHT
    sla r1, 16
    or r1, ICON_WIDTH
    out r0, r1
    add r0, 0x100
    mov r1, ICON_FRAMEBUFFER_PTR
    out r0, r1
    add r0, 0x100
    out r0, 1

    mov.8 [UPDATE_ICON], 1

    pop r1
    pop r0
    ret

cleanup_icon:
    out 0x8000031C, 0
    mov.8 [UPDATE_ICON], 0
    ret

icon_update:
    push r0

    movz.8 r0, [ICON_TICK]
    inc r0
    rem r0, 60
    mov.8 [ICON_TICK], r0
    cmp r0, 0
    ifz jmp icon_update1
    cmp r0, 30
    ifz jmp icon_update2
    jmp icon_update_ret
icon_update1:
    mov r0, disk_icon_q
    call change_icon
    jmp icon_update_ret
icon_update2:
    mov r0, disk_icon
    call change_icon
icon_update_ret:
    pop r0
    ret
