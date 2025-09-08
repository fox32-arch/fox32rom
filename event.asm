; event system routines

; event types
const EVENT_TYPE_MOUSE_CLICK:    0x00000000
const EVENT_TYPE_MOUSE_RELEASE:  0x00000001
const EVENT_TYPE_KEY_DOWN:       0x00000002
const EVENT_TYPE_KEY_UP:         0x00000003
const EVENT_TYPE_MENU_BAR_CLICK: 0x00000004
const EVENT_TYPE_MENU_UPDATE:    0x00000005
const EVENT_TYPE_MENU_CLICK:     0x00000006
const EVENT_TYPE_MENU_ACK:       0x00000007
const EVENT_TYPE_EMPTY:          0xFFFFFFFF

; block until an event is available
; inputs:
; none
; outputs:
; r0: event type
; r1-r7: event parameters
wait_for_event: jmp event_wait

; add an event to the event queue
; inputs:
; r0: event type
; r1-r7: event parameters
; outputs:
; none
new_event: jmp event_new

; get the next event and remove it from the event queue
; inputs:
; none
; outputs:
; r0: event type
; r1-r7: event parameters
get_next_event: jmp event_next

; implementation
; this is my child - lua

const EVENT_SIZE: 32

event_wait:
    call event__init

event_wait_0:
    ise
    halt

    cmp [EVENT_QUEUE_POINTER], [EVENT_QUEUE_BOTTOM]
    ifz jmp event_wait_0
    jmp event_next_0

event_next:
    call event__init

    cmp [EVENT_QUEUE_POINTER], [EVENT_QUEUE_BOTTOM]
    ifz jmp event__empty

event_next_0:
    icl
    push r8
    push r9

    mov r8, [EVENT_QUEUE_BOTTOM]
    call event__load
    mov r8, [EVENT_TEMP]
    call event__store

    mov r9, [EVENT_QUEUE_BOTTOM]

event_next_1:
    add r9, EVENT_SIZE

    cmp [EVENT_QUEUE_POINTER], r9
    ifz jmp event_next_2

    mov r8, r9
    call event__load

    mov r8, r9
    sub r8, EVENT_SIZE
    call event__store

    jmp event_next_1

event_next_2:
    mov r8, [EVENT_TEMP]
    call event__load

    sub [EVENT_QUEUE_POINTER], EVENT_SIZE

    pop r9
    pop r8
    ise
    ret

event_new:
    call event__init

    push r8

    mov r8, [EVENT_QUEUE_POINTER]
    call event__store
    mov [EVENT_QUEUE_POINTER], r8

    pop r8
    ret

event__init:
    cmp [EVENT_QUEUE_POINTER], 0
    ifz mov [EVENT_QUEUE_POINTER], [EVENT_QUEUE_BOTTOM]
    ret

event__empty:
    mov r0, EVENT_TYPE_EMPTY
    mov r1, 0
    mov r2, 0
    mov r3, 0
    mov r4, 0
    mov r5, 0
    mov r6, 0
    mov r7, 0
    ret

event__load:
    mov r0, [r8]
    add r8, 4
    mov r1, [r8]
    add r8, 4
    mov r2, [r8]
    add r8, 4
    mov r3, [r8]
    add r8, 4
    mov r4, [r8]
    add r8, 4
    mov r5, [r8]
    add r8, 4
    mov r6, [r8]
    add r8, 4
    mov r7, [r8]
    add r8, 4
    ret

event__store:
    mov [r8], r0
    add r8, 4
    mov [r8], r1
    add r8, 4
    mov [r8], r2
    add r8, 4
    mov [r8], r3
    add r8, 4
    mov [r8], r4
    add r8, 4
    mov [r8], r5
    add r8, 4
    mov [r8], r6
    add r8, 4
    mov [r8], r7
    add r8, 4
    ret
