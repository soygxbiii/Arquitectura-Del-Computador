.data
	msg1: .asciiz "Introduce un numero entero positivo: "
	msg2: .asciiz "Es un numero par"
	msg3: .asciiz "Es un numero impar"
.text
.globl main

main:

	# Pide el valor de n al usuario
	la $a0, msg1
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	move $a0, $v0 # Guarda n en $a0
	
	slt $t0,$a0, $zero # Verifica si el número es negativo
	bne $t0, $zero, fin # Si es negativo, termina el programa
	
	# Calcular paridad(n)
	jal paridad
	move $s0, $v0 # Guardar resultado en $s0
	
	bne $s0, $zero, impar # Si $s0 es distinto de 0, el número es impar
	
	# Imprime el mensaje de que n es par
	la $a0, msg2
	li $v0,4
	syscall
	
	j fin
	
	impar:
	
	# Imprime el mensaje de que n es impar
	la $a0, msg3
	li $v0, 4
	syscall
	
	fin:
	
	# Termina el programa
	li $v0, 10
	syscall
	
paridad:

	addi $sp, $sp, -8 # Reserva 8 bytes
	sw $a0, 4($sp) # Guarda el valor de n en la pila
	sw $ra, 0($sp) # Guarda la dirección de retorno en la pila
	
	# Caso base: (n = 0)	
	li $v0, 0 # Valor por defecto
	beq $a0, $zero, finparidad
	
	# Llamada recursiva
	addi $a0, $a0, -1 # n = n - 1
	jal paridad
	
	li $t0, 1
	sub $v0, $t0, $v0 # $v0 = 1 - paridad(n - 1)
	
finparidad:

	lw $ra, 0($sp) # Recupera la dirección de retorno
	lw $a0, 4($sp) # Recupera el n original
	addi $sp, $sp, 8 # Libera el espacio de la pila
	jr $ra # Regresa