
section .data
    ask_name db "What is your name? "
    ask_name_len equ $ - ask_name

    ask_age db "How old are you? "
    ask_age_len equ $ - ask_age

    ask_year db "Enter your year level (1-4): "
    ask_year_len equ $ - ask_year

    hello db "Hello "
    hello_len equ $ - hello

    you_are db "You are "
    you_are_len equ $ - you_are

    years_old db " years old", 10
    years_old_len equ $ - years_old

    freshman db "Freshman", 10
    freshman_len equ $ - freshman

    sophomore db "Sophomore", 10
    sophomore_len equ $ - sophomore

    junior db "Junior", 10
    junior_len equ $ - junior

    senior db "Senior", 10
    senior_len equ $ - senior

    invalid_msg db "INVALID YEAR LEVEL", 10
    invalid_len equ $ - invalid_msg

    newline db 10

section .bss
    name_buffer resb 128
    age_buffer resb 32
    year_buffer resb 32
    name_length resd 1
    age_length resd 1

section .text
global _start

_start:
    ; Ask for the student's name
    mov ecx, ask_name
    mov edx, ask_name_len
    call print_string

    mov ecx, name_buffer
    mov edx, 127
    call read_input
    mov [name_length], eax

    ; Ask for the student's age
    mov ecx, ask_age
    mov edx, ask_age_len
    call print_string

    mov ecx, age_buffer
    mov edx, 31
    call read_input
    mov [age_length], eax

    ; Ask for the year level
    mov ecx, ask_year
    mov edx, ask_year_len
    call print_string

    mov ecx, year_buffer
    mov edx, 31
    call read_input

    ; Print the student's name
    mov ecx, hello
    mov edx, hello_len
    call print_string

    mov ecx, name_buffer
    mov edx, [name_length]
    call print_string

    mov ecx, newline
    mov edx, 1
    call print_string

    ; Print the student's age
    mov ecx, you_are
    mov edx, you_are_len
    call print_string

    mov ecx, age_buffer
    mov edx, [age_length]
    call print_string

    mov ecx, years_old
    mov edx, years_old_len
    call print_string

    ; Check the year level
    cmp byte [year_buffer], '1'
    je show_freshman

    cmp byte [year_buffer], '2'
    je show_sophomore

    cmp byte [year_buffer], '3'
    je show_junior

    cmp byte [year_buffer], '4'
    je show_senior

    jmp show_invalid

show_freshman:
    mov ecx, freshman
    mov edx, freshman_len
    call print_string
    jmp exit_program

show_sophomore:
    mov ecx, sophomore
    mov edx, sophomore_len
    call print_string
    jmp exit_program

show_junior:
    mov ecx, junior
    mov edx, junior_len
    call print_string
    jmp exit_program

show_senior:
    mov ecx, senior
    mov edx, senior_len
    call print_string
    jmp exit_program

show_invalid:
    mov ecx, invalid_msg
    mov edx, invalid_len
    call print_string

exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; Display text
print_string:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

; Read input and remove the line ending
read_input:
    mov eax, 3
    mov ebx, 0
    int 0x80

    cmp eax, 0
    jle read_done

    dec eax
    mov byte [ecx + eax], 0
    ret

read_done:
    xor eax, eax
    ret
