.data
    msg_verde:    .asciiz "\nSemáforo en verde, esperando pulsador (tecla 's')\n"
    msg_activado: .asciiz "Pulsador activado: en 20 segundos, el semáforo cambiará a amarillo\n"
    msg_amarillo: .asciiz "Semáforo en amarillo, en 10 segundos, semáforo en rojo\n"
    msg_rojo:     .asciiz "Semáforo en rojo, en 30 segundos, semáforo en verde\n"

.text

main:
	verde: 
	
    		li $v0, 4
   		la $a0, msg_verde
    		syscall
	
	# Espera la tecla 's' mediante memory-mapped I/O
	esperar: 
	
    		lw $t0, 0xffff0000 # Receiver Control
    		andi $t0, $t0, 1 # Bit Ready
    		beq $t0, $zero, esperar # No hay tecla

    		lw $t1, 0xffff0004 # Receiver Data (ASCII)
    		li $t2, 115 # 's' minúscula
   		bne $t1, $t2, esperar # Ignorar si no es 's'

    		li $v0, 4
    		la $a0, msg_activado
    		syscall

    		li $a0, 20000 # 20 segundos
    		jal temporizador
	
	amarillo: 
	
    		li $v0, 4
    		la $a0, msg_amarillo
    		syscall

    		li $a0, 10000 # 10 segundos
    		jal temporizador

	rojo: 
	
    		li $v0, 4
    		la $a0, msg_rojo
    		syscall

    		li $a0, 30000 # 30 segundos
    		jal temporizador

    		j verde

	temporizador: # Espera $a0 milisegundos
	
    		move $s0, $a0 # Tiempo deseado
    		li $v0, 30 # Obtener tiempo actual
    		syscall
    		move $s1, $a0 # Tiempo de inicio
		
		bucle: 
	
    			li $v0, 30
    			syscall
    			sub $t0, $a0, $s1 # Transcurrido = actual - inicio        
    			blt $t0, $s0, bucle # Si no ha pasado, seguir
    
    			jr $ra # Volver
    			
