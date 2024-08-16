### BRONNEN: Chat GPT
### BITMAP SETTINGS: 16-16-512-256-$gp

#################################################################################

.globl main

.data

mazeFilename:    .asciiz "input_1.txt"

.align 2
buffer:          .space 4096
victoryMessage:  .asciiz "\nYou have won the game!"
loadingMessage:	  .asciiz "Loading game...\n"
startMessage:	  .asciiz "Start! (ZQSD)\n"
exitMessage: 	.asciiz "\nGoodbye"

amountOfRows:    .word 16  # The mount of rows of pixels
amountOfColumns: .word 32  # The mount of columns of pixels

wallColor:      .word 0x004286F4    # Color used for walls (blue)
passageColor:   .word 0x00000000    # Color used for passages (black)
playerColor:    .word 0x00FFFF00    # Color used for player (yellow)
exitColor:      .word 0x0000FF00    # Color used for exit (green)

.text

# NOTE: used regs: 
	# $s0 global pointer (begin bitmap)
	# $s1 playerpos (row)
	# $s2 playerpos (col)
	# $s3 #chars to read
	# $s4 + $s5 = exit pos
	
main:

################################################################
	## INLEZEN VAN HET DOOLHOF 
	
	# readfile function: 
		# args: none
		# return value: number_of_chars_read
		# result: buffer will contain the read inputfile
		
		    # Print het uitgangsbericht
    li $v0, 4            # syscall 4: print string
    la $a0, loadingMessage
    syscall
	addi $sp, $sp, -8		# reserve space for return value + fp
	
	jal readfile
	
	# return val is now at 4($sp)
	lw $s3, 4($sp)		# load #chars to reg

	


################################################################
	## INKLEUREN VAN DE BITMAP
	
	# color_bitmap function:
		# args: buffer, #chars
		# return val: none
		# result: bitmap will be stored at 0($gp)

jal color_bitmap
################################################################
# MAIN LOOP


map_done: 
    # Print het uitgangsbericht
    li $v0, 4            # syscall 4: print string
    la $a0, startMessage
    syscall
    
j mainLoop
##################################################################



mainLoop:
	# CHECK IF EXIT FOUND
	bne $s1, $s4, no_exit
	beq $s2, $s5, victory
	j no_exit
	
	
	no_exit:
    # Wacht 60 ms met behulp van de "sleep" syscall
    li $v0, 32           # syscall 32: sleep
    li $a0, 60        # laad de wachttijd in $a0
    
	keyboard_input:
	li $v0, 12		# load read_char syscall
	syscall
	

	li $t1, 'z'
	li $t2, 's'
	li $t3, 'q'
	li $t4, 'd'
	li $t5, 'x'
	
	beq $v0, $t1, moveUp
	beq $v0, $t2, moveDown
	beq $v0, $t3, moveLeft
	beq $v0, $t4, moveRight
	beq $v0, $t5, exitGame


    # Controleer of er input is
    beqz $v0, mainLoop   # ga naar mainLoop als er geen input is

    # Voer de gepaste actie uit
    beq $v0, 122, moveUp    # z: beweeg omhoog
    beq $v0, 115, moveDown  # s: beweeg omlaag
    beq $v0, 113, moveLeft  # q: beweeg naar links
    beq $v0, 100, moveRight # d: beweeg naar rechts
    beq $v0, 120, exitGame   # x: beëindig het spel

    j mainLoop            # onbekende input, ga terug naar de hoofd lus

moveUp:
	move $t0 $s1 # move row pos to a temp reg
    addi $t0, $t0, -1 # row--
    move $a0, $s1 # load old pos in $a reg
	move $a1, $s2	
	move $a2, $t0 # load new row pos
	move $a3, $s2 # load kolom
	jal move_player
    j mainLoop

moveDown:
	move $t0 $s1 # move row pos to a temp reg
    addi $t0, $t0, 1 # row++
    move $a0, $s1 # load old pos in $a reg
	move $a1, $s2	
	move $a2, $t0 # load new row pos
	move $a3, $s2 # load kolom
	jal move_player
    j mainLoop

moveLeft:
	move $t0 $s2 # move kolom pos to a temp reg
    addi $t0, $t0, -1 # kolom --
    move $a0, $s1 # load old pos in $a reg
	move $a1, $s2	
	move $a2, $s1 # load row
	move $a3, $t0 # load new kolom
	jal move_player
    j mainLoop

moveRight:
	move $t0 $s2 # move kolom pos to a temp reg
    addi $t0, $t0, 1 # kolom++
    move $a0, $s1 # load old pos in $a reg
	move $a1, $s2	
	move $a2, $s1 # load row
	move $a3, $t0 # load new kolom
	jal move_player
    j mainLoop

exitGame:
    # Print het uitgangsbericht
    li $v0, 4            # syscall 4: print string
    la $a0, exitMessage
    syscall

    # Beëindig het programma
    li $v0, 10           # syscall 10: exit
    syscall
    
victory:
    # Print het uitgangsbericht
    li $v0, 4            # syscall 4: print string
    la $a0, victoryMessage
    syscall

    # Beëindig het programma
    li $v0, 10           # syscall 10: exit
    syscall








###############################################################

move_player:

# ARGS: old pos (row,col) ; (potential) new pos (row, col)
# return val: new pos (row,col)
addi $sp, $sp, -8
sw $fp, 0($sp)
sw $ra, 4($sp)
move $fp, $sp



# Check if new pos is valid:
	# 1) within screen borders?
	blt $a2, 0, invalid_pos
	bgt $a2, 15, invalid_pos
	blt $a3, 0, invalid_pos
	bgt $a3, 31, invalid_pos
	
	# 2) not a wall? (compute bitmap addr + check whether color is blue)
	lw $t0, wallColor
	
	
	addi $sp, $sp, -20	# reserve space for args
	# (leave some slots open on stack for the function to work)
	sw $a2, 16($sp)	# push arg (row)
	sw $a3, 12($sp)	# push arg (kol)
	
	jal bereken_geheugenadres
	
	lw $ra, 4($fp) # restore $ra
	lw $t1, 4($sp) # retrieve returnval (address)
	move $sp, $fp # pop frame
	lw $t3, 0($t1) # load color at address to a reg
	lw $t0, wallColor # load blue to a reg
	beq $t0, $t3, invalid_pos # check if the color is blue (wall)
	j valid_pos
	
invalid_pos:
move $v0, $a0 # return old pos
move $v1, $a1
move $s1, $v0 # save pos at $s regs
move $s2, $v1

jr $ra # return

valid_pos:
move $v0, $a2 # return new pos
move $v1, $a3
move $s1, $v0 # save pos at $s regs
move $s2, $v1


j change_pos

# (at this point, $ra contains the address under 'jal move_player' in the 'map_done' label
	change_pos:
	

	move $t0, $a0 # put old pos in temp regs
	move $t1, $a1
	lw $t6, passageColor # load color to temp reg
	
	addi $sp, $sp, -20 # reserve space for args (leave some slots open!)
	sw $t0, 16($sp) # push args on stack - rijnummer
	sw $t1, 12($sp) # kolomnummer
	sw $t6, 8($sp) # color
	# leave the other 2 slots open for the function to work.
	
	jal kleur_pixel # kleur de huidige positie zwart

	
	move $t0, $a2 # put new pos in temp regs
	move $t1, $a3
	lw $t6, playerColor # load color to temp reg
	addi $sp, $sp, -20 # reserve space for args
	sw $t0, 16($sp) # push args on stack - rijnummer
	sw $t1, 12($sp) # kolomnummer
	sw $t6, 8($sp) # color
	# leave the other 2 slots open for the function to work.
	jal kleur_pixel # kleur de nieuwe pos geel
	
	lw $ra, 4($fp) # restore ra


jr $ra







color_bitmap:
# TEMPS REGS
	# $t0: row, $t1, col
	# $t2: chars to read
	# $t3: chars read (counter)
	# $t4: buffer begin addr
	# $t5: char at address


li $t0, 0 # INITIALISE ROWNUMBER
li $t1, 0 # INITIALISE COLNUMBER

addi $sp, $sp, -12 # reserve space for args
	# push args on stack
	sw $t0, 8($sp) # rijnummer
	sw $t1, 4($sp) # kolomnummer
	sw $s3, 0($sp) # #charstoread

j readbuffer

    readbuffer:
    # ARGS: #chars, 
    # TEMPS: row, col, buffer addr
    # RESULT: branch to right 'letter case'
    
    	addi $sp, $sp, -8 # make space for $fp and $ra
    	sw $fp, 0($sp) # store old fp
    	sw $ra, 4($sp) # store ra
    	move $fp, $sp # set new fp
    	
    	# retrieve args
    	lw $t0, 16($fp) # row
    	lw $t1, 12($fp) # col
    	lw $t2, 8($fp) # #charstoread
    	
    	li $t3, 0 # number of chars read
        # Open het bestand
        li $v0, 13           # syscall-code voor openen bestand
        la $a0, mazeFilename     # adres van de bestandsnaam
        li $a1, 0            # vlaggen voor lezen (O_RDONLY)
        li $a2, 0            # toestemming (niet relevant voor lezen)
        syscall
        move $s0, $v0        # sla het bestandsdescriptornummer op in $s0

        # Lees het bestand in de buffer
        li $v0, 14           # syscall-code voor lezen bestand
        move $a0, $s0        # bestandsdescriptornummer
        la $a1, buffer       # adres van de buffer
        li $a2, 4096         # aantal bytes om te lezen
        syscall

        # Loop door elk karakter in de buffer
        la $t4, buffer       # laad het adres van het begin van de buffer in $t4
		li $t3, 0 # initialise # chars read
    loop:
        lb $t5, 0($t4)       # laad het karakter van het geheugen in $t5
        beq $t3, $t2, map_done    # ga naar end_loop als het alle chars gelezen zijn
        
        
		beq $t5, 'w', muur
		beq $t5, 'p', doorgang
		beq $t5, 's', speler
		beq $t5, 'u', uitgang
		j newline # 'default'

		muur:
  lw $t6, wallColor
	# pass args to color_pixel()
	addi $sp, $sp, -20 # reserve space for args
	sw $t0, 16($sp) # rijnummer
	sw $t1, 12($sp) # kolomnummer
	sw $t6, 8($sp) # color
	sw $t2, 4($sp) # #charstoread (restore purposes)
	sw $t3, 0($sp) # chars read
	
	jal kleur_pixel

		j next_char
		
		newline:

		 addi $t3, $t3, 1 # increment number of chars read
        addi $t4, $t4, 1      # increment buffer address
        j loop
        
        # (no increment for row/col)
		doorgang:

  lw $t6, passageColor
	# pass args to color_pixel()
	addi $sp, $sp, -20 # reserve space for args
	sw $t0, 16($sp) # rijnummer
	sw $t1, 12($sp) # kolomnummer
	sw $t6, 8($sp) # color
	sw $t2, 4($sp) # #charstoread (restore purposes)
	sw $t3, 0($sp) # chars read
		jal kleur_pixel
		j next_char
		
		speler:
  lw $t6, playerColor
	# pass args to color_pixel()
	addi $sp, $sp, -20 # reserve space for args
	sw $t0, 16($sp) # rijnummer
	sw $t1, 12($sp) # kolomnummer
	sw $t6, 8($sp) # color
	sw $t2, 4($sp) # #charstoread (restore purposes)
	sw $t3, 0($sp) # chars read
	
	
	move $s1, $t0 # save player row
	move $s2, $t1 # save player kol
		jal kleur_pixel

		j next_char
		
		uitgang:

  lw $t6, exitColor
	# pass args to color_pixel()
	addi $sp, $sp, -20 # reserve space for args
	sw $t0, 16($sp) # rijnummer
	sw $t1, 12($sp) # kolomnummer
	sw $t6, 8($sp) # color
	sw $t2, 4($sp) # #charstoread (restore purposes)
	sw $t3, 0($sp) # chars read
	
	move $s4, $t0 # save exit pos
	move $s5, $t1
		jal kleur_pixel
		j next_char


    next_char:
    	addi $t3, $t3, 1 # increment number of chars read
        addi $t4, $t4, 1      # increment buffer address
        
        # increment row/col
       	bgt $t1, 31, endl # check if colnr out of range
       	j not_endl # else... (default)
       	
        endl:
        addi $t0, $t0, 1 # increment rownr
        li $t1, 0 # reset colnr
        
        not_endl:
		addi $t1, $t1, 1 # incremenet colnr        

        j loop


    	end_loop:
        	# Sluit het bestand
        	li $v0, 16           # syscall-code voor sluiten bestand
        	move $a0, $s0        # bestandsdescriptornummer
        	syscall
        	
        	move $sp, $fp # pop frame
        	#lw $fp, 0($fp) # restore old fp
        	lw $ra, 4($fp) # restore ra
        	jr $ra # return
        	
        	
# Functie om een pixel in te kleuren
# args: rijnummer, kolomnummer, kleur
kleur_pixel:
	addi $sp, $sp, -8	# reserve space on stack for $ra, and fp
	sw $fp, 0($sp)	# save old fp on stack
	sw $ra, 4($sp)	# save $ra at 4($fp) in the allocated spot
	move $fp, $sp	# set new fp to current sp

	# pass args via stack for function "bereken_geheugenadres"
	addi $sp, $sp, -20	# make space to save 5 temp regs
	
	lw $t0, 24($fp)	# retrieve arg 1 (rijnummer)
	sw $t0, 16($sp)	# push arg
	lw $t0, 20($fp)	# retrieve arg 2 (kolomnummer)
	sw $t0, 12($sp)	# push arg
	lw $t0, 16($fp)	# retrieve arg 3 (color)
	sw $t0, 8($sp) # push variable -color- (restoring purposes)
	lw $t0, 12($fp) # retrieve #charstoread (restore purposes)
	sw $t0, 4($sp) # push variable (restore purposes)
	lw $t0, 8($fp) # retrieve #charsread (restore purposes)
	sw $t0, 0($sp) # push variable

    jal bereken_geheugenadres	# overwrites $ra, but the previous is stored on the stack
    
    lw $t5, 4($sp) # retrieve returnval (address)
    sw $t6, 0($t5) # write color to addr
    

    
    # no return results to store
    ## RESTORE

    move $sp, $fp	    # set sp to fp (pop frame)

       lw $ra, 4($fp)	# restore return address
       lw $fp, 0($sp)		 # restore fp
    jr $ra


bereken_geheugenadres:
# Functie die het geheugenadres voor een pixel berekent
# $a0 = rijnummer, $a1 = kolomnummer

	addi $sp, $sp, -12 # reserve place for $fp, returnval, $ra
	sw $ra, 8($sp)
	# returnval will be put at 4($fp)
	sw $fp, 0($sp)	# save old fp on stack

	move $fp, $sp	# set fp to current sp


    
    # retrieve args:
    lw $t0, 28($fp) # rijnr
    lw $t1, 24($fp) # kolomnr
    
    # compute offsets (in relation to $gp)
    mul $t2, $t0, 32       # $t2 = offset_rij (rijnummer * breedte_scherm)
    # NOTE: $t2 is now overwrited!
    # offset_kolom already in $t1 (= kolomnummer)
    
    mul $t2, $t2, 4        # 4 bytes per pixel
    mul $t1, $t1, 4        # 4 bytes per pixel
    
    add $t3, $t2, $t1       # $t3 = offset_rij + offset_kolom
    # $t3 is now overwrited!
    move $s0, $gp          # Laad de waarde van $gp in $s0 (het beginadres van de pixelgegevens)
    add $v0, $s0, $t3       # $v0 = $gp + offset_rij + offset_kolom
    
    andi $t2, $v0, 3        # Zorg voor word alignment
    subu $v0, $v0, $t2      # Trek de rest af om het word aligned te maken
    
    sw $v0, 4($fp) 		# push result at allocated slot on stack
    
    # RESTORE TEMPORARIES
    lw $t0, 28($fp) # row
    lw $t1, 24($fp) # column
    lw $t6, 20($fp) # color
    lw $t2, 16($fp) # charstoread
    lw $t3, 12($fp) # chars read
    

    move $sp, $fp        # pop frame (sp := fp)
        lw $fp, 0($fp)       # restore old framepointer

    jr $ra # return


readfile:

	sw $fp, 0($sp)	# store old fp
	move $fp, $sp		# set fp to current sp
	
	# no need to reserve space for temporaries
	# no need to store $ra as leaf function
	
# Open (for reading) a file
li $v0, 13 # system call for open file
la $a0, mazeFilename # output file name
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
move $s3, $v0 # save #charstoread in $s3

sw $v0, 4($fp)		# store returnval above fp

# Close the file
li $v0, 16 # system call for close file
move $a0, $s6 # file descriptor to close
syscall 	# close

move $sp, $fp		# pop the frame
lw $fp, 0($fp)	# restore old fp

jr $ra		# return




    


	


