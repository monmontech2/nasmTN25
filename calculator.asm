
BITS 32
GLOBAL _start

SECTION .data
menu db 10, "----------------------------------", 10
     db "MENU", 10
     db "[A]dd", 10
     db "[S]ubtract", 10
     db "[M]ultiply", 10
     db "[D]ivide", 10
     db "----------------------------------", 10
     db "Enter your choice: "
menu_len equ $-menu

prompt1 db "Enter first number (-99 to 99): "
prompt1_len equ $-prompt1
prompt2 db "Enter second number (-99 to 99): "
prompt2_len equ $-prompt2
again_prompt db "Do you want to try again (Y/N)? "
again_len equ $-again_prompt

sum_msg db "The sum is "
sum_len equ $-sum_msg
diff_msg db "The difference is "
diff_len equ $-diff_msg
prod_msg db "The product is "
prod_len equ $-prod_msg
quot_msg db "The quotient is "
quot_len equ $-quot_msg
remainder_msg db "The remainder is "
remainder_len equ $-remainder_msg

invalid_choice db "Invalid choice. Please enter A, S, M, or D.", 10
invalid_choice_len equ $-invalid_choice
invalid_number db "Invalid input. Enter an integer from -99 to 99.", 10
invalid_number_len equ $-invalid_number
divide_zero db "Error: cannot divide by zero.", 10
divide_zero_len equ $-divide_zero
newline db 10

SECTION .bss
input resb 32
num1 resd 1
num2 resd 1
result resd 1
remainder resd 1
outbuf resb 16

SECTION .text
_start:
menu_loop:
    ; Clear screen
    mov eax, 4
    mov ebx, 1
    mov ecx, clear_screen
    mov edx, clear_screen_len
    int 0x80

    mov ecx, menu
    mov edx, menu_len
    call print

    call read_line
    mov al, [input]
    cmp al, 'a'
    je .lower_a
    cmp al, 'A'
    je .add
    cmp al, 's'
    je .lower_s
    cmp al, 'S'
    je .subtract
    cmp al, 'm'
    je .lower_m
    cmp al, 'M'
    je .multiply
    cmp al, 'd'
    je .lower_d
    cmp al, 'D'
    je .divide
    jmp .invalid

.lower_a:
    jmp .add
.lower_s:
    jmp .subtract
.lower_m:
    jmp .multiply
.lower_d:
    jmp .divide

.invalid:
    mov ecx, invalid_choice
    mov edx, invalid_choice_len
    call print
    jmp ask_again

.add:
    call get_two_numbers
    jc ask_again
    mov eax, [num1]
    add eax, [num2]
    mov [result], eax
    mov ecx, sum_msg
    mov edx, sum_len
    call print
    mov eax, [result]
    call print_number
    call print_newline
    jmp ask_again

.subtract:
    call get_two_numbers
    jc ask_again
    mov eax, [num1]
    sub eax, [num2]
    mov [result], eax
    mov ecx, diff_msg
    mov edx, diff_len
    call print
    mov eax, [result]
    call print_number
    call print_newline
    jmp ask_again

.multiply:
    call get_two_numbers
    jc ask_again
    mov eax, [num1]
    imul eax, dword [num2]
    mov [result], eax
    mov ecx, prod_msg
    mov edx, prod_len
    call print
    mov eax, [result]
    call print_number
    call print_newline
    jmp ask_again

.divide:
    call get_two_numbers
    jc ask_again
    cmp dword [num2], 0
    je .zero
    mov eax, [num1]
    cdq
    idiv dword [num2]
    mov [result], eax
    mov [remainder], edx
    mov ecx, quot_msg
    mov edx, quot_len
    call print
    mov eax, [result]
    call print_number
    call print_newline
    mov ecx, remainder_msg
    mov edx, remainder_len
    call print
    mov eax, [remainder]
    call print_number
    call print_newline
    jmp ask_again

.zero:
    mov ecx, divide_zero
    mov edx, divide_zero_len
    call print
    jmp ask_again

ask_again:
    mov ecx, again_prompt
    mov edx, again_len
    call print
    call read_line
    mov al, [input]
    cmp al, 'Y'
    je menu_loop
    cmp al, 'y'
    je menu_loop
    jmp exit_program

get_two_numbers:
    mov ecx, prompt1
    mov edx, prompt1_len
    call print
    call read_line
    call parse_number
    jc .bad
    mov [num1], eax

    mov ecx, prompt2
    mov edx, prompt2_len
    call print
    call read_line
    call parse_number
    jc .bad
    mov [num2], eax
    clc
    ret

.bad:
    mov ecx, invalid_number
    mov edx, invalid_number_len
    call print
    stc
    ret

print:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

print_newline:
    mov ecx, newline
    mov edx, 1
    call print
    ret

read_line:
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 31
    int 0x80
    cmp eax, 0
    jle exit_program
    mov byte [input + eax - 1], 0
    ret

parse_number:
    mov esi, input
    xor eax, eax
    xor ebx, ebx
    cmp byte [esi], '-'
    jne .digits
    mov bl, 1
    inc esi

.digits:
    cmp byte [esi], '0'
    jb .bad
    cmp byte [esi], '9'
    ja .bad
    movzx eax, byte [esi]
    sub eax, '0'
    inc esi
    cmp byte [esi], 0
    je .sign
    cmp byte [esi], '0'
    jb .bad
    cmp byte [esi], '9'
    ja .bad
    imul eax, eax, 10
    movzx edx, byte [esi]
    sub edx, '0'
    add eax, edx
    inc esi
    cmp byte [esi], 0
    jne .bad

.sign:
    cmp eax, 99
    ja .bad
    test bl, bl
    jz .ok
    neg eax

.ok:
    clc
    ret

.bad:
    stc
    ret

print_number:
    mov edi, outbuf + 15
    mov byte [edi], 0
    mov ebx, 10
    xor esi, esi
    test eax, eax
    jns .convert
    neg eax
    mov esi, 1

.convert:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .convert
    test esi, esi
    jz .write
    dec edi
    mov byte [edi], '-'

.write:
    mov ecx, edi
    mov edx, outbuf + 15
    sub edx, edi
    call print
    ret

exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80

SECTION .rodata
clear_screen db 27, '[2J', 27, '[H'
clear_screen_len equ $-clear_screen
