; audio routines

; use ffmpeg to convert an audio file for playback:
; ffmpeg -i input.mp3 -f s16le -ac 1 -ar 22050 audio.raw

const AUDIO_POINTER_0:          0x01FFFF00 ; 4 bytes
const AUDIO_POINTER_1:          0x01FFFF04 ; 4 bytes
const AUDIO_POINTER_2:          0x01FFFF08 ; 4 bytes
const AUDIO_POINTER_3:          0x01FFFF0C ; 4 bytes
const AUDIO_LENGTH_0:           0x01FFFF10 ; 4 bytes
const AUDIO_LENGTH_1:           0x01FFFF14 ; 4 bytes
const AUDIO_LENGTH_2:           0x01FFFF18 ; 4 bytes
const AUDIO_LENGTH_3:           0x01FFFF1C ; 4 bytes
const OLD_BUFFER_SWAP_VECTOR_0: 0x01FFFF20 ; 4 bytes
const OLD_BUFFER_SWAP_VECTOR_1: 0x01FFFF24 ; 4 bytes
const OLD_BUFFER_SWAP_VECTOR_2: 0x01FFFF28 ; 4 bytes
const OLD_BUFFER_SWAP_VECTOR_3: 0x01FFFF2C ; 4 bytes

; play an audio clip (does not block)
; inputs:
; r0: pointer to audio clip
; r1: length of audio clip in bytes (must be a multiple of 32768 bytes)
; r2: audio sample rate
; r3: audio channel (0-3)
; outputs:
; none
play_audio:
    push r0
    push r1

    cmp r3, 0
    ifz jmp play_audio_0
    cmp r3, 1
    ifz jmp play_audio_1
    cmp r3, 2
    ifz jmp play_audio_2
    cmp r3, 3
    ifz jmp play_audio_3
    jmp play_audio_done
play_audio_0:
    ; set the interrupt vector for interrupt 0xFE
    ; save the old one only if it wasn't already saved earlier
    cmp [OLD_BUFFER_SWAP_VECTOR_0], refill_buffer_0
    ifnz mov [OLD_BUFFER_SWAP_VECTOR_0], [0x000003F8]
    mov [0x000003F8], refill_buffer_0

    ; store audio pointer
    mov [AUDIO_POINTER_0], r0

    ; store audio length
    ; floor it to the nearest multiple of 32768
    and r1, 0xFFFF8000
    mov [AUDIO_LENGTH_0], r1

    ; enable audio playback and set sample rate
    mov r0, 0x80000600
    out r0, r2

    ; initial buffer fill
    int 0xFE

    jmp play_audio_done
play_audio_1:
    ; set the interrupt vector for interrupt 0xFD
    ; save the old one only if it wasn't already saved earlier
    cmp [OLD_BUFFER_SWAP_VECTOR_1], refill_buffer_1
    ifnz mov [OLD_BUFFER_SWAP_VECTOR_1], [0x000003F4]
    mov [0x000003F4], refill_buffer_1

    ; store audio pointer
    mov [AUDIO_POINTER_1], r0

    ; store audio length
    ; floor it to the nearest multiple of 32768
    and r1, 0xFFFF8000
    mov [AUDIO_LENGTH_1], r1

    ; enable audio playback and set sample rate
    mov r0, 0x80000601
    out r0, r2

    ; initial buffer fill
    int 0xFD

    jmp play_audio_done
play_audio_2:
    ; set the interrupt vector for interrupt 0xFC
    ; save the old one only if it wasn't already saved earlier
    cmp [OLD_BUFFER_SWAP_VECTOR_2], refill_buffer_2
    ifnz mov [OLD_BUFFER_SWAP_VECTOR_2], [0x000003F0]
    mov [0x000003F0], refill_buffer_2

    ; store audio pointer
    mov [AUDIO_POINTER_2], r0

    ; store audio length
    ; floor it to the nearest multiple of 32768
    and r1, 0xFFFF8000
    mov [AUDIO_LENGTH_2], r1

    ; enable audio playback and set sample rate
    mov r0, 0x80000602
    out r0, r2

    ; initial buffer fill
    int 0xFC

    jmp play_audio_done
play_audio_3:
    ; set the interrupt vector for interrupt 0xFB
    ; save the old one only if it wasn't already saved earlier
    cmp [OLD_BUFFER_SWAP_VECTOR_3], refill_buffer_3
    ifnz mov [OLD_BUFFER_SWAP_VECTOR_3], [0x000003EC]
    mov [0x000003EC], refill_buffer_3

    ; store audio pointer
    mov [AUDIO_POINTER_3], r0

    ; store audio length
    ; floor it to the nearest multiple of 32768
    and r1, 0xFFFF8000
    mov [AUDIO_LENGTH_3], r1

    ; enable audio playback and set sample rate
    mov r0, 0x80000603
    out r0, r2

    ; initial buffer fill
    int 0xFB
play_audio_done:
    pop r1
    pop r0
    ret

; stop audio playback
; inputs:
; r0: audio channel (0-3)
; outputs:
; none
stop_audio:
    push r0

    ; disable audio playback
    or r0, 0x80000600
    out r0, 0

    ; restore the old buffer refill vector
    cmp.8 r0, 0
    ifz mov [0x000003F8], [OLD_BUFFER_SWAP_VECTOR_0]
    cmp.8 r0, 1
    ifz mov [0x000003F4], [OLD_BUFFER_SWAP_VECTOR_1]
    cmp.8 r0, 2
    ifz mov [0x000003F0], [OLD_BUFFER_SWAP_VECTOR_2]
    cmp.8 r0, 3
    ifz mov [0x000003EC], [OLD_BUFFER_SWAP_VECTOR_3]

    pop r0
    ret

refill_buffer_0:
    add rsp, 4
    push r0
    push r1
    push r31

    mov r31, 8192 ; 32768 bytes = 8192 words
    mov r0, [AUDIO_POINTER_0]
    mov r1, 0x0212C000 ; buffer 0 address
refill_buffer_0_loop:
    mov [r1], [r0]
    add r0, 4
    add r1, 4
    loop refill_buffer_0_loop
    mov [AUDIO_POINTER_0], r0
    sub [AUDIO_LENGTH_0], 32768
    ifz mov r0, 0
    ifz call stop_audio

    pop r31
    pop r1
    pop r0
    reti

refill_buffer_1:
    add rsp, 4
    push r0
    push r1
    push r31

    mov r31, 8192 ; 32768 bytes = 8192 words
    mov r0, [AUDIO_POINTER_1]
    mov r1, 0x02134000 ; buffer 1 address
refill_buffer_1_loop:
    mov [r1], [r0]
    add r0, 4
    add r1, 4
    loop refill_buffer_1_loop
    mov [AUDIO_POINTER_1], r0
    sub [AUDIO_LENGTH_1], 32768
    ifz mov r0, 1
    ifz call stop_audio

    pop r31
    pop r1
    pop r0
    reti

refill_buffer_2:
    add rsp, 4
    push r0
    push r1
    push r31

    mov r31, 8192 ; 32768 bytes = 8192 words
    mov r0, [AUDIO_POINTER_2]
    mov r1, 0x02290000 ; buffer 2 address
refill_buffer_2_loop:
    mov [r1], [r0]
    add r0, 4
    add r1, 4
    loop refill_buffer_2_loop
    mov [AUDIO_POINTER_2], r0
    sub [AUDIO_LENGTH_2], 32768
    ifz mov r0, 2
    ifz call stop_audio

    pop r31
    pop r1
    pop r0
    reti

refill_buffer_3:
    add rsp, 4
    push r0
    push r1
    push r31

    mov r31, 8192 ; 32768 bytes = 8192 words
    mov r0, [AUDIO_POINTER_3]
    mov r1, 0x02298000 ; buffer 3 address
refill_buffer_3_loop:
    mov [r1], [r0]
    add r0, 4
    add r1, 4
    loop refill_buffer_3_loop
    mov [AUDIO_POINTER_3], r0
    sub [AUDIO_LENGTH_3], 32768
    ifz mov r0, 3
    ifz call stop_audio

    pop r31
    pop r1
    pop r0
    reti
