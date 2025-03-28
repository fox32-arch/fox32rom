; save command

monitor_shell_save_command_string: data.strz "save"

monitor_shell_save_command:
    call monitor_shell_parse_arguments

    ; r0: pointer to disk id string
    ; r1: pointer to destination sector number string
    ; r2: pointer to source address string
    ; r3: pointer to number of sectors string

    push r3
    push r2
    push r1
    mov r1, 16
    call string_to_int
    mov r10, r0
    pop r0
    mov r1, 16
    call string_to_int
    mov r11, r0
    pop r0
    mov r1, 16
    call string_to_int
    mov r12, r0
    pop r0
    mov r1, 16
    call string_to_int
    mov r13, r0

    ; r10: disk id
    ; r11: destination sector number
    ; r12: source address
    ; r13: number of sectors

    mov r31, r13
    cmp r31, 0
    ifz ret
    mov r0, r11
    mov r1, r10
    mov r2, r12
monitor_shell_save_command_loop:
    call write_sector
    inc r0
    add r2, 512
    loop monitor_shell_save_command_loop

    ret
