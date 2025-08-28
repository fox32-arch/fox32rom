; command parser

; TODO: all commands need to check for invalid arguments

monitor_shell_parse_command:
    ; push the address of monitor_breakpoint_update to the stack so that it
    ; will be called as soon as the command returns
    push monitor_breakpoint_update

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

    ; loop over the table of *user* commands
    ; data.32 NAME_STR_PTR, data.32 FUNC_PTR, data.32 HELP_STR_PTR
    mov r2, [MONITOR_USER_CMD_PTR]
    cmp [r2], 0x00444D43 ; "CMD",0
    ifnz rjmp monitor_shell_parse_command_error
    inc r2, 4
monitor_shell_parse_user_command_loop:
    mov r1, [r2]
    call compare_string
    ifnz rjmp monitor_shell_parse_user_command_loop_next
    ; if the string matches, parse args and jump to the address in the table
    mov r10, [r2+4]
    call monitor_shell_parse_arguments
    jmp r10
monitor_shell_parse_user_command_loop_next:
    ; otherwise, move to the next entry
    add r2, 12
    ; if the entry is zero, then we have reached the end of the table
    cmp [r2], 0
    ifnz jmp monitor_shell_parse_user_command_loop
monitor_shell_parse_command_error:
    ; invalid command
    mov r0, monitor_shell_invalid_command_string
    call print_string_to_monitor
    call redraw_monitor_console

    ret

monitor_shell_command_table:
    data.32 monitor_shell_brk_command_string
    data.32 monitor_shell_brk_command
    data.32 monitor_shell_brkrm_command_string
    data.32 monitor_shell_brkrm_command
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
    data.32 monitor_shell_save_command_string
    data.32 monitor_shell_save_command
    data.32 monitor_shell_set8_command_string
    data.32 monitor_shell_set8_command
    data.32 monitor_shell_set16_command_string
    data.32 monitor_shell_set16_command
    data.32 monitor_shell_set32_command_string
    data.32 monitor_shell_set32_command
    data.32 0 data.32 0
monitor_shell_invalid_command_string: data.str "invalid command" data.8 10 data.8 0

    ; all commands
    #include "monitor/commands/brk.asm"
    #include "monitor/commands/brkrm.asm"
    #include "monitor/commands/exit.asm"
    #include "monitor/commands/help.asm"
    #include "monitor/commands/jump.asm"
    #include "monitor/commands/list.asm"
    #include "monitor/commands/load.asm"
    #include "monitor/commands/reg.asm"
    #include "monitor/commands/save.asm"
    #include "monitor/commands/set.asm"
