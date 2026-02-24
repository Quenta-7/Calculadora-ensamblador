; ============================================
; MÓDULO DE CONVERSIÓN
; Responsable: Emmi
; ============================================
; Operaciones del submenú:
;   1) Binario (8 bits)  -> Hexadecimal (2 dígitos)
;   2) Hexadecimal (2 dígitos) -> Binario (8 bits)
;   3) Volver al menú principal
; ============================================

section .data
    ; ----------------------------
    ; SUBMENÚ CONVERSIÓN (texto)
    ; ----------------------------
    ; menu_conv es la cadena que se imprimirá en pantalla.
    ; Contiene códigos ANSI para color (27,"[...m") y diseño.
    ; Termina en 0 porque print_string espera cadena terminada en NULL.
    menu_conv db 10, 27, "[1;33m"
              db "      ┌──────────────────────────────┐", 10
              db "      │   OPERACIONES DE CONVERSION  │", 10
              db "      └──────────────────────────────┘", 10
              db 27, "[0m"
              db "       ", 27, "[1;37m", "1.", 27, "[0m", " Binario (8 bits) a Hexadecimal", 10
              db "       ", 27, "[1;37m", "2.", 27, "[0m", " Hexadecimal (2 digitos) a Binario", 10
              db "       ", 27, "[1;31m", "3.", 27, "[0m", " Volver al menu principal", 10, 10
              db "      Opcion: ", 0

    ; ----------------------------
    ; MENSAJES DE ENTRADA / SALIDA
    ; ----------------------------
    msg_input_bin8      db 10, "  Ingrese número binario (8 bits): ", 0
    msg_input_hex2      db 10, "  Ingrese número hexadecimal (2 dígitos): ", 0

    msg_resultado_hex   db "  Hexadecimal: ", 0
    msg_resultado_bin8  db "  Binario: ", 0

    ; Mensajes de error por validación
    msg_bin_invalido    db 10, "  ❌ ERROR: Use solo 0 y 1, exactamente 8 dígitos.", 10, 0
    msg_hex_invalido    db 10, "  ❌ ERROR: Use solo 0-9 y A-F, exactamente 2 dígitos.", 10, 0
    msg_opcion_invalida db 10, "  ❌ Opción inválida.", 10, 0

    newline  db 10, 0

    ; clear_scr usa ANSI para limpiar pantalla y mover cursor al inicio.
    clear_scr db 27, "[2J", 27, "[H", 0

section .bss
    ; ----------------------------
    ; BUFFERS DE ENTRADA/SALIDA
    ; ----------------------------
    ; bin_input: guarda lo que el usuario escribe para binario (hasta 8 + Enter)
    ; hex_input: guarda lo que el usuario escribe para hex (2 + Enter)
    ; resultado_str: mini buffer para imprimir un solo carácter (0-terminado)
    bin_input     resb 10
    hex_input     resb 4
    resultado_str resb 10

    ; buffer es externo 
    extern buffer

section .text
    global menu_conversion

    ; ----------------------------
    ; FUNCIONES EXTERNAS (utils.asm)
    ; ----------------------------
    extern print_string    ; imprime cadena (RSI = dirección de string 0-terminado)
    extern leer_opcion     ; lee opción del usuario y la deja en [buffer]
    extern pausar          ; pausa "presione una tecla" (según implement.)
    
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

    ; Imprimir menú
    mov rsi, menu_conv
    call print_string

    ; Leer opción (queda en [buffer])
    call leer_opcion

    ; Tomar la opción como carácter
    mov al, [buffer]

    ; Comparaciones (Guía 6: CMP + JE)
    cmp al, '1'
    je .bin_to_hex

    cmp al, '2'
    je .hex_to_bin

    cmp al, '3'
    je .volver

    ; Si no es 1/2/3 -> opción inválida
    mov rsi, msg_opcion_invalida
    call print_string
    call pausar
    jmp .loop

.bin_to_hex:
    ; Ejecutar conversión bin->hex y volver al menú
    call operacion_bin_to_hex
    call pausar
    jmp .loop

.hex_to_bin:
    ; Ejecutar conversión hex->bin y volver al menú
    call operacion_hex_to_bin
    call pausar
    jmp .loop

.volver:
    ; Retornar al main (menú principal)
    pop rbp
    ret

; ============================================
; OPERACIÓN: Binario (8 bits) → Hexadecimal
; ============================================
operacion_bin_to_hex:
    push rbp
    mov rbp, rsp

    ; Pedir entrada binaria
    mov rsi, msg_input_bin8
    call print_string

    ; Leer del teclado 
   
    mov rax, 0
    mov rdi, 0
    mov rsi, bin_input
    mov rdx, 10
    syscall

    ; Convertir y validar que sean EXACTAMENTE 8 bits y solo 0/1
    mov rsi, bin_input
    call binary_to_num_8bits
    cmp rax, -1
    je .error

    ; Guardar el número (byte) en BL
    mov bl, al

    ; Imprimir "Hexadecimal: "
    mov rsi, msg_resultado_hex
    call print_string

    ; Convertir a 2 dígitos hex:

    mov al, bl
    shr al, 4
    call print_hex_digit


    mov al, bl
    and al, 0x0F
    call print_hex_digit

    ; Salto de línea final
    mov rsi, newline
    call print_string
    jmp .fin

.error:
    ; Si falla validación, mostrar mensaje
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

    ; Pedir entrada hexadecimal
    mov rsi, msg_input_hex2
    call print_string

    ; Leer del teclado 
    ; lee hasta 4 bytes (2 dígitos + Enter + posible 0)
    mov rax, 0
    mov rdi, 0
    mov rsi, hex_input
    mov rdx, 4
    syscall

    ; Convertir "2 dígitos hex" -> número 0..255

    mov rsi, hex_input
    call hex_to_num
    cmp rax, -1
    je .error

    ; Guardar el valor antes de imprimir texto (por si print_string modifica registros)
    push rax

    ; Imprimir "Binario: "
    mov rsi, msg_resultado_bin8
    call print_string

    ; Recuperar valor y imprimir sus 8 bits
    pop rax
    movzx rax, al
    call print_binary_8bits

    ; Salto de línea
    mov rsi, newline
    call print_string
    jmp .fin

.error:
    ; Si falla validación, mostrar mensaje
    mov rsi, msg_hex_invalido
    call print_string

.fin:
    pop rbp
    ret

; ============================================
; FUNCIÓN: Convertir binario a número (8 bits)
; Entrada : RSI = dirección del string (ej: "10101010\n")
; Salida  : RAX = número 0..255 si OK, o RAX = -1 si error
; ============================================
binary_to_num_8bits:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx

    ; RAX = acumulador del número resultante
    ; RBX = índice (posición dentro del string)
    xor rax, rax
    xor rbx, rbx

.loop:
    ; Leer carácter actual: CL = bin_input[RBX]
    movzx rcx, byte [rsi + rbx]

    ; Si llega Enter (10) o fin de cadena (0), verificar longitud
    cmp cl, 10
    je .check_count
    cmp cl, 0
    je .check_count

    ; Validar: solo '0' o '1'
    cmp cl, '0'
    je .bit_0
    cmp cl, '1'
    je .bit_1

    ; Si no es 0/1 -> error
    jmp .error

.bit_0:
    ; Desplazar 1 bit a la izquierda (multiplica por 2)
    shl rax, 1
    jmp .continue

.bit_1:
    ; Desplazar e insertar 1
    shl rax, 1
    or  rax, 1

.continue:
    inc rbx              ; siguiente posición
    cmp rbx, 8           ; si ya pasó 8 dígitos -> error
    jg .error
    jmp .loop

.check_count:
    ; Debe tener EXACTAMENTE 8 bits
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
; Entrada : RSI = string hex (ej: "A3\n")
; Salida  : RAX = número 0..255 si OK, o RAX = -1 si error
; ============================================
hex_to_num:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx

    ; RAX = acumulador del número resultante
    ; RBX = índice del string
    xor rax, rax
    xor rbx, rbx

.loop:
    ; CL = hex_input[RBX]
    movzx rcx, byte [rsi + rbx]

    ; Si Enter (10) o fin (0), verificar que se ingresaron 2 dígitos
    cmp cl, 10
    je .check_count
    cmp cl, 0
    je .check_count

    ; Construcción: resultado = (resultado << 4) | valor
    shl rax, 4
    call hex_char_to_value   ; devuelve el valor del dígito en RCX (0..15) o RAX=-1

    ; Si hubo error en conversión del carácter
    cmp rcx, -1
    je .error

    ; Combinar nibble convertido
    or rax, rcx

    inc rbx
    cmp rbx, 2              ; si pasa de 2 dígitos -> error
    jg .error
    jmp .loop

.check_count:
    ; Deben ser EXACTAMENTE 2 dígitos
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
; FUNCIÓN: Convertir carácter hex a valor 0..15
; Entrada : CL = carácter (0-9, A-F, a-f)
; Salida  : RCX = valor (0..15) si OK
;          RAX = -1 si error (carácter inválido)
; ============================================
hex_char_to_value:
    push rbp
    mov rbp, rsp

    ; Rangos válidos:
    ; '0'..'9'
    ; 'A'..'F'
    ; 'a'..'f'
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
    mov rcx, -1         

.fin:
    pop rbp
    ret

; ============================================
; FUNCIÓN: Imprimir un dígito hexadecimal (0..15)
; Entrada : AL = valor 0..15
; Salida  : imprime '0'..'9' o 'A'..'F'
; ============================================
print_hex_digit:
    push rbp
    mov rbp, rsp
    push rax

    ; asegurar nibble válido
    and al, 0x0F

    ; Si AL <= 9 -> '0'..'9', sino -> 'A'..'F'
    cmp al, 9
    jle .digit

    sub al, 10
    add al, 'A'
    jmp .print

.digit:
    add al, '0'

.print:
    ; Guardar carácter en buffer y terminar con 0
    mov [resultado_str], al
    mov byte [resultado_str + 1], 0

    ; Imprimir ese carácter
    mov rsi, resultado_str
    call print_string

    pop rax
    pop rbp
    ret

; ============================================
; FUNCIÓN: Imprimir binario de 8 bits
; Entrada : RAX = número (0..255)
; Salida  : imprime 8 caracteres '0'/'1'
; ============================================
print_binary_8bits:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx

    ; Tomar solo los 8 bits bajos
    and rax, 0xFF
    mov rbx, rax

    ; RCX será el contador (8 bits a imprimir)
    mov rcx, 8

.loop:
    ; Vamos de bit 7 hacia bit 0
    dec rcx

    ; Extraer bit: (rbx >> rcx) & 1
    mov rax, rbx
    shr rax, cl
    and rax, 1

    ; Convertir 0/1 a '0'/'1'
    add al, '0'

    ; Preparar string de un solo carácter
    mov [resultado_str], al
    mov byte [resultado_str + 1], 0

    ; print_string puede modificar registros, por eso guardamos antes
    push rcx
    push rbx
    mov rsi, resultado_str
    call print_string
    pop rbx
    pop rcx

    ; Si todavía quedan bits, repetir
    cmp rcx, 0
    jne .loop

    pop rcx
    pop rbx
    pop rbp
    ret
