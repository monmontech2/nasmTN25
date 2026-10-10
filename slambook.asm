; ============================================================
; SLAMBOOK APPLICATION
; Computer System and Architecture - Midterm Machine Problem
; 32-bit NASM Assembly for Linux (int 0x80)
; ============================================================
; This program asks the user for basic slambook information and
; displays a neatly arranged ASCII-art slambook card.
;
; Build:
;   nasm -f elf32 slambook.asm -o slambook.o
;   ld -m elf_i386 slambook.o -o slambook
; Run:
;   ./slambook
; ============================================================

section .data
    title       db 10, "  .----------------------------------------------.", 10
                db "  |              * MY SLAMBOOK *                 |", 10
                db "  |        FRIENDSHIP - MEMORIES - FUN            |", 10
                db "  '----------------------------------------------'", 10, 0
    prompt_name db 10, "  Enter your full name: ", 0
    prompt_nick db "  Enter your nickname: ", 0
    prompt_color db "  Enter your favorite color: ", 0
    prompt_hobby db "  Enter one hobby: ", 0
    prompt_motto db "  Enter your personal motto: ", 0

    card_top    db 10, "  +--------------------------------------------------+", 10, 0
    card_head   db "  |                  SLAMBOOK PROFILE               |", 10, 0
    card_mid    db "  +--------------------------------------------------+", 10, 0
    label_name  db "  |  NAME      : ", 0
    label_nick  db "  |  NICKNAME  : ", 0
    label_color db "  |  COLOR     : ", 0
    label_hobby db "  |  HOBBY     : ", 0
    label_motto db "  |  MOTTO     : ", 0
    card_bottom db "  +--------------------------------------------------+", 10
                db "  |   Thanks for sharing your memories!             |", 10
                db "  '--------------------------------------------------'", 10
                db "             .-.-.  FRIENDS FOREVER  .-.-.", 10, 10, 0
    newline     db 10, 0

section .bss
    name_buf    resb 80
    nick_buf    resb 40
    color_buf   resb 40
    hobby_buf   resb 60
    motto_buf   resb 80

section .text
    global _start

_start:
    mov ecx, title
    call print_string

    mov ecx, prompt_name
    call print_string
    mov ecx, name_buf
    mov edx, 80
    call read_input

    mov ecx, prompt_nick
    call print_string
    mov ecx, nick_buf
    mov edx, 40
    call read_input

    mov ecx, prompt_color
    call print_string
    mov ecx, color_buf
    mov edx, 40
    call read_input

    mov ecx, prompt_hobby
    call print_string
    mov ecx, hobby_buf
    mov edx, 60
    call read_input

    mov ecx, prompt_motto
    call print_string
    mov ecx, motto_buf
    mov edx, 80
    call read_input

    mov ecx, card_top
    call print_string
    mov ecx, card_head
    call print_string
    mov ecx, card_mid
    call print_string

    mov ecx, label_name
    call print_string
    mov ecx, name_buf
    call print_string
    call print_newline

    mov ecx, label_nick
    call print_string
    mov ecx, nick_buf
    call print_string
    call print_newline

    mov ecx, label_color
    call print_string
    mov ecx, color_buf
    call print_string
    call print_newline

    mov ecx, label_hobby
    call print_string
    mov ecx, hobby_buf
    call print_string
    call print_newline

    mov ecx, label_motto
    call print_string
    mov ecx, motto_buf
    call print_string
    call print_newline

    mov ecx, card_bottom
    call print_string

    mov eax, 1              ; sys_exit
    xor ebx, ebx
    int 0x80

; print_string: writes a zero-terminated string to stdout.
; Input: ECX = address of string.
print_string:
    push ecx
    mov edx, ecx
    xor eax, eax
.count:
    cmp byte [edx], 0
    je .write
    inc edx
    inc eax
    jmp .count
.write:
    mov edx, eax
    pop ecx
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    int 0x80
    ret

; read_input: reads one line from stdin into a buffer.
; Input: ECX = buffer address, EDX = maximum bytes.
read_input:
    mov eax, 3              ; sys_read
    mov ebx, 0              ; stdin
    int 0x80
    ; Replace the final line-feed with NUL for print_string.
    test eax, eax
    jle .done
    mov byte [ecx + eax - 1], 0
.done:
    ret

print_newline:
    push ecx
    mov ecx, newline
    call print_string
    pop ecx
    ret