.data
	msg_n: .asciiz "Longitud del vector (Max 10): "
	msg_num: .asciiz "Ingrese un numero: "
	msg3: .asciiz "Vector original: "
	msg4: .asciiz "Vector ordenado: "
	espacio: .asciiz " "
	salto: .asciiz "\n"
    
.text
.globl main

main:
	la $a0, msg_n # pedimos cuantos numeros va a tener el vector
	li $v0, 4
	syscall
	
	li $v0, 5 # leemos la cantidad
	syscall
	move $s7, $v0 # guardamos en $s7
	sll $s6, $v0, 2 # multiplicamos por 4 para saber cuantos bytes
	
	move $a0, $s6 # reservamos memoria para el arreglo principal
	li $v0, 9
	syscall
	move $s5, $v0 # $s5 = puntero al arreglo
	
	li $v0, 9 # reservamos memoria para el arreglo auxiliar
	syscall
	move $s4, $v0 # $s4 = puntero al arreglo auxiliar

	move $t0, $s5 # $t0 apunta al inicio
	add $t1, $s5, $s6 # $t1 apunta al final

	for1:
		bge $t0, $t1, endfor1 # si llegamos al final salimos
	
		la $a0, msg_num # pedimos un numero
		li $v0, 4
		syscall
	
		li $v0, 5 # leemos el numero
		syscall
		sw $v0, 0($t0) # lo guardamos en el arreglo
		addi $t0, $t0, 4 # avanzamos al siguiente espacio
		j for1
		
	endfor1:

	la $a0, msg3 # imprimimos "Vector original: "
	li $v0, 4
	syscall
	
	move $a0, $s5 # pasamos el arreglo
	move $a1, $s7 # pasamos la cantidad
	jal imprimir  # llamamos a imprimir

	move $a0, $s5 # pasamos el arreglo
	add $a1, $s5, $s6 # pasamos el final
	jal mergesort # llamamos a ordenar

	la $a0, msg4 # imprimimos "Vector ordenado: "
	li $v0, 4
	syscall
	
	move $a0, $s5 # pasamos el arreglo
	move $a1, $s7 # pasamos la cantidad
	jal imprimir # llamamos a imprimir

	li $v0, 10 # salimos
	syscall

	imprimir:
		move $t0, $a0 # $t0 = direccion del vector
		li $t1, 0 # contador = 0

		imprimirLoop:
			bge $t1, $a1, finImprimir # si ya imprimimos todo salimos
			lw $a0, 0($t0) # cargamos el numero
	
			li $v0, 1 # lo imprimimos
			syscall
	
			li $v0, 4 # imprimimos un espacio
			la $a0, espacio
			syscall
	
			addi $t0, $t0, 4 # avanzamos al siguiente
			addi $t1, $t1, 1 # contador++
			j imprimirLoop

		finImprimir:
		
		la $a0, salto # imprimimos salto de linea
		li $v0, 4
		syscall
		jr $ra # volvemos

mergesort:

	sub $t0, $a1, $a0 # calculamos el tamaño en bytes
	ble $t0, 4, endmergesort # si es 1 elemento o menos salimos
	
	sub $t0, $a1, $a0 # calculamos el punto medio
	addi $t0, $t0, 3
	srl $t0, $t0, 3
	sll $t0, $t0, 2
	add $t0, $a0, $t0 # $t0 = puntero al medio
	
	addi $sp, $sp, -20 # guardamos todo en la pila
	sw $t0, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $ra, 12($sp)
	sw $s0, 16($sp)
	
	move $a1, $t0 # ordenamos la primera mitad
	jal mergesort
	
	lw $a0, 0($sp) # recuperamos el medio
	lw $a1, 8($sp) # recuperamos el final
	jal mergesort # ordenamos la segunda mitad
	
	lw $a0, 4($sp) # recuperamos el inicio
	lw $a1, 0($sp) # recuperamos el medio
	lw $a2, 8($sp) # recuperamos el final
	jal merge # mezclamos las dos mitades
	
	lw $s0, 16($sp) # recuperamos todo
	lw $ra, 12($sp)
	addi $sp, $sp, 20
	
endmergesort:

	jr $ra

merge:
	move $t0, $a0 # $t0 = puntero a la primera parte
	move $t1, $a1 # $t1 = puntero a la segunda parte
	move $t2, $s4 # $t2 = puntero al auxiliar

while1:
	bge $t0, $a1, endwhile1 # si la primera parte se acabo salimos
	bge $t1, $a2, endwhile1 # si la segunda parte se acabo salimos
	lw $t3, 0($t0) # carga elemento de la izquierda
	lw $t4, 0($t1) # carga elemento de la derecha

	if1:
		bgt $t3, $t4, endif1 # si el de la derecha es menor va al else
		sw $t3, 0($t2) # guarda el de la izquierda en el auxiliar
		addi $t0, $t0, 4 # avanza en la izquierda
		addi $t2, $t2, 4 # avanza en el auxiliar
		j finif1
	endif1:
	
	sw $t4, 0($t2) # guarda el de la derecha en el auxiliar
	addi $t1, $t1, 4 # avanza en la derecha
	addi $t2, $t2, 4 # avanza en el auxiliar
	finif1:
	
	j while1
	
endwhile1:

while2:
	bge $t0, $a1, endwhile2 # si la izquierda ya se acabó salimos
	lw $t3, 0($t0) # carga el elemento que sobro de la izquierda
	sw $t3, 0($t2) # lo guarda en el auxiliar
	addi $t0, $t0, 4 # avanza
	addi $t2, $t2, 4
	j while2
	
endwhile2:

while3:
	bge $t1, $a2, endwhile3 # si la derecha ya se acabo salimos
	lw $t4, 0($t1) # carga el elemento que sobro de la derecha
	sw $t4, 0($t2) # lo guarda en el auxiliar
	addi $t1, $t1, 4 # avanzo
	addi $t2, $t2, 4
	j while3
	
endwhile3:

	move $t0, $a0 # $t0 apunta al inicio del arreglo original
	move $t1, $s4 # $t1 apunta al inicio del auxiliar

while4:
	bge $t0, $a2, endwhile4 # si ya copió todo salimos
	lw $t2, 0($t1) # carga del auxiliar
	sw $t2, 0($t0) # lo guarda en el original
	addi $t0, $t0, 4 # avanza
	addi $t1, $t1, 4
	j while4
	
endwhile4:

	move $t0, $s4 # limpia el auxiliar para la proxima vez
	move $t1, $a0
	sub $t2, $a2, $a0

while5:
	ble $t2, $zero, endwhile5 # si ya limpió todo salimos
	sw $zero, 0($t0) # pone 0 en el auxiliar
	addi $t0, $t0, 4 # avanza
	sub $t2, $t2, 4 # resta 4 bytes
	j while5
	
endwhile5:

	jr $ra #volvemos