# ===== Section donnees =====  
.data

    file: .asciiz "grille.txt"
    grille: .space 81 
    #grille: .asciiz "123456789456789123789123456214365897365897214897214365531642978642978531978531642"
    espace_col: .asciiz "|"
    espace_row: .asciiz "____________"
    z_t_s: .asciiz " "
    erreur_message: .asciiz "Erreur : doublon trouv� dans la ligne.\n"
    no_error_message: .asciiz "Aucune erreur : la ligne est valide.\n"

# ===== Section code =====  
.text
# ----- Main ----- 

main:
    la $a0, file
    jal loadFile
    move $t0, $v0
    
    move $a0, $t0
    jal parseValues
    
    move $a0, $t0
    jal closeFile
    
    jal transformAsciiValues
    jal displayGrille
    jal addNewLine
    
    #jal check_columns
    #jal check_rows
    #jal check_square 
    
    jal check_sudoku
    jal solve_sudoku
    
    jal zeroToSpace
    jal displaySudoku
    jal exit


# ----- Fonctions ----- 

# ouvrir un fichier pass� en argument : appel systeme 13 
#	$a0 nom du fichier
#	$a1 (= 0 lecture, = 1 ecriture)
# Registres utilises : $v0, $a1
loadFile:
	li $v0, 13
	li $a1, 0
	syscall
	jr $ra
#lire un fichier pass� en argument : appel syst�me 14
#$a0 descripteur du fichier ouvert
#Registres utilis�s : $a1, $a2, $v0	
parseValues:
	la $a1, grille #charge l'adresse de l� ou va �tre stock� la grille
	li $a2, 81 #lecture 81 carat�res
	li $v0, 14 #appel syst�me 14 : lire
	syscall
	jr $ra

# Fermer le fichier : appel systeme 16
# $a0 descripteur de fichier  ouvert
# Registres utilises : $v0
closeFile:
	li $v0, 16
	syscall
	jr  $ra

# ----- Fonction addNewLine -----  
# objectif : fait un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0
addNewLine:
    li      $v0, 11
    li      $a0, 10
    syscall
    jr $ra



# ----- Fonction displayGrille -----   
# Affiche la grille.
# Registres utilises : $v0, $a0, $t[0-2]
displayGrille:  
    la      $t0, grille
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    li      $t1, 0
    boucle_displayGrille:
        bge     $t1, 81, end_displayGrille     # Si $t1 est plus grand ou egal a 81 alors branchement a end_displayGrille
            add     $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            lb      $a0, ($t2)              # load byte at $t2(adress) in $a0
            li      $v0, 1                  # code pour l'affichage d'un entier
            syscall
            add     $t1, $t1, 1             # $t1 += 1;
        j boucle_displayGrille
    end_displayGrille:
        lw      $ra, 0($sp)                 # On recharge la reference 
        add     $sp, $sp, 4                 # du dernier jump
    jr $ra


# ----- Fonction transformAsciiValues -----   
# Objectif : transforme la grille de ascii a integer
# Registres utilises : $t[0-3]
transformAsciiValues:  
    add     $sp, $sp, -4
    sw      $ra, 0($sp)
    la      $t3, grille
    li      $t0, 0
    boucle_transformAsciiValues:
        bge     $t0, 81, end_transformAsciiValues
            add     $t1, $t3, $t0
            lb      $t2, ($t1)
            sub     $t2, $t2, 48
            sb      $t2, ($t1)
            add     $t0, $t0, 1
        j boucle_transformAsciiValues
    end_transformAsciiValues:
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra


# ----- Fonction getModulo ----- 
# Objectif : Fait le modulo (a mod b)
#   $a0 represente le nombre a (doit etre positif)
#   $a1 represente le nombre b (doit etre positif)
# Resultat dans : $v0
# Registres utilises : $a0
getModulo: 
    sub     $sp, $sp, 4
    sw      $ra, 0($sp)
    boucle_getModulo:
        blt     $a0, $a1, end_getModulo
            sub     $a0, $a0, $a1
        j boucle_getModulo
    end_getModulo:
    move    $v0, $a0
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra


#################################################
#               A completer !                   #
#                                               #
# Nom et prenom binome 1 :                      #
# Nom et prenom binome 2 :                      #
#                                               #
# Fonction check_n_column                       #
# Objectif : V�rifie la validit� de la n-i�me ligne du Sudoku.
#registres utilis�s :$t[0-7], $s0, $v0
check_n_col:
    # Arguments : n est pass� dans $s0
    # $t0 = adresse de la grille (grille commence � l'adresse de la m�moire)
    la $t0, grille                # Charger l'adresse de la grille (tableau 9x9)
    add $sp, $sp, -4              # Sauvegarde de la r�f�rence du dernier jump
    sw  $ra, 0($sp)

    # Calculer l'adresse de la colonne n
    mul $t1, $s0, 1               # $t1 = n (index de la colonne)
    add $t1, $t0, $t1             # $t1 = adresse de la premi�re cellule de la colonne n (grille + n)

    li $t2, 0                     # Index1 (pour la premi�re boucle de v�rification)
    li $t3, 0                     # Index2 (pour la deuxi�me boucle de v�rification)
    li $t7, 0                     # Compteur de doublons (0 initialement)

	boucle_verification_1_c:
    		bge $t2, 9, end_check        # Si index1 >= 9, fin de la v�rification (pas de doublon)

    		bge $t7, 1, end_check        # Si doublon trouv�, sortir de la boucle

    		# Charger la valeur de grille[t2][n] dans $t5 (�l�ment de la colonne)
    		mul $t4, $t2, 9              # D�calage pour la ligne t2
    		add $t5, $t1, $t4            # $t5 = adresse de grille[t2][n]
    		lb $t5, 0($t5)               # Charger la valeur dans $t5

   		 li $t3, 0                     # R�initialisation de l'index2

	boucle_verification_2_c:
    		bge $t3, 9, boucle_verification_1_bis_c  # Si index2 >= 9, revenir � la v�rification de la ligne suivante

    		bge $t7, 1, end_check_c      # Si doublon trouv�, sortir

   		beq $t2, $t3, next_index2_c  # Si t2 == t3, ne pas se comparer � soi-m�me

    		# Charger la valeur de grille[t3][n] dans $t6 (�l�ment de la colonne)
    		mul $t4, $t3, 9              # D�calage pour la ligne t3
    		add $t6, $t1, $t4            # $t6 = adresse de grille[t3][n]
    		lb $t6, 0($t6)               # Charger la valeur dans $t6

    		beq $t5, $t6, cas_faux_c      # Si grille[t2][n] == grille[t3][n], il y a un doublon

    		addi $t3, $t3, 1             # Incr�menter index2
    		j boucle_verification_2_c     # Revenir � la boucle interne

	boucle_verification_1_bis_c:
    		addi $t2, $t2, 1             # Incr�menter index1
    		j boucle_verification_1_c    # Revenir � la premi�re boucle

	next_index2_c:
    		addi $t3, $t3, 1             # Incr�menter index2
    		j boucle_verification_2_c    # Revenir � la deuxi�me boucle

	cas_faux_c:
    		# Cas o� il y a un doublon (grille[t2][n] == grille[t3][n])
    		addi $t7, $t7, 1             # Incr�menter le compteur de doublons
    		j end_check_c                # Fin de la v�rification

	end_check_c:
    		# Afficher un message en fonction de la valeur de $t7 (compteur d'erreurs)
    		beqz $t7, no_error_c         # Si $t7 == 0, pas d'erreur, afficher "Aucune erreur"

    		# Message d'erreur
    		li $v0, 0
    		lw      $ra, 0($sp)
    		add     $sp, $sp, 4
    		jr $ra                       # Terminer la fonction

	no_error_c:
   		 # Message de succ�s (pas d'erreur)
   		li $v0, 1
    		lw      $ra, 0($sp)
    		add     $sp, $sp, 4
    		jr $ra                       # Terminer la fonction

 
#                                               #
#                                               #
#                                               #
# Fonction check_n_row                          #

# ----- Fonction check_n_row -----
# Objectif : V�rifie la validit� de la n-i�me ligne du Sudoku.
#registres utilis�s :$t[0-7], $s0, $v0
check_n_row:
    # Arguments : n est pass� dans $s0b
    # $t0 = adresse de la grille (grille commence � l'adresse de la m�moire)
    la $t0, grille                # Charger l'adresse de la grille (tableau 9x9)
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)

    # Calculer l'adresse de la ligne n (lignes de 9 �l�ments)
    mul $t1, $s0, 9               # $t1 = n * 9 (9 �l�ments par ligne)
    add $t1, $t0, $t1             # $t1 = adresse de la ligne n (grille + n*9)

    li $t2, 0                     # Index1 (pour la premi�re boucle de v�rification)
    li $t3, 0                      # Index2 (pour la deuxi�me boucle de v�rification)
    li $t4, 9                     # Compteur de la ligne (9 �l�ments)
    li $t7, 0                     # Compteur de doublons

	boucle_verification_1:
    		bge $t2, $t4, end_check       # Si index1 >= 8, fin de la v�rification (pas de doublon)

    		bge $t7, 1, end_check         # Si doublon trouv� (t7 > 0), sortir

    		# Charger la valeur de grille[n][t2] dans $t5
    		add $t5, $t1, $t2             # $t5 = adresse de grille[n][t2]
    		lb $t5, 0($t5)                # Charger la valeur dans $t5

    		li $t3, 1                     # R�initialisation de l'index2

	boucle_verification_2:
   		bge $t3, $t4, boucle_verification_1_bis # Si index2 >= 8, passer � la v�rification suivante

    		bge $t7, 1, end_check         # Si doublon trouv�, sortir
    		beq $t2, $t3, next_index2     # Si t2 == t3, passer � la prochaine it�ration (on ne se compare pas � soi-m�me)

    		# Charger la valeur de grille[n][t3] dans $t6
    		add $t6, $t1, $t3             # $t6 = adresse de grille[n][t3]
    		lb $t6, 0($t6)                # Charger la valeur dans $t6

    		beq $t5, $t6, cas_faux        # Si grille[n][t2] == grille[n][t3], il y a un doublon

    		addi $t3, $t3, 1              # Incr�menter index2
    		j boucle_verification_2        # Revenir � la boucle interne

	boucle_verification_1_bis:
    		addi $t2, $t2, 1              # Incr�menter index1
    		j boucle_verification_1       # Revenir � la premi�re boucle
    		
    	next_index2:
            addi $t3, $t3, 1              # Incr�menter index2
            j boucle_verification_2       # Revenir � la deuxi�me boucle
    	

	cas_faux:
    		# Cas o� il y a un doublon (grille[n][t2] == grille[n][t3])
    		addi $t7, $t7, 1              # Incr�menter le compteur de doublons
    		j end_check                   # Fin de la v�rification

	end_check:
    		# Afficher un message en fonction de la valeur de $t7 (compteur d'erreurs)
    		beqz $t7, no_error             # Si $t7 == 0, pas d'erreur, afficher "Aucune erreur"
    
    		# Message d'erreur
    		li $v0, 0
    		lw      $ra, 0($sp)
    		add     $sp, $sp, 4
    		jr $ra                        # Terminer la fonction

	no_error:
    		# Message de succ�s (pas d'erreur)
    		li $v0, 1
    		lw      $ra, 0($sp)
    		add     $sp, $sp, 4
    		jr $ra                        # Terminer la fonction


#                                               #
#                                               #
#                                               #
#--------Fonction check_n_square---------

# Fonction check_n_square
# Objectif : V�rifie qu'il n'y a pas de doublon dans la
#            n-i�me case 3x3 du Sudoku.
#            n est pass� dans $s0 (0 <= n <= 8).
#
#   - Parcours des 9 cellules de la sous-grille 3x3
#     depuis (rowStart, colStart).
#     On compare chaque case i avec toutes les cases j > i.
#
#   - Si on trouve un doublon, on affiche le message
#     d'erreur, sinon on affiche "Aucune erreur".
#
#registres utilis�s :$t[0-7], $s[0-5], $a0, $v0, 

check_n_square:
    addi    $sp, $sp, -4          # R�serve 4 octets sur la pile 
    sw      $ra, 0($sp)           # Sauvegarde l'adresse de retour ($ra)
    la      $t0, grille           # $t0 pointe sur le d�but de la grille (tableau 9x9)

    move    $a0, $s0              # Pr�pare $a0 pour getModulo, o� n = $s0
    li      $a1, 3                # Diviseur = 3
    jal     getModulo             # Appel de la fonction getModulo(n,3)
    # => R�sultat (n % 3) dans $v0

    mul     $t4, $v0, 3           # = (n % 3) * 3
                                  # On stocke le r�sultat dans $t4

    div     $s0, $a1              # DIV : divise $s0 par 3
    mflo    $t3                   # R�cup�re la partie enti�re de la division dans $t3
    mul     $t3, $t3, 3           # = floor(n/3) * 3
                                  # Stock� dans $t3


    #===== 2) Boucle pour comparer les 9 cases de la 3x3 =========
    # t7 = 0 => compteur de doublons
    # t1 va servir d'indice i dans la premi�re boucle

    li      $t7, 0                # Initialise le compteur de doublons � 0
    li      $t1, 0                # i = 0 (index de la premi�re boucle)

boucle_i:
    bge     $t1, 9, end_check_square  
    # Si i >= 9, on a parcouru toutes les 9 cases du carr� 3x3
    # et on sort de la fonction.
    
    # On calcule la position dans la sous-grille

    move    $s1, $t1              # Sauvegarde i dans $s1 (avant d'utiliser div)
    li      $a1, 3

    # i % 3 => calcul de la colonne relative dans la 3x3
    move    $a0, $s1
    jal     getModulo             # Appel getModulo(i, 3)
    move    $s2, $v0              # $s2 = (i % 3)

    # i / 3 => calcul de la ligne relative dans la 3x3
    div     $s1, $a1
    mflo    $s3                   # $s3 = (i / 3)

    add     $s3, $t3, $s3         # row_i =  + (i / 3)
    add     $s2, $t4, $s2         # col_i =  + (i % 3)


    # Charger la valeur de grille[row_i][col_i] dans t5

    mul     $t6, $s3, 9           # D�calage en ligne : row_i * 9
    add     $t6, $t6, $s2         # Ajout de col_i pour atteindre la bonne colonne
    add     $t6, $t6, $t0         # Ajout de l'adresse de base de la grille
    lb      $t5, 0($t6)           # t5 = grille[row_i][col_i]


    # Boucle j = i+1..8 => on compare la case i aux cases qui suivent
    addi    $t2, $t1, 1           # j = i + 1

boucle_j:
    bge     $t2, 9, next_i        # Si j >= 9, on a fini de comparer i, on passe au suivant
    bge     $t7, 1, end_check_square  
    # Si un doublon a d�j� �t� trouv� (t7 > 0), on peut quitter

    # On calcule la position de la case j dans la sous-grille
    move    $s1, $t2              # Sauvegarde j dans $s1
    li      $a1, 3

    # j % 3
    move    $a0, $s1
    jal     getModulo
    move    $s4, $v0              # s4 = (j % 3)

    # j / 3
    div     $s1, $a1
    mflo    $s5                   # s5 = (j / 3)

    add     $s5, $t3, $s5         # row_j =  + (j / 3)
    add     $s4, $t4, $s4         # col_j =  + (j % 3)

    # Charger grille[row_j][col_j] => t9
    mul     $t9, $s5, 9
    add     $t9, $t9, $s4
    add     $t9, $t9, $t0
    lb      $t9, 0($t9)

    # Comparer la case i (t5) � la case j (t9)
    beq     $t5, $t9, doublon  # Si grille[i] == grille[j], on a un doublon

    # Sinon on continue de comparer
    addi    $t2, $t2, 1           # j++
    j       boucle_j


# On a fini de comparer i avec toutes les j
# On passe � la case i+1

next_i:
    addi    $t1, $t1, 1           # i++
    j       boucle_i


# doublon : on a trouv� un doublon

doublon:
    addi    $t7, $t7, 1           # Incr�mente le compteur de doublons
    j       end_check_square  


# end_check_square : fin de la v�rification

end_check_square:  
    beqz    $t7, no_error_sq 
    # Si t7 == 0 => pas d'erreur, sinon on affiche erreur

    # s�il y a un doublon
    li $v0, 0
    lw      $ra, 0($sp)         # Restaurer $ra
    addi    $sp, $sp, 4
    jr      $ra

no_error_sq:
    li $v0, 1
    lw      $ra, 0($sp)            # Restaurer $ra
    addi    $sp, $sp, 4
    jr      $ra





#                                               #
#                                               #
#                                               #
# Fonction check_columns                        #
# ----- Fonction check_columns -----   
# Objectif : Check chaque colonne de la grille pour voir si elles sont valides
# Registres utilises : $s0
check_columns:
	add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    	sw      $ra, 0($sp)
	li $s0, 0	#$s0 -> indice de la colonne a v�rifier
	
	boucle_check_columns:
	
		bge $s0, 8, end_check_columns	#Si $s0 est sup�rieur � 8 on s'arr�te, car la 9e est inutile � v�rifier
		jal check_n_col	#sinon on v�rifie la colonne $s0
		addi $s0, $s0, 1	#on incr�mente l'indice
		beq $v0, $zero, erreur_col
		j boucle_check_columns
		
	erreur_col:
		j end_check_columns
		
	end_check_columns:
		lw	$ra, 0($sp)
		add	$sp, $sp, 4
		jr 	$ra
#                                               #
#                                               #
#                                               #
# Fonction check_rows                           #
# Fonction check_rows  				#
# Objectif : Check toutes les lignes de la grille pour v�rifier qu'elles sont valides
# Registres utilises : $t[0-3]
check_rows:
	add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    	sw      $ra, 0($sp)
	li $s0, 0		#$s0 -> indice de la ligne � v�rifier
	
	boucle_check_rows:
	
		bge $s0, 9, end_check_rows	#si $s0 >= 9, on s'arr�te
		jal check_n_row		#on v�rifie la n-ieme ligne
		addi $s0, $s0, 1	#on incr�mente l'indice
		beq $v0, $zero, erreur_row
		j boucle_check_rows
	
	erreur_row:
		j end_check_rows
	
	end_check_rows:
		lw	$ra, 0($sp)
		add	$sp, $sp, 4
		jr 	$ra
#                                               #
#                                               #
#                                               #
#--------Fonction check_square---------
#--------------------------------------------------------
# Fonction check_square
# Objectif : V�rifie les 9 sous-grilles 3x3 du Sudoku,
#            en appelant la fonction check_n_square pour
#            chacune d'entre elles (n = 0..8).
#--------------------------------------------------------
check_square:
    addi    $sp, $sp, -4          # R�serve 4 octets sur la pile
    sw      $ra, 0($sp)           # Sauvegarde l'adresse de retour ($ra)

    li      $s0, 0                # Initialise $s0 � 0 
                                  # (nous parcourons les sous-grilles de n=0 � n=8)

boucle_all_squares:
    bgt     $s0, 8, end_all_squares 
    # Si $s0 > 8, nous avons v�rifi� toutes les 9 sous-grilles (0..8),
    # on sort de la boucle.

    jal     check_n_square        # Appel de la fonction check_n_square(n=$s0)
    addi    $s0, $s0, 1           # Incr�mente n (on passe � la sous-grille suivante)
    beq	    $v0, $zero, erreur_square
    j       boucle_all_squares    # Retour au d�but de la boucle

erreur_square :
    j end_all_squares
    
end_all_squares:
    lw      $ra, 0($sp)           # Restaure l'adresse de retour
    addi    $sp, $sp, 4           # Lib�re l'espace occup� sur la pile
    jr      $ra                   # Retour � l'appelant




#                                               #
#                                               #
#                                               #
# Fonction check_sudoku                         #
# V�rifier si toute la grille est valide
# Registres utilises : $v0, $zero
check_sudoku:
	addi $sp, $sp, -4 #r�serve 4 octects sur la pile
	sw $ra, 0($sp) #save de l'addresse de retour
	
	#V�rification des lignes
	jal check_rows #fonction v�rifiant toutes les lignes
	beq $v0, $zero, sudoku_error #si check_n_rows renvoie 0, il y a une erreur donc on arr�te de check
	
	#V�rification des colonnes
	jal check_columns #Fonction qui v�rifie les colonnes
	beq $v0, $zero, sudoku_error #si check_n_columns renvoie 0, on a une erreur, on sort
	
	#V�rification des carr�s 3x3
	jal check_square #fonction qui v�rifie les carr�s
	beq $v0, $zero, sudoku_error #si il y a une erreur dans un carr� on arr�te la fonction
	
	#aucune erreur d�tect�
	li $v0, 1 #sudoku valide
	j sudoku_end
	
	sudoku_error:
		li $v0, 0 #sudoku invalide
		j sudoku_end
	
	sudoku_end:
		lw $ra, 0($sp)
		addi $sp, $sp 4 #on lib�re l'espace de la pile
		jr $ra
	
#                                               #
#                                               #
#                                               #
# Fonction solve_sudoku : résout le Sudoku en utilisant le backtracking
# Arguments :
# - $a0 : adresse de la grille Sudoku (tableau de 81 éléments)
# - $a1 : Flag indiquant si la grille a été complètement remplie (1 pour complet, 0 sinon)
# Retour : 
# - $v0 : TRUE si une solution a été trouvée, sinon FALSE
solve_sudoku:
    # Chercher la première case vide (0) dans la grille
    jal find_empty_cell
    # Si aucune case vide n'est trouvée, la grille est complète, afficher la solution
    beq $v0, $zero, solution_found

    # Récupérer la position de la case vide
    move $t0, $v0      # $t0 = ligne de la case vide
    move $t1, $v1      # $t1 = colonne de la case vide

    # Essayer chaque chiffre de 1 à 9
    li $t2, 1          # $t2 = valeur de 1 à 9
try_values:
    # Placer le chiffre dans la case vide
    jal check_sudoku   # Vérifier si la grille est valide après placement
    beq $v0, $zero, try_next_value

    # Appel récursif pour résoudre le reste du Sudoku
    jal solve_sudoku
    beq $v0, $zero, try_next_value

    # Si une solution a été trouvée, retour
    move $v0, $t2      # Retourner TRUE
    jr $ra

try_next_value:
    # Incrémenter la valeur et essayer la suivante
    addi $t2, $t2, 1
    blt $t2, 10, try_values   # Si t2 < 10, réessayer

    # Si aucune valeur n'a fonctionné, retirer la dernière tentative (backtracking)
    sw $zero, 0($a0)    # Remettre la case à 0 (vide)
    jr $ra

solution_found:
    # Si aucune case vide n'est trouvée, afficher la grille
    jal displaySudoku   # Afficher la grille complète
    li $v0, 1           # Indiquer que la solution est trouvée
    jr $ra

# Fonction find_empty_cell : trouve la première case vide dans la grille
# Arguments : 
# - $a0 : adresse de la grille
# Retour : 
# - $v0 : ligne de la case vide, ou 0 si aucune case vide
# - $v1 : colonne de la case vide, ou 0 si aucune case vide
find_empty_cell:
    li $t0, 0           # Initialiser l'index de la ligne
    li $t1, 0           # Initialiser l'index de la colonne
find_loop:
    # Calculer l'index de la case (ligne * 9 + colonne)
    mul $t2, $t0, 9     # $t2 = index de la ligne (ligne * 9)
    add $t2, $t2, $t1    # $t2 = index final (ligne * 9 + colonne)
    lb $t3, 0($a0)      # Lire la valeur de la case
    beqz $t3, found_empty  # Si la case est vide (0), sortir

    # Incrémenter les indices pour passer à la prochaine case
    addi $t1, $t1, 1
    blt $t1, 9, find_loop # Si $t1 < 9, continuer sur la même ligne

    # Passer à la ligne suivante
    addi $t0, $t0, 1
    li $t1, 0           # Réinitialiser la colonne
    blt $t0, 9, find_loop

    # Si aucune case vide n'a été trouvée, retourner 0
    li $v0, 0
    li $v1, 0
    jr $ra

found_empty:
    # Retourner la ligne et la colonne de la case vide
    move $v0, $t0
    move $v1, $t1
    jr $ra



#                                               #
#                                               #
#                                               #
# Autres fonctions que nous avons ajoute :      #
#                                               #
# Fonction ???                                  #  


# Fonction displaySudoku   			#
# Affiche le sudoku de fa�on matricielle.
# Registres utilises : $v0, $a0, $t[0-5]
displaySudoku:
	la      $t0, grille
    	add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    	sw      $ra, 0($sp)
    	li      $t1, 0
    	li	$t3, 0
    	li	$t4, 0
    	li	$t5, 0
    	boucle_displaySudoku:
        	bge     $t1, 81, end_displaySudoku     # Si $t1 est plus grand ou egal a 81 alors branchement a end_displayGrille
        	bge	$t3, 9, if_sup_a_9	#Si $t3 est plus grand ou egal � 9 alors branchement a if_sup_a_9
        	bge	$t5, 27, make_espace_row #si $t5 est >= � 27 alors branchement � make_espace_row
        	bge	$t4, 3, make_espace_col #Si $t4 est >= � 3 alors branchement � make_espace_col
            	add     $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            	lb      $a0, ($t2)              # load byte at $t2(adress) in $a0
            	bge	$a0, 32, espace_0
            	li      $v0, 1                  # code pour l'affichage d'un entier
            	syscall
            	add     $t1, $t1, 1             # $t1 += 1;
            	add	$t3, $t3, 1		# $t3 += 1;
            	add	$t4, $t4, 1		# $t4 += 1;
            	add	$t5, $t5, 1		# $t5 += 1;
        	j boucle_displaySudoku
        espace_0:
        	la	$a0, z_t_s
        	li	$v0, 4
        	syscall
        	add     $t1, $t1, 1             # $t1 += 1;
            	add	$t3, $t3, 1		# $t3 += 1;
            	add	$t4, $t4, 1		# $t4 += 1;
            	add	$t5, $t5, 1		# $t5 += 1;
        	j boucle_displaySudoku
        if_sup_a_9:
        	jal addNewLine			#ce sous alorithme sert � sauter une ligne d�s que
        	li	$t3, 0			#l'on arrive a neuf chiffres (donc 1 ligne )
        	j boucle_displaySudoku
        make_espace_col:
        	la	$a0, espace_col		#permet de mettre un "|" entre les colonnes de la grille
        	li	$v0, 4
        	syscall
        	li	$t4, 0
        	j boucle_displaySudoku
        make_espace_row:
        	la	$a0, espace_row		#permet de mettre un "_" entre les lignes de la grille
        	li	$v0, 4
        	syscall
        	li	$t5, 0
        	jal addNewLine
        	j boucle_displaySudoku
    	end_displaySudoku:
        	lw      $ra, 0($sp)                 # On recharge la reference 
        	add     $sp, $sp, 4                 # du dernier jump
    		jr $ra 

# ----- Fonction zeroToSpace -----   
# Affiche un espace dans le sudoku � la place des z�ro.
# Registres utilises : $a0, $t[0-2]
zeroToSpace:
	add     $sp, $sp, -4 # Sauvegarde de la reference du dernier jump
    	sw      $ra, 0($sp)
    	la      $t0, grille #on charge l'adresse de la grille
    	li	$t1, 0	#$t1 -> indice de la ou on se trouve dans la grille
    	boucle_z_t_s:
    		bge	$t1, 81, end_z_t_s	#si $t1 >= 81, on a fini de parcourir la grille, on arr�te la fonction
    		add	$t2, $t0, $t1	#$t2 -> le chiffre actuel grille[n]
    		lb	$a0, ($t2)	#On loadbyte grille[n] dans $a0
    		beq	$a0, 0, remplacer	#Si le chiffre est �gal � 0 on remplace
    		add	$t1, $t1, 1	#sinon on incr�mente l'indice
    		j boucle_z_t_s
    	remplacer:
    		li	$a0, 32		#32 est le code ascii de l'espace
    		sb	$a0, ($t2)	#on remplace
        	add	$t1, $t1, 1	#on incr�mente l'indice
    		j boucle_z_t_s	
    	end_z_t_s:
    		lw	$ra, 0($sp)
    		add	$sp, $sp, 4
    	jr $ra


#                                               #
#                                               #
#                                               #
#                                               #
# Fonction !!!                                  #  
#                                               #
#                                               #
#                                               #
################################################# 





exit: 
    li $v0, 10
    syscall
