.data

fin:	.asciiz "del.txt"
buffer:	.space 2048


.text

# Open (for reading) a file
li $v0, 13 # system call for open file
la $a0, fin # output file name
li $a1, 0 # Open for writing (flags are 0: read, 1: write)
li $a2, 0 # mode is ignored
syscall # open a file (file descriptor returned in $v0)
move $s6, $v0 # save the file descriptor

# Read from file to buffer
li $v0, 14 # system call for read from file
move $a0, $s6 # file descriptor
la $a1, buffer # address of buffer to which to load the contents
li $a2, 2048 # hardcoded max number of characters (equal to size of buffer)
syscall # read from file, $v0 contains number of characters read

# Print de inhoud van het bestand naar het scherm
li $v0, 4            # Syscall nummer voor schrijven naar standaarduitvoer
la $a0, buffer        # Laad het bestandsdescriptor in $a0

syscall              # Roep de syscall aan

# Close the file
li $v0, 16 # system call for close file
move $a0, $s6 # file descriptor to close
syscall 	# close
