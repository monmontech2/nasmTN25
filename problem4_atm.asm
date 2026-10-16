
section .data
    ask_name db "Enter account name: "
    ask_name_len equ $ - ask_name

    ask_pin db "Enter PIN: "
    ask_pin_len equ $ - ask_pin

    ask_amount db "Enter withdrawal amount (PHP): "
    ask_amount_len equ $ - ask_amount

    access_granted db "ACCESS GRANTED", 10
    access_granted_len equ $ - access_granted

    access_denied db "ACCESS DENIED", 10
    access_denied_len equ $ - access_denied

    balance_msg db "Current balance: PHP "
    balance_msg_len equ $ - balance_msg

    remaining_msg db "Remaining balance: PHP "
    remaining_msg_len equ $ - remaining_msg

    invalid_msg db "INVALID AMOUNT", 10
    invalid_len equ $ - invalid_msg

    insufficient_msg db "INSUFFICIENT FUNDS", 10
    insufficient_len equ $ - insufficient_msg

    multiple_msg db "AMOUNT MUST BE A MULTIPLE OF 100", 10
    multiple_len equ $ - multiple_msg

    success_msg db "WITHDRAWAL SUCCESSFUL", 10
    success_len equ $ - success_msg

    newline db 10

    correct_pin db "1234", 0

section .bss
    name_buffer resb 128
    pin_buffer resb 32
    amount_buffer resb 32
    number_buffer resb 16

    balance resd 1
    name_length resd 1

section .text
global _start

_start:
    ; Initial ATM balance: PHP 10,000
    mov dword [balance], 10000

    ; Ask for account name
    mov ecx, ask_name
    mov edx, ask_name_len
    call print_string

    mov ecx, name_buffer
    mov edx, 127
    call read_input
    mov [name_length], eax

    ; Ask for PIN
    mov ecx, ask_pin
    mov edx, ask_pin_len
    call print_string

    mov ecx, pin_buffer
    mov edx, 31
    call read_input

    ; Compare PIN with 1234
    mov esi, pin_buffer
    mov edi, correct_pin

check_pin:
    mov al, [esi]
    cmp al, [edi]
    jne pin_denied

    cmp al, 0
    je pin_granted

    inc esi
    inc edi
    jmp check_pin

pin_denied:
    mov ecx, access_denied
    mov edx, access_denied_len
    call print_string
    jmp exit_program

pin_granted:
    mov ecx, access_granted
    mov edx, access_granted_len
    call print_string

    ; Display current balance
    mov ecx, balance_msg
    mov edx, balance_msg_len
    call print_string

    mov eax, [balance]
    call print_unsigned

    mov ecx, newline
    mov edx, 1
    call print_string

    ; Ask for withdrawal amount
    mov ecx, ask_amount
    mov edx, ask_amount_len
    call print_string

    mov ecx, amount_buffer
    mov edx, 31
    call read_input

    ; Validate and convert amount
    mov esi, amount_buffer
    xor eax, eax
    xor ebx, ebx

parse_amount:
    mov bl, [esi]

    cmp bl, 0
    je amount_parsed

    cmp bl, '0'
    jb invalid_amount

    cmp bl, '9'
    ja invalid_amount

    imul eax, eax, 10
    sub bl, '0'
    movzx edx, bl
    add eax, edx

    inc esi
    jmp parse_amount

amount_parsed:
    ; Withdrawal must be positive
    cmp eax, 0
    je invalid_amount

    ; Withdrawal cannot exceed balance
    cmp eax, [balance]
    ja insufficient_funds

    ; Withdrawal must be a multiple of 100
    xor edx, edx
    mov ebx, 100
    div ebx

    cmp edx, 0
    jne invalid_multiple

    ; Convert amount again for balance subtraction
    mov esi, amount_buffer
    xor eax, eax

convert_again:
    mov bl, [esi]
    cmp bl, 0
    je subtract_amount

    imul eax, eax, 10
    sub bl, '0'
    movzx edx, bl
    add eax, edx

    inc esi
    jmp convert_again

subtract_amount:
    ; Update balance
    sub dword [balance], eax

    mov ecx, success_msg
    mov edx, success_len
    call print_string

    mov ecx, remaining_msg
    mov edx, remaining_msg_len
    call print_string

    mov eax, [balance]
    call print_unsigned

    mov ecx, newline
    mov edx, 1
    call print_string
    jmp exit_program

invalid_amount:
    mov ecx, invalid_msg
    mov edx, invalid_len
    call print_string
    jmp exit_program

insufficient_funds:
    mov ecx, insufficient_msg
    mov edx, insufficient_len
    call print_string
    jmp exit_program

invalid_multiple:
    mov ecx, multiple_msg
    mov edx, multiple_len
    call print_string
    jmp exit_program

; Print a string to the terminal
print_string:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

; Print unsigned integer in EAX
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

; Read input and remove newline
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
