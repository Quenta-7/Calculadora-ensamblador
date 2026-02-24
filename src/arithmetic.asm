; ============================================
; MÓDULO ARITMÉTICO
; Responsable: José
; ============================================
; Operaciones:
;   - Suma (00-99)
;   - Resta (00-99)
;   - Multiplicación (00-99)
;   - División con cociente y residuo
; ============================================

section .data
    ; === SUBMENÚ ARITMÉTICO ===
    menu_arit db 10, 27, "[1;33m"
              db "      ┌──────────────────────────────┐", 10
              db "      │   OPERACIONES ARITMETICAS    │", 10
              db "      └──────────────────────────────┘", 10
              db 27, "[0m"
              db "       ", 27, "[1;37m", "1.", 27, "[0m", " Suma", 10
              db "       ", 27, "[1;37m", "2.", 27, "[0m", " Resta", 10
              db "       ", 27, "[1;37m", "3.", 27, "[0m", " Multiplicacion", 10
              db "       ", 27, "[1;37m", "4.", 27, "[0m", " Division", 10
              db "       ", 27, "[1;31m", "5.", 27, "[0m", " Volver al menu principal", 10, 10
              db "      Opcion: ", 0
    
    ; === MENSAJES ===
    msg_num1 db 10, "  Ingrese primer número (00-99): ", 0
    msg_num2 db "  Ingrese segundo número (00-99): ", 0
    msg_resultado db "  Resultado: ", 0
    msg_cociente db "  Cociente: ", 0
    msg_residuo db "  Residuo: ", 0
    msg_div_cero db 10, "  ❌ ERROR: División por cero no permitida!", 10, 0
    msg_invalido db 10, "  ❌ ERROR: Número inválido. Use solo dígitos 0-9.", 10, 0
    msg_opcion_invalida db 10, "  ❌ Opción inválida.", 10, 0
    newline db 10, 0

section .bss
    num1 resb 4
    num2 resb 4
    extern buffer

section .data
    clear_scr db 27, "[2J", 27, "[H", 0

section .text
    global menu_aritmetico
    
    ; Funciones externas de utils.asm
    extern print_string
    extern leer_opcion
    extern pausar
    extern print_number
    extern ascii_to_num

; ============================================
; MENÚ ARITMÉTICO
; ============================================
menu_aritmetico:
    push rbp
    mov rbp, rsp

.loop:
    ; Limpiar pantalla
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel clear_scr]
    mov rdx, 7
    syscall
    
    mov rsi, menu_arit
    call print_string
    
    call leer_opcion
    mov al, [buffer]
    
    cmp al, '1'
    je .suma
    cmp al, '2'
    je .resta
    cmp al, '3'
    je .multiplicacion
    cmp al, '4'
    je .division
    cmp al, '5'
    je .volver
    
    mov rsi, msg_opcion_invalida
    call print_string
    call pausar
    jmp .loop

.suma:
    call operacion_suma
    call pausar
    jmp .loop

.resta:
    call operacion_resta
    call pausar
    jmp .loop

.multiplicacion:
    call operacion_multiplicacion
    call pausar
    jmp .loop

.division:
    call operacion_division
    call pausar
    jmp .loop

.volver:
    pop rbp
    ret

; ============================================
; OPERACIÓN: SUMA
; ============================================
operacion_suma:
    push rbp
    mov rbp, rsp
    
    call leer_dos_numeros
    cmp rax, 0
    je .error
    
    add bl, cl
    
    mov rsi, msg_resultado
    call print_string
    
    movzx rax, bl
    call print_number
    
    mov rsi, newline
    call print_string
    jmp .fin

.error:
    mov rsi, msg_invalido
    call print_string

.fin:
    pop rbp
    ret

; ============================================
; OPERACIÓN: RESTA
; ============================================
operacion_resta:
    push rbp
    mov rbp, rsp
    
    call leer_dos_numeros
    cmp rax, 0
    je .error
    
    sub bl, cl
    
    mov rsi, msg_resultado
    call print_string
    
    movzx rax, bl
    call print_number
    
    mov rsi, newline
    call print_string
    jmp .fin

.error:
    mov rsi, msg_invalido
    call print_string

.fin:
    pop rbp
    ret

; ============================================
; OPERACIÓN: MULTIPLICACIÓN
; ============================================
operacion_multiplicacion:
    push rbp
    mov rbp, rsp
    
    call leer_dos_numeros
    cmp rax, 0
    je .error
    
    movzx rax, bl
    movzx rcx, cl
    mul rcx            ; RDX:RAX = RAX * RCX
    
    mov rsi, msg_resultado
    call print_string
    
    call print_number  ; RAX ya tiene el resultado
    
    mov rsi, newline
    call print_string
    jmp .fin

.error:
    mov rsi, msg_invalido
    call print_string

.fin:
    pop rbp
    ret

; ============================================
; OPERACIÓN: DIVISIÓN (CORREGIDA 64 BITS)
; ============================================
operacion_division:
    push rbp
    mov rbp, rsp
    
    call leer_dos_numeros
    cmp rax, 0
    je .error
    
    cmp cl, 0
    je .div_cero
    
    movzx rax, bl
    movzx rcx, cl
    xor rdx, rdx
    div rcx            ; RAX=cociente, RDX=residuo
    
    push rdx
    
    mov rsi, msg_cociente
    call print_string
    call print_number
    
    mov rsi, newline
    call print_string
    
    mov rsi, msg_residuo
    call print_string
    
    pop rax
    call print_number
    
    mov rsi, newline
    call print_string
    jmp .fin

.div_cero:
    mov rsi, msg_div_cero
    call print_string
    jmp .fin

.error:
    mov rsi, msg_invalido
    call print_string

.fin:
    pop rbp
    ret

; ============================================
; FUNCIÓN AUXILIAR: Leer dos números
; Retorna:
;   BL = num1
;   CL = num2
;   RAX = 1 si OK, 0 si error
; ============================================
leer_dos_numeros:
    push rbp
    mov rbp, rsp
    
    mov rsi, msg_num1
    call print_string
    
    mov rax, 0
    mov rdi, 0
    mov rsi, num1
    mov rdx, 4
    syscall
    
    mov rsi, num1
    call ascii_to_num
    cmp rax, -1
    je .error
    mov bl, al
    
    mov rsi, msg_num2
    call print_string
    
    mov rax, 0
    mov rdi, 0
    mov rsi, num2
    mov rdx, 4
    syscall
    
    mov rsi, num2
    call ascii_to_num
    cmp rax, -1
    je .error
    mov cl, al
    
    mov rax, 1
    jmp .fin

.error:
    xor rax, rax

.fin:
    pop rbp
    ret
