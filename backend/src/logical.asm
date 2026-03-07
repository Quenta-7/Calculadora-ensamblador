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
    menuLogico db 10, 27, "[1;33m"
                db "      ┌──────────────────────────────┐", 10
                db "      │     OPERACIONES LOGICAS     │", 10
                db "      └──────────────────────────────┘", 10
                db 27, "[0m"
                db "       ", 27, "[1;37m", "1.", 27, "[0m", " AND", 10
                db "       ", 27, "[1;37m", "2.", 27, "[0m", " OR", 10
                db "       ", 27, "[1;37m", "3.", 27, "[0m", " NOT", 10
                db "       ", 27, "[1;37m", "4.", 27, "[0m", " XOR", 10
                db "       ", 27, "[1;31m", "5.", 27, "[0m", " Volver al menu principal", 10, 10
                db "      Opcion: ", 0
    
    ; === MENSAJES ===
    msgBin1 db 10, "  Ingrese primer número binario (4 bits): ", 0
    msgBin2 db "  Ingrese segundo número binario (4 bits): ", 0
    msgBinNot db 10, "  Ingrese número binario (4 bits): ", 0
    msgResultadoBin db "  Resultado: ", 0
    msgBinInvalido db 10, "  ❌ ERROR: Use solo 0 y 1, exactamente 4 dígitos.", 10, 0
    msgOpcionInvalida db 10, "  ❌ Opción inválida.", 10, 0
    newline db 10, 0
    clearScr db 27, "[2J", 27, "[H", 0

    ; === TÍTULOS DE OPERACIONES ===
    tituloAnd db 10, 27, "[1;36m", "  --- Operación AND (4 bits) ---", 27, "[0m", 10, 0
    tituloOr  db 10, 27, "[1;36m", "  --- Operación OR  (4 bits) ---", 27, "[0m", 10, 0
    tituloNot db 10, 27, "[1;36m", "  --- Operación NOT (4 bits) ---", 27, "[0m", 10, 0
    tituloXor db 10, 27, "[1;36m", "  --- Operación XOR (4 bits) ---", 27, "[0m", 10, 0
    msgOp1 db "  Operando 1: ", 0
    msgOp2 db "  Operando 2: ", 0
    msgOpNot db "  Operando:   ", 0

section .bss
    binInput resb 10
    resultadoStr resb 10
    extern buffer

section .text
    global menuLogicoMain
    
    ; Funciones externas
    extern print_string
    extern leer_opcion
    extern pausar

; ============================================
; MENÚ LÓGICO PRINCIPAL
; ============================================
menuLogicoMain:
    push rbp
    mov rbp, rsp

.loop:
    ; Limpiar pantalla
    mov rax, 1
    mov rdi, 1
    mov rsi, clearScr
    mov rdx, 7
    syscall
    
    mov rsi, menuLogico
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
    je .xor_op
    
    cmp al, '5'
    je .volver
    
    mov rsi, msgOpcionInvalida
    call print_string
    call pausar
    jmp .loop

.and_op:
    call operacionAnd
    call pausar
    jmp .loop

.or_op:
    call operacionOr
    call pausar
    jmp .loop

.not_op:
    call operacionNot
    call pausar
    jmp .loop

.xor_op:
    call operacionXor
    call pausar
    jmp .loop

.volver:
    pop rbp
    ret

; ============================================
; OPERACIÓN: AND
; Ejemplo: 1010 AND 1100 = 1000
; ============================================
operacionAnd:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    ; Mostrar título
    mov rsi, tituloAnd
    call print_string

    call leerDosBinarios
    cmp rax, 0
    je .error

    ; Guardar operandos originales
    mov r12b, bl          ; r12b = operando 1
    mov r13b, cl          ; r13b = operando 2

    ; Mostrar operando 1
    mov rsi, msgOp1
    call print_string
    movzx rax, r12b
    call printBinary4bits
    mov rsi, newline
    call print_string

    ; Mostrar operando 2
    mov rsi, msgOp2
    call print_string
    movzx rax, r13b
    call printBinary4bits
    mov rsi, newline
    call print_string

    ; Calcular AND
    mov bl, r12b
    and bl, r13b

    ; Mostrar resultado
    mov rsi, msgResultadoBin
    call print_string
    movzx rax, bl
    call printBinary4bits
    mov rsi, newline
    call print_string

    jmp .fin

.error:
    mov rsi, msgBinInvalido
    call print_string

.fin:
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; ============================================
; OPERACIÓN: OR
; Ejemplo: 1010 OR 0101 = 1111
; ============================================
operacionOr:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    ; Mostrar título
    mov rsi, tituloOr
    call print_string

    call leerDosBinarios
    cmp rax, 0
    je .error

    ; Guardar operandos originales
    mov r12b, bl          ; r12b = operando 1
    mov r13b, cl          ; r13b = operando 2

    ; Mostrar operando 1
    mov rsi, msgOp1
    call print_string
    movzx rax, r12b
    call printBinary4bits
    mov rsi, newline
    call print_string

    ; Mostrar operando 2
    mov rsi, msgOp2
    call print_string
    movzx rax, r13b
    call printBinary4bits
    mov rsi, newline
    call print_string

    ; Calcular OR
    mov bl, r12b
    or bl, r13b

    ; Mostrar resultado
    mov rsi, msgResultadoBin
    call print_string
    movzx rax, bl
    call printBinary4bits
    mov rsi, newline
    call print_string

    jmp .fin

.error:
    mov rsi, msgBinInvalido
    call print_string

.fin:
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; ============================================
; OPERACIÓN: NOT
; Ejemplo: NOT 1010 = 0101
; ============================================
operacionNot:
    push rbp
    mov rbp, rsp
    push rbx                ; Guardar RBX (callee-saved)

    ; Mostrar título
    mov rsi, tituloNot
    call print_string

    mov rsi, msgBinNot
    call print_string

    ; Leer entrada del usuario
    mov rax, 0
    mov rdi, 0
    mov rsi, binInput
    mov rdx, 6
    syscall

    ; Convertir string binario a valor numérico
    mov rsi, binInput
    call binaryToNum4bits
    cmp rax, -1
    je .error

    mov bl, al              ; BL = operando original

    ; Mostrar operando
    mov rsi, msgOpNot
    call print_string
    movzx rax, bl
    call printBinary4bits
    mov rsi, newline
    call print_string

    ; Calcular NOT (complemento a 1, solo 4 bits)
    not bl
    and bl, 0x0F            ; Enmascarar a 4 bits

    ; Mostrar resultado
    mov rsi, msgResultadoBin
    call print_string
    movzx rax, bl            ; Usar BL que está preservado
    call printBinary4bits

    mov rsi, newline
    call print_string

    jmp .fin

.error:
    mov rsi, msgBinInvalido
    call print_string

.fin:
    pop rbx                  ; Restaurar RBX
    pop rbp
    ret

; ============================================
; OPERACIÓN: XOR
; Ejemplo: 1010 XOR 1100 = 0110
; ============================================
operacionXor:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    ; Mostrar título
    mov rsi, tituloXor
    call print_string

    call leerDosBinarios
    cmp rax, 0
    je .error

    ; Guardar operandos originales
    mov r12b, bl          ; r12b = operando 1
    mov r13b, cl          ; r13b = operando 2

    ; Mostrar operando 1
    mov rsi, msgOp1
    call print_string
    movzx rax, r12b
    call printBinary4bits
    mov rsi, newline
    call print_string

    ; Mostrar operando 2
    mov rsi, msgOp2
    call print_string
    movzx rax, r13b
    call printBinary4bits
    mov rsi, newline
    call print_string

    ; Calcular XOR
    mov bl, r12b
    xor bl, r13b

    ; Mostrar resultado
    mov rsi, msgResultadoBin
    call print_string
    movzx rax, bl
    call printBinary4bits
    mov rsi, newline
    call print_string

    jmp .fin

.error:
    mov rsi, msgBinInvalido
    call print_string

.fin:
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; ============================================
; FUNCIÓN: Leer dos números binarios
; Retorna: BL = num1, CL = num2, RAX = 1 si OK, 0 si error
; ============================================
leerDosBinarios:
    push rbp
    mov rbp, rsp
    
    ; Leer primer binario
    mov rsi, msgBin1
    call print_string
    
    mov rax, 0
    mov rdi, 0
    mov rsi, binInput
    mov rdx, 6
    syscall
    
    mov rsi, binInput
    call binaryToNum4bits
    cmp rax, -1
    je .error
    mov bl, al
    
    ; Leer segundo binario
    mov rsi, msgBin2
    call print_string
    
    mov rax, 0
    mov rdi, 0
    mov rsi, binInput
    mov rdx, 6
    syscall
    
    mov rsi, binInput
    call binaryToNum4bits
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
binaryToNum4bits:
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
printBinary4bits:
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
    mov [resultadoStr], al
    mov byte [resultadoStr + 1], 0
    
    push rcx
    push rbx
    mov rsi, resultadoStr
    call print_string
    pop rbx
    pop rcx
    
    cmp rcx, 0
    jne .loop
    
    pop rcx
    pop rbx
    pop rbp
    ret