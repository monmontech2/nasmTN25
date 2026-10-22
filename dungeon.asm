
; Machine Problem No. 2
; Dungeon Adventure and Survival Game
; NASM 32-bit Linux

section .data
    welcome db 10, "====================================", 10
            db "      DUNGEON OF THE LOST KING", 10
            db "====================================", 10
            db "             |>>>>", 10
            db "             |", 10
            db "          _ _|_ _", 10
            db "         |;|_|;|_|;|", 10
            db "          ENTER IF YOU DARE!", 10
            db "====================================", 10
    welcome_len equ $ - welcome

    askname db "Enter your hero name: "
    askname_len equ $ - askname

    classmenu db 10, "Choose your character:", 10
              db "[1] Warrior", 10
              db "[2] Mage", 10
              db "[3] Archer", 10
              db "Enter choice: "
    classmenu_len equ $ - classmenu

    invalid db "Invalid choice. Try again.", 10
    invalid_len equ $ - invalid

    mainmenu db 10, "===== MAIN MENU =====", 10
             db "[1] Explore Dungeon", 10
             db "[2] View Character Status", 10
             db "[3] Use Health Potion", 10
             db "[4] View Inventory", 10
             db "[5] Exit Game", 10
             db "Enter choice: "
    mainmenu_len equ $ - mainmenu

    warrior_msg db "You selected Warrior!", 10
                db "Health: 100 | Attack: 20 | Potions: 2", 10
    warrior_len equ $ - warrior_msg

    mage_msg db "You selected Mage!", 10
             db "Health: 70 | Attack: 30 | Potions: 3", 10
    mage_len equ $ - mage_msg

    archer_msg db "You selected Archer!", 10
               db "Health: 85 | Attack: 25 | Potions: 2", 10
    archer_len equ $ - archer_msg

    statusmsg db 10, "===== CHARACTER STATUS =====", 10
    statusmsg_len equ $ - statusmsg

    healthmsg db "Health: "
    healthmsg_len equ $ - healthmsg

    attackmsg db "Attack: "
    attackmsg_len equ $ - attackmsg

    potionmsg db "Potions: "
    potionmsg_len equ $ - potionmsg

    goldmsg db "Gold: "
    goldmsg_len equ $ - goldmsg

    goblinmsg db 10, "ROOM 1: GOBLIN CHAMBER", 10
              db "       ,       ,", 10
              db "      /  .---.  \", 10
              db "     |  o   o  |", 10
              db "      \   ^   /", 10
              db "       '-----'", 10
              db "A GOBLIN APPEARS!", 10
    goblin_len equ $ - goblinmsg

    chestmsg db 10, "ROOM 2: TREASURE CHAMBER", 10
             db "       __________", 10
             db "      /_________/|", 10
             db "      |  _____  | |", 10
             db "      | |  ?  | | |", 10
             db "      | |_____| | /", 10
             db "      |_________|/", 10
             db "[1] Open Chest", 10
             db "[2] Leave Chest", 10
             db "Enter choice: "
    chest_len equ $ - chestmsg

    dragonmsg db 10, "ROOM 3: DRAGON'S LAIR", 10
              db "          / \  //\", 10
              db "     |\__/   \_/|", 10
              db "     /  o     o \", 10
              db "    /      ^     \", 10
              db "    \____/ \____/", 10
              db "THE DRAGON AWAKENS!", 10
    dragon_len equ $ - dragonmsg

    combatmenu db 10, "[1] Attack", 10
               db "[2] Defend", 10
               db "[3] Use Potion", 10
               db "[4] Run", 10
               db "Enter choice: "
    combat_len equ $ - combatmenu

    hitmsg db "You attacked the enemy!", 10
    hit_len equ $ - hitmsg

    defendmsg db "You defend against the next attack.", 10
    defend_len equ $ - defendmsg

    enemymsg db "The enemy attacks you!", 10
    enemy_len equ $ - enemymsg

    goblindead db "The goblin has been defeated!", 10
    goblindead_len equ $ - goblindead

    dragondead db "The dragon has been defeated!", 10
    dragondead_len equ $ - dragondead

    chestwin db "You found 50 gold!", 10
    chestwin_len equ $ - chestwin

    no_potions db "You have no potions left!", 10
    no_potions_len equ $ - no_potions

    healedmsg db "You restored health using a potion.", 10
    healed_len equ $ - healedmsg

    fullhealth db "Your health is already full!", 10
    fullhealth_len equ $ - fullhealth

    runmsg db "You escaped. Returning to the main menu.", 10
    runmsg_len equ $ - runmsg

    gameover db 10, "========== GAME OVER ==========", 10
             db "Your hero has fallen.", 10
             db "The dungeon remains undefeated.", 10
    gameover_len equ $ - gameover

    victory db 10, "============ VICTORY! ============", 10
            db "You defeated the dragon and escaped!", 10
            db "YOU ARE A HERO!", 10
    victory_len equ $ - victory

    goodbye db "Thanks for playing!", 10
    goodbye_len equ $ - goodbye

    newline db 10
    newline_len equ $ - newline

section .bss
    name resb 32
    inputbuf resb 32
    numberbuf resb 16

    health resd 1
    maxhealth resd 1
    attack resd 1
    potions resd 1
    gold resd 1
    room resd 1
    enemyhealth resd 1
    enemy_damage resd 1
    defending resd 1
    chest_opened resd 1
    escaped resd 1

section .text
    global _start

%macro PRINT 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

_start:
    call display_welcome
    call get_player_info
    call initialize_character

main_loop:
    cmp dword [health], 0
    jle lose_game

    call display_main_menu
    call read_integer

    cmp eax, 1
    je explore_choice
    cmp eax, 2
    je status_choice
    cmp eax, 3
    je potion_choice
    cmp eax, 4
    je inventory_choice
    cmp eax, 5
    je exit_program

    PRINT invalid, invalid_len
    jmp main_loop

explore_choice:
    mov dword [escaped], 0
    call explore_dungeon
    jmp main_loop

status_choice:
    call display_status
    jmp main_loop

potion_choice:
    call use_potion
    jmp main_loop

inventory_choice:
    call display_inventory
    jmp main_loop

; Display welcome screen
display_welcome:
    PRINT welcome, welcome_len
    ret

; Read the player's name and class
get_player_info:
    PRINT askname, askname_len

    mov eax, 3
    mov ebx, 0
    mov ecx, name
    mov edx, 32
    int 0x80

choose_class:
    PRINT classmenu, classmenu_len
    call read_integer

    cmp eax, 1
    je set_warrior
    cmp eax, 2
    je set_mage
    cmp eax, 3
    je set_archer

    PRINT invalid, invalid_len
    jmp choose_class

set_warrior:
    mov dword [health], 100
    mov dword [maxhealth], 100
    mov dword [attack], 20
    mov dword [potions], 2
    PRINT warrior_msg, warrior_len
    ret

set_mage:
    mov dword [health], 70
    mov dword [maxhealth], 70
    mov dword [attack], 30
    mov dword [potions], 3
    PRINT mage_msg, mage_len
    ret

set_archer:
    mov dword [health], 85
    mov dword [maxhealth], 85
    mov dword [attack], 25
    mov dword [potions], 2
    PRINT archer_msg, archer_len
    ret

; Initialize game data
initialize_character:
    mov dword [gold], 0
    mov dword [room], 1
    mov dword [defending], 0
    mov dword [chest_opened], 0
    mov dword [escaped], 0
    ret

; Display main menu
display_main_menu:
    PRINT mainmenu, mainmenu_len
    ret

; Explore the current dungeon room
explore_dungeon:
    cmp dword [room], 1
    je goblin_room

    cmp dword [room], 2
    je treasure_room

    cmp dword [room], 3
    je dragon_room

    ret

goblin_room:
    PRINT goblinmsg, goblin_len
    mov dword [enemyhealth], 30
    mov dword [enemy_damage], 10
    call battle_enemy

    cmp dword [health], 0
    jle ret_from_explore

    cmp dword [escaped], 1
    je ret_from_explore

    cmp dword [enemyhealth], 0
    jg ret_from_explore

    mov dword [room], 2
    ret

treasure_room:
    cmp dword [chest_opened], 1
    je advance_to_dragon

    PRINT chestmsg, chest_len
    call read_integer

    cmp eax, 1
    je open_chest
    cmp eax, 2
    je leave_chest

    PRINT invalid, invalid_len
    ret

open_chest:
    add dword [gold], 50
    mov dword [chest_opened], 1
    PRINT chestwin, chestwin_len
    jmp advance_to_dragon

leave_chest:
    mov dword [chest_opened], 1

advance_to_dragon:
    mov dword [room], 3
    ret

dragon_room:
    PRINT dragonmsg, dragon_len
    mov dword [enemyhealth], 60
    mov dword [enemy_damage], 15
    call battle_enemy

    cmp dword [health], 0
    jle ret_from_explore

    cmp dword [escaped], 1
    je ret_from_explore

    cmp dword [enemyhealth], 0
    jle win_game

ret_from_explore:
    ret

; Handle combat choices
battle_enemy:
combat_loop:
    cmp dword [health], 0
    jle combat_end

    cmp dword [enemyhealth], 0
    jle combat_end

    PRINT combatmenu, combat_len
    call read_integer

    cmp eax, 1
    je attack_enemy
    cmp eax, 2
    je defend_player
    cmp eax, 3
    je combat_potion
    cmp eax, 4
    je run_away

    PRINT invalid, invalid_len
    jmp combat_loop

attack_enemy:
    mov eax, [enemyhealth]
    sub eax, [attack]
    mov [enemyhealth], eax

    PRINT hitmsg, hit_len

    cmp dword [enemyhealth], 0
    jle enemy_defeated

    call enemy_attack
    jmp combat_loop

enemy_defeated:
    mov dword [enemyhealth], 0

    cmp dword [room], 1
    je goblin_defeated

    PRINT dragondead, dragondead_len
    jmp combat_end

goblin_defeated:
    PRINT goblindead, goblindead_len
    jmp combat_end

defend_player:
    mov dword [defending], 1
    PRINT defendmsg, defend_len
    call enemy_attack
    jmp combat_loop

combat_potion:
    call use_potion

    cmp dword [health], 0
    jle combat_end

    call enemy_attack
    jmp combat_loop

run_away:
    mov dword [escaped], 1
    PRINT runmsg, runmsg_len
    jmp combat_end

combat_end:
    ret

; Enemy attacks the player
enemy_attack:
    PRINT enemymsg, enemy_len
    mov eax, [enemy_damage]

    cmp dword [defending], 1
    jne apply_damage

    sub eax, 5
    cmp eax, 0
    jge damage_ready

    xor eax, eax

damage_ready:
    mov dword [defending], 0

apply_damage:
    sub dword [health], eax

    cmp dword [health], 0
    jg damage_done

    mov dword [health], 0

damage_done:
    ret

; Restore health using a potion
use_potion:
    cmp dword [potions], 0
    jle empty_potion

    mov eax, [health]
    cmp eax, [maxhealth]
    jge health_full

    dec dword [potions]
    add eax, 20

    cmp eax, [maxhealth]
    jle potion_healed

    mov eax, [maxhealth]

potion_healed:
    mov [health], eax
    PRINT healedmsg, healed_len
    ret

empty_potion:
    PRINT no_potions, no_potions_len
    ret

health_full:
    PRINT fullhealth, fullhealth_len
    ret

; Display character statistics
display_status:
    PRINT statusmsg, statusmsg_len

    PRINT healthmsg, healthmsg_len
    mov eax, [health]
    call print_number
    PRINT newline, newline_len

    PRINT attackmsg, attackmsg_len
    mov eax, [attack]
    call print_number
    PRINT newline, newline_len

    PRINT potionmsg, potionmsg_len
    mov eax, [potions]
    call print_number
    PRINT newline, newline_len

    PRINT goldmsg, goldmsg_len
    mov eax, [gold]
    call print_number
    PRINT newline, newline_len
    ret

; Display inventory
display_inventory:
    PRINT potionmsg, potionmsg_len
    mov eax, [potions]
    call print_number
    PRINT newline, newline_len

    PRINT goldmsg, goldmsg_len
    mov eax, [gold]
    call print_number
    PRINT newline, newline_len
    ret

; Read a nonnegative integer
read_integer:
    mov eax, 3
    mov ebx, 0
    mov ecx, inputbuf
    mov edx, 32
    int 0x80

    mov esi, inputbuf
    xor eax, eax
    xor ebx, ebx

parse_loop:
    mov bl, [esi]

    cmp bl, 10
    je parse_done
    cmp bl, 13
    je parse_done

    cmp bl, '0'
    jb parse_done
    cmp bl, '9'
    ja parse_done

    imul eax, eax, 10
    sub bl, '0'
    movzx ebx, bl
    add eax, ebx

    inc esi
    jmp parse_loop

parse_done:
    ret

; Print the unsigned integer in EAX
print_number:
    mov edi, numberbuf
    add edi, 15
    mov byte [edi], 0
    mov ebx, 10

number_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl

    test eax, eax
    jnz number_loop

    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, numberbuf
    add edx, 15
    sub edx, edi
    int 0x80
    ret

; Display defeat screen
lose_game:
    PRINT gameover, gameover_len
    jmp exit_program

; Display victory screen
win_game:
    PRINT victory, victory_len

    PRINT goldmsg, goldmsg_len
    mov eax, [gold]
    call print_number
    PRINT newline, newline_len

    PRINT healthmsg, healthmsg_len
    mov eax, [health]
    call print_number
    PRINT newline, newline_len

    jmp exit_program

; Exit program
exit_program:
    PRINT goodbye, goodbye_len

    mov eax, 1
    xor ebx, ebx
    int 0x80
