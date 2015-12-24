###############################################################################################################################
############ 				                Chiffre de Vigenère               			   ############
############        				MIPS PROJECT - Polytech Montpellier     			   ############
############            				Author : Johan BRUNET               			   ############
###############################################################################################################################

.data
	menu: .asciiz "                         MENU\n 1- Cryptage de chaine\n 2- Déryptage de chaine\n 3- Cryptage de fichier\n 4- Déryptage de fichier\n 5- Sortie\n"
	demande_continuer : .asciiz "Voulez vous continuer ?"
	
	demande_chaine_cryptage: .asciiz "\n Veuillez entrer la chaine à crypter (majuscules uniquement)\n"
	demande_cle_cryptage: .asciiz "\n Veuillez entrer la clé de cryptage (majuscules uniquement)\n"
	msg_chaine_cryptee: .asciiz "\n Chaine cryptée : \n"
	chaine_cryptee: .space 255
	
	demande_chaine_decryptage: .asciiz "\n Veuillez entrer la chaine à décrypter (majuscules uniquement)\n"
	demande_cle_decryptage: .asciiz "\n Veuillez entrer la clé de décryptage (majuscules uniquement)\n"
	msg_chaine_decryptee: .asciiz "\n Chaine décryptée : \n"
	chaine_decryptee: .space 255
	
	chaine: .space 2000
	cle: .space 255
	cle_repetee: .space 255
	
	fichier_entree: .space 255
	fichier_sortie: .asciiz "fichier_sortie.txt"
	msg_fichier_ecrit: .asciiz "Votre fichier a été écrit avec succès"
	
	demande_fichier_cryptage: .asciiz "\n Veuillez entrer le nom du fichier à crypter (extension .txt)\n"
	demande_fichier_decryptage: .asciiz "\n Veuillez entrer le nom du fichier à décrypter (extension .txt)\n"
	
.text

# Remise à 0 des registres
# Appelé à la fin du cryptage ou décriptage
# Redirige vers le menu
effacer_registres:
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	li $a0, 0
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $v0, 0
	li $v1, 0
	j affiche_menu
	
# Affichage du menu, redirige vers l'une des 4 fonctions
affiche_menu:
	# Affichage du menu dans une fenêtre graphique
	li $v0, 51
	la $a0, menu
	syscall
	move $t0, $a0 
	# Branchement vers la fonction désirée en fonction de la réponse utilisateur
	beq $t0, 1, cryptage_chaine
	beq $t0, 2, decryptage_chaine
	beq $t0, 3, cryptage_fichier
	beq $t0, 4, decryptage_fichier
	beq $t0, 5, exit
	j affiche_menu

##################################################################################################################################

# Première fonction, demande la saisie d'une chaine de caractères et d'une clé
# Renvoie la chaine cryptée en fonction de la clé selon, le chiffrement de Vigénère

##################################################################################################################################

cryptage_chaine: 
	# Demande de la saisie de la chaine à crypter et la stocke dans "chaine" (taille maximale de 255 caractères)
	li $v0, 54
	la $a0, demande_chaine_cryptage
	la $a1, chaine
	la $a2, 255
	syscall
	# Demande de la saisie de la clé de cryptage et la stocke dans "cle" (taille maximale de 255 caractères)
	li $v0, 54
	la $a0, demande_cle_cryptage
	la $a1, cle
	la $a2, 255
	syscall
	jal contact_cle_chaine			# Saut avec retour vers la routine de contact entre la clé et la chaine
	jal routine_cryptage			# Saut avec retour vers la routine de de cryptage de chaine
	# Affichage de la chaine cryptée
	li $v0, 59
	la $a0, msg_chaine_cryptee
	la $a1, chaine_cryptee
	syscall
	j continuer

##################################################################################################################################

# Deuxième fonction, demande la saisie d'une chaine de caractères et d'une clé
# Renvoie la chaine décryptée en fonction de la clé, selon le chiffrement de Vigénère

##################################################################################################################################

# Renvoie la chaine décryptée
decryptage_chaine: 
	# Demande de la saisie de la chaine à décrypter et la stocke dans "chaine" (taille maximale de 255 caractères)
	li $v0, 54
	la $a0, demande_chaine_decryptage
	la $a1, chaine
	la $a2, 255
	syscall
	# Demande de la saisie de la clé de décryptage et la stocke dans "cle" (taille maximale de 255 caractères)
	li $v0, 54
	la $a0, demande_cle_decryptage
	la $a1, cle
	la $a2, 255
	syscall
	jal contact_cle_chaine			# Saut avec retour vers la routine de contact entre la clé et la chaine
	jal routine_decryptage			# Saut avec retour vers la routine de de décryptage de chaine
	# Affichage de la chaine décryptée
	li $v0, 59
	la $a0, msg_chaine_decryptee
	la $a1, chaine_decryptee
	syscall
	j continuer
  
##################################################################################################################################

# Troisième fonction, demande la saisie d'un nom de fichier et d'une clé
# Renvoie le fichier crypté, dans un nouveau fichier, en fonction de la clé, selon le chiffrement de Vigénère

##################################################################################################################################

cryptage_fichier:
	li $v0, 54
	la $a0, demande_fichier_cryptage
	la $a1, fichier_entree
	la $a2, 255
	syscall
	
	# Demande de la saisie de la clé de cryptage et la stocke dans "cle" (taille maximale de 255 caractères)
	li $v0, 54
	la $a0, demande_cle_cryptage
	la $a1, cle
	la $a2, 255
	syscall
	jal nettoyer_nom_fichier
	
	# Ouverture d'un fichier en lecture
	li   $v0, 13       			# Appel système pour l'ouverture de fichier
	la   $a0, fichier_entree     		# Nom du fichier à ouvrir
	li   $a1, 0        			# Ouverture en lecture
	li   $a2, 0				# On ignore le mode d'ouverture
	syscall            			# Ouverture du fichier (descripteur de fichier retourné dans $v0)
	move $s6, $v0      			# Stockage du descripteur de fichier 
	# Lecture dans un fichier
	li   $v0, 14       			# Appel système pour lire dans un fichier
	move $a0, $s6      			# Descripteur du fichier 
	la   $a1, chaine   			# Adresse du buffer dans lequel enregistrer la lecture
	li   $a2, 2000     			# Taille du buffer 'en dur'
	syscall            			# Lecture du fichier
	# Fermeture du fichier 
	li   $v0, 16      			# Appel système pour la fermeture de fichier
	move $a0, $s6     			# Descripteur du fichier à fermer
	syscall           			# Fermetur du fichier

	jal contact_cle_chaine
	jal routine_cryptage

  	# Ouverture en écriture d'un fichier inexistant
  	li   $v0, 13       			# Appel système pour l'ouverture de fichier
  	la   $a0, fichier_sortie     		# Nom du fichier de sortie
  	li   $a1, 1        			# Ouverture en écriture
  	li   $a2, 0        			# On ignore le mode d'ouverture
  	syscall            			# Ouverture du fichier (descripteur de fichier retourné dans $v0)
  	move $s6, $v0      			# Stockage du descripteur de fichier
  	# Ecriture dans le fichier ouvert
  	li   $v0, 15       			# Appel système pour écrire dans un fichier
  	move $a0, $s6      			# Descripteur du fichier 
  	la   $a1, chaine_cryptee   		# Adresse du buffer depuis lequel on écrit
 	li   $a2, 2000       			# Taille du buffer 'en dur'
 	syscall            			# Ecriture dans le fichier
  	# Fermeture du fichier 
	li   $v0, 16      			# Appel système pour la fermeture de fichier
	move $a0, $s6     			# Descripteur du fichier à fermer
	syscall           			# Fermetur du fichier
	
  	# Affichage d'un message pour notifier à l'utilisateur que le fichier a bien été écrit
  	li $v0, 55
  	la $a0, msg_fichier_ecrit
  	la $a1, 1
  	syscall
  	j continuer

##################################################################################################################################

# Quatrième fonction, demande la saisie d'une chaine de caractères et d'une clé
# Renvoie le fichier décrypté, dans un nouveau fichier, en fonction de la clé, selon le chiffrement de Vigénère

##################################################################################################################################


decryptage_fichier:
	li $v0, 54
	la $a0, demande_fichier_decryptage
	la $a1, fichier_entree
	la $a2, 255
	syscall
	
	# Demande de la saisie de la clé de cryptage et la stocke dans "cle" (taille maximale de 255 caractères)
	li $v0, 54
	la $a0, demande_cle_decryptage
	la $a1, cle
	la $a2, 255
	syscall
	jal nettoyer_nom_fichier
	
	# Ouverture d'un fichier en lecture
	li   $v0, 13       			# Appel système pour l'ouverture de fichier
	la   $a0, fichier_entree     		# Nom du fichier à ouvrir
	li   $a1, 0        			# Ouverture en lecture
	li   $a2, 0				# On ignore le mode d'ouverture
	syscall            			# Ouverture du fichier (descripteur de fichier retourné dans $v0)
	move $s6, $v0      			# Stockage du descripteur de fichier 
	# Lecture dans un fichier
	li   $v0, 14       			# Appel système pour lire un fichier
	move $a0, $s6      			# Descripteur du fichier 
	la   $a1, chaine   			# Adresse du buffer dans lequel enregistrer la lecture
	li   $a2, 2000     			# Taille du buffer 'en dure'
	syscall            			# Lecture du fichier
	# Fermeture du fichier 
	li   $v0, 16      			# Appel système pour la fermeture de fichier
	move $a0, $s6     			# Descripteur du fichier à fermer
	syscall           			# Fermetur du fichier

	jal contact_cle_chaine
	jal routine_decryptage

  	# Ouverture d'un fichier en lecture
	li   $v0, 13       			# Appel système pour l'ouverture de fichier
	la   $a0, fichier_sortie     		# Nom du fichier à ouvrir
	li   $a1, 1        			# Ouverture en écriture
	li   $a2, 0				# On ignore le mode d'ouverture
	syscall            			# Ouverture du fichier (descripteur de fichier retourné dans $v0)
	move $s6, $v0      			# Stockage du descripteur de fichier
  	# Ecriture dans le fichier
  	li   $v0, 15       			# Appel système pour l'écriture dans un fichier
  	move $a0, $s6      			# Descripteur du fichier 
  	la   $a1, chaine_decryptee   		# Adresse du buffer depuis lequel écrire
 	li   $a2, 2000       			# Taille du buffer 'en dure'
 	syscall            			# Ecriture dans le fichier
  	# Fermeture du fichier 
	li   $v0, 16      			# Appel système pour la fermeture de fichier
	move $a0, $s6     			# Descripteur du fichier à fermer
	syscall           			# Fermetur du fichier
  	# Affichage d'un message pour notifier à l'utilisateur que le fichier a bien été écrit
  	li $v0, 55
  	la $a0, msg_fichier_ecrit
  	la $a1, 1
  	syscall
  	j continuer

##################################################################################################################################

# Routines permettant de faire le contact entre la clé et la chaine, le cryptage et le décryptage de chaines de caractères

##################################################################################################################################

# Répète la clé afin d'avoir la même taille que la chaine
contact_cle_chaine:
	# Allocation et enregistrement de l'adresse de retour dans la pile
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	# Chargement des chaines et positionnement sur le premier caractère
	la $t0, chaine
	lb $t1, 0($t0)
	la $t4, cle_repetee	
	
	# Pour revenir au premier caractère de la clé lorsqu'on la répète 
	debut_cle:
	la $t2, cle
	lb $t3, 0($t2)
	# Début de la boucle de répétition de la clé
	boucle:
	beq $t1, 10, retour_appelant		# Retour à l'appelant si on a atteint la fin de la chaine (10 = \n)
	beq $t1, 0, retour_appelant		# Retour à l'appelant si on a atteint la fin de la chaine (sans line feed) (0 = \0)
	beq $t3, 10, debut_cle			# Retour au début de la clé lorsqu'elle se termine (10 = \n)
	beq $t1, 32, ajout_espace		# On ajoute un espace dans la clé répétée lorsqu'il y a un espace dans la chaine
	sb $t3, ($t4)				# On enregistre le caractère courant dans la nouvelle chaine

	addi $t0, $t0, 1			# On passe au caractère suivant dans la chaine
	lb $t1, ($t0)
	addi $t2, $t2, 1			# On passe au caractère suivant dans la clé
	lb $t3, ($t2)
	addi $t4, $t4, 1			# On passe au caractère suivant dans la nouvelle chaine
	j boucle				# On revient au début de la clé

# Ajout d'un espace dans la clé répétée
ajout_espace:
	sb $t1, ($t4)
	addi $t0, $t0, 1
	lb $t1, ($t0)
	addi $t4, $t4, 1
	j boucle
	
# Routine de cryptage de chaine de caractères
routine_cryptage:
	# Allocation et enregistrement de l'adresse de retour dans la pile
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	# On charge la chaine à crypter ainsi que la clé répétée
	la $t0, chaine
	lb $t1, 0($t0)
	la $t4, chaine_cryptee
	la $t2, cle_repetee
	lb $t3, 0($t2)
	# Début de la boucle de cryptage de la chaine
	crypte:
	beq $t1, 10, pas_modif			# Retour à l'appelant si on a atteint la fin de la chaine (10 = \n)
	beq $t1, 0, retour_appelant		# Retour à l'appelant si on a atteint la fin de la chaine (sans line feed) (0 = \0)
	beq $t1, 32, pas_modif			# On ne code pas les espaces
	add $t5, $t1, $t3			# Addition des deux caractères courants : chaine + clé
	div $t5, $t5, 26		
	mfhi $t5				# Modulo 26 pour revenir dans l'alphabet
	addi $t5, $t5, 65			# Ajout de 65 pour avoir une lettre entre A et Z
	sb $t5, ($t4)				# Stockage du caractère dans la nouvelle chaine	
	jal car_suivant	
	j crypte				# Passage au caractère suivant
	# Le caractère "espace" est laissé tel-quel
	pas_modif :
	sb $t1, ($t4)
	jal car_suivant
	j crypte
	
# Routine de décryptage de chaine de caractères
routine_decryptage:
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	# On charge la chaine à décrypter ainsi que la clé répétée
	la $t0, chaine
	lb $t1, 0($t0)
	la $t4, chaine_decryptee
	la $t2, cle_repetee
	lb $t3, 0($t2)
	# Début de la boucle de cryptage de la chaine
	decrypte:
	beq $t1, 10, retour_appelant		# Retour à l'appelant si on a atteint la fin de la chaine (10 = \n)
	beq $t1, 0, retour_appelant		# Retour à l'appelant si on a atteint la fin de la chaine (sans line feed) (0 = \0)
	beq $t1, 32, espaces
	sub $t5, $t1, $t3			# Soustraction des deux caractères courants : chaine - clé
	addi $t5, $t5, 26			# Ajout de 26 pour revenir à des nombres positifs
	div $t5, $t5, 26		
	mfhi $t5				# Modulo 26 pour revenir dans l'alphabet
	addi $t5, $t5, 65			# Ajout de 65 pour avoir une lettre entre A et Z
	sb $t5, ($t4)				# Stockage du caractère dans la nouvelle chaine
	jal car_suivant	
	j decrypte				# Passage au caractère suivant
	# Le caractère "espace" est laissé tel-quel
	espaces :
	sb $t1, ($t4)
	jal car_suivant
	j decrypte

# Passage au caractère suivant
car_suivant:
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	addi $t0, $t0, 1
	lb $t1, 0($t0)
	addi $t2, $t2, 1
	lb $t3, 0($t2)
	addi $t4, $t4, 1
	j retour_appelant

# Permet de supprimer le caractère '\n' à la fin du nom du fichier (pour pouvoir l'ouvrir)
nettoyer_nom_fichier:
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	li $t0, 0       #loop counter
	li $t1, 21      #loop end
nettoyage:
    	beq $t0, $t1, retour_appelant
    	lb $t3, fichier_entree($t0)
    	bne $t3, 0x0a, L6
    	sb $zero, fichier_entree($t0)
    	L6:
   	addi $t0, $t0, 1
	j nettoyage

# Retour à l'appelant
retour_appelant:
	lw $ra, 0($sp)				# Récupération de l'adresse de retour
	addi $sp, $sp, 4			# Mot désaloué sur la pile
	jr $ra					# Retour à l'appelant

# Demande à l'utilisateur si il veut continuer l'exécution du programme
continuer:
	li $v0, 50			 	# Service MIPS permettant d'afficher une fenêtre de dialogue
	la $a0, demande_continuer		# Message à afficher dans la fenêtre de dialogue 
	syscall
	move $t0, $a0				# Récupération de la réponse de l'utilisateur : 0 - Oui, 1 - Non, 2 - Annuler
	beq $t0, 0, effacer_registres		# Si "Oui", retour au menu en remmetant à 0 les registres
	beq $t0, 1, exit			# Si "Non", on sort "proprement" du programme avec "exit"
	beq $t0, 2, continuer			# Sinon on réaffiche la fenêtre

# Sortir proprement du programme
exit:
	li $v0, 10				# Service MIPS permettant de mettre fin proprement au programme
	syscall
