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

section .data              ; Sección de datos inicializados

    ; === SUBMENÚ ARITMÉTICO ===
    menu_arit db 10, 27, "[1;33m"   ; Salto de línea + código ANSI color amarillo
              db "      ┌──────────────────────────────┐", 10
              db "      │   OPERACIONES ARITMETICAS    │", 10
              db "      └──────────────────────────────┘", 10
              db 27, "[0m"          ; Resetear color
              db "       ", 27, "[1;37m", "1.", 27, "[0m", " Suma", 10
              db "       ", 27, "[1;37m", "2.", 27, "[0m", " Resta", 10
              db "       ", 27, "[1;37m", "3.", 27, "[0m", " Multiplicacion", 10
              db "       ", 27, "[1;31m", "4.", 27, "[0m", " Division", 10
              db "       ", 27, "[1;31m", "5.", 27, "[0m", " Volver al menu principal", 10, 10
              db "      Opcion: ", 0     ; Texto final del menú terminado en NULL
    
    ; === MENSAJES ===
    msg_num1 db 10, "  Ingrese primer número (00-99): ", 0
    msg_num2 db "  Ingrese segundo número (00-99): ", 0
    msg_resultado db "  Resultado: ", 0
    msg_cociente db "  Cociente: ", 0
    msg_residuo db "  Residuo: ", 0
    msg_div_cero db 10, "  ❌ ERROR: División por cero no permitida!", 10, 0
    msg_invalido db 10, "  ❌ ERROR: Número inválido. Use solo dígitos 0-9.", 10, 0
    msg_opcion_invalida db 10, "  ❌ Opción inválida.", 10, 0
    newline db 10, 0        ; Salto de línea

section .bss               ; Sección de variables sin inicializar
    num1 resb 4            ; Reserva 4 bytes para número 1
    num2 resb 4            ; Reserva 4 bytes para número 2
    extern buffer          ; Buffer externo (de utils.asm)

section .data
    clear_scr db 27, "[2J", 27, "[H", 0   ; Código ANSI para limpiar pantalla

section .text
    global menu_aritmetico ; Hace visible esta función a otros módulos
    
    ; Funciones externas de utils.asm
    extern print_string    ; Imprime cadena
    extern leer_opcion     ; Lee una opción del teclado
    extern pausar          ; Espera una tecla
    extern print_number    ; Imprime número en RAX
    extern ascii_to_num    ; Convierte ASCII a número

; ============================================
; MENÚ ARITMÉTICO
; ============================================
menu_aritmetico:
    push rbp               ; Guarda base pointer anterior
    mov rbp, rsp           ; Establece nuevo stack frame

.loop:
    ; Limpiar pantalla
    mov rax, 1             ; syscall write
    mov rdi, 1             ; stdout
    lea rsi, [rel clear_scr] ; Dirección del string limpiar pantalla
    mov rdx, 7             ; Cantidad de bytes
    syscall                ; Llamada al sistema
    
    mov rsi, menu_arit     ; Cargar dirección del menú
    call print_string      ; Mostrar menú
    
    call leer_opcion       ; Leer opción
    mov al, [buffer]       ; Obtener carácter ingresado
    
    cmp al, '1'            ; ¿Es '1'?
    je .suma
    cmp al, '2'
    je .resta
    cmp al, '3'
    je .multiplicacion
    cmp al, '4'
    je .division
    cmp al, '5'
    je .volver
    
    mov rsi, msg_opcion_invalida ; Mensaje error
    call print_string
    call pausar
    jmp .loop              ; Volver al menú

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
    
    call leer_dos_numeros   ; BL=num1, CL=num2
    cmp rax, 0              ; ¿Hubo error?
    je .error
    
    add bl, cl              ; BL = BL + CL
    
    mov rsi, msg_resultado
    call print_string
    
    movzx rax, bl           ; Pasar resultado a RAX
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
    
    sub bl, cl              ; BL = BL - CL
    
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
    
    movzx rax, bl           ; RAX = num1
    movzx rcx, cl           ; RCX = num2
    mul rcx                 ; RDX:RAX = RAX * RCX
    
    mov rsi, msg_resultado
    call print_string
    
    call print_number       ; RAX ya contiene resultado
    
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
; OPERACIÓN: DIVISIÓN (64 BITS)
; ============================================
operacion_division:
    push rbp
    mov rbp, rsp
    
    call leer_dos_numeros
    cmp rax, 0
    je .error
    
    cmp cl, 0               ; ¿Divisor es 0?
    je .div_cero
    
    movzx rax, bl           ; Dividendo
    movzx rcx, cl           ; Divisor
    xor rdx, rdx            ; Limpiar RDX antes de dividir
    div rcx                 ; RAX=cociente, RDX=residuo
    
    push rdx                ; Guardar residuo
    
    mov rsi, msg_cociente
    call print_string
    call print_number       ; Imprime cociente
    
    mov rsi, newline
    call print_string
    
    mov rsi, msg_residuo
    call print_string
    
    pop rax                 ; Recuperar residuo
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
; ============================================
leer_dos_numeros:
    push rbp
    mov rbp, rsp
    
    mov rsi, msg_num1
    call print_string
    
    mov rax, 0              ; syscall read
    mov rdi, 0              ; stdin
    mov rsi, num1           ; buffer destino
    mov rdx, 4              ; máximo 4 bytes
    syscall
    
    mov rsi, num1
    call ascii_to_num       ; Convertir texto a número
    cmp rax, -1             ; ¿Error?
    je .error
    mov bl, al              ; Guardar en BL
    
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
    mov cl, al              ; Guardar en CL
    
    mov rax, 1              ; Retornar éxito
    jmp .fin

.error:
    xor rax, rax            ; Retornar 0 (error)

.fin:
    pop rbp
    ret