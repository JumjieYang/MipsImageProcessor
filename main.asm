######################Assignment 3 main function###############
			.data
			.align 2
inputFile:		.asciiz "feep.pgm"
			.align 2
outputFile:		.asciiz "feepOut.pgm"
			.align 2
blank:			.asciiz "\n"
			.align 2
sucessStr:		.asciiz "Exit Success\n"
			.text
			.globl main			
main:		
	#Open Image file for reading
	la $a0, inputFile
	jal read_image		# read image File
	move $s0,$v0		# copy address of image

	move $a0,$s0		# get pixel value at (4,7)
	li $a1,4
	li $a2,7
	jal get_pixel
	
	move $a0,$s0		# set value at (4,7) to 45
	li $a1,4
	li $a2,7
	li $a3,45
	jal set_pixel


	move $a0,$s0		# invert image
	jal invert_image
	
	move $a0,$s0		# rescale image
	jal rescale_image
	
	move $a0,$s0		# write pgm file 
	la $a1,outputFile	# to `outputFile'
	jal write_image
	
	j main.exitSucess
										
########################Exit Labels#########################
main.exitSucess:
	li $v0, 4		#syscall for print string
	la $a0,sucessStr
	syscall
	j main.exit
main.exit:
	li $v0,10
	syscall	
		
