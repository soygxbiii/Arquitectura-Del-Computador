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
	move $t0, $v0 # Guarda n en $t0
	
	li $t1, -1
	ble $t0, $t1, finparidad # Ignora números negativos
		
	li $t2, 2
	div $t0, $t2
	mfhi $t3 # Guarda el residuo de la división ($t0 % 2) en $t3
			
	bne $t3, $zero, impar # Si $t3 es distinto de 0, el número es impar
			
	# Imprime el mensaje de que n es par
	la $a0, msg2
	li $v0,4
	syscall
			
	j finparidad
			
	impar:
		
	# Imprime el mensaje de que n es impar
	la $a0, msg3
	li $v0, 4
	syscall
		
	finparidad:
	
	# Termina el programa
	li $v0, 10
	syscall
