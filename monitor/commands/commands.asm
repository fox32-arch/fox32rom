; command parser

monitor_shell_parse_command:
    mov r0, MONITOR_SHELL_TEXT_BUF_BOTTOM

    ; loop over the table of commands
    mov r2, monitor_shell_command_table
monitor_shell_parse_command_loop:
    mov r1, [r2]
    call compare_string
    ; if the string matches, jump to the corresponding address in the table
    ifz jmp [r2+4]
    ; otherwise, move to the next entry
    add r2, 8
    ; if the entry is zero, then we have reached the end of the table
    cmp [r2], 0
    ifnz jmp monitor_shell_parse_command_loop

    ; invalid command
    mov r0, monitor_shell_invalid_command_string
    call print_string_to_monitor
    call redraw_monitor_console

    ret

monitor_shell_command_table:
    data.32 monitor_shell_exit_command_string
    data.32 monitor_shell_exit_command
    data.32 monitor_shell_help_command_string
    data.32 monitor_shell_help_command
    data.32 monitor_shell_jump_command_string
    data.32 monitor_shell_jump_command
    data.32 monitor_shell_list_command_string
    data.32 monitor_shell_list_command
    data.32 monitor_shell_load_command_string
    data.32 monitor_shell_load_command
    data.32 monitor_shell_reg_command_string
    data.32 monitor_shell_reg_command
    data.32 monitor_shell_set8_command_string
    data.32 monitor_shell_set8_command
    data.32 monitor_shell_set16_command_string
    data.32 monitor_shell_set16_command
    data.32 monitor_shell_set32_command_string
    data.32 monitor_shell_set32_command
    data.32 0 data.32 0
monitor_shell_invalid_command_string: data.str "invalid command" data.8 10 data.8 0

    ; all commands
    #include "monitor/commands/exit.asm"
    #include "monitor/commands/help.asm"
    #include "monitor/commands/jump.asm"
    #include "monitor/commands/list.asm"
    #include "monitor/commands/load.asm"
    #include "monitor/commands/reg.asm"
    #include "monitor/commands/set.asm"
