.data
	vector: .space 40
	ind_izq: .word 0
	ind_der: .word 3
	msg1: .asciiz "Longitud del vector (Max 10): "
	msg2: .asciiz "Ingrese un numero: "
	msg3: .asciiz "Vector original: "
	msg4: .asciiz "Vector ordenado: "
	espacio: .asciiz " "
	salto: .asciiz "\n"
	
.text
.globl main

main:
	# pedimos cuantos números va a meter el usuario
	la $a0, msg1
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	move $s0, $v0 # guardamos la cantidad en $s0
	
	la $s1, vector # $s1 apunta al inicio del vector
	li $t0, 0 # contador = 0
	
	leer:
	
	# leemos cada número y lo guardamos en el vector
	bge $t0, $s0, finleer # si ya leímos todos, salimos
	
	la $a0, msg2
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	sw $v0, 0($s1)  # guardamos el número en el vector
	addi $s1, $s1, 4 # avanzamos al siguiente espacio
	addi $t0, $t0, 1 # contador++
	j leer
	
	finleer:
		# imprime " vector original: "
		la $a0, msg3
		li $v0, 4
		syscall
	
		la $a0, vector
		move $a1, $s0 
		jal imprimir # imprime el vector desordenado
	
		# llamamos a ordenar con el vector completo
		la $a0, vector
		li $a1, 0 # ind_izq = 0
		subi $a2, $s0, 1  # ind_der = cantidad-1
	
		jal quicksort
	
		# imprime " vector ordenado: "
		la $a0, msg4
		li $v0, 4
		syscall
	
		la $a0, vector
		move $a1, $s0
		jal imprimir # imprime el vector ordenado
	
		li $v0, 10 # fin del programa
		syscall
	
	imprimir:
		# función para imprimir el vector
		move $t0, $a0 # $t0 = dirección del vector
		li $t1, 0 # contador = 0
	
		imprimirLoop:
	
			bge $t1, $a1, finImprimir # si ya imprimimos todo, salimos
		
			lw $a0, 0($t0) # cargamos el número
			li $v0, 1
			syscall # lo imprimimos
			
			li $v0, 4
			la $a0, espacio
			syscall # ponemos espacio entre números
		
			addi $t0, $t0, 4 # avanzamos al siguiente
			addi $t1, $t1, 1 # contador++
		
			j imprimirLoop
	
	finImprimir:
	
		la $a0, salto
		li $v0, 4
		syscall # saltamos de línea
		jr $ra  # volvemos a donde llamaron
	
quicksort:
	# guardamos todo lo que necesitamos en la pila
	addi $sp, $sp, -32
	sw $a2, 28($sp)
	sw $a1, 24($sp)
	sw $a0, 20($sp)
	sw $ra, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	sw $s3, 4($sp)
	sw $s4, 0($sp)

	bge $a1, $a2, fin  # si izq >= der, ya no hay nada que hacer

	move $s1, $a1 # i = ind_izq
	move $s2, $a2 # j = ind_der
	
	# elegimos el pivote como el elemento del medio
	add $t1, $a1, $a2
	li $t2, 2
	div $t1, $t2
	mflo $t1 # $t1 = (izq+der)/2
	
	sll $t1, $t1, 2 # multiplicamos por 4 para obtener el offset
	add $t1, $a0, $t1
	lw $t7, 0($t1) # $t7 = pivote
	
	do:
		# mientras v[i] < pivote, avanzamos i
		while1:
			sll $t1, $s1, 2
			add $t1, $a0, $t1
			lw $s3, 0($t1) # $s3 = v[i]
			
			slt $t0, $s3, $t7 # v[i] < pivote?
			beq $t0, $zero, endwhile1
			addi $s1, $s1, 1 # i++
			j while1
			
		endwhile1:
		
		# mientras v[j] > pivote, retrocedemos j
		while2:
			sll $t2, $s2, 2
			add $t2, $a0, $t2
			lw $s4, 0($t2) # $s4 = v[j]
			
			slt $t0, $t7, $s4 # pivote < v[j]?
			beq $t0, $zero, endwhile2
			sub $s2, $s2, 1 # j--
			j while2
			
		endwhile2:
		
		# si i <= j, intercambiamos v[i] y v[j]
		if1:
			bgt $s1, $s2, finif1
			sll $t3, $s1, 2
			add $t3, $a0, $t3 # $t3 = &v[i]
			sll $t4, $s2, 2
			add $t4, $a0, $t4 # $t4 = &v[j]
			lw $t5, 0($t3) # guardamos v[i]
			lw $t6, 0($t4) # guardamos v[j]
			sw $t6, 0($t3) # v[i] = v[j]
			sw $t5, 0($t4) # v[j] = v[i]
			addi $s1, $s1, 1 # i++
			sub $s2, $s2, 1  # j--
		finif1:
		
	while:
	ble $s1, $s2, do # repetimos mientras i <= j
		
	# ordenamos la parte izquierda
	if2:
		bge $a1, $s2, endif2 # si no hay elementos a la izquierda, saltamos
		move $a2, $s2 # nuevo der = j
		jal quicksort # llamada recursiva
	endif2:
		
	# ordenamos la parte derecha
	if3:
		bge $s1, $a2, endif3 # si no hay elementos a la derecha, saltamos
		move $a1, $s1 # nuevo izq = i
		jal quicksort # llamada recursiva
	endif3:

fin:
	# recuperamos todo lo que guardamos
	lw $s4, 0($sp)
	lw $s3, 4($sp)
	lw $s2, 8($sp)
	lw $s1, 12($sp)
	lw $ra, 16($sp)
	lw $a0, 20($sp)
	lw $a1, 24($sp)
	lw $a2, 28($sp)
	addi $sp, $sp, 32
	jr $ra # volvemos a donde llamaron
