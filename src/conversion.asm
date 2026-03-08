; ============================================
; MÓDULO DE CONVERSIÓN
; Responsable: Emmi
; ============================================

default rel

section .data
    menu_conv db 10, 27, "[1;33m"
              db "      ┌──────────────────────────────┐", 10
              db "      │   OPERACIONES DE CONVERSION  │", 10
              db "      └──────────────────────────────┘", 10
              db 27, "[0m"
              db "       ", 27, "[1;37m", "1.", 27, "[0m", " Binario (8 bits) a Hexadecimal", 10
              db "       ", 27, "[1;37m", "2.", 27, "[0m", " Hexadecimal (2 digitos) a Binario", 10
              db "       ", 27, "[1;31m", "3.", 27, "[0m", " Volver al menu principal", 10, 10
              db "      Opcion: ", 0

    msg_input_bin8      db 10, "  Ingrese número binario (8 bits): ", 0
    msg_input_hex2      db 10, "  Ingrese número hexadecimal (2 dígitos): ", 0
    msg_resultado_hex   db "  Hexadecimal: ", 0
    msg_resultado_bin8  db "  Binario: ", 0
    msg_bin_invalido    db 10, "  ❌ ERROR: Use solo 0 y 1, exactamente 8 dígitos.", 10, 0
    msg_hex_invalido    db 10, "  ❌ ERROR: Use solo 0-9 y A-F, exactamente 2 dígitos.", 10, 0
    msg_opcion_invalida db 10, "  ❌ Opción inválida.", 10, 0
    newline             db 10, 0
    clear_scr           db 27, "[2J", 27, "[H", 0

section .bss
    bin_input     resb 10
    hex_input     resb 4
    resultado_str resb 10
    extern buffer

section .text
    global menu_conversion
    global hex_to_num
    global binary_to_num_8bits
    global asmHexToNum
    global asmBinToNum8

    extern print_string
    extern leer_opcion
    extern pausar

; ============================================
; WRAPPERS PARA CTYPES
; ============================================
asmBinToNum8:
    push rbp
    mov rbp, rsp
    mov rsi, rdi
    call binary_to_num_8bits
    pop rbp
    ret

asmHexToNum:
    push rbp
    mov rbp, rsp
    mov rsi, rdi
    call hex_to_num
    pop rbp
    ret

; ============================================
; MENÚ CONVERSIÓN
; ============================================
menu_conversion:
    push rbp
    mov rbp, rsp

.loop:
    mov rax, 1
    mov rdi, 1
    lea rsi, [clear_scr]
    mov rdx, 7
    syscall

    lea rsi, [menu_conv]
    call print_string wrt ..plt

    call leer_opcion wrt ..plt
    mov al, [buffer]

    cmp al, '1'
    je .bin_to_hex
    cmp al, '2'
    je .hex_to_bin
    cmp al, '3'
    je .volver

    lea rsi, [msg_opcion_invalida]
    call print_string wrt ..plt
    call pausar wrt ..plt
    jmp .loop

.bin_to_hex:
    call operacion_bin_to_hex
    call pausar wrt ..plt
    jmp .loop

.hex_to_bin:
    call operacion_hex_to_bin
    call pausar wrt ..plt
    jmp .loop

.volver:
    pop rbp
    ret

operacion_bin_to_hex:
    push rbp
    mov rbp, rsp

    lea rsi, [msg_input_bin8]
    call print_string wrt ..plt

    mov rax, 0
    mov rdi, 0
    lea rsi, [bin_input]
    mov rdx, 10
    syscall

    lea rsi, [bin_input]
    call binary_to_num_8bits
    cmp rax, -1
    je .error

    mov bl, al

    lea rsi, [msg_resultado_hex]
    call print_string wrt ..plt

    mov al, bl
    shr al, 4
    call print_hex_digit

    mov al, bl
    and al, 0x0F
    call print_hex_digit

    lea rsi, [newline]
    call print_string wrt ..plt
    jmp .fin

.error:
    lea rsi, [msg_bin_invalido]
    call print_string wrt ..plt

.fin:
    pop rbp
    ret

operacion_hex_to_bin:
    push rbp
    mov rbp, rsp

    lea rsi, [msg_input_hex2]
    call print_string wrt ..plt

    mov rax, 0
    mov rdi, 0
    lea rsi, [hex_input]
    mov rdx, 4
    syscall

    lea rsi, [hex_input]
    call hex_to_num
    cmp rax, -1
    je .error

    push rax

    lea rsi, [msg_resultado_bin8]
    call print_string wrt ..plt

    pop rax
    movzx rax, al
    call print_binary_8bits

    lea rsi, [newline]
    call print_string wrt ..plt
    jmp .fin

.error:
    lea rsi, [msg_hex_invalido]
    call print_string wrt ..plt

.fin:
    pop rbp
    ret

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
    or  rax, 1

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

    shl rax, 4
    call hex_char_to_value
    cmp rcx, -1
    je .error

    or rax, rcx

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
    mov rcx, -1

.fin:
    pop rbp
    ret

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

    lea rsi, [resultado_str]
    call print_string wrt ..plt

    pop rax
    pop rbp
    ret

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
    lea rsi, [resultado_str]
    call print_string wrt ..plt
    pop rbx
    pop rcx

    cmp rcx, 0
    jne .loop

    pop rcx
    pop rbx
    pop rbp
    ret