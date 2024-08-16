# Stackframe is not yet used correctly here

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

	# pass arguments via $a regs
	move $a0, $t0  # Rijnummer
	move $a1, $t1  # Kolomnummer
	lw $a2, yellow  # load yellow
	
	addi $sp, $sp, -12     	# reserve space on stack (3 arguments)
	
	
	sw $a0, 8($sp) # push args on stack
	sw $a1, 4($sp)
	sw $a2, 0($sp)
	
	
	addi $sp, $sp, -12	# reserve space on stack for return val, $ra, and fp

	jal kleur_pixel	# call color pixel
	
	
	addi $t1, $t1, 1  # increment j
    j inner_loop    # goto next iteration

no_border:
	# pass arguments
	move $a0, $t0  # Rijnummer
	move $a1, $t1  # Kolomnummer

    lw $a2, red  # load red
	jal kleur_pixel	# color pixel
	addi $t1, $t1, 1  # increment j
    j inner_loop  # goto next iteration

end_inner_loop:

    addi $t0, $t0, 1 # increment i
    j outer_loop  # Ga terug naar de buitenste lus

end_outer_loop:
  # Sluit het programma af
    li $v0, 10
    syscall
    

# Bereken het geheugenadres
# Functie die het geheugenadres voor een pixel berekent
# $a0 = rijnummer, $a1 = kolomnummer
bereken_geheugenadres:
    addi $sp, $sp, -4      # Maak ruimte voor het frame
    sw $fp, 4($sp)         # Sla oude framepointer op

    move $fp, $sp          # Zet de framepointer naar de huidige stackpositie

    mul $t4, $a0, 32       # $t0 = offset_rij (rijnummer * breedte_scherm)
    
    mul $t4, $t4, 4        # 4 bytes per pixel
    mul $a1, $a1, 4        # 4 bytes per pixel
    
    add $t3, $t4, $a1       # $t3 = offset_rij + offset_kolom

    move $s0, $gp          # Laad de waarde van $gp in $s0 (het beginadres van de pixelgegevens)

    add $v0, $s0, $t3       # $v0 = $gp + offset_rij + offset_kolom

    andi $t2, $v0, 3        # Zorg voor word alignment
    subu $v0, $v0, $t2      # Trek de rest af om het word aligned te maken

    lw $fp, 4($fp)          # Herstel oude framepointer
    addi $sp, $sp, 4        # Verplaats de stackpointer om het frame te verwijderen

    jr $ra

# Functie om een pixel in te kleuren
# $a0 = rijnummer, $a1 = kolomnummer, $a2 = kleur
kleur_pixel:
	sw $fp, 0($sp)	# save old fp on stack
	move $fp, $sp	# set new fp to current sp
	sw $ra, -4($fp)	# save $ra at -4($fp)
	
	# pass args for next function
	# note: no need to push args or $ra on stack as it is the last function to call (here)
    # no need to reserve space on stack for args or $ra as last function
    jal bereken_geheugenadres	# overwrites $ra, but the previous is stored on the stack
    sw $a2, 0($v0)          # Schrijf de kleurinformatie naar het geheugenadres
    
    ## restore process
    # no return results to store
    lw $ra, -4($fp)	# !!! restore return address
    move $sp, $fp	    # set sp to fp (pop frame)
    lw $fp, 4($sp)		 # restore fp
    jr $ra	# return
