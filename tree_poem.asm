section .data
    line1  db "             I", 10
    len1   equ $ - line1

    line2  db "           wrote", 10
    len2   equ $ - line2

    line3  db "          a poem", 10
    len3   equ $ - line3

    line4  db "        in the shape", 10
    len4   equ $ - line4

    line5  db "      of a Christmas", 10
    len5   equ $ - line5

    line6  db "    tree but then forgot", 10
    len6   equ $ - line6

    line7  db "  to water it and only a few", 10
    len7   equ $ - line7

    line8  db "             days", 10
    len8   equ $ - line8

    line9  db "             later", 10, 10
    len9   equ $ - line9

    line10 db "             there", 10
    len10  equ $ - line10

    line11 db "           were", 10
    len11  equ $ - line11

    line12 db "                    words", 10
    len12  equ $ - line12

    line13 db "          all", 10
    len13  equ $ - line13

    line14 db "                 over", 10
    len14  equ $ - line14

    line15 db "          the", 10
    len15  equ $ - line15

    line16 db "                            carpet", 10
    len16  equ $ - line16

section .text
    global _start

; MACRO: prints a string to the terminal
%macro PRINT_LINE 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

_start:
    call print_poem

    ; Exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80

; PROCEDURE: displays the complete tree poem
print_poem:
    PRINT_LINE line1, len1
    PRINT_LINE line2, len2
    PRINT_LINE line3, len3
    PRINT_LINE line4, len4
    PRINT_LINE line5, len5
    PRINT_LINE line6, len6
    PRINT_LINE line7, len7
    PRINT_LINE line8, len8
    PRINT_LINE line9, len9
    PRINT_LINE line10, len10
    PRINT_LINE line11, len11
    PRINT_LINE line12, len12
    PRINT_LINE line13, len13
    PRINT_LINE line14, len14
    PRINT_LINE line15, len15
    PRINT_LINE line16, len16

    ret
