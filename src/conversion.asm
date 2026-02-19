; ============================================
; MÓDULO DE CONVERSIÓN
; Responsable: Emmi
; ============================================
; Operaciones:
;   - Binario (8 bits) → Hexadecimal (2 dígitos)
;   - Hexadecimal (2 dígitos) → Binario (8 bits)
; ============================================

section .data
    ; === SUBMENÚ CONVERSIÓN ===
    menu_conv db 10, 27, "[1;33m", "  === OPERACIONES DE CONVERSIÓN ===", 27, "[0m", 10
              db "  1. Binario (8 bits) a Hexadecimal", 10
              db "  2. Hexadecimal (2 dígitos) a Binario", 10
              db "  3. Volver al menú principal", 10
              db "  Opción: ", 0
    
    ; === MENSAJES ===
    msg_input_bin8 db 10, "  Ingrese número binario (8 bits): ", 0
    msg_input_hex2 db 10, "  Ingrese número hexadecimal (2 dígitos): ", 0
    msg_resultado_hex db "  Hexadecimal: ", 0
    msg_resultado_bin8 db "  Binario: ", 0
    msg_bin_invalido db 10, "  ❌ ERROR: Use solo 0 y 1, exactamente 8 dígitos.", 10, 0
    msg_hex_invalido db 10, "  ❌ ERROR: Use solo 0-9 y A-F, exactamente 2 dígitos.", 10, 0
    msg_opcion_invalida db 10, "  ❌ Opción inválida.", 10, 0
    newline db 10, 0
    clear_scr db 27, "[2J", 27, "[H", 0

section .bss
    bin_input resb 10
    hex_input resb 4
    resultado_str resb 10
    extern buffer

section .text
    global menu_conversion
    
    ; Funciones externas
    extern print_string
    extern leer_opcion
    extern pausar

; ============================================
; MENÚ CONVERSIÓN
; ============================================
menu_conversion:
    push rbp
    mov rbp, rsp

.loop:
    ; Limpiar pantalla
    mov rax, 1
    mov rdi, 1
    mov rsi, clear_scr
    mov rdx, 7
    syscall
    
    mov rsi, menu_conv
    call print_string
    
    call leer_opcion
    
    mov al, [buffer]
    
    cmp al, '1'
    je .bin_to_hex
    
    cmp al, '2'
    je .hex_to_bin
    
    cmp al, '3'
    je .volver
    
    mov rsi, msg_opcion_invalida
    call print_string
    call pausar
    jmp .loop

.bin_to_hex:
    call operacion_bin_to_hex
    call pausar
    jmp .loop

.hex_to_bin:
    call operacion_hex_to_bin
    call pausar
    jmp .loop

.volver:
    pop rbp
    ret

; ============================================
; OPERACIÓN: Binario (8 bits) → Hexadecimal
; ============================================
operacion_bin_to_hex:
    push rbp
    mov rbp, rsp
    
    mov rsi, msg_input_bin8
    call print_string
    
    mov rax, 0
    mov rdi, 0
    mov rsi, bin_input
    mov rdx, 10
    syscall
    
    mov rsi, bin_input
    call binary_to_num_8bits
    cmp rax, -1
    je .error
    
    mov bl, al
    
    mov rsi, msg_resultado_hex
    call print_string
    
    ; Nibble alto (bits 4-7)
    mov al, bl
    shr al, 4
    call print_hex_digit
    
    ; Nibble bajo (bits 0-3)
    mov al, bl
    and al, 0x0F
    call print_hex_digit
    
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
; OPERACIÓN: Hexadecimal → Binario (8 bits)
; ============================================
operacion_hex_to_bin:
    push rbp
    mov rbp, rsp
    
    mov rsi, msg_input_hex2
    call print_string
    
    mov rax, 0
    mov rdi, 0
    mov rsi, hex_input
    mov rdx, 4
    syscall
    
    mov rsi, hex_input
    call hex_to_num
    cmp rax, -1
    je .error
    
    mov rsi, msg_resultado_bin8
    call print_string
    
    movzx rax, al
    call print_binary_8bits
    
    mov rsi, newline
    call print_string
    
    jmp .fin

.error:
    mov rsi, msg_hex_invalido
    call print_string

.fin:
    pop rbp
    ret

; ============================================
; FUNCIÓN: Convertir binario a número (8 bits)
; Entrada: RSI = string binario
; Salida: RAX = número (0-255) o -1 si error
; ============================================
binary_to_num_8bits:
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
    cmp rbx, 8
    jg .error
    jmp .loop

.check_count:
    cmp rbx, 8
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
; FUNCIÓN: Convertir hex a número (2 dígitos)
; Entrada: RSI = string hex
; Salida: RAX = número (0-255) o -1 si error
; ============================================
hex_to_num:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx
    
    xor rax, rax
    xor rbx, rbx
    
.loop:
    movzx rcx, byte [rsi + rbx]
    
    cmp cl, 10
    je .check_count
    cmp cl, 0
    je .check_count
    
    ; Convertir dígito hex
    push rax
    call hex_char_to_value
    pop rdx
    
    cmp rax, -1
    je .error
    
    shl rdx, 4
    or rdx, rcx
    mov rax, rdx
    
    inc rbx
    cmp rbx, 2
    jg .error
    jmp .loop

.check_count:
    cmp rbx, 2
    jne .error
    jmp .fin

.error:
    mov rax, -1

.fin:
    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret

; ============================================
; FUNCIÓN: Convertir carácter hex a valor
; Entrada: CL = carácter
; Salida: RCX = valor (0-15) o RAX = -1 si error
; ============================================
hex_char_to_value:
    push rbp
    mov rbp, rsp
    
    cmp cl, '0'
    jl .error
    cmp cl, '9'
    jle .digit
    
    cmp cl, 'A'
    jl .error
    cmp cl, 'F'
    jle .letter
    
    cmp cl, 'a'
    jl .error
    cmp cl, 'f'
    jle .letter_lower
    
    jmp .error

.digit:
    sub cl, '0'
    movzx rcx, cl
    jmp .fin

.letter:
    sub cl, 'A'
    add cl, 10
    movzx rcx, cl
    jmp .fin

.letter_lower:
    sub cl, 'a'
    add cl, 10
    movzx rcx, cl
    jmp .fin

.error:
    mov rax, -1

.fin:
    pop rbp
    ret

; ============================================
; FUNCIÓN: Imprimir dígito hexadecimal
; Entrada: AL = valor (0-15)
; ============================================
print_hex_digit:
    push rbp
    mov rbp, rsp
    push rax
    
    and al, 0x0F
    
    cmp al, 9
    jle .digit
    
    sub al, 10
    add al, 'A'
    jmp .print

.digit:
    add al, '0'

.print:
    mov [resultado_str], al
    mov byte [resultado_str + 1], 0
    
    mov rsi, resultado_str
    call print_string
    
    pop rax
    pop rbp
    ret

; ============================================
; FUNCIÓN: Imprimir binario de 8 bits
; Entrada: RAX = número (0-255)
; ============================================
print_binary_8bits:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    
    and rax, 0xFF
    mov rbx, rax
    mov rcx, 8
    
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