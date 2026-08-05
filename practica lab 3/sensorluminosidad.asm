# Direcciones fijas del hardware (E/S mapeada en memoria):
# LuzControl = 0xFFFF0000
# LuzEstado  = 0xFFFF0004
# LuzDatos   = 0xFFFF0008

.data
	msg: .asciiz "Error en el sensor de luz"
	LuzControl: .word 0
	LuzEstado:  .word 1 # 0 = no listo, 1 = listo, -1 = error
	LuzDatos:   .word 512 # Valor de luminosidad (0 - 1023)

.text
.globl main

main:

    jal InicializarSensorLuz
    bne $v0, $zero, error # Si no retorna 0, hubo error en la inicialización

    jal LeerLuminosidad # Devuelve el valor leido
    bne $v0, $zero, error # Si el código de estado no es 0, hubo error

    move $a0, $s0 # Pasa el valor de luminosidad a $a0
    li  $v0, 1 # Imprime un valor entero entre 0 y 1023)
    syscall
    
    j   fin

	error:
	
	# Imprime la cadena
    	la  $a0, msg
    	li  $v0, 4
    	syscall
    
	fin:
	
    	# Finaliza el programa
    	li  $v0, 10
    	syscall


InicializarSensorLuz:
  
    la  $t0, LuzControl # Direccion simulada de LuzControl
    li  $t1, 1 # Valor 0x1 para inicializar
    sw  $t1, 0($t0) # Escribe en LuzControl 

	while:
   		la  $t0, LuzEstado # Direccion simulada de LuzEstado
    		lw  $t1, 0($t0) # Lee el estado
    
    		beq $t1, 1, if # Si es 1, lectura disponible/listo
    		beq $t1, -1, else # Si es -1, error de hardware
    		beq $t1, 0, while

	if:
    		li  $v0, 0 # Retorna 0 (éxito)
    		jr  $ra

	else:
    		li  $v0, -1 # Retorna -1 (error)
    		jr  $ra


LeerLuminosidad:

    la  $t0, LuzEstado # Direccion simulada de LuzEstado
    lw  $t1, 0($t0) # Lee el estado
    
    bne $t1, 1, fallo # Si no es 1, hay error

    la  $t0, LuzDatos # Direccion simulada de LuzDatos
    lw  $s0, 0($t0) # Guarda el valor de luminosidad en $s0 (para no perderlo)
    
    li  $v0, 0 # Retorna 0 (lectura correcta)
    jr  $ra

	fallo:
	
    		li  $v0, -1 # Retorna -1 (error)
    		jr  $ra