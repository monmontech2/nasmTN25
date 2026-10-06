; ============================================================
; ASCII ART DESIGN
; NASM 32-bit Assembly Language
; ============================================================
; This program displays an ASCII-art design in the terminal.
;
; Requirements:
; - NASM 32-bit Assembly Language
; - .data and .text sections
; - Linux int 0x80 and sys_write
; - Loop for repeated printing
; - Procedure/function for printing
; - Comments
; ============================================================

section .data

; ------------------------------------------------------------
; ASCII ART
; ------------------------------------------------------------

line1  db "                         ___________", 10
len1   equ $ - line1

line2  db "                    _.-'             '-._", 10
len2   equ $ - line2

line3  db "                 .-'                     '-.", 10
len3   equ $ - line3

line4  db "               .'       .---------.         '.", 10
len4   equ $ - line4

line5  db "              /        /           \          \", 10
len5   equ $ - line5

line6  db "             /        |      @      |           \", 10
len6   equ $ - line6

line7  db "            ;         |      #      |            ;", 10
len7   equ $ - line7

line8  db "            |          \     -     /             |", 10
len8   equ $ - line8

line9  db "            |           '---------'              |", 10
len9   equ $ - line9

line10 db "            ;                |                   ;", 10
len10  equ $ - line10

line11 db "             \               |                  /", 10
len11  equ $ - line11

line12 db "              '.             |                .'", 10
len12  equ $ - line12

line13 db "                '-._         |          _.-'", 10
len13  equ $ - line13

line14 db "                    '--------|--------'", 10
len14  equ $ - line14

line15 db "                            /|\", 10
len15  equ $ - line15

line16 db "                           / | \", 10
len16  equ $ - line16

line17 db "                          /  |  \", 10
len17  equ $ - line17

line18 db "                         /   |   \", 10
len18  equ $ - line18

line19 db "                        /____|____\", 10
len19  equ $ - line19

line20 db "                       |  DDDDDD  |", 10
len20  equ $ - line20

line21 db "                       | DDDDDDDD |", 10
len21  equ $ - line21

line22 db "                       |DDDDDDDDDD|", 10
len22  equ $ - line22

line23 db "                       |DDDDDDDDDD|", 10
len23  equ $ - line23

line24 db "                        \DDDDDDDD/", 10
len24  equ $ - line24

line25 db "                         \DDDDDD/", 10
len25  equ $ - line25

line26 db "                          \DDDD/", 10
len26  equ $ - line26

line27 db "                           \DD/", 10
len27  equ $ - line27

line28 db "                            \/ ", 10
len28  equ $ - line28

; ------------------------------------------------------------
; Array of addresses of all ASCII-art lines.
; This is used by the loop in the .text section.
; ------------------------------------------------------------

lines:
    dd line1, line2, line3, line4
    dd line5, line6, line7, line8
    dd line9, line10, line11, line12
    dd line13, line14, line15, line16
    dd line17, line18, line19, line20
    dd line21, line22, line23, line24
    dd line25, line26, line27, line28

; ------------------------------------------------------------
; Array containing the length of every line.
; ------------------------------------------------------------

lengths:
    dd len1, len2, len3, len4
    dd len5, len6, len7, len8
    dd len9, len10, len11, len12
    dd len13, len14, len15, len16
    dd len17, len18, len19, len20
    dd len21, len22, len23, len24
    dd len25, len26, len27, len28

line_count equ 28


section .text

global _start

; ============================================================
; PROCEDURE: print_line
;
; Prints one line using Linux sys_write.
;
; ECX = address of the line
; EDX = length of the line
; ============================================================

print_line:

    mov eax, 4          ; sys_write system call
    mov ebx, 1          ; file descriptor 1 = standard output
    int 0x80            ; call Linux kernel

    ret                 ; return to the loop


; ============================================================
; PROGRAM START
; ============================================================

_start:

    ; ESI stores the current line number.
    xor esi, esi

print_loop:

    ; Check if all lines have been printed.
    cmp esi, line_count
    jge exit_program

    ; --------------------------------------------------------
    ; Get the address of the current ASCII-art line.
    ; --------------------------------------------------------

    mov eax, esi
    mov ecx, [lines + eax*4]

    ; --------------------------------------------------------
    ; Get the length of the current line.
    ; --------------------------------------------------------

    mov edx, [lengths + eax*4]

    ; --------------------------------------------------------
    ; Call the printing procedure.
    ; --------------------------------------------------------

    call print_line

    ; Move to the next line.
    inc esi

    ; Repeat until all lines are printed.
    jmp print_loop


; ============================================================
; EXIT PROGRAM
; ============================================================

exit_program:

    mov eax, 1          ; sys_exit system call
    xor ebx, ebx        ; exit status = 0
    int 0x80
