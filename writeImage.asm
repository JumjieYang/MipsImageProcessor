# Student ID = 260829732
####################################write Image#####################
.data

.macro save %reg
	sub $sp, $sp, 4
	sw %reg, ($sp)
	.end_macro 

.macro load %reg
	lw %reg, ($sp)
	addi $sp, $sp, 4
	.end_macro 

.macro convert %x,%reg
	li $t9,10
	move $t8,$sp	# starting stack address
	
Loop1:	div %x,$t9
	mfhi $t2
	mflo %x
	addi $t2,$t2,0x30	# convert to char
	save $t2
	bne %x,0,Loop1
	
Loop2:
	load $t2
	sb $t2,charBuffer
	la $a1,charBuffer
	move $a0,%reg
	li $a2,1
	li $v0,15
	syscall
	bne $sp,$t8,Loop2
	.end_macro 

.macro cleanRegs
	li $s1,0
	li $s2,0
	li $s3,0
	li $s4,0
	li $s5,0
	li $s6,0
	li $s7,0 
	.end_macro 
	

header:		.space 3
charBuffer:	.space 1
err:		.asciiz "ERROR!"
space:		.ascii " "
blank:		.ascii "\n"

.text
	.globl write_image

write_image:
	li $v0,13
	addi $s1,$a0,0
	addi $s2,$a1,0
	addi $s3,$a2,0		# type is in s3
	addi $a0,$s2,0		# move file to a0
	li $a1,1		# open file for writing
	li $a2,9		# create and append
	syscall
	beq $v0,-1,error
	move $s6,$v0		# save file descriptor
	li $v0,15
	move $a0,$s6
	li $t0,80		# ascii code for "P"
	sb $t0,charBuffer
	la $a1,charBuffer
	li $a2,1
	syscall			# write P into the file
	beq $s3,1,P2
	
P2:
	li $t0,0x32
	sb $t0,charBuffer
	li $v0,15
	move $a0,$s6		# write 2 into the file
	la $a1,charBuffer
	li $a2,1
	syscall
	
P5:
	li $t0,0x35
	sb $t0,charBuffer
	li $v0,15
	move $a0,$s6		# write 5 into the file
	la $a1,charBuffer
	li $a2,1
	syscall
	j success

success:
	li $v0,15
	move $a0,$s6
	la $a1,space
	li $a2,1
	syscall			# write a space into the file
	
	lw $t0,0($s1)		# load the width field
	
	convert $t0,$s6
	
	li $v0,15
	move $a0,$s6
	la $a1,space
	li $a2,1
	syscall			# write a space into the file
	
	lw $t0,4($s1)		# load the height field
	
	convert $t0,$s6
	
	li $v0,15
	move $a0,$s6
	la $a1,space
	li $a2,1
	syscall			# write a space into the file
	
	lw $t0,8($s1)		# load the max_value field
	
	convert $t0,$s6
	
	li $v0,15
	move $a0,$s6
	la $a1,blank
	li $a2,1
	syscall			# write a blank into the file
				# now the header is completed
	lw $t3,0($s1)
	lw $t4,4($s1)
	mul $t3,$t3,$t4		# row* column
	li $t7,0		# counter
	move $s4,$s1		# $s4 is traveling pointer
	beq $s3,1,contentP2
	
contentP2:
	lbu $t0,12($s4)
	convert $t0,$s6
	addi $s4,$s4,1
	addi $t7,$t7,1
	li $v0,15
	move $a0,$s6
	la $a1,space
	li $a2,1
	syscall
	bne $t7,$t3,contentP2
	
contentP5:
	lbu $t0,12($s4)		# load pixel
	addi $s4,$s4,1		# move pointer
	addi $t7,$t7,1		# increment counter
	li $v0,15
	move $a0,$s6
	sb $t0,charBuffer
	la $a1,charBuffer
	li $a2,1
	syscall
	bne $t7,$t3,contentP5
	b finish
	

	
finish:	
	
	li $v0,16		# close file
	move $a0,$s6
	syscall
	cleanRegs
	jr $ra

error:
	li $v0,4
	la $a0,err
	syscall
	jr $ra
	
