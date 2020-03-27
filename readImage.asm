#Student ID = 260829732
#########################Read Image#########################
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
		.globl read_image
read_image:
	# $a0 -> input file name
	################# return #####################
	# $v0 -> Image struct :
	# struct image {
	#	int width;
	#       int height;
	#	int max_value;
	#	char contents[width*height];
	#	}
	##############################################
	# Add code here
	
	jr $ra
