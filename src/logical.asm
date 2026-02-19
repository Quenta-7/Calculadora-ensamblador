; ============================================
; MÓDULO LÓGICO
; Responsable: Efraín
; ============================================
; Operaciones:
;   - AND (4 bits)
;   - OR (4 bits)
;   - NOT (4 bits)
; ============================================

section .data
    ; === SUBMENÚ LÓGICO ===
    menu_logico db 10, 27, "[1;33m", "  === OPERACIONES LÓGICAS ===", 27, "[0m", 10
                db "  1. AND", 10
                db "  2. OR", 10
                db "  3. NOT", 10
                db "  4. Volver al menú principal", 10
                db "  Opción: ", 0
    
    ; === MENSAJES ===
    msg_bin1 db 10, "  Ingrese primer número binario (4 bits): ", 0
    msg_bin2 db "  Ingrese segundo número binario (4 bits): ", 0
    msg_bin_not db 10, "  Ingrese número binario (4 bits): ", 0
    msg_resultado_bin db "  Resultado: ", 0
    msg_bin_invalido db 10, "  ❌ ERROR: Use solo 0 y 1, exactamente 4 dígitos.", 10, 0
    msg_opcion_invalida db 10, "  ❌ Opción inválida.", 10, 0
    newline db 10, 0
    clear_scr db 27, "[2J", 27, "[H", 0

section .bss
    bin_input resb 10
    resultado_str resb 10
    extern buffer

section .text
    global menu_logico_main
    
    ; Funciones externas
    extern print_string
    extern leer_opcion
    extern pausar

; ============================================
; MENÚ LÓGICO PRINCIPAL
; ============================================
menu_logico_main:
    push rbp
    mov rbp, rsp

.loop:
    ; Limpiar pantalla
    mov rax, 1
    mov rdi, 1
    mov rsi, clear_scr
    mov rdx, 7
    syscall
    
    mov rsi, menu_logico
    call print_string
    
    call leer_opcion
    
    mov al, [buffer]
    
    cmp al, '1'
    je .and_op
    
    cmp al, '2'
    je .or_op
    
    cmp al, '3'
    je .not_op
    
    cmp al, '4'
    je .volver
    
    mov rsi, msg_opcion_invalida
    call print_string
    call pausar
    jmp .loop

.and_op:
    call operacion_and
    call pausar
    jmp .loop

.or_op:
    call operacion_or
    call pausar
    jmp .loop

.not_op:
    call operacion_not
    call pausar
    jmp .loop

.volver:
    pop rbp
    ret

; ============================================
; OPERACIÓN: AND
; ============================================
operacion_and:
    push rbp
    mov rbp, rsp
    
    call leer_dos_binarios
    cmp rax, 0
    je .error
    
    ; BL = num1, CL = num2
    and bl, cl
    
    mov rsi, msg_resultado_bin
    call print_string
    
    movzx rax, bl
    call print_binary_4bits
    
    mov rsi, newline
    call print_string
    
    jmp .fin

.error:
    mov rsi, msg_bin_invalido
    call print_string

.fin:
    pop rbp
    ret

; ============================================
; OPERACIÓN: OR
; ============================================
operacion_or:
    push rbp
    mov rbp, rsp
    
    call leer_dos_binarios
    cmp rax, 0
    je .error
    
    or bl, cl
    
    mov rsi, msg_resultado_bin
    call print_string
    
    movzx rax, bl
    call print_binary_4bits
    
    mov rsi, newline
    call print_string
    
    jmp .fin

.error:
    mov rsi, msg_bin_invalido
    call print_string

.fin:
    pop rbp
    ret

; ============================================
; OPERACIÓN: NOT
; ============================================
operacion_not:
    push rbp
    mov rbp, rsp
    
    mov rsi, msg_bin_not
    call print_string
    
    mov rax, 0
    mov rdi, 0
    mov rsi, bin_input
    mov rdx, 6
    syscall
    
    mov rsi, bin_input
    call binary_to_num_4bits
    cmp rax, -1
    je .error
    
    not al
    and al, 0x0F
    
    mov rsi, msg_resultado_bin
    call print_string
    
    movzx rax, al
    call print_binary_4bits
    
    mov rsi, newline
    call print_string
    
    jmp .fin

.error:
    mov rsi, msg_bin_invalido
    call print_string

.fin:
    pop rbp
    ret

; ============================================
; FUNCIÓN: Leer dos números binarios
; Retorna: BL = num1, CL = num2, RAX = 1 si OK, 0 si error
; ============================================
leer_dos_binarios:
    push rbp
    mov rbp, rsp
    
    ; Leer primer binario
    mov rsi, msg_bin1
    call print_string
    
    mov rax, 0
    mov rdi, 0
    mov rsi, bin_input
    mov rdx, 6
    syscall
    
    mov rsi, bin_input
    call binary_to_num_4bits
    cmp rax, -1
    je .error
    mov bl, al
    
    ; Leer segundo binario
    mov rsi, msg_bin2
    call print_string
    
    mov rax, 0
    mov rdi, 0
    mov rsi, bin_input
    mov rdx, 6
    syscall
    
    mov rsi, bin_input
    call binary_to_num_4bits
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

; ============================================
; FUNCIÓN: Convertir binario a número (4 bits)
; Entrada: RSI = string binario
; Salida: RAX = número (0-15) o -1 si error
; ============================================
binary_to_num_4bits:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    
    xor rax, rax
    xor rbx, rbx
    
.loop:
    movzx rcx, byte [rsi + rbx]
    
    cmp cl, 10
    je .check_count
    cmp cl, 0
    je .check_count
    
    cmp cl, '0'
    je .bit_0
    cmp cl, '1'
    je .bit_1
    
    jmp .error

.bit_0:
    shl rax, 1
    jmp .continue

.bit_1:
    shl rax, 1
    or rax, 1

.continue:
    inc rbx
    cmp rbx, 4
    jg .error
    jmp .loop

.check_count:
    cmp rbx, 4
    jne .error
    jmp .fin

.error:
    mov rax, -1

.fin:
    pop rcx
    pop rbx
    pop rbp
    ret

; ============================================
; FUNCIÓN: Imprimir binario de 4 bits
; Entrada: RAX = número (0-15)
; ============================================
print_binary_4bits:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    
    and rax, 0x0F
    mov rbx, rax
    mov rcx, 4
    
.loop:
    dec rcx
    
    mov rax, rbx
    shr rax, cl
    and rax, 1
    
    add al, '0'
    mov [resultado_str], al
    mov byte [resultado_str + 1], 0
    
    push rcx
    push rbx
    mov rsi, resultado_str
    call print_string
    pop rbx
    pop rcx
    
    cmp rcx, 0
    jne .loop
    
    pop rcx
    pop rbx
    pop rbp
    ret