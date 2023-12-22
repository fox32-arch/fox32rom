; command parser

; FIXME: thjs is a terrible way to do this
monitor_shell_parse_command:
    mov r0, MONITOR_SHELL_TEXT_BUF_BOTTOM

    ; exit
    mov r1, monitor_shell_exit_command_string
    call compare_string
    ifz jmp monitor_shell_exit_command

    ; help
    mov r1, monitor_shell_help_command_string
    call compare_string
    ifz jmp monitor_shell_help_command

    ; jump
    mov r1, monitor_shell_jump_command_string
    call compare_string
    ifz jmp monitor_shell_jump_command

    ; list
    mov r1, monitor_shell_list_command_string
    call compare_string
    ifz jmp monitor_shell_list_command

    ; load
    mov r1, monitor_shell_load_command_string
    call compare_string
    ifz jmp monitor_shell_load_command

    ; reg
    mov r1, monitor_shell_reg_command_string
    call compare_string
    ifz jmp monitor_shell_reg_command

    ; set.8
    mov r1, monitor_shell_set8_command_string
    call compare_string
    ifz jmp monitor_shell_set8_command

    ; set.16
    mov r1, monitor_shell_set16_command_string
    call compare_string
    ifz jmp monitor_shell_set16_command

    ; set.32
    mov r1, monitor_shell_set32_command_string
    call compare_string
    ifz jmp monitor_shell_set32_command

    ; invalid command
    mov r0, monitor_shell_invalid_command_string
    call print_string_to_monitor
    call redraw_monitor_console

    ret

monitor_shell_invalid_command_string: data.str "invalid command" data.8 10 data.8 0

    ; all commands
    #include "monitor/commands/exit.asm"
    #include "monitor/commands/help.asm"
    #include "monitor/commands/jump.asm"
    #include "monitor/commands/list.asm"
    #include "monitor/commands/load.asm"
    #include "monitor/commands/reg.asm"
    #include "monitor/commands/set.asm"
