# Direcciones fijas del hardware (E/S mapeada en memoria):
# TensionControl = 0xFFFF0000
# TensionEstado  = 0xFFFF0004
# TensionSistol  = 0xFFFF0008
# TensionDiastol = 0xFFFF000C

.data
	TensionControl:  .word 0
	TensionEstado:   .word 1 # 0 = midiendo, 1 = listo
	TensionSistol:   .word 120 # Valor de tension sistolica
	TensionDiastol:  .word 80 # Valor de tension diastolica 

.text
.globl main

main:

    jal controlador_tension
    
    # Imprime el valor de tension sistolica
    move $a0, $v0
    li $v0, 1
    syscall
    
    # Imprime un espacio
    li $a0, ' '
    li $v0, 11
    syscall
    
    # Imprime el valor de tension diastolica
    move $a0, $v1
    li $v0, 1
    syscall
    
    # Finaliza el programa
    li $v0, 10
    syscall

controlador_tension:

    # Inicia la medición escribiendo 1 en TensionControl
    li $t0, 1
    la $t1, TensionControl
    sw $t0, 0($t1) # Escribir 1 para iniciar medición
    
	esperar_medicion:
	
	# Ahora espera a que la medición esté lista (TensionEstado == 1)
    	la $t1, TensionEstado
    	lw $t0, 0($t1) # Leer estado
    	
    	beq $t0, $zero, esperar_medicion # Si es 0, seguir esperando
    
    	# Lee los valores
    	
    	la $t1, TensionSistol
    	lw $v0, 0($t1) # Guarda el valor sistólico a $v0
    
    	la $t1, TensionDiastol
    	lw $v1, 0($t1) # Guarda el valor diastólico a $v1
    
    	jr $ra 
