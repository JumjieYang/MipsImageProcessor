# Student ID = 260829732
##########################set pixel #######################
.data
err:	.asciiz "Index out of bounds!"
.text
.globl set_pixel
set_pixel:
	# $a0 -> image struct
	# $a1 -> row number
	# $a2 -> column number
	# $a3 -> new value (clipped at 255)
	###############return################
	#void
	# Add code here
	ble $a3, 255, check
	li $a3,255

check:
	lw $t1, ($a0) #get the width
	blt $a1, 0, print_error
	bge $a1, $t1, print_error
	
	lw $t2, 4($a0) #get the height
	blt $a1, 0, print_error
	bge $a1, $t1, print_error
	
	addi $a0, $a0, 12
	
	mul $t1, $t1, $a1
	add $t1, $t1, $a2
	add $t1, $t1, $t0
	
	li $v0, 0
	sb $a3, ($t1)
	jr $ra

print_error:
	
	sub $sp, $sp, 4
	sw $a0, ($sp)
	
	sub $sp, $sp, 4
	sw $v0, ($sp)
	
	la $a0, err
	li $v0, 4
	syscall
	
	lw $v0, ($sp)
	addi $sp, $sp, 4
	lw $a0, ($sp)
	addi $sp, $sp, 4
	li $v0, 0
	jr $ra
	
	
