; exception handling routines

; called if a page fault occurs
; does not return, calls panic
system_page_fault_handler:
    mov r0, system_page_fault_str
    pop r1
    jmp panic
system_page_fault_str: data.str "Page fault at virtual address r1" data.8 10 data.8 0
