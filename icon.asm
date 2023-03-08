; status icon routines
; created by TalonFox for Ry :3

; note to self: icon overlay is overlay 28 (0x1c)

; changes the 32x32 pixel icon to the given icon pointed at the given address
; inputs:
; r0: Pointer to icon data
; outputs:
; none
change_icon:
    push r0
    push r1
    push r31

    ; write the cursor bitmap to the overlay framebuffer
    movz.32 r1, r0
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
    movz r0, 0x8000001c
    movz r1, ICON_POSITION_Y
    sla r1, 16
    or r1, ICON_POSITION_X
    out r0, r1
    add r0, 0x100
    movz r1, ICON_HEIGHT
    sla r1, 16
    or r1, ICON_WIDTH
    out r0, r1
    add r0, 0x100
    movz r1, ICON_FRAMEBUFFER_PTR
    out r0, r1
    add r0, 0x100
    movz r1, 1
    out r0, r1
    pop r1
    pop r0
    ret

const ICON_TICK: 0x03FFFFFC

icon_update:
    push r0
    mov.32 r0, [ICON_TICK]
    add r0, 1
    rem r0, 60
    mov.32 [ICON_TICK], r0
    cmp r0, 0
    ifz jmp icon_update1
    cmp r0, 30
    ifz jmp icon_update2
    jmp icon_update_ret
icon_update1:
    movz r0, disk_icon_q
    call change_icon
    jmp icon_update_ret
icon_update2:
    movz r0, disk_icon
    call change_icon
icon_update_ret:
    pop r0
    ret