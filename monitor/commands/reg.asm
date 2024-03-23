; reg command

monitor_shell_reg_command_string: data.strz "reg"

monitor_shell_reg_command:
    push r0
    push r1
    push r2
    push r3

    ; print the display containing all of the registers
    ; r1 - used to store a pointer to the current string
    ; r2 - stores the current address on the stack
    ; r3 - loop counter
    mov r1, monitor_shell_reg_command_r0_str
    mov r2, [MONITOR_OLD_RSP]
    inc r2, 4
    mov r3, 0
monitor_shell_reg_command_print_loop:
    ; print the register label
    mov r0, r1
    call print_string_to_monitor
    ; print the register value
    mov r0, [r2]
    call print_hex_word_to_monitor
    ; adjust string pointer, stack address, and loop counter
    add r1, MONITOR_SHELL_COMMAND_R_STR_SIZE
    inc r2, 4
    inc r3
    ; decide whether to print a separator or a newline by checking if the loop
    ; counter is a multiple of 4
    mov r0, r3
    and r0, 0x03
    ifnz jmp monitor_shell_reg_command_print_sep
monitor_shell_reg_command_print_newline:
    mov r0, 10
    jmp monitor_shell_reg_command_print_last_char
monitor_shell_reg_command_print_sep:
    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
monitor_shell_reg_command_print_last_char:
    call print_character_to_monitor
    ; loop again if not on last register
    cmp r3, 35
    iflt jmp monitor_shell_reg_command_print_loop
    ; print rip
    mov r0, monitor_shell_reg_command_rip_str
    call print_string_to_monitor
    mov r0, [r2+1]
    call print_hex_word_to_monitor
    mov r0, 10
    call print_character_to_monitor

    call redraw_monitor_console

    pop r3
    pop r2
    pop r1
    pop r0

    ret

const MONITOR_SHELL_COMMAND_R_STR_SIZE: 7
monitor_shell_reg_command_r0_str:  data.strz "r0:   "
monitor_shell_reg_command_r1_str:  data.strz "r1:   "
monitor_shell_reg_command_r2_str:  data.strz "r2:   "
monitor_shell_reg_command_r3_str:  data.strz "r3:   "
monitor_shell_reg_command_r4_str:  data.strz "r4:   "
monitor_shell_reg_command_r5_str:  data.strz "r5:   "
monitor_shell_reg_command_r6_str:  data.strz "r6:   "
monitor_shell_reg_command_r7_str:  data.strz "r7:   "
monitor_shell_reg_command_r8_str:  data.strz "r8:   "
monitor_shell_reg_command_r9_str:  data.strz "r9:   "
monitor_shell_reg_command_r10_str: data.strz "r10:  "
monitor_shell_reg_command_r11_str: data.strz "r11:  "
monitor_shell_reg_command_r12_str: data.strz "r12:  "
monitor_shell_reg_command_r13_str: data.strz "r13:  "
monitor_shell_reg_command_r14_str: data.strz "r14:  "
monitor_shell_reg_command_r15_str: data.strz "r15:  "
monitor_shell_reg_command_r16_str: data.strz "r16:  "
monitor_shell_reg_command_r17_str: data.strz "r17:  "
monitor_shell_reg_command_r18_str: data.strz "r18:  "
monitor_shell_reg_command_r19_str: data.strz "r19:  "
monitor_shell_reg_command_r20_str: data.strz "r20:  "
monitor_shell_reg_command_r21_str: data.strz "r21:  "
monitor_shell_reg_command_r22_str: data.strz "r22:  "
monitor_shell_reg_command_r23_str: data.strz "r23:  "
monitor_shell_reg_command_r24_str: data.strz "r24:  "
monitor_shell_reg_command_r25_str: data.strz "r25:  "
monitor_shell_reg_command_r26_str: data.strz "r26:  "
monitor_shell_reg_command_r27_str: data.strz "r27:  "
monitor_shell_reg_command_r28_str: data.strz "r28:  "
monitor_shell_reg_command_r29_str: data.strz "r29:  "
monitor_shell_reg_command_r30_str: data.strz "r30:  "
monitor_shell_reg_command_r31_str: data.strz "r31:  "
monitor_shell_reg_command_rsp_str: data.strz "rsp:  "
monitor_shell_reg_command_resp_str: data.strz "resp: "
monitor_shell_reg_command_rfp_str: data.strz "rfp:  "
monitor_shell_reg_command_rip_str: data.strz "rip:  "
