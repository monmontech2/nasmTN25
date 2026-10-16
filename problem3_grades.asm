
section .data
    ask_name db "What is your name? "
    ask_name_len equ $ - ask_name

    ask_id db "Enter your student ID: "
    ask_id_len equ $ - ask_id

    ask_grade db "Enter your grade (0-100): "
    ask_grade_len equ $ - ask_grade

    hello db "Hello "
    hello_len equ $ - hello

    id_msg db "Student ID: "
    id_msg_len equ $ - id_msg

    grade_msg db "Grade: "
    grade_msg_len equ $ - grade_msg

    excellent db "Excellent", 10
    excellent_len equ $ - excellent

    very_good db "Very Good", 10
    very_good_len equ $ - very_good

    good db "Good", 10
    good_len equ $ - good

    passed db "Passed", 10
    passed_len equ $ - passed

    failed db "Failed", 10
    failed_len equ $ - failed

    invalid_msg db "INVALID GRADE", 10
    invalid_len equ $ - invalid_msg

    newline db 10

section .bss
    name_buffer resb 128
    id_buffer resb 64
    grade_buffer resb 32
    number_buffer resb 16

    name_length resd 1
    id_length resd 1
    grade_value resd 1

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

    ; Ask for the student ID
    mov ecx, ask_id
    mov edx, ask_id_len
    call print_string

    mov ecx, id_buffer
    mov edx, 63
    call read_input
    mov [id_length], eax

    ; Ask for the grade
    mov ecx, ask_grade
    mov edx, ask_grade_len
    call print_string

    mov ecx, grade_buffer
    mov edx, 31
    call read_input

    ; Convert the grade from ASCII to an integer
    mov esi, grade_buffer
    xor eax, eax

parse_grade:
    mov bl, [esi]

    cmp bl, 0
    je grade_parsed

    cmp bl, '0'
    jb invalid_grade

    cmp bl, '9'
    ja invalid_grade

    imul eax, eax, 10
    sub bl, '0'
    movzx edx, bl
    add eax, edx

    inc esi
    jmp parse_grade

grade_parsed:
    mov [grade_value], eax

    ; Reject grades above 100
    cmp eax, 100
    ja invalid_grade

    ; Display the student's name
    mov ecx, hello
    mov edx, hello_len
    call print_string

    mov ecx, name_buffer
    mov edx, [name_length]
    call print_string

    mov ecx, newline
    mov edx, 1
    call print_string

    ; Display the student ID
    mov ecx, id_msg
    mov edx, id_msg_len
    call print_string

    mov ecx, id_buffer
    mov edx, [id_length]
    call print_string

    mov ecx, newline
    mov edx, 1
    call print_string

    ; Display the grade
    mov ecx, grade_msg
    mov edx, grade_msg_len
    call print_string

    mov eax, [grade_value]
    call print_unsigned

    mov ecx, newline
    mov edx, 1
    call print_string

    ; Classify the grade
    mov eax, [grade_value]

    cmp eax, 90
    jae show_excellent

    cmp eax, 85
    jae show_very_good

    cmp eax, 80
    jae show_good

    cmp eax, 75
    jae show_passed

    jmp show_failed

show_excellent:
    mov ecx, excellent
    mov edx, excellent_len
    call print_string
    jmp exit_program

show_very_good:
    mov ecx, very_good
    mov edx, very_good_len
    call print_string
    jmp exit_program

show_good:
    mov ecx, good
    mov edx, good_len
    call print_string
    jmp exit_program

show_passed:
    mov ecx, passed
    mov edx, passed_len
    call print_string
    jmp exit_program

show_failed:
    mov ecx, failed
    mov edx, failed_len
    call print_string
    jmp exit_program

invalid_grade:
    mov ecx, invalid_msg
    mov edx, invalid_len
    call print_string
    jmp exit_program

; Print a string to the terminal
print_string:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

; Print an unsigned integer in EAX
print_unsigned:
    mov ebx, 10
    mov ecx, number_buffer + 15
    mov byte [ecx], 0

    cmp eax, 0
    jne convert_digits

    dec ecx
    mov byte [ecx], '0'
    jmp print_number

convert_digits:
    xor edx, edx
    div ebx
    add dl, '0'
    dec ecx
    mov [ecx], dl
    test eax, eax
    jnz convert_digits

print_number:
    mov edx, number_buffer + 15
    sub edx, ecx

    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

; Read input and remove the newline
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

exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80
