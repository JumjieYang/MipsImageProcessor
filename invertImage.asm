#Student ID = 260829732
#################################invert Image######################
.data
.macro save %reg
	sub $sp, $sp, 4
	sw %reg, ($sp)
	.end_macro 

.macro load %reg
	lw %reg, ($sp)
	addi $sp, $sp, 4
	.end_macro 
	
	
.text
.globl invert_image
invert_image:
	# $a0 -> image struct
	#############return###############
	# $v0 -> new inverted image
	############################
	# Add Code
	save ($ra)
	save ($fp)
	move $fp, $sp
	
	lw $s1, ($a0)	#width
	lw $s2, 4($a0)	#height
	lw $s3, 8($a0)	#maxValue
	
	mul $s4, $s1, $s2	#size of array
	
	addi $s0, $a0, 12	#pointer to the start
	li $s5, 0	#initialize the maximum as 0
	move $t0, $s4	#counter

Loop:
	beq $t0, 0, end
	lbu $t1, ($s0)
	
	sub $t2, $s3, $t1
	
	ble $t2, $s5, finish
	move $s5, $t2	#potential maximum

finish:
	sb $t2, ($s0)
	addi $t0, $t0, -1
	addi $s0, $s0, 1
	j Loop

end:
	sw $s5, 8($a0)	#maxValue
	
	move $sp, $fp
	load ($fp)
	load ($ra)
	jr $ra
