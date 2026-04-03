; disasm command

monitor_shell_disasm_command_string: data.strz "disasm"
monitor_shell_disasm_command_string_2: data.strz "d"

monitor_shell_disasm_command:
    call monitor_shell_parse_arguments
    push r1
    mov r1, 16
    call string_to_int
    pop r1
    push r0
    mov r0, r1
    mov r1, 10
    call string_to_int
    mov r1, r0
    pop r0

    ; r0: address
    ; r1: number of instrs to disassemble
    call monitor_disassemble

    call redraw_monitor_console
    ret
