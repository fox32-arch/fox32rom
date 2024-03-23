; brkrm command

monitor_shell_brkrm_command_string: data.strz "brkrm"

monitor_shell_brkrm_command:
    ; push an extra return to redraw the console
    push redraw_monitor_console
    call monitor_shell_parse_arguments

    ; arguments:
    ; $0: number of breakpoint to be removed

    ; check if argument $0 is empty
    cmp r0, 0
    ifz jmp monitor_shell_brkrm_command_missing_arg
    ; if not, convert it to integer
    mov r1, 16
    call string_to_int
    mov r10, r0

    ; make sure the breakpoint number is in range
    cmp r10, 0x10
    ifgteq jmp monitor_shell_brkrm_command_invalid_num

    ; remove the breakpoint
    call monitor_breakpoint_remove
    ; determine whether a breakpoint was removed
    cmp r0, 0
    ifz jmp monitor_shell_brkrm_command_not_set
    ; breakpoint was set, so print removal message
    mov r1, r10
    call monitor_shell_brkrm_command_print_rm_msg
    ret

monitor_shell_brkrm_command_not_set:
    ; breakpoint was not set, so print the corresponding message
    mov r0, monitor_shell_brkrm_command_not_set_msg_1
    call print_string_to_monitor
    mov r0, r10
    call print_hex_digit_to_monitor
    mov r0, monitor_shell_brkrm_command_not_set_msg_2
    call print_string_to_monitor
    ret

monitor_shell_brkrm_command_invalid_num:
    ; print a message indicating that the breakpoint number is invalid
    mov r0, r10
    call monitor_shell_brk_command_print_invalid_msg
    ret

monitor_shell_brkrm_command_missing_arg:
    ; print a message indicating that an argument is missing
    mov r0, monitor_shell_brkrm_command_missing_arg_msg
    call print_string_to_monitor
    ret

; print a message stating that the breakpoint was removed
; 'Removed breakpoint X at XXXXXXXX'
; inputs:
; r0: address of breakpoint
; r1: breakpoint number
; outputs:
; none
monitor_shell_brkrm_command_print_rm_msg:
    push r0
    mov r0, monitor_shell_brkrm_command_rm_str
    call print_string_to_monitor
    pop r0
    call monitor_shell_brk_command_print_num_at_addr
    ret

monitor_shell_brkrm_command_rm_str:
    data.strz "Removed breakpoint "
monitor_shell_brkrm_command_missing_arg_msg:
    data.str "Missing argument $0; breakpoint number is required"
    data.8 10 data.8 0
monitor_shell_brkrm_command_not_set_msg_1:
    data.strz "Breakpoint "
monitor_shell_brkrm_command_not_set_msg_2:
    data.str " not set" data.8 10 data.8 0
