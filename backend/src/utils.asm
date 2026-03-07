; ============================================
; UTILIDADES COMPARTIDAS
; Funciones comunes usadas por todos los módulos
; ============================================

section .data
    newline db 10, 0
    msgPausar db 10, "  Presione ENTER para continuar...", 0

section .bss
    extern buffer

section .text
    global print_string
    global strlen
    global leer_opcion
    global pausar
    global print_number
    global ascii_to_num

; ============================================
; PROCEDIMIENTO: Imprimir string
; Entrada: RSI = dirección del string (terminado en 0)
; ============================================
print_string:
    push rbp
    mov rbp, rsp
    push rdi
    push rdx
    
    mov rdi, rsi
    call strlen
    mov rdx, rax
    
    mov rax, 1
    mov rdi, 1
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
; PROCEDIMIENTO: Leer opción del usuario
; ============================================
leer_opcion:
    push rbp
    mov rbp, rsp
    
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 10
    syscall
    
    pop rbp
    ret

; ============================================
; PROCEDIMIENTO: Pausar (esperar ENTER)
; ============================================
pausar:
    push rbp
    mov rbp, rsp
    
    ; Mostrar mensaje
    mov rsi, msgPausar
    call print_string
    
    ; Esperar ENTER
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 2
    syscall
    
    pop rbp
    ret

; ============================================
; PROCEDIMIENTO: Imprimir número (0-9999)
; Entrada: RAX = número
; ============================================
print_number:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    push rdx
    
    ; Buffer local para el número
    sub rsp, 16
    mov rbx, rsp
    
    ; Convertir número a string
    mov rcx, 10
    xor r8, r8          ; Contador de dígitos
    
    ; Caso especial: 0
    cmp rax, 0
    jne .convert
    
    mov byte [rbx], '0'
    mov byte [rbx + 1], 0
    mov rsi, rbx
    call print_string
    jmp .fin

.convert:
    ; Dividir por 10 repetidamente
.div_loop:
    xor rdx, rdx
    div rcx             ; RAX = RAX / 10, RDX = resto
    
    add dl, '0'
    push rdx
    inc r8
    
    cmp rax, 0
    jne .div_loop
    
    ; Construir string desde el stack
    xor r9, r9
.build_string:
    pop rdx
    mov [rbx + r9], dl
    inc r9
    dec r8
    jnz .build_string
    
    mov byte [rbx + r9], 0
    
    mov rsi, rbx
    call print_string

.fin:
    add rsp, 16
    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret

; ============================================
; PROCEDIMIENTO: Convertir ASCII a número (max 2 dígitos)
; Entrada: RSI = string
; Salida: RAX = número (0-99) o -1 si error
; ============================================
ascii_to_num:
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    
    xor rax, rax
    xor rbx, rbx
    
.loop:
    movzx rcx, byte [rsi + rbx]
    
    cmp cl, 10
    je .done
    cmp cl, 0
    je .done
    
    cmp cl, '0'
    jl .error
    cmp cl, '9'
    jg .error
    
    sub cl, '0'
    imul rax, 10
    add rax, rcx
    
    inc rbx
    cmp rbx, 2
    jg .error
    
    jmp .loop

.done:
    cmp rbx, 0
    je .error
    
    cmp rax, 99
    jg .error
    
    jmp .fin

.error:
    mov rax, -1

.fin:
    pop rcx
    pop rbx
    pop rbp
    ret