; ============================================
; CALCULADORA API - Ensamblador x86-64
; Punto de entrada no interactivo para frontend
; ============================================
; Protocolo stdin:
;   Línea 1: Código de operación (1 carácter)
;   Línea 2: Argumento 1
;   Línea 3: Argumento 2 (opcional)
;
; Códigos de operación:
;   1 = Suma           (decimal 0-99, decimal 0-99)
;   2 = Resta          (decimal 0-99, decimal 0-99)
;   3 = Multiplicación (decimal 0-99, decimal 0-99)
;   4 = División       (decimal 0-99, decimal 0-99) → "cociente,residuo"
;   5 = AND            (binario 4 bits, binario 4 bits)
;   6 = OR             (binario 4 bits, binario 4 bits)
;   7 = NOT            (binario 4 bits)
;   8 = XOR            (binario 4 bits, binario 4 bits)
;   9 = Bin→Hex        (binario 8 bits)
;   a = Hex→Bin        (hexadecimal 2 dígitos)
;
; Salida stdout: resultado + newline
; Error: "ERROR\n"
; ============================================

section .data
    comma_str db ",", 0
    error_str db "ERROR", 0
    minus_str db "-", 0
    newline_byte db 10

section .bss
    input_buf resb 64
    arg1_ptr resq 1
    arg2_ptr resq 1
    result_buf resb 16
    buffer resb 20
    global buffer

section .text
    global _start
    extern print_string
    extern print_number
    extern ascii_to_num
    extern strlen

; ============================================
; PUNTO DE ENTRADA
; ============================================
_start:
    ; Leer toda la entrada de stdin
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buf
    mov rdx, 63
    syscall
    mov r15, rax

    ; Null-terminar
    mov byte [input_buf + r15], 0

    ; Parsear: reemplazar \n con \0, encontrar arg1 y arg2
    mov rsi, input_buf
    xor rbx, rbx
    xor r8, r8

.parse_loop:
    cmp rbx, r15
    jge .parse_done
    cmp byte [rsi + rbx], 10
    jne .parse_next
    mov byte [rsi + rbx], 0
    inc r8
    cmp r8, 1
    jne .parse_check2
    lea rax, [rsi + rbx + 1]
    mov [arg1_ptr], rax
    jmp .parse_next
.parse_check2:
    cmp r8, 2
    jne .parse_next
    lea rax, [rsi + rbx + 1]
    mov [arg2_ptr], rax
.parse_next:
    inc rbx
    jmp .parse_loop
.parse_done:

    ; Despachar según código de operación
    movzx rax, byte [input_buf]

    cmp al, '1'
    je op_suma
    cmp al, '2'
    je op_resta
    cmp al, '3'
    je op_multiplicacion
    cmp al, '4'
    je op_division
    cmp al, '5'
    je op_and
    cmp al, '6'
    je op_or
    cmp al, '7'
    je op_not
    cmp al, '8'
    je op_xor
    cmp al, '9'
    je op_bin2hex
    cmp al, 'a'
    je op_hex2bin
    cmp al, 'A'
    je op_hex2bin

    jmp op_error

; ============================================
; OPERACIONES ARITMÉTICAS
; (Instrucciones: ADD, SUB, MUL, DIV)
; ============================================
op_suma:
    call parse_two_decimals
    movzx rax, bl
    movzx rcx, cl
    add rax, rcx              ; ADD - suma en ensamblador
    call print_number
    jmp exit_ok

op_resta:
    call parse_two_decimals
    movzx rax, bl
    movzx rcx, cl
    cmp rax, rcx
    jl .resta_neg
    sub rax, rcx              ; SUB - resta en ensamblador
    call print_number
    jmp exit_ok
.resta_neg:
    sub rcx, rax
    push rcx
    mov rsi, minus_str
    call print_string
    pop rax
    call print_number
    jmp exit_ok

op_multiplicacion:
    call parse_two_decimals
    movzx rax, bl
    movzx rcx, cl
    mul rcx                    ; MUL - multiplicación en ensamblador
    call print_number
    jmp exit_ok

op_division:
    call parse_two_decimals
    cmp cl, 0
    je op_error
    movzx rax, bl
    movzx rcx, cl
    xor rdx, rdx
    div rcx                    ; DIV - división en ensamblador: RAX=cociente, RDX=residuo
    push rdx
    call print_number
    mov rsi, comma_str
    call print_string
    pop rax
    call print_number
    jmp exit_ok

; ============================================
; OPERACIONES LÓGICAS (4 bits)
; (Instrucciones: AND, OR, NOT, XOR)
; ============================================
op_and:
    call parse_two_binary4
    mov al, bl
    and al, cl                 ; AND - operación lógica en ensamblador
    movzx rax, al
    call print_binary_4bits
    jmp exit_ok

op_or:
    call parse_two_binary4
    mov al, bl
    or al, cl                  ; OR - operación lógica en ensamblador
    and al, 0x0F
    movzx rax, al
    call print_binary_4bits
    jmp exit_ok

op_not:
    mov rsi, [arg1_ptr]
    call parse_binary_4bits
    cmp rax, -1
    je op_error
    not al                     ; NOT - operación lógica en ensamblador
    and al, 0x0F
    movzx rax, al
    call print_binary_4bits
    jmp exit_ok

op_xor:
    call parse_two_binary4
    mov al, bl
    xor al, cl                 ; XOR - operación lógica en ensamblador
    and al, 0x0F
    movzx rax, al
    call print_binary_4bits
    jmp exit_ok

; ============================================
; OPERACIONES DE CONVERSIÓN
; (Instrucciones: SHR, AND, SHL, OR)
; ============================================
op_bin2hex:
    mov rsi, [arg1_ptr]
    call parse_binary_8bits
    cmp rax, -1
    je op_error
    mov bl, al
    mov al, bl
    shr al, 4                 ; SHR - extraer nibble alto
    call write_hex_char
    mov al, bl
    and al, 0x0F              ; AND - extraer nibble bajo
    call write_hex_char
    jmp exit_ok

op_hex2bin:
    mov rsi, [arg1_ptr]
    call parse_hex_2digits
    cmp rax, -1
    je op_error
    call print_binary_8bits
    jmp exit_ok

; ============================================
; SALIDA Y ERROR
; ============================================
op_error:
    mov rsi, error_str
    call print_string

exit_ok:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline_byte
    mov rdx, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

; ============================================
; FUNCIONES AUXILIARES
; ============================================

; --- Parsear dos números decimales (0-99) ---
; Salida: BL=num1, CL=num2
parse_two_decimals:
    push rbp
    mov rbp, rsp

    mov rsi, [arg1_ptr]
    call ascii_to_num
    cmp rax, -1
    je .error
    mov bl, al

    mov rsi, [arg2_ptr]
    call ascii_to_num
    cmp rax, -1
    je .error
    mov cl, al

    pop rbp
    ret
.error:
    pop rbp
    jmp op_error

; --- Parsear dos binarios de 4 bits ---
; Salida: BL=num1, CL=num2
parse_two_binary4:
    push rbp
    mov rbp, rsp

    mov rsi, [arg1_ptr]
    call parse_binary_4bits
    cmp rax, -1
    je .error
    mov bl, al

    mov rsi, [arg2_ptr]
    call parse_binary_4bits
    cmp rax, -1
    je .error
    mov cl, al

    pop rbp
    ret
.error:
    pop rbp
    jmp op_error

; --- Parsear string binario de 4 bits ---
; Entrada: RSI = string
; Salida: RAX = 0-15 o -1
parse_binary_4bits:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx

    xor rax, rax
    xor rbx, rbx

.loop:
    movzx rcx, byte [rsi + rbx]
    cmp cl, 0
    je .check
    cmp cl, 10
    je .check
    cmp cl, '0'
    je .bit0
    cmp cl, '1'
    je .bit1
    jmp .error

.bit0:
    shl rax, 1
    jmp .next
.bit1:
    shl rax, 1
    or rax, 1
.next:
    inc rbx
    cmp rbx, 4
    jg .error
    jmp .loop

.check:
    cmp rbx, 4
    jne .error
    jmp .done
.error:
    mov rax, -1
.done:
    pop rcx
    pop rbx
    pop rbp
    ret

; --- Parsear string binario de 8 bits ---
; Entrada: RSI = string
; Salida: RAX = 0-255 o -1
parse_binary_8bits:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx

    xor rax, rax
    xor rbx, rbx

.loop:
    movzx rcx, byte [rsi + rbx]
    cmp cl, 0
    je .check
    cmp cl, 10
    je .check
    cmp cl, '0'
    je .bit0
    cmp cl, '1'
    je .bit1
    jmp .error

.bit0:
    shl rax, 1
    jmp .next
.bit1:
    shl rax, 1
    or rax, 1
.next:
    inc rbx
    cmp rbx, 8
    jg .error
    jmp .loop

.check:
    cmp rbx, 8
    jne .error
    jmp .done
.error:
    mov rax, -1
.done:
    pop rcx
    pop rbx
    pop rbp
    ret

; --- Parsear 2 dígitos hexadecimales ---
; Entrada: RSI = string
; Salida: RAX = 0-255 o -1
parse_hex_2digits:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx

    xor rax, rax
    xor rbx, rbx

.loop:
    movzx rcx, byte [rsi + rbx]
    cmp cl, 0
    je .check
    cmp cl, 10
    je .check

    shl rax, 4

    cmp cl, '0'
    jl .error
    cmp cl, '9'
    jle .digit
    cmp cl, 'A'
    jl .error
    cmp cl, 'F'
    jle .upper
    cmp cl, 'a'
    jl .error
    cmp cl, 'f'
    jle .lower
    jmp .error

.digit:
    sub cl, '0'
    jmp .combine
.upper:
    sub cl, 'A'
    add cl, 10
    jmp .combine
.lower:
    sub cl, 'a'
    add cl, 10
.combine:
    movzx rcx, cl
    or rax, rcx
    inc rbx
    cmp rbx, 2
    jg .error
    jmp .loop

.check:
    cmp rbx, 2
    jne .error
    jmp .done
.error:
    mov rax, -1
.done:
    pop rcx
    pop rbx
    pop rbp
    ret

; --- Imprimir 4 bits binarios ---
; Entrada: RAX = 0-15
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
    mov [result_buf], al
    mov byte [result_buf + 1], 0

    push rcx
    push rbx
    mov rsi, result_buf
    call print_string
    pop rbx
    pop rcx

    cmp rcx, 0
    jne .loop

    pop rcx
    pop rbx
    pop rbp
    ret

; --- Imprimir 8 bits binarios ---
; Entrada: RAX = 0-255
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
    mov [result_buf], al
    mov byte [result_buf + 1], 0

    push rcx
    push rbx
    mov rsi, result_buf
    call print_string
    pop rbx
    pop rcx

    cmp rcx, 0
    jne .loop

    pop rcx
    pop rbx
    pop rbp
    ret

; --- Escribir un dígito hexadecimal ---
; Entrada: AL = valor 0-15
write_hex_char:
    push rbp
    mov rbp, rsp
    push rax

    and al, 0x0F
    cmp al, 9
    jle .digit
    sub al, 10
    add al, 'A'
    jmp .write
.digit:
    add al, '0'
.write:
    mov [result_buf], al
    mov byte [result_buf + 1], 0
    mov rsi, result_buf
    call print_string

    pop rax
    pop rbp
    ret
