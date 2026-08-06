.data
    buffer:     .space 100 # Espacio para 100 caracteres
    tamanio:    .word 100 # Tamaño máximo del buffer
    msg_inicio: .asciiz "\nIniciando intervalo de 20s (Solo A-Z):\n"
    msg_fin:    .asciiz "\nTiempo agotado. Contenido del buffer:\n"
    nuevaLinea:    .asciiz "\n"

.text

main:
    bucle: # Bucle infinito principal
    
        li $t7, 0 # Índice de escritura
        lw $t8, tamanio # Límite del buffer
    
        li $v0, 4
        la $a0, msg_inicio
        syscall

        li $v0, 30 # Tiempo actual
        syscall
        move $s0, $a0 # Guardar inicio

    leer: # Captura por 20 segundos
        
        li $v0, 30
        syscall
        sub $t0, $a0, $s0 # Tiempo transcurrido
        bgt $t0, 20000, repetir # Si pasaron 20s, imprimir

        lw $t1, 0xffff0000 # Receiver Control
        andi $t1, $t1, 1 # Bit Ready
        beq $t1, $zero, leer # No hay tecla

        lw $t2, 0xffff0004 # ASCII de la tecla

        blt $t2, 65, leer # Menor que 'A'
        bgt $t2, 90, leer # Mayor que 'Z'

        sb $t2, buffer($t7) # Guardar caracter
        addi $t7, $t7, 1
    
        blt $t7, $t8, leer # Si no está lleno
        li $t7, 0 # Reiniciar índice si está lleno
        j leer

    repetir: # Mostrar buffer
    
        li $v0, 4
        la $a0, msg_fin
        syscall

        li $t1, 0 # Índice de lectura
        
    imprimir:
        beq $t1, $t7, reiniciar
    
        lb $a0, buffer($t1)
        li $v0, 11
        syscall
    
        addi $t1, $t1, 1
        j imprimir

    reiniciar:
        li $v0, 4
        la $a0, nuevaLinea
        syscall
        j bucle