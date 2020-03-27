#Student ID = 260829732
############################ Q1: file-io########################
.data
			.align 2
inputTest1:		.asciiz "/Users/junjie/Downloads/comp273A3/template/test1.txt"
			.align 2
inputTest2:		.asciiz "test2.txt"
			.align 2
outputFile:		.asciiz "/Users/junjie/Downloads/comp273A3/template/copy.pgm"
			.align 2
buffer:			.space 1024

err:			.asciiz "error when opening file"
info:			.asciiz "P2\n24 7\n15\n"
.text
.globl fileio

fileio:
	
	la $a0,inputTest1
	#la $a0,inputTest2
	jal read_file
	
	la $a0,outputFile
	la $a1,buffer
	jal write_file
	
	li $v0,10		# exit...
	syscall	
		

	
read_file:
	# $a0 -> input filename	
	# Opens file
	# read file into buffer
	# return
	# Add code here
	li $v0, 13	#open the input file
	li $a1, 0
	li $a2, 0
	syscall
	blt $v0, $0, print_error	#check for err
	move $t1, $v0
	
	li $v0, 14		#read from file
	move $a0, $t1
	la $a1, buffer
	li $a2, 1024
	syscall
	blt $v0, $0, print_error	#check for err
	
	la $a0, buffer		#print buffer
	li $v0, 4
	syscall
	
	li $v0, 16		#close file
	move $a0, $t1
	syscall
	
	blt $v0, 0, print_error	#check for err
	jr $ra
	
write_file:
	# $a0 -> outputFilename
	# open file for writing
	# write following contents:
	# P2
	# 24 7
	# 15
	# write out contents read into buffer
	# close file
	# Add  code here
	move $t0, $a1	#save address of the location
	
	li $v0, 13	#open file for writing
	li $a1, 1	#Open for writing (flags are 0: read, 1: write)
	li $a2, 0
	syscall
	blt $v0, 0, print_error	#check for err
	move $t1, $v0	#save file descriptor
	
	li $v0, 15	#write the infomations ahead
	move $a0, $t1
	la $a1, info
	li $a2, 1024
	syscall
	
	li $v0, 15	#write the buffer
	move $a0, $t1
	move $a1, $t0
	li $a2, 1024
	syscall
	
	li $v0, 16	#close file
	move $a0, $t1
	syscall
	
	jr $ra

print_error:
	la $a0, err
	li $v0, 4
	syscall
	
	jr $ra	  	  
