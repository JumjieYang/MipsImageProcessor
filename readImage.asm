#Student ID = 260829732
#########################Read Image#########################
.data
buffer: .space 1024

num: .word 0
numStr: .space 16

width: .word 0
height: .word 0
size: .word 0
maxValue: .word 0
type: .word 0

nChar: .word 0
charLeft: .word 0

contentPointer: .word 0
structPointer: .word 0

err: .asciiz "ERROR!"

.macro mallocImage %width %height %maxValue
	move $t1, %width
	move $t2, %height
	move $t3, %maxValue
	mul $t4, $t1, $t2
	add $t5, $t4, 12
	li $v0, 9
	move $a0, $t5
	syscall
	move $s0, $v0
	# Initialize values
	sw $t1, ($s0)	# width
	sw $t2, 4($s0)	# height
	sw $t3, 8($s0)	# maxValue
	.end_macro 

.macro save %reg
	sub $sp, $sp, 4
	sw %reg, ($sp) # save %reg
	.end_macro
  
.macro load %reg
	lw %reg, ($sp) # loads %reg
	addi $sp, $sp, 4
	.end_macro

.macro saveRegs
	save ($s0)
	save ($s1)
	save ($s2)
	save ($s3)
	save ($s4)
	save ($s5)
	save ($s6)
	save ($s7)
	.end_macro

.macro restoreRegs
	load ($s7)
	load ($s6)
	load ($s5)
	load ($s4)
	load ($s3)
	load ($s2)
	load ($s1)
	load ($s0)
	.end_macro

.text
	.globl read_image
read_image:
	# $a0 -> input file name
	################# return #####################
	# $v0 -> Image struct :
	# struct image {
	# int width;
	# int height;
	# int maxValueue;
	# char contents[width*height];
	# }
	##############################################
	# Add code here  
	save($ra)
	save($fp)
	move $fp, $sp  
	
	saveRegs
  
readfile: 
	li $v0, 13 # open file
	li $a1,0 # read flag
	li $a2, 0
	syscall
  
	move $s0,$v0 # save the file descriptor
	blt $s0, $zero, error_open
  

	li $v0, 14 # read_file
	move $a0,$s0 # file descriptor
	la $a1,buffer
	la $a2,1024 # hardcoded buffer length
	syscall

	la $t1, nChar
	sw $v0, ($t1)

	la $a0, buffer
	li $v0, 4
	syscall 
	la $a0, buffer
	add $a0, $a0, 1
	jal getInt
  
	la $t1, type
	sw $v1, ($t1)
	li $v1, 0
  
	move $a0, $v0
	save($ra)
	jal getInt
	load($ra)
  
	la $t1, width
	sw $v1, ($t1)
	li $v1, 0
  
	move $a0, $v0
	save($ra)
	jal getInt
	load($ra)
  
	la $t1, height
	sw $v1, ($t1)
	li $v1, 0
  
	move $a0, $v0
	jal getInt
 
	la $t1, maxValue
	sw $v1, ($t1)
	li $v1, 0
	
	save($v0)
	move $a0, $v0
	li $v0, 4
	syscall   
	
	la $t1, width
	lw $t1, ($t1)
	la $t2, height
	lw $t2, ($t2)
	la $t3, maxValue
	lw $t3, ($t3)
	mul $t4, $t1, $t2
	la $t5, size
	sw $t4, ($t5)
  
	mallocImage($t1, $t2, $t3)
	la $t4, structPointer
	sw $s0, ($t4)
	
	load($v0)
  
	move $a0, $v0
	la $a1, type
	lw $a1, ($a1)
	jal get_content 

	li $v0, 16 # close file
	move $a0,$s0 # file descriptor
	syscall
  
	la $v0, structPointer
	lw $v0, ($v0)
	restoreRegs
	move $sp, $fp
	load($fp)
	load($ra)
	jr $ra
  
error_open:
	la $a0, err
	li $v0, 4
	syscall
	move $v1, $v0
	move $v0, $s0  
	restoreRegs
	move $sp, $fp
	load($fp)
	load($ra)
	jr $ra
getInt:
	save($ra)
	save($fp)
	move $fp, $sp
	move $s1, $a0

preLoop:
	la $t4, numStr # Get the address to str
	li $t3, 0

Loop:
	lbu $t1, ($s1) #load unsigned char from array into t1
	beq $t1, $0, endStr #NULL terminator found
	beq $t1, 13, endNum
	beq $t1, 10, endNum
	beq $t1, 32, endNum
	beq $t1, 9, endNum
	sb $t1, ($t4)
	addi $t3, $t3, 1
	addi $t4, $t4, 1
	addi $s1, $s1, 1 #increment array address
	j Loop #jump to start of loop
  
endNum:
	addi $s1, $s1, 1
	beq $t3, $zero, preLoop
	li $t3, 0
	sb $t3, ($t4)
	la $a0, numStr
	save($s1)
	jal readInt
	load($v0)

endStr:
	move $sp, $fp
	load($fp)
	load($ra)
	la $a1, numStr
	jr $ra
  
readInt:
	save($ra)
	save($fp)
	move $fp, $sp
	move $s1, $a0
	li $t0, 10
	li $s2, 0
	
loopInt:   
	lbu $t1, ($s1) #load unsigned char from array into t1
	beq $t1, $0, FIN #NULL terminator found
	blt $t1, 48, errorInt #check if char is not a digit (ascii<'0')
	bgt $t1, 57, errorInt #check if char is not a digit (ascii>'9')
	addi $t1, $t1, -48 #converts t1's ascii value to dec value
	mul $s2, $s2, $t0 #sum *= 10
	add $s2, $s2, $t1 #sum += array[s1]-'0'
	addi $s1, $s1, 1 #increment array address
	j loopInt #jump to start of loop
  
errorInt: #if non digit chars are entered, readInt returns 0
	add $s2, $zero, $zero
	j FIN
	
FIN:
	la $t1, num
	sw $s2, ($t1)
	move $v1, $s2
	move $sp, $fp
	load($fp)
	load($ra)
	jr $ra

preLoopP2:
	la $t1, size
	lw $t0, ($t1)  
	la $t2, contentPointer
	sw $s1, ($t2)  
	move $t2, $s1  
	save($t0)
  
LoopP2:
	ble $t0, 0, endP2  
	save($t2)
	save($t0)
	save($t1)
	save($s1)
	move $a0, $t2
	jal getInt
	load($s1)
	load($t1)
	load($t0)
	load($t2)
	move $t2, $v0
	sb $v1, ($s1)
	addi $s1, $s1, 1
	addi $t0, $t0, -1
	j LoopP2
	
endP2:
	load($t0)
	j copyContent

get_content:
	save($ra)
	save($fp)
	move $fp, $sp
	move $s1, $a0  
	beq $a1, 2, preLoopP2
	beq $a1, 5, preLoopP5
  
# Else it's not a valid type...
# If you need to handle errors just add that part here.

preLoopP5:
	la $t1, size
	lw $t0, ($t1)  
	la $t2, contentPointer
	sw $s1, ($t2)  
	move $t2, $s1  
	save($t0)
	
loopContent:
	lbu $t1, ($s1) #load unsigned char from array into t1
	beq $t1, 13, getNext
	beq $t1, 10, getNext
	beq $t1, 32, getNext
	beq $t1, 9, getNext
	j startContent #jump to start of loop
  
getNext:
	addi $s1, $s1, 1
	j preLoopP5
  
startContent:
  	la $t2, contentPointer
	sw $s1, ($t2)
	la $t2, buffer
	sub $t2, $s1, $t2
	la $t3, nChar
	lw $t3, ($t3)
	sub $t3, $t3, $t2
	la $t4, charLeft
	sw $t3, ($t4)
	move $t0, $t3
  
copyContent: 
	la $t1, structPointer
	lw $t1, ($t1)
	addi $t1, $t1, 12
	la $t2, contentPointer
	lw $t2, ($t2)  
  
loopCopy:
	beq $t0, $zero, copyEnd
	lbu $t3, ($t2)
	sb $t3, ($t1)
	addi $t2, $t2, 1
	addi $t1, $t1, 1
	addi $t0, $t0, -1
	j loopCopy
  
copyEnd:
	la $v0, structPointer
	lw $v0, ($v0) 
	move $sp, $fp
	load($fp)
	load($ra)
	jr $ra
