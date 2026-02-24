; ============================================
; CALCULADORA EN LENGUAJE ENSAMBLADOR
; Programa Principal
; ============================================
; Organización y Arquitectura del Computador
; UNMSM - 2025
; 
; Integrantes:
;   - José [Apellido]    - Módulo Aritmético
;   - Efraín [Apellido]  - Módulo Lógico
;   - Emmi [Apellido]    - Módulo Conversión
; ============================================

section .data
    ; === CÓDIGOS ANSI PARA COLORES ===
    clear_screen db 27, "[2J", 27, "[H", 0
    
    ; === CARÁTULA ===
    titulo db 27, "[1;36m", 10
           db "      _____________________________", 10
           db "     |  ___________________________  |", 10
           db "     | |                           | |", 10
           db "     | |   CALCULADORA  ASM x86    | |", 10
           db "     | |___________________________| |", 10
           db "     |   ___ ___ ___ ___   ___ ___   |", 10
           db "     |  | 7 | 8 | 9 | / | |AND| OR|  |", 10
           db "     |  |___|___|___|___| |___|___|  |", 10
           db "     |  | 4 | 5 | 6 | x | |NOT|XOR|  |", 10
           db "     |  |___|___|___|___| |___|___|  |", 10
           db "     |  | 1 | 2 | 3 | - | |BIN|HEX|  |", 10
           db "     |  |___|___|___|___| |___|___|  |", 10
           db "     |  | 0 | . | = | + | | ENTER |  |", 10
           db "     |  |___|___|___|___| |_______|  |", 10
           db "     |_____________________________|", 10
           db 27, "[0m", 10, 0
    
    curso db 27, "[0;37m"
          db "      Organizacion y Arquitectura del Computador", 10
          db "      Universidad Nacional de San Antonio Abad del Cusco", 10
          db 27, "[0m", 10, 0
    
    integrantes db 27, "[1;33m", "      Integrantes:", 27, "[0m", 10
                db "        ", 27, "[0;36m", ">> ", 27, "[0m", "Huaman Tairo, Emmi Daniela", 10
                db "        ", 27, "[0;36m", ">> ", 27, "[0m", "Quentasi Juachin, Jose Francisco", 10
                db "        ", 27, "[0;36m", ">> ", 27, "[0m", "Vitorino Marin, Efrain", 10, 10, 0
    
    presione db "  Presione ENTER para continuar...", 0
    
    ; === MENÚ PRINCIPAL ===
    menu_titulo db 27, "[1;32m", 10
                db "      ╔══════════════════════════════════╗", 10
                db "      ║       ", 27, "[1;37m", "MENU PRINCIPAL", 27, "[1;32m", "           ║", 10
                db "      ╠══════════════════════════════════╣", 10
                db 27, "[0m", 0
    
    menu_opciones db 27, "[1;32m"
                  db "      ║", 27, "[0m", "  ", 27, "[1;33m", "1.", 27, "[0m", " Operaciones Aritmeticas   ", 27, "[1;32m", "  ║", 10
                  db "      ║", 27, "[0m", "  ", 27, "[1;33m", "2.", 27, "[0m", " Operaciones Logicas       ", 27, "[1;32m", "  ║", 10
                  db "      ║", 27, "[0m", "  ", 27, "[1;33m", "3.", 27, "[0m", " Operaciones de Conversion ", 27, "[1;32m", "  ║", 10
                  db "      ║", 27, "[0m", "  ", 27, "[1;31m", "4.", 27, "[0m", " Salir                     ", 27, "[1;32m", "  ║", 10
                  db "      ╚══════════════════════════════════╝", 10
                  db 27, "[0m", 10
                  db "      Seleccione opcion [1-4]: ", 0
    
    ; === MENSAJES GENERALES ===
    msg_opcion_invalida db 10, "  ❌ Opcion invalida. Intente de nuevo.", 10, 0
    msg_despedida db 10, 27, "[1;33m"
                  db "      ╔══════════════════════════════════╗", 10
                  db "      ║                                  ║", 10
                  db "      ║  Gracias por usar la calculadora ║", 10
                  db "      ║         Hasta pronto!            ║", 10
                  db "      ║                                  ║", 10
                  db "      ╚══════════════════════════════════╝", 10
                  db 27, "[0m", 10, 0

section .bss
    buffer resb 20

    ; Exportar buffer para otros módulos
    global buffer

section .text
    global _start
    
    ; Declarar funciones externas de otros módulos
    extern menu_aritmetico        ; De arithmetic.asm
    extern menuLogicoMain       ; De logical.asm
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
; PROCEDIMIENTO: Limpiar pantalla
; ============================================
limpiar_pantalla:
    push rbp
    mov rbp, rsp
    
    mov rax, 1
    mov rdi, 1
    mov rsi, clear_screen
    mov rdx, 7
    syscall
    
    pop rbp
    ret

; ============================================
; PROCEDIMIENTO: Mostrar carátula
; ============================================
mostrar_caratula:
    push rbp
    mov rbp, rsp
    
    mov rsi, titulo
    call print_string
    
    mov rsi, curso
    call print_string
    
    mov rsi, integrantes
    call print_string
    
    pop rbp
    ret

; ============================================
; PROCEDIMIENTO: Menú principal
; ============================================
menu_principal_loop:
    push rbp
    mov rbp, rsp

.loop:
    call limpiar_pantalla
    
    mov rsi, menu_titulo
    call print_string
    
    mov rsi, menu_opciones
    call print_string
    
    call leer_opcion
    
    mov al, [buffer]
    
    cmp al, '1'
    je .opcion_aritmetica
    
    cmp al, '2'
    je .opcion_logica
    
    cmp al, '3'
    je .opcion_conversion
    
    cmp al, '4'
    je .salir
    
    mov rsi, msg_opcion_invalida
    call print_string
    call pausar
    jmp .loop

.opcion_aritmetica:
    call menu_aritmetico       ; Llamar módulo externo
    jmp .loop

.opcion_logica:
    call menuLogicoMain      ; Llamar módulo externo
    jmp .loop

.opcion_conversion:
    call menu_conversion       ; Llamar módulo externo
    jmp .loop

.salir:
    call limpiar_pantalla
    mov rsi, msg_despedida
    call print_string
    
    mov rax, 60
    xor rdi, rdi
    syscall