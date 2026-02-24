; ============================================
; CALCULADORA EN LENGUAJE ENSAMBLADOR
; Programa Principal
; ============================================

section .data

    ; === CÓDIGOS ANSI ===
    clear_screen db 27,"[2J",27,"[H",0

    ; === CARÁTULA COMPLETA EN UN SOLO BLOQUE ===
    caratula db 27,"[1;37m",10
             db "************************************************************",10
             db "*                                                          *",10

             db 27,"[1;36m"
             db "*        CALCULADORA EN LENGUAJE ENSAMBLADOR               *",10

             db 27,"[1;33m"
             db "*    Universidad Nacional de San Antonio Abad del Cusco    *",10
             db "*      Facultad de Ingenieria Electronica, Electrica,      *",10
             db "*               Informatica y Mecanica                     *",10
             db "*     Escuela Profesional de Ingenieria Informatica        *",10
             db "*                   y de Sistemas                          *",10
             db "*                                                          *",10
             db "*      Organizacion y Arquitectura del Computador          *",10
             
             db 27,"[1;35m"
             db "*                                                          *",10
             db "*  Docente: Vanesa Lavilla Alvarez                         *",10


             db 27,"[1;32m"
             db "*                                                          *",10
             db "*  Integrantes:                                            *",10
             db "*    - Huaman Tairo, Emmi Daniela                          *",10
             db "*    - Quentasi Juachin, Jose Francisco                    *",10
             db "*    - Vitorino Marin, Efrain                              *",10

             
             db 27,"[1;31m"
             db "*                                                          *",10
             db "*   CCCCCC   U     U   SSSSSS   CCCCC    OOOOO             *",10
             db "*  C        U     U  S         C     C  O     O            *",10
             db "*  C        U     U   SSSSS    C        O     O            *",10
             db "*  C        U     U        S   C        O     O            *",10
             db "*  C        U     U        S   C     C  O     O            *",10
             db "*   CCCCCC    UUUUU   SSSSSS    CCCCC    OOOOO             *",10

             db 27,"[1;37m"
             db "*                                                          *",10
             db "************************************************************",10
             db 27,"[0m",10,0

    presione db "  Presione ENTER para continuar...",0

    ; === MENÚ PRINCIPAL ===
    menu_titulo db 27,"[1;32m",10
                db "  **************************************",10
                db "  *        MENU PRINCIPAL              *",10
                db "  **************************************",10
                db 27,"[0m",10,0

    menu_opciones db "  1) Operaciones Aritmeticas",10
                  db "  2) Operaciones Logicas",10
                  db "  3) Operaciones de Conversion",10
                  db "  4) Salir",10,10
                  db "  Seleccione opcion [1-4]: ",0

    msg_opcion_invalida db 10,"  Opcion invalida. Intente de nuevo.",10,0

    msg_despedida db 10,27,"[1;33m"
                  db "  **************************************",10
                  db "  *  Gracias por usar la calculadora!  *",10
                  db "  **************************************",10
                  db 27,"[0m",10,0


section .bss
    buffer resb 20
    global buffer


section .text
    global _start
    
    ; Declarar funciones externas de otros módulos
    extern menu_aritmetico        ; De arithmetic.asm
    extern menuLogicoMain         ; De logical.asm
    extern menu_conversion        ; De conversion.asm
    extern print_string           ; De utils.asm
    extern strlen                 ; De utils.asm
    extern leer_opcion           ; De utils.asm
    extern pausar                ; De utils.asm

_start:
    call limpiar_pantalla
    call mostrar_caratula
    call pausar
    call menu_principal_loop


; ============================================
; LIMPIAR PANTALLA
; ============================================
limpiar_pantalla:
    mov rax,1
    mov rdi,1
    mov rsi,clear_screen
    mov rdx,7
    syscall
    ret


; ============================================
; MOSTRAR CARÁTULA
; ============================================
mostrar_caratula:
    mov rsi,caratula
    call print_string
    ret


; ============================================
; MENÚ PRINCIPAL
; ============================================
menu_principal_loop:

.loop:
    call limpiar_pantalla

    mov rsi,menu_titulo
    call print_string

    mov rsi,menu_opciones
    call print_string

    call leer_opcion

    mov al,[buffer]

    cmp al,'1'
    je .aritmetica

    cmp al,'2'
    je .opcion_logica

    cmp al,'3'
    je .conversion

    cmp al,'4'
    je .salir

    mov rsi,msg_opcion_invalida
    call print_string
    call pausar
    jmp .loop


.aritmetica:
    call menu_aritmetico
    jmp .loop

.opcion_logica:
    call menuLogicoMain        ; Llamar módulo externo
    jmp .loop

.conversion:
    call menu_conversion
    jmp .loop


.salir:
    call limpiar_pantalla
    mov rsi,msg_despedida
    call print_string

    mov rax,60
    xor rdi,rdi
    syscall