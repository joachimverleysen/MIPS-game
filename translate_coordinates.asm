.data
    # Definieer het beginadres van de pixelgegevens
    pixel_data:     .space 512  # (32 pixels breed * 16 pixels hoog * 4 bytes per pixel)

    rij_prompt:     .asciiz "Voer het rijnummer in: "
    kolom_prompt:   .asciiz "Voer het kolomnummer in: "
    resultaat_msg:  .asciiz "Het geheugenadres voor de pixel is: "

.text
    .globl main

main:
    # Zet het $gp-register op het beginadres van de pixelgegevens
    la $gp, pixel_data

    # Vraag de gebruiker om het rijnummer
    li $v0, 4
    la $a0, rij_prompt
    syscall
    li $v0, 5
    syscall
    move $t0, $v0  # $t0 bevat nu het ingevoerde rijnummer

    # Vraag de gebruiker om het kolomnummer
    li $v0, 4
    la $a0, kolom_prompt
    syscall
    li $v0, 5
    syscall
    move $a1, $v0  # $a1 bevat nu het ingevoerde kolomnummer

	move $a0, $t0  # $a0 bevat nu ingevoerde rijnummer
	
    # Roep de functie aan om het geheugenadres te berekenen
    jal bereken_geheugenadres
    
    move $t0, $v0		#  return value in $t0 bewaren

    # Druk het resultaat af
    li $v0, 4
    la $a0, resultaat_msg
    syscall
    li $v0, 1
    move $a0, $t0  # Druk het geheugenadres af
    syscall

    # Sluit het programma af
    li $v0, 10
    syscall

# Functie die het geheugenadres voor een pixel berekent
# $a0 = rijnummer, $a1 = kolomnummer
bereken_geheugenadres:
    # Maak een stackframe
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Bereken de offset voor de rij en kolom
    mul $t0, $a0, 32          # $t0 = offset_rij (rijnummer * breedte_scherm)
    add $t1, $t0, $a1          # $t1 = offset_rij + offset_kolom

    # Laad de waarde van $gp in $v0 (het beginadres van de pixelgegevens)
    move $v0, $gp

    # Bereken het geheugenadres
    add $v0, $v0, $t1          # $v0 = $gp + offset_rij + offset_kolom

    # Zorg voor word alignment
    andi $t2, $v0, 3    # Bereken de rest bij deling door 4
    subu $v0, $v0, $t2  # Trek de rest af om het word aligned te maken

    # Herstel het stackframe
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    # Keer terug naar de aanroepende functie
    jr $ra
