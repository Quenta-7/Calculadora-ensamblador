; ============================================
; CALCULADORA EN LENGUAJE ENSAMBLADOR
; ============================================

section .data
    ; === CÓDIGOS ANSI PARA COLORES ===
    clear_screen db 27, "[2J", 27, "[H", 0
    color_cyan db 27, "[1;36m", 0
    color_reset db 27, "[0m", 0
    color_green db 27, "[1;32m", 0
    
    ; === CARÁTULA ===
    titulo db 27, "[1;36m", 10
           db "  ╔════════════════════════════════════════════════╗", 10
           db "  ║                                                ║", 10
           db "  ║      CALCULADORA EN LENGUAJE ENSAMBLADOR       ║", 10
           db "  ║                                                ║", 10
           db "  ╚════════════════════════════════════════════════╝", 10
           db 27, "[0m", 10, 0
    
    curso db "  Organización y Arquitectura del Computador", 10
          db "  UUniversidad Nacional de San Antonio Abab del Cusco", 10, 10, 0
    
    integrantes db "  Integrantes:", 10
                db "     - [Huaman Tairo, Emmi Daniela]", 10
                db "     - [Quentasi Juachin, Jose Francisco]", 10
                db "     - [Vitorino Marin, Efrain]", 10, 10, 0
    
    presione db "  Presione ENTER para continuar...", 0
    
    ; === MENÚ PRINCIPAL ===
    menu_titulo db 27, "[1;32m", 10
                db "  ╔════════════════════════════════════╗", 10
                db "  ║         MENÚ PRINCIPAL             ║", 10
                db "  ╚════════════════════════════════════╝", 10
                db 27, "[0m", 10, 0
    
    menu_opciones db "  1. Operaciones Aritméticas", 10
                  db "  2. Operaciones Lógicas", 10
                  db "  3. Operaciones de Conversión", 10
                  db "  4. Salir", 10, 10
                  db "  Seleccione opción [1-4]: ", 0
    
    ; === SUBMENÚ ARITMÉTICO ===
    menu_arit db 10, "  === OPERACIONES ARITMÉTICAS ===", 10
              db "  1. Suma", 10
              db "  2. Resta", 10
              db "  3. Multiplicación", 10
              db "  4. División", 10
              db "  5. Volver al menú principal", 10
              db "  Opción: ", 0
    
    ; === MENSAJES ===
    msg_opcion_invalida db 10, "  Opción inválida. Intente de nuevo.", 10, 0
    msg_despedida db 10, 27, "[1;33m"
                  db "  ╔════════════════════════════════════╗", 10
                  db "  ║  Gracias por usar la calculadora!  ║", 10
                  db "  ╚════════════════════════════════════╝", 10
                  db 27, "[0m", 10, 0
    
    msg_desarrollo db "  Módulo en desarrollo...", 10, 0
    newline db 10, 0

section .bss
    buffer resb 10    ; Buffer para entrada del usuario

section .text
    global _start

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
    
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
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
    
    ; Imprimir título
    mov rsi, titulo
    call print_string
    
    ; Imprimir curso
    mov rsi, curso
    call print_string
    
    ; Imprimir integrantes
    mov rsi, integrantes
    call print_string
    
    ; Mensaje presionar ENTER
    mov rsi, presione
    call print_string
    
    pop rbp
    ret

; ============================================
; PROCEDIMIENTO: Pausar (esperar ENTER)
; ============================================
pausar:
    push rbp
    mov rbp, rsp
    
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, buffer
    mov rdx, 2
    syscall
    
    pop rbp
    ret

; ============================================
; PROCEDIMIENTO: Menú principal (loop)
; ============================================
menu_principal_loop:
    push rbp
    mov rbp, rsp

.loop:
    call limpiar_pantalla
    
    ; Mostrar título del menú
    mov rsi, menu_titulo
    call print_string
    
    ; Mostrar opciones
    mov rsi, menu_opciones
    call print_string
    
    ; Leer opción del usuario
    call leer_opcion
    
    ; Procesar opción en AL
    mov al, [buffer]
    
    cmp al, '1'
    je .opcion_aritmetica
    
    cmp al, '2'
    je .opcion_logica
    
    cmp al, '3'
    je .opcion_conversion
    
    cmp al, '4'
    je .salir
    
    ; Opción inválida
    mov rsi, msg_opcion_invalida
    call print_string
    call pausar
    jmp .loop

.opcion_aritmetica:
    call menu_aritmetico
    jmp .loop

.opcion_logica:
    call menu_logico
    jmp .loop

.opcion_conversion:
    call menu_conversion
    jmp .loop

.salir:
    call limpiar_pantalla
    mov rsi, msg_despedida
    call print_string
    
    ; Salir del programa
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; código 0
    syscall

; ============================================
; PROCEDIMIENTO: Leer opción del usuario
; ============================================
leer_opcion:
    push rbp
    mov rbp, rsp
    
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, buffer
    mov rdx, 10
    syscall
    
    pop rbp
    ret

; ============================================
; PROCEDIMIENTO: Imprimir string
; Entrada: RSI = dirección del string (terminado en 0)
; ============================================
print_string:
    push rbp
    mov rbp, rsp
    push rdi
    push rdx
    
    ; Calcular longitud
    mov rdi, rsi
    call strlen
    mov rdx, rax        ; longitud en RDX
    
    ; Imprimir
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    ; RSI ya tiene la dirección
    syscall
    
    pop rdx
    pop rdi
    pop rbp
    ret

; ============================================
; PROCEDIMIENTO: Calcular longitud de string
; Entrada: RDI = dirección del string
; Salida: RAX = longitud
; ============================================
strlen:
    push rbp
    mov rbp, rsp
    push rsi
    
    mov rsi, rdi
    xor rax, rax
    
.loop:
    cmp byte [rsi + rax], 0
    je .done
    inc rax
    jmp .loop
    
.done:
    pop rsi
    pop rbp
    ret

; ============================================
; MÓDULOS (stubs - a implementar)
; ============================================
menu_aritmetico:
    push rbp
    mov rbp, rsp
    
    call limpiar_pantalla
    mov rsi, menu_arit
    call print_string
    
    ; TODO: Implementar submenú completo
    mov rsi, msg_desarrollo
    call print_string
    call pausar
    
    pop rbp
    ret

menu_logico:
    push rbp
    mov rbp, rsp
    
    mov rsi, msg_desarrollo
    call print_string
    call pausar
    
    pop rbp
    ret

menu_conversion:
    push rbp
    mov rbp, rsp
    
    mov rsi, msg_desarrollo
    call print_string
    call pausar
    
    pop rbp
    ret