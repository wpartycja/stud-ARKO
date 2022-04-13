#########################################################################
#
#	Projekt w ramach przedmiotu ARKO - Architerktura Komputerów
#	Temat 16: Imprementacja algorytmu Flood-Fill na obrazku BMP
#	Autorka: Patrycja Wysocka
#	Prowadz¹cy: mgr in¿. S³awomir Niespodziany
#	
#########################################################################

# Programme performs flood-fill algorithm on 24-bit BMP files
# size: 128x64


#define 
.eqv 	FILE_SIZE 	24630
.eqv 	BYTES_PER_ROW 	384
.eqv 	FILL_COLOUR 	0x00ffbfff	# pink
.eqv 	X 		64		# x coordinate of the seed
.eqv 	Y 		32		# y coordinate of the seed


	.data
		.align 4
res:		.space 2
image_addr: 	.space FILE_SIZE
fname: 		.asciiz "image.bmp"

	.text
main:

read_bmp:
	
	#open file
	li 	$v0, 13 	# 13 - open file
	la 	$a0, fname 	# file name
	li 	$a1, 0 		# flags: 0-read file
	li 	$a2, 0  	# mode: ignored
	syscall
	move 	$s0, $v0 	# save the file descriptor (like `fopen` in C) 
	
	#read file
	li 	$v0, 14		# 14 - read from file
	move 	$a0, $s0	# file descriptor
	la 	$a1, image_addr	
	li 	$a2, FILE_SIZE	
	syscall
	
	#close file
	li 	$v0, 16		# 16 - close file
	move 	$a0, $s0	# file descriptor
	syscall


get_seed_colour:
# here are setted:
#
#  $s3 - previous colour
#  $s4 - new_colour
#  $s5 - address of pixel array


	la 	$t4, X			# x cooridnate of seed ( for func )
	la 	$t5, Y			# x cooridnate of seed ( for func )

	la 	$t1, image_addr + 10 	# +10 to find file offset to pixel array
	lw 	$s5, ($t1) 		
	la 	$t1, image_addr 	# address of bitmap
	add 	$s5, $t1, $s5		# $s5 holds address of the array
	

	
	#calculate pixel address
	la	$t2, ($s5)
	mul 	$t1, $t5, BYTES_PER_ROW
	move 	$t3, $t4
	sll	$t4, $t4, 1
	add 	$t3, $t3, $t4 		# $t3 = 3*x
	add 	$t1, $t1, $t3 		# $t1 = 3*x + y*BYTES_PER_ROW
	add 	$t2, $t2, $t1 		# pixel address
	
	#get colour
	lbu 	$s3, ($t2) 		# load Blue
	lbu 	$t1, 1($t2) 		# load Green
	sll 	$t1, $t1, 8 
	or	$s3, $s3, $t1
	lbu 	$t1, 2($t2) 		# load Red
	sll 	$t1, $t1, 16
	or 	$s3, $s3, $t1		# $s3 holds previuos color
	
	
	li	$s4, FILL_COLOUR	# $s4 hold the target colour
	la	$a0, X
	la	$a1, Y
	
	jal flood_fill
	
save_bmp:
	
	# open file
	li 	$v0, 13		# 13 - open file
	la 	$a0, fname  	# file name
	li 	$a1, 1  
	li 	$a2, 0  	# mode: ignored
	syscall
	move 	$s0, $v0 	# save the file descriptor (with open) 
	
	# save file
	li 	$v0, 15		# 15 - save file
	move 	$a0, $s0
	la 	$a1, image_addr
	li 	$a2, FILE_SIZE
	syscall

	# close file
	li 	$v0, 16
	move 	$a0, $s0
	syscall

exit:
	li $v0, 10
	syscall




flood_fill:
#  changes the colour of all other adjacent pixels
#  $a0 - x coordinate
#  $a1 - y coordinate
#  return: None
	
	
	subiu	$sp, $sp, 12
	sw	$s0, ($sp)	
	sw 	$s1, 4($sp)	
	sw	$ra, 8($sp)
	

	#calculate pixel address
	la	$t2, ($s5)	# stores address of pixel array
	la	$t4, ($a0)	# stores x coordinate to func
	
	mul 	$t1, $a1, BYTES_PER_ROW
	move	$t3, $t4
	sll	$t4, $t4, 1
	add 	$t3, $t3, $t4 		# $t3 = 3*x
	add 	$t1, $t1, $t3 		# $t1 = 3x + y*BYTES_PER_ROW
	add 	$t2, $t2, $t1 		# pixel address
	
	#get colour
	lbu 	$t3, ($t2) 	# load Blue
	lbu 	$t1, 1($t2) 	# load Green
	sll 	$t1, $t1, 8 
	or	$t3, $t3, $t1
	lbu 	$t1, 2($t2) 	# load Red
	sll 	$t1, $t1, 16
	or 	$t3, $t3, $t1	# $t3 holds  colour
	
	bne	$t3, $s3, end
	
	#put pixel
	la	$t6, ($s4)
	sb 	$t6, ($t2) 	# store Blue
	srl 	$t6, $t6, 8
	sb 	$t6, 1($t2) 	# store Green
	srl 	$t6, $t6, 8
	sb 	$t6, 2($t2) 	# store Red
	
	# save current pixel
	move	$s0, $a0	# x coordinate
	move	$s1, $a1	# y coordinate
	
down:
	move	$a0, $s0	# x
	subiu	$a1, $s1, 1	# y = y - 1
	jal	flood_fill


up:
	move	$a0, $s0	# x
	addiu	$a1, $s1, 1	# y = y + 1
	jal	flood_fill	
			
right:
	addiu	$a0, $s0, 1	# x = x + 1
	move	$a1, $s1	# y 
	jal	flood_fill

	
left:
	subiu	$a0, $s0, 1	# x = x - 1
	move	$a1, $s1	# y 
	jal	flood_fill
	

end:
	lw	$s0, ($sp)	
	lw 	$s1, 4($sp)	
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	
	jr	$ra
	

	
	
	
	
	
