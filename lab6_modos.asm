; lab6_modos.asm - Demostracion de modos de direccionamiento x86
; Arquitectura de Computadores - Unidad 6 - Post-contenido (Parte 2)
; Autor: Alferez
; Compilar: nasm -f bin lab6_modos.asm -o lab6_modos.com
;
; El programa es un .COM de DOS (un solo segmento, inicio en el offset 100h).
; Accede a los mismos tipos de dato (un array de enteros y un registro de tres
; campos) con modos de direccionamiento distintos para que la direccion
; efectiva de cada acceso pueda verificarse en DEBUG.

        org 100h                ; offset de inicio de todo archivo .COM

; -- Datos de prueba -------------------------------------------------------
        jmp inicio              ; el programa salta sobre los datos hacia el codigo

; Array de 5 enteros de 16 bits
array       dw 10, 20, 30, 40, 50

; Registro de estudiante: nota1 (16 b) + nota2 (16 b) + promedio (16 b)
nota1       dw 85
nota2       dw 73
promedio    dw 0

; Variable simple para direccionamiento directo
var_x       dw 0FFFFh

; Tabla de bytes con los digitos hexadecimales en ASCII (uso opcional con XLAT)
tabla_hex   db 30h, 31h, 32h, 33h, 34h, 35h, 36h, 37h
            db 38h, 39h, 41h, 42h, 43h, 44h, 45h, 46h

; -- Codigo ----------------------------------------------------------------
inicio:

; == MODO 1: INMEDIATO =====================================================
; El operando es una constante incluida dentro de la propia instruccion
        mov ax, 100             ; AX = 100 (inmediato decimal)
        mov bx, 0A5h            ; BX = 0A5h (inmediato hexadecimal)
        add cx, 55              ; CX = CX + 55 (inmediato en una suma)
        and dx, 00FFh           ; DX = DX AND mascara inmediata
        ; DEBUG: U 100 muestra el valor dentro del opcode (MOV AX,0064)

; == MODO 2: DIRECTO =======================================================
; La direccion del operando esta fija en la instruccion
        mov ax, [var_x]         ; AX = mem[var_x] = 0FFFFh
        mov bx, [array]         ; BX = mem[array] = 10 (primer elemento)
        mov cx, [nota1]         ; CX = mem[nota1] = 85
        mov [var_x], word 0     ; mem[var_x] = 0 (escritura directa a memoria)
        ; DEBUG: U muestra MOV AX,[01xx] con la direccion dentro del opcode

; == MODO 3: INDIRECTO POR REGISTRO ========================================
; El registro contiene la direccion; el puntero puede cambiar en ejecucion
        mov si, nota1           ; SI = direccion de nota1 (no su valor)
        mov ax, [si]            ; AX = mem[SI] = 85
        mov si, nota2           ; SI = direccion de nota2
        mov bx, [si]            ; BX = mem[SI] = 73
        add ax, bx              ; AX = 85 + 73 = 158
        shr ax, 1               ; AX = 158 / 2 = 79
        mov si, promedio        ; SI = direccion de promedio
        mov [si], ax            ; mem[SI] = 79 (guarda el promedio por el puntero)
.fin_indirecto:

; == MODO 4: INDEXADO (BASE + INDICE + DESPLAZAMIENTO) =====================
; Direccion efectiva = base + indice + desplazamiento
        ; Elemento puntual: array[2] = 30
        mov bx, array           ; BX = direccion base del array
        mov si, 4               ; SI = indice * tamano del elemento = 2 * 2 = 4
        mov ax, [bx + si]       ; AX = mem[BX+SI] = array[2] = 30

        ; Suma acumulada de todos los elementos del array
        xor ax, ax              ; AX = 0 (acumulador)
        mov bx, array           ; BX = direccion base
        mov cx, 5               ; CX = cantidad de elementos
        xor si, si              ; SI = 0 (indice en bytes)
.bucle_array:
        add ax, [bx + si]       ; AX = AX + array[SI/2]
        add si, 2               ; avanza 2 bytes (una palabra)
        loop .bucle_array
        ; Al terminar: AX = 10+20+30+40+50 = 150
.fin_array:

        ; Acceso a los campos del registro con desplazamiento fijo
        mov bx, nota1           ; BX = base del registro (nota1, nota2, promedio)
        mov ax, [bx]            ; AX = nota1 = 85 (desplazamiento 0)
        mov cx, [bx + 2]        ; CX = nota2 = 73 (desplazamiento 2)
        mov dx, [bx + 4]        ; DX = promedio = 79 (desplazamiento 4)

        int 20h                 ; el programa retorna a DOS
