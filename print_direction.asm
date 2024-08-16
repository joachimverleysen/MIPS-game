.data


up_text:	.asciiz "up"
down_text:	.asciiz "down"
left_text:	.asciiz "left"
right_text:	.asciiz "right"
default_text:	.asciiz "Unknown input! Valid inputs: z s q d x"


.text

main:

 
	li $v0, 12		# load read_char syscall
	syscall
	
	move $t0, $v0	# store result (letter) in $t0
	


	
	li $t1, 'z'
	li $t2, 's'
	li $t3, 'q'
	li $t4, 'd'
	li $t5, 'x'
	
	beq $t0, $t1, case0
	beq $t0, $t2, case1
	beq $t0, $t3, case2
	beq $t0, $t4, case3
	beq $t0, $t5, case4
	j default
	
	li $v0, 32		# load sleep syscall
	li $a0 2000	# two seconds in miliseconds
	
	syscall		# sleep
	
	j main
	
	
	
	
case0:		# up
li $v0, 4		# load print_string syscall
la $a0 up_text	# pass arg
syscall	# print string
j main
	
case1:		# down
li $v0, 4		# load print_string syscall
la $a0 down_text	# pass arg
syscall	# print stringµ
j main

case2:		# left
li $v0, 4		# load print_string syscall
la $a0 left_text	# pass arg
syscall	# print string
j main

case3:		# right
li $v0, 4		# load print_string syscall
la $a0 right_text	# pass arg
syscall	# print string
j main

case4:		# close
		
# End program
li $v0, 10              # load syscall code for exit in $v0
syscall                 # execute syscall      

default:	# right
li $v0, 4		# load print_string syscall
la $a0 default_text	# pass arg
syscall	# print string
j main



