# Student ID = 260829732
###############################rescale image######################
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
.globl rescale_image
rescale_image:
	# $a0 -> image struct
	############return###########
	# $v0 -> rescaled image
	######################
	# Add Code
	save ($ra)
	save ($fp)
	move $fp, $sp
	save ($a0)
	
	lw $t1, ($a0)
	lw $t2, 4($a0)
	lw $t3, 8($a0)
	
	li $t4, 255	#assign maximum as 255
	sw $t4, 8($a0)
	
	mul $t4, $t1, $t2
	
	addi $t0, $a0, 12
	
	save($t1)
	save($t2)
	save($t3)
	save($t4)
	save($t0)
	
	move $a1, $t4
	jal findMin
	
	load($t0)
	load($t4)
	load($t3)
	load($t2)
	load($t1)
	
	move $t5, $v0
	move $t6, $v1
	
	move $a0, $t0
	move $a1, $t4
	move $a2, $t5
	move $a3, $t3
	jal rescale
	j end
	
end:
	load ($a0)
	move $sp, $fp
	load ($fp)
	load ($ra)
	jr $ra
	
# $a0 will have old value of the pixel
# $a1 will have the new maxValue
# $a2 will ahve the old maxValue
# $a3 will have the old	miinValue
# $v0 will ahve the converted integer
convert:
	sub $t1, $a0, $a3
	sub $t2, $a2, $a3
	mul $t1, $t1, $a1
	mtc1 $t1, $f1
	mtc1 $t2, $f2
	cvt.s.w $f3, $f1
	cvt.s.w $f4, $f2
	div.s $f5, $f3, $f4
	
	round.w.s $f6, $f5
	mfc1 $v0, $f6
	jr $ra
	
newMin:
	move $t2, $t1
	j exit

findMin:
	lbu $t2, ($a0)	#$t2 is the minimum
	addi $a0, $a0, 1
	addi $a1, $a1, -1
	li $a1, 0
	li $v1, -1

LoopMin:
	ble $a1, 0, minEnd
	lbu $t1, ($a0)
	blt $t1, $t2, newMin
	
minEnd:
	move $v0, $t2
jr $ra
# $a0 will have the address of array
# $a1 will have the size
# $a2 will have minValue
# $a3 will have maxValue
rescale:
	save ($ra)
	move $t0, $a1	#counter
	move $t1, $a0	#address of array
LoopRes:
	beq $t0,0, resEnd
	
	save($t0)
	save($t1)
	save($a0)
	save($a1)
	save($a2)
	save($a3)
	lbu $a0, ($t1)
	li $a1, 255
	move $t2, $a2
	move $a2, $a3
	move $a3, $t2
	jal convert
	
	load($a3)
	load($a2)
	load($a1)
	load($a0)
	load($t1)
	load($t0)
	sb $v0, ($t1)
	
	addi $t0, $t0, -1
	addi $t1, $t1, 1
	j LoopRes
	
resEnd:
	load($ra)

exit:
	bne $t1, $t3, notEqual

notEqual:
	li $v1, 1
	j cont

cont:
	addi $a0, $a0,1
	addi $a1, $a1, -1
	j LoopMin
jr $ra
