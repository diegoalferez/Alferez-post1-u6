; lab6_instrucciones.asm - Demostracion de categorias de instrucciones x86
; Arquitectura de Computadores - Unidad 6 - Post-contenido (Parte 1)
; Autor: Alferez
; Compilar: nasm -f bin lab6_instrucciones.asm -o lab6_instrucciones.com
;
; El programa es un .COM de DOS (un solo segmento, inicio en el offset 100h).
; Recorre en orden las cuatro categorias de instrucciones x86 (transferencia,
; aritmetica, logica y control de flujo), el contraste entre desplazamiento y
; rotacion de bits, y termina con INT 20h para retornar a DOS.

        org 100h                ; offset de inicio de todo archivo .COM

; -- Datos -----------------------------------------------------------------
        jmp inicio              ; el programa salta sobre los datos hacia el codigo
valor_a     dw 45               ; primer operando
valor_b     dw 12               ; segundo operando
resultado   dw 0                ; almacena el resultado de la suma
contador    db 5                ; contador de bucle (documental)
mascara     db 0Fh              ; mascara de los 4 bits bajos

; -- Codigo ----------------------------------------------------------------
inicio:

; == BLOQUE 1: Transferencia de datos ======================================
        ; MOV: copia de memoria a registro
        mov ax, [valor_a]       ; AX = 45 (contenido de valor_a)
        mov bx, [valor_b]       ; BX = 12 (contenido de valor_b)

        ; MOV entre registros
        mov cx, ax              ; CX = AX = 45
        mov dx, bx              ; DX = BX = 12

        ; LEA: carga la direccion de la variable, no su contenido
        lea si, [valor_a]       ; SI = direccion de valor_a
        mov ax, [si]            ; AX = mem[SI] = 45 (acceso indirecto por SI)

        ; XCHG: intercambio de registros
        xchg cx, dx             ; CX = 12, DX = 45
        xchg cx, dx             ; se restaura: CX = 45, DX = 12

        ; PUSH/POP: el programa preserva y restaura AX
        push ax                 ; guarda AX = 45 en la pila
        mov ax, 0FFFFh          ; modifica AX temporalmente
        pop ax                  ; restaura AX = 45

; == BLOQUE 2: Operaciones aritmeticas =====================================
        ; ADD: suma con actualizacion de flags
        mov ax, [valor_a]       ; AX = 45
        add ax, [valor_b]       ; AX = 45 + 12 = 57 (ZF=0, CF=0, OF=0)
        mov [resultado], ax     ; guarda 57 en memoria

        ; SUB: resta
        mov ax, [valor_b]       ; AX = 12
        sub ax, [valor_a]       ; AX = 12 - 45 = -33 = 0FFDFh (SF=1, CF=1, OF=0)

        ; INC y DEC: incremento y decremento (no afectan CF)
        mov ax, [valor_a]       ; AX = 45
        inc ax                  ; AX = 46
        dec ax                  ; AX = 45

        ; MUL: multiplicacion sin signo de 8 bits (AX = AL * operando)
        mov al, 10              ; AL = 10
        mov bl, 7               ; BL = 7
        mul bl                  ; AX = 10 * 7 = 70

        ; DIV: division sin signo de 8 bits (AL = cociente, AH = resto)
        mov ax, 100             ; AX = 100
        mov bl, 7               ; BL = 7
        div bl                  ; AL = 14, AH = 2 (100 = 7 * 14 + 2)

; == BLOQUE 3: Operaciones logicas =========================================
        mov al, 0B7h            ; AL = 1011 0111b

        ; AND: mascara de limpieza, conserva solo los 4 bits bajos
        and al, [mascara]       ; AL = 0B7h AND 0Fh = 07h
        mov al, 0B7h            ; se restaura AL

        ; OR: activa bits, enciende los 4 bits altos
        or al, 0F0h             ; AL = 0B7h OR 0F0h = 0F7h
        mov al, 0AAh            ; AL = 1010 1010b

        ; XOR: inversion selectiva
        xor al, 0FFh            ; AL = NOT AL = 55h

        ; XOR reg,reg: forma estandar de poner un registro en cero
        xor bx, bx              ; BX = 0 (mas corto que MOV bx, 0)

        ; TEST: AND sin guardar el resultado, solo actualiza flags
        mov al, 0B7h
        test al, 01h            ; ZF=0 porque el bit 0 es 1 (numero impar)

        ; SHL/SHR: desplazamiento = multiplicar o dividir por potencias de 2
        mov al, 08h             ; AL = 8
        shl al, 2              ; AL = 8 * 4 = 32 = 20h
        shr al, 1               ; AL = 32 / 2 = 16 = 10h

; == BLOQUE 4: Control de flujo ============================================
        ; Estructura if/else: compara valor_a con valor_b
        mov ax, [valor_a]       ; AX = 45
        cmp ax, [valor_b]       ; 45 - 12 = 33 > 0
        jg .mayor               ; salta si AX > valor_b (con signo)
        je .igual               ; salta si AX = valor_b
        xor cx, cx              ; caso menor (no se alcanza): CX = 0
        jmp .fin_cmp
.mayor:
        mov cx, 1               ; CX = 1 indica que valor_a > valor_b
        jmp .fin_cmp
.igual:
        mov cx, 2               ; CX = 2 indica igualdad
.fin_cmp:

        ; Bucle: suma acumulada de 1 a 5 (resultado esperado: 15)
        xor ax, ax              ; AX = 0 (acumulador)
        mov cx, 5               ; CX = contador del bucle
        mov bx, 1               ; BX = siguiente valor a sumar
.bucle_suma:
        add ax, bx              ; AX = AX + BX
        inc bx                  ; BX = siguiente valor
        loop .bucle_suma        ; CX = CX - 1; si CX <> 0 salta a .bucle_suma
        ; Al terminar: AX = 1+2+3+4+5 = 15
.fin_suma:

        int 20h                 ; el programa retorna a DOS
