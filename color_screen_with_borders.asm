.data
    bitmap:            .space 2048          # Een 16x16 pixel bitmap (16 pixels * 16 pixels * 4 bytes per pixel)
    red:    .word 0xFF0000     # Red color
    yellow: .word 0xFFFF00     # Yellow color
    green:  .word 0x00FF00     # Green color
    blue:	.word 0x00FF00		# blue color
 

.text
    .globl main

main:

    
    # programma dat alle pixels rood kleurt en de randen geel
    
     # Outer loop: i = rijnummer
    li $t0, 0            # Initialisatie i (rijnummer) met 0
    
    
outer_loop:
    bge $t0, 16, end_outer_loop  # Als i >= 16, eindig de buitenste lus

    # Inner loop: j = kolomnummer
    li $t1, 0            # Initialisatie j (kolomnummer) met 0
    
    j inner_loop

inner_loop:
    bge $t1, 32, end_inner_loop  # Als j >= 32, eindig de binnenste lus

    # Vergelijk rijnummer (i) met 0 en 15
    beq $t0, 0, border_pixel   # Als i == 0, voer border_pixel uit
    beq $t0, 15, border_pixel  # Als i == 15, voer border_pixel uit

    # Vergelijk kolomnummer (j) met 0 en 31
    beq $t1, 0, border_pixel   # Als j == 0, voer border_pixel uit
    beq $t1, 31, border_pixel  # Als j == 31, voer border_pixel uit

	j no_border
	
border_pixel:

	addi $sp, $sp, -12     	# reserve space on stack (3 arguments)
	
	# push args on stack
	sw $t0, 8($sp) # rijnummer
	sw $t1, 4($sp) # kolomnummer
	lw $t2, yellow  # load yellow
	sw $t2, 0($sp) # kleur

	jal kleur_pixel	# call color func
	
	
	addi $t1, $t1, 1  # increment j (kolomnr)
    j inner_loop    # goto next iteration

no_border:
	addi $sp, $sp, -12     	# reserve space on stack (3 arguments)
	# push args on stack
	sw $t0, 8($sp) # rijnummer
	sw $t1, 4($sp) # kolomnummer
	lw $t2, red  # load red
	sw $t2, 0($sp) # kleur
	
	jal kleur_pixel	# call color func

	addi $t1, $t1, 1  # increment j
    j inner_loop  # goto next iteration

end_inner_loop:

    addi $t0, $t0, 1 # increment i (rijnr)
    j outer_loop  # Ga terug naar de buitenste lus

end_outer_loop:
  # Sluit het programma af
    li $v0, 10
    syscall
    
# Functie om een pixel in te kleuren
# args: $a0 = rijnummer, $a1 = kolomnummer, $a2 = kleur
kleur_pixel:
	addi $sp, $sp, -8	# reserve space on stack for $ra, and fp
	sw $fp, 0($sp)	# save old fp on stack
	sw $ra, 4($sp)	# save $ra at 4($fp) in the allocated spot
	move $fp, $sp	# set new fp to current sp

	# pass args via stack for function "bereken_geheugenadres"
	addi $sp, $sp, -12	# make space to store 3 temp regs
	
	lw $t0, 16($fp)	# retrieve arg 1 (rijnummer)
	sw $t0, 8($sp)	# push arg
	lw $t0, 12($fp)	# retrieve arg 2 (kolomnummer)
	sw $t0, 4($sp)	# push arg
	lw $t0, 8($fp)	# retrieve arg 3 (color)
	sw $t0, 0($sp) # push variable -color- (restoring purposes)

    jal bereken_geheugenadres	# overwrites $ra, but the previous is stored on the stack
    

    
    # no return results to store
    ## RESTORE
    lw $ra, 4($fp)	# restore return address
    move $sp, $fp	    # set sp to fp (pop frame)
    lw $fp, 0($sp)		 # restore fp
    jr $ra	# 


bereken_geheugenadres:
# Functie die het geheugenadres voor een pixel berekent
# $a0 = rijnummer, $a1 = kolomnummer

	addi $sp, $sp, -8 # reserve place for $fp, returnval
	sw $fp, 0($sp)	# save old fp on stack
	# no need to store $ra (leaf func)
	move $fp, $sp	# set fp to current sp

    addi $sp, $sp, -4      # Maak ruimte voor het frame (2 args)
    
    # retrieve args:
    lw $t0, 16($fp) # rijnr
    lw $t1, 12($fp) # kolomnr
    
    # compute offsets (in relation to $gp)
    mul $t2, $t0, 32       # $t2 = offset_rij (rijnummer * breedte_scherm)
    # NOTE: $t2 is now overwrited!
    # offset_kolom already in $t1 (= kolomnummer)
    
    mul $t2, $t2, 4        # 4 bytes per pixel
    mul $t1, $t1, 4        # 4 bytes per pixel
    
    add $t3, $t2, $t1       # $t3 = offset_rij + offset_kolom
    move $s0, $gp          # Laad de waarde van $gp in $s0 (het beginadres van de pixelgegevens)
    add $v0, $s0, $t3       # $v0 = $gp + offset_rij + offset_kolom
    
    andi $t2, $v0, 3        # Zorg voor word alignment
    subu $v0, $v0, $t2      # Trek de rest af om het word aligned te maken
    
    sw $v0, 4($fp) 		# push result at allocated slot on stack
    # RESTORE TEMPORARIES
    lw $t0, 16($fp)
    lw $t1, 12($fp)
    lw $t2, 8($fp)
    
    lw $fp, 0($fp)       # restore old framepointer
    move $sp, $fp        # pop frame (sp = fp)

    jr $ra # return


