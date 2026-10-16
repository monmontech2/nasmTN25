
section .data
    ask_name    db "What is your name? "
    ask_name_len equ $ - ask_name

    ask_age     db "How old are you? "
    ask_age_len equ $ - ask_age

    ask_gender  db "What is your gender? "
    ask_gender_len equ $ - ask_gender

    hello       db "Hello "
    hello_len   equ $ - hello

    age_text    db "You are "
    age_text_len equ $ - age_text

    years_text  db " years old", 10
    years_text_len equ $ - years_text

    male_text   db "Hello", 10
    male_len    equ $ - male_text

    female_text db "World", 10
    female_len  equ $ - female_text

    invalid_text db "INVALID", 10
    invalid_len equ $ - invalid_text

    newline     db 10

section .bss
    name_buffer   resb 128
    age_buffer    resb 32
    gender_buffer resb 32

section .text
global _start

_start:
    ; Ask for the full name
    mov ecx, ask_name
    mov edx, ask_name_len
    call print_string

    mov ecx, name_buffer
    mov edx, 127
    call read_input
    mov [name_length], eax

    ; Ask for the age
    mov ecx, ask_age
    mov edx, ask_age_len
    call print_string

    mov ecx, age_buffer
    mov edx, 31
    call read_input
    mov [age_length], eax

    ; Ask for gender
    mov ecx, ask_gender
    mov edx, ask_gender_len
    call print_string

    mov ecx, gender_buffer
    mov edx, 31
    call read_input

    ; Print the greeting
    mov ecx, hello
    mov edx, hello_len
    call print_string

    mov ecx, name_buffer
    mov edx, [name_length]
    call print_string

    mov ecx, newline
    mov edx, 1
    call print_string

    ; Print the age
    mov ecx, age_text
    mov edx, age_text_len
    call print_string

    mov ecx, age_buffer
    mov edx, [age_length]
    call print_string

    mov ecx, years_text
    mov edx, years_text_len
    call print_string

    ; Check gender: M/m or F/f
    mov al, [gender_buffer]

    cmp al, 'M'
    je male

    cmp al, 'm'
    je male

    cmp al, 'F'
    je female

    cmp al, 'f'
    je female

    jmp invalid

male:
    mov ecx, male_text
    mov edx, male_len
    call print_string
    jmp exit_program

female:
    mov ecx, female_text
    mov edx, female_len
    call print_string
    jmp exit_program

invalid:
    mov ecx, invalid_text
    mov edx, invalid_len
    call print_string
    jmp exit_program

; Procedure to print text
print_string:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

; Procedure to read input and remove the line ending
; ECX = buffer address, EDX = maximum input length
read_input:
    mov eax, 3
    mov ebx, 0
    int 0x80

    cmp eax, 0
    jle read_done

    ; Remove the newline character
    dec eax
    mov byte [ecx + eax], 0
    ret

read_done:
    xor eax, eax
    ret

exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80

section .bss
    name_length resd 1
    age_length  resd 1
