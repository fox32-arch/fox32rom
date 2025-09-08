; debug breakpoint handling routines

; set a breakpoint at at particular address, using a specific slot in the
; breakpoint table. does nothing if there is already a breakpoint set at this
; address. if this slot is already occupied, that breakpoint will be removed
; before the new one is added.
; inputs:
; r0: address at which to set breakpoint
; r1: breakpoint number
; outputs:
; r0: if a breakpoint was removed, the address of that breakpoint;
;     0 if no breakpoint was removed to add this breakpoint;
;     -1 if the breakpoint could not be added
monitor_breakpoint_add:
    ; check if the address is a valid location for a breakpoint
    ; if the address is not in RAM, a breakpoint cannot be added
    ; (maximum possible address is 0x03fffffe, because the brk opcode is two
    ; bytes)
    cmp r0, 0x03fffffe
    ifgt mov r0, 0xFFFFFFFF
    ifgt ret
    ; check if breakpoint is already defined at this address, and fail if so
    push r1
    mov r1, r0
    call monitor_breakpoint_find_addr
    cmp r0, 0xffffffff
    ifnz jmp monitor_breakpoint_add_addr_check_fail
    ; check if breakpoint is already defined at one address below this
    ; address, and fail if so
    mov r0, r1
    dec r0
    call monitor_breakpoint_find_addr
    cmp r0, 0xffffffff
    ifnz jmp monitor_breakpoint_add_addr_check_fail
    ; check if breakpoint is already defined at one address above this
    ; address, and fail if so
    mov r0, r1
    inc r0
    call monitor_breakpoint_find_addr
    cmp r0, 0xffffffff
    ifnz jmp monitor_breakpoint_add_addr_check_fail
    mov r0, r1
    pop r1
    ; check if the breakpoint number is valid, and if not, return
    cmp r1, 0x10
    ifgteq mov r0, 0xFFFFFFFF
    ifgteq ret

    push r1
    push r2
    push r3
    push r4
    ; clear r4 to indicate no breakpoint removed
    mov r4, 0
    ; get offset into saved instruction table in r3
    mov r2, r1
    sla r2, 1
    mov r3, r2
    ; get offset into breakpoint table in r2
    sla r2, 1
    ; add base addresses of tables
    add r2, MONITOR_BREAKPOINT_TABLE
    add r3, MONITOR_SAVED_INSTR_TABLE
    ; check if breakpoint is currently set, and if so, remove it
    cmp [r2], 0
    ifz jmp monitor_breakpoint_add_skip_rm
    ; remove the breakpoint occupying the slot
    push r0
    mov r0, r1
    call monitor_breakpoint_remove
    ; store its address in r4
    mov r4, r0
    pop r0
monitor_breakpoint_add_skip_rm:
    ; save current contents of breakpoint location
    mov.16 [r3], [r0]
    ; place break instruction at the address
    mov.16 [r0], MONITOR_BREAKPOINT_BRK_INSTR
    ; save address in table
    mov [r2], r0
    ; return the address of the removed breakpoint (if any)
    mov r0, r4
    
    pop r4
    pop r3
    pop r2
    pop r1
    ret
monitor_breakpoint_add_addr_check_fail:
    pop r1
    mov r0, 0xffffffff
    ret

; set a breakpoint at a particular address, using the first available slot in
; the breakpoint table. does nothing if there are no available slots.
; inputs:
; r0: address at which to set breakpoint
; outputs:
; r0: the number of the set breakpoint; -1 if no breakpoint was set
monitor_breakpoint_add_any:
    push r1
    mov r1, r0
    ; get the first available slot in the breakpoint table
    mov r0, 0
    call monitor_breakpoint_find_addr
    ; if the breakpoint number is -1, return
    cmp r0, 0x10
    ifgteq jmp monitor_breakpoint_add_any_ret
    ; swap r1 and r0
    push r0
    mov r0, r1
    pop r1
    ; set the breakpoint
    call monitor_breakpoint_add
    ; if r0 is -1, the breakpoint could not be added, so return
    cmp r0, 0xFFFFFFFF
    ifz jmp monitor_breakpoint_add_any_ret
    ; get breakpoint number in r0
    mov r0, r1
monitor_breakpoint_add_any_ret:
    pop r1
    ret

; remove a breakpoint. does nothing if that breakpoint number is not set.
; inputs:
; r0: the breakpoint number to remove
; outputs:
; r0: the address of the removed breakpoint; zero if the breakpoint was not
;     set
monitor_breakpoint_remove:
    ; if breakpoint number is out of range, return immediately
    cmp r0, 0x10
    ifgteq ret
    push r1
    push r2
    ; get offset into saved instruction table in r1
    sla r0, 1
    mov r1, r0
    ; get offset into breakpoint table in r0
    sla r0, 1
    ; add base addresses of tables
    add r0, MONITOR_BREAKPOINT_TABLE
    add r1, MONITOR_SAVED_INSTR_TABLE
    ; get breakpoint address in r2
    mov r2, [r0]
    ; if breakpoint address is zero, return
    cmp r2, 0
    ifz jmp monitor_breakpoint_remove_ret
    ; clear address in table
    mov [r0], 0
    ; restore original instruction
    mov.16 [r2], [r1]
monitor_breakpoint_remove_ret:
    ; copy breakpoint address into r0
    mov r0, r2

    pop r2
    pop r1
    ret

; remove a breakpoint at a particular address. does nothing if there is no
; breakpoint at that address.
; inputs:
; r0: address to remove breakpoint from
; outputs:
; r0: number of the breakpoint that was removed; -1 if no breakpoint was
;     removed
monitor_breakpoint_remove_addr:
    ; get the breakpoint number corresponding to the address
    call monitor_breakpoint_find_addr
    ; check if breakpoint number is -1, and if so, return it
    cmp r0, 0x10
    ifgteq ret
    
    push r0
    call monitor_breakpoint_remove
    pop r0
    ret

; get the first occurence of a particular address in the breakpoint table.
; can be used with zero to find the first unused entry.
; inputs:
; r0: the address to search for
; outputs:
; r0: the number of the first matching breakpoint; -1 if no match is found
monitor_breakpoint_find_addr:
    push r1
    push r2
    ; initialize registers before loop
    mov r2, r0
    mov r0, 0
    mov r1, MONITOR_BREAKPOINT_TABLE
monitor_breakpoint_find_addr_loop:
    ; check if this table entry matches
    cmp [r1], r2
    ifz jmp monitor_breakpoint_find_addr_found
    ; increment loop registers
    inc r0
    inc r1, 4
    ; check if the current breakpoint number is within range (< 0x10)
    cmp r0, 0x10
    iflt jmp monitor_breakpoint_find_addr_loop
    ; otherwise, there is no matching breakpoint slot, so return -1
    mov r0, 0xFFFFFFFF
monitor_breakpoint_find_addr_found:
    pop r2
    pop r1
    ret

; called when the monitor starts; checks if a breakpoint needs to be removed
monitor_breakpoint_update:
    ; loop over each breakpoint in the table and check if the corresponding
    ; brk instruction is still present
    mov r1, MONITOR_BREAKPOINT_TABLE
    mov r2, 0
monitor_breakpoint_update_check_opcode_loop:
    ; check if this breakpoint is set
    cmp [r1], 0
    ifz jmp monitor_breakpoint_update_check_opcode_loop_skip
    ; if the breakpoint is set, check whether the opcode still corresponds to
    ; a brk instruction, and if so, do nothing
    mov r3, [r1]
    cmp.16 [r3], MONITOR_BREAKPOINT_BRK_INSTR
    ifz jmp monitor_breakpoint_update_check_opcode_loop_skip
    ; if the brk instruction has been removed, remove the breakpoint from
    ; the table manually, as calling monitor_breakpoint_remove would attempt
    ; to restore the instruction from the now-invalid value in
    ; MONITOR_SAVED_INSTR_TABLE
    mov [r1], 0
    ; print a message indicating that the breakpoint has been removed because
    ; the instruction was modified
    mov r0, monitor_breakpoint_instr_modified_str
    call print_string_to_monitor
    mov r0, r2
    call print_hex_digit_to_monitor
    mov r0, monitor_breakpoint_at_str
    call print_string_to_monitor
    mov r0, r3
    call print_hex_word_to_monitor
    mov r0, 10
    call print_character_to_monitor
    call redraw_monitor_console
monitor_breakpoint_update_check_opcode_loop_skip:
    ; adjust registers for next iteration
    inc r1, 4
    inc r2
    ; loop again if breakpoint number is in range
    cmp r2, 0x10
    iflt jmp monitor_breakpoint_update_check_opcode_loop

    ; get the ip when the breakpoint occurred
    mov r2, [MONITOR_OLD_RSP]
    ;   4 byte monitor return address
    ; + 140 = 4 bytes * 35 saved registers
    ; + 1 byte of flags
    ; = 145 bytes to reach saved rip
    add r2, 145
    mov r1, [r2]
    ; adjust it to point to the brk instruction itself
    dec r1, 2
    ; is there a matching breakpoint in the table? if not, simply return
    mov r0, r1
    call monitor_breakpoint_find_addr
    cmp r0, 0xFFFFFFFF
    ifz ret
    ; if so, remove the breakpoint, and write the adjusted rip back to the
    ; stack
    call monitor_breakpoint_remove
    mov [r2], r1
    ret

; called to initialize the breakpoint state when the machine starts
monitor_breakpoint_init:
    push r0
    push r1
    ; zero the breakpoint table
    mov r0, MONITOR_BREAKPOINT_TABLE
    mov r1, 0
monitor_breakpoint_init_loop:
    mov [r0], 0
    inc r0, 4
    inc r1
    cmp r1, 32
    iflt jmp monitor_breakpoint_init_loop
    pop r1
    pop r0
    ret
    

monitor_breakpoint_instr_modified_str:
    data.strz "brk instruction modified; removing breakpoint "
monitor_breakpoint_at_str:
    data.strz " at "

const MONITOR_BREAKPOINT_BRK_INSTR: 0xA000
