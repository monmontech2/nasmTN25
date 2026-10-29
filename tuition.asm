
%macro print_text 2
    mov ecx, %1
    mov edx, %2
    call print_proc
%endmacro

section .data
    title db 10, "=== FEU TECH TUITION FEE ===", 10
    title_len equ $-title

    msg1 db "Enter Tuition Fee: "
    len1 equ $-msg1

    msg2 db "Enter Miscellaneous Fee: "
    len2 equ $-msg2

    msg3 db "Enter ID Validation Fee: "
    len3 equ $-msg3

    msg4 db "Enter Lab Fee CCS0021: "
    len4 equ $-msg4

    msg5 db "Enter Lab Fee CS0003: "
    len5 equ $-msg5

    msg6 db "Enter Lab Fee CS0070: "
    len6 equ $-msg6

    msg7 db "Enter Science Lab Fee: "
    len7 equ $-msg7

    total_msg db 10, "Total Assessment: P"
    total_len equ $-total_msg

    down_msg db "Down Payment (40%): P"
    down_len equ $-down_msg

    mid_msg db "Midterm (30%): P"
    mid_len equ $-mid_msg

    final_msg db "Final (30%): P"
    final_len equ $-final_msg

    newline db 10

section .bss
    input resb 32
    number resd 1
    total resd 1
    down resd 1
    mid resd 1
    final resd 1

    outbuf resb 16

section .text
    global _start

_start:
    print_text title, title_len

    print_text msg1, len1
    call read_proc
    mov eax, [number]
    mov [total], eax

    print_text msg2, len2
    call read_proc
    add [total], eax

    print_text msg3, len3
    call read_proc
    add [total], eax

    print_text msg4, len4
    call read_proc
    add [total], eax

    print_text msg5, len5
    call read_proc
    add [total], eax

    print_text msg6, len6
    call read_proc
    add [total], eax

    print_text msg7, len7
    call read_proc
    add [total], eax

    ; Compute 40% down payment
    mov eax, [total]
    imul eax, 40
    xor edx, edx
    mov ebx, 100
    div ebx
    mov [down], eax

    ; Compute 30% midterm
    mov eax, [total]
    imul eax, 30
    xor edx, edx
    mov ebx, 100
    div ebx
    mov [mid], eax

    ; Compute 30% final
    mov eax, [total]
    imul eax, 30
    xor edx, edx
    mov ebx, 100
    div ebx
    mov [final], eax

    ; Display total
    print_text total_msg, total_len
    mov eax, [total]
    call print_num

    ; Display down payment
    print_text down_msg, down_len
    mov eax, [down]
    call print_num

    ; Display midterm
    print_text mid_msg, mid_len
    mov eax, [mid]
    call print_num

    ; Display final
    print_text final_msg, final_len
    mov eax, [final]
    call print_num

    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

; =================================
; PROCEDURE: PRINT TEXT
; =================================
print_proc:
    push eax
    push ebx

    mov eax, 4
    mov ebx, 1
    int 0x80

    pop ebx
    pop eax
    ret

; =================================
; PROCEDURE: READ INPUT
; =================================
read_proc:
    push ebx
    push ecx
    push edx
    push esi

    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 32
    int 0x80

    ; Convert ASCII to integer
    xor eax, eax
    mov esi, input

convert:
    movzx ebx, byte [esi]

    cmp bl, 10
    je done_read

    cmp bl, 13
    je done_read

    cmp bl, 0
    je done_read

    sub ebx, '0'

    cmp ebx, 9
    ja done_read

    imul eax, 10
    add eax, ebx

    inc esi
    jmp convert

done_read:
    mov [number], eax

    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

; =================================
; PROCEDURE: PRINT NUMBER
; =================================
print_num:
    push ebx
    push ecx
    push edx
    push esi

    mov esi, outbuf
    add esi, 15

    mov byte [esi], 10
    dec esi

    mov ebx, 10

convert_num:
    xor edx, edx
    div ebx

    add dl, '0'
    mov [esi], dl

    dec esi

    test eax, eax
    jnz convert_num

    inc esi

    mov eax, 4
    mov ebx, 1
    mov ecx, esi

    mov edx, outbuf
    add edx, 15
    sub edx, esi

    int 0x80

    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
