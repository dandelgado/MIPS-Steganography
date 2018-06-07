##############################################################
# Homework #2
# name: Daniel Delgado
# sbuid: 109986180
##############################################################
.text

##############################
# PART 1 FUNCTIONS 
##############################

toUpper:
	la $t0, ($a0) #Load the string into $t0.
	
	toUpperLoop:
	lb $t1, 0($t0) #Load the first byte (character) of the string into $t1.
	beqz $t1, toUpperBreak #If the character is null, break.
	blt $t1, 'a', Capitalized #If the character is not a lowercase letter, jump to the next character.
	bgt $t1, 'z', Capitalized #If the character is not a lowercase letter, jump to the next character.
	addi $t1, $t1, -32 #If the character IS a lowercase letter, subtract 32 from its ASCII value to capitalize it.
	
	Capitalized:
	sb $t1, 0($t0) #Store the capitalized character into $t2.
	addi $t0, $t0, 1 #Iterate through the string
	j toUpperLoop
	
	toUpperBreak:
	la $v0, ($a0)
	jr $ra

length2Char:
	la $t2, ($a0)
	lb $t3, ($a1)
	li $t4, 0 #Length = 0
	
	length2CharLoop:
	lb $t1, 0($t2)
	beq $t1, $zero, getLength
	beq $t1, $t3, getLength
	addi $t4, $t4, 1
	addi $t2, $t2, 1
	j length2CharLoop
	
	getLength:
	move $v0, $t4
	jr $ra

strcmp:
	li $t2, 1 #Match flag set to true.
	la $t0, ($a0)
	la $t1, ($a1)
	blt $a2, 0, strcmpDone
	li $t5, 0 #Total matching characters = 0
	li $t6, 0 #Length counter = 0
	beq $a2, 0, LengthEquals0
	
	#Check length of strings.
	lengthCheck:
	lb $t3, 0($t0)
	lb $t4, 0($t1)
	beq $t3, $zero, lengthCheckDone
	beq $t4, $zero, lengthCheckDone
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	addi $t6, $t6, 1
	j lengthCheck
	
	#Determine whether or not the length entered by the user is valid.
	lengthCheckDone:
	blt $t6, $a2, strcmpError
	li $t6, 0
	li $t8, 0
	la $t0, ($a0)
	la $t1, ($a1)
	la $t1, ($a1)
	
	strcmpLoop:
	beq $a2, 0, LengthEquals0
	beq $t6, $a2, strcmpDone
	addi $t6, $t6, 1
	LengthEquals0:
	lb $t3, 0($t0)
	lb $t4, 0($t1)
	beq $t3, $zero, strcmpDone
	beq $t4, $zero, strcmpDone
	beq $t3, $t4, match
	li $t2, 0
	j strcmpContinue
	match:
	addi $t5, $t5, 1
	strcmpContinue:
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j strcmpLoop
	
	strcmpError:
	li $t2, 0
	
	strcmpDone:
	beq $t3, $t4, strcmpMatch
	li $t2, 0
	strcmpMatch:
	move $v0, $t5
	move $v1, $t2
	jr $ra

##############################
# PART 2 FUNCTIONS
##############################

toMorse:
	blez $a2, toMorseDone
	la $t1, ($a0)
	li $t5, 1 #Completed Flag set to true.
	li $t4, 1
	la $t0, MorseCode
	li $t7, 0 #Will be set to 1 if first character is not null
	la $t8, EndMorseChar
	lb $t8, 0($t8)
	li $t9, 0 #Will only be set to 1 after a character is not a space.
	
	toMorseLoop:
	lb $t3, 0($t1)
	beq $t3, $zero, toMorseComplete
	beq $t3, ' ', toMorseSpace
	blt $t3, '!', toMorseContinue
	bgt $t3, 'Z', toMorseContinue
	li $t9, 1
	li $t7, 1
	addi $t3, $t3, -33
	li $t2, 4
	mul $t2, $t3, $t2
	add $t2, $t0, $t2
	lw $t6, 0($t2)
	j charCount
	counted:
	sb $t8, 0($a1)
	addi $a1, $a1, 1
	addi $t4, $t4, 1
	beq $t4, $a2, toMorseError
	toMorseContinue:
	addi $t1, $t1, 1
	j toMorseLoop
	
	toMorseSpace:
	beqz $t7, toMorseSpace2
	j toMorseSpace3
	toMorseSpace2:
	lb $t3, 1($t1)
	beqz $t3, addSpace
	beq $t3, ' ', addSpace
	blt $t3, '!', addSpace
	bgt $t3, 'Z', addSpace
	beqz $t9, toMorseContinue
	toMorseSpace3:
	lb $t3, 1($t1)
	beqz $t9, toMorseContinue
	beqz $t3, toMorseComplete
	addSpace:
	li $t9, 0
	li $t7, 1
	j counted
	
	charCount:
	lb $t3, 0($t6)
	beq $t3, $zero, counted
	addi $t6, $t6, 1
	sb $t3, 0($a1)
	addi $a1, $a1, 1
	addi $t4, $t4, 1
	beq $t4, $a2, toMorseError
	j charCount
	
	toMorseError:
	la $t4, ($a2)
	li $t5, 0
	j toMorseDone
	
	toMorseComplete:
	beq $t7, 0, toMorseDone
	sb $t8, 0($a1)
	addi $t4, $t4, 1
	
	toMorseDone:
	move $v0, $t4
	move $v1, $t5
	jr $ra

createKey:
	#Convert string to uppercase.
	#Iterate through capitalized string. For each char, iterate through key. 
	#If char is valid and has been used, add 1 and try again.
	#Save return address to stack
	addi $sp, $sp, -12
	la $s0, ($a0)
	la $s1, ($a1)
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	jal toUpper #Call toUpper
	#Change return address
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	la $a0, ($s0)
	la $a1, ($s1)
	addi $sp, $sp, 12
	li $t5, 0 #key size counter = 0
	createKeyConverted:
	la $t2, ($v0)
	createKeyLoop:
		lb $t1, 0($t2)
		beq $t5, 26, createKeyBreak
		beq $t1, $zero, createKeyBreak
		blt $t1, 'A', createKeyContinue
		bgt $t1, 'Z', createKeyContinue
		beginKeyCharCheck:
			la $t3, ($a1)
			sub $t3, $t3, $t5
			keyCharCheck:
			lb $t4, 0($t3)
			beq $t4, $zero, keyCharCheckDone
			bgt $t4, $t1, keyCharCheckContinue
			blt $t4, $t1, keyCharCheckContinue
			j createKeyContinue
			keyCharCheckContinue:
			addi $t3, $t3, 1
			j keyCharCheck
			keyCharCheckDone:
			sb $t1, 0($t3)
			addi $t3, $t3, 1
			move $a1, $t3
			addi $t5, $t5, 1
		createKeyContinue:
			addi $t2, $t2, 1
			j createKeyLoop
	createKeyBreak:
	#Fill $a1 with remaining characters.
	li $t1, 'A'
	beginCreateKeyFill:
	beq $t5, 26, keyComplete
	la $t3, ($a1)
	sub $t3, $t3, $t5
	createKeyFill:
	lb $t4, 0($t3)
	beq $t4, $zero, fillDone
	blt $t4, $t1, fillContinue
	bgt $t4, $t1, fillContinue
	addi $t1, $t1, 1
	j beginCreateKeyFill
	fillContinue:
	addi $t3, $t3, 1
	j createKeyFill
	fillDone:
	sb $t1, 0($t3)
	addi $t3, $t3, 1
	move $a1, $t3
	addi $t5, $t5, 1
	addi $t1, $t1, 1
	j beginCreateKeyFill
	
	keyComplete:
	move $v0, $a1
	jr $ra

keyIndex: 
	li $s3, 0 #Total character counter
	tryAgain:
	la $a1, FMorseCipherArray
	li $a2, 3
	add $a1, $a1, $s3
	#Null character check START
	lb $t0, 0($a1)
	beqz $t0, keyIndexError
	lb $t0, 1($a1)
	beqz $t0, keyIndexError
	lb $t0, 2($a1)
	beqz $t0, keyIndexError
	lb $t0, 0($a0)
	beqz $t0, keyIndexError
	lb $t0, 1($a0)
	beqz $t0, keyIndexError
	lb $t0, 2($a0)
	beqz $t0, keyIndexError
	#Null character check END
	la $s0, ($a0)
	la $s1, ($a1)
	la $s2, ($a2)
	#STACK
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	jal strcmp
	lw $s3, 16($sp)
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 20
	#STACK
	la $a0, ($s0)
	la $a1, ($s1)
	la $a2, ($s2)
	beq $v1, 1, keyIndexDone
	addi $s3, $s3, 3
	j tryAgain
	
	keyIndexError:
	li $v0, -1
	jr $ra
	
	keyIndexDone:
	li $t0, 3
	div $s3, $t0
	mflo $s3
	move $v0, $s3
	jr $ra

FMCEncrypt:
	#$a0: FMCEncrypt_plaintext
	#$a1: FMCEncrypt_phrase
	#$a2: FMCEncrypt_encryptBuffer
	#$a3: FMCEncrypt_size
	#$v0: FMCEncrypt_encryptBuffer
	#$v1: 1 if success, 0 if not
	
	#toMorse: $a0 = FMCEncrypt_plaintext, $a1 = FMC_mcmsg, $a2 = FMC_size
	#$v0 = mcmsg length, $v1 = 1 if success, 0 if not
	la $s0, ($a0)
	la $s1, ($a1)
	la $s2, ($a2)
	la $s3, ($a3)
	la $a1, FMC_mcmsg #FMCEncrypt_phrase can be recovered from $s1
	lw $a2, FMC_size #FMCEncrypt_encryptBuffer can be recovered from $s2
	la $s4, ($a1)
	la $s5, ($a2)
	#7 values to save including $ra: Allocate 28 bytes in stack.
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	jal toMorse	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	
	la $s4, ($a1)
	la $s5, ($a2)
	
	#createKey: $a0 = FMCEncrypt_phrase, $a1 = FMC_key
	#$v0 = FMC_key
	la $a0, ($s1) #FMC_mcmsg can be recovered from $s4
	la $a1, FMC_key #FMCEncrypt_size can be recovered from $s5
	la $s0, ($a1) #Overwrite plaintext. We don't need it anymore. Current $a0 is still in $s1.
	
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	jal createKey	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	
	la $s0, FMC_key
	
	#keyIndex: $a0 = FMC_mcmsg
	#$v0 = integer value of 1st 3 characters, $v1 = 1 if success, 0 if not
	la $a0, FMC_mcmsg
	li $s5, 0 #Counter
	FMCloop:
	la $s4, ($a0)
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	jal keyIndex	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	
	#Repeat until the end of the mcmsg or buffer is full.
	beq $v1, -1, FMCfailed
	la $a0, ($s4)
	move $t3, $v0
	add $s0, $s0, $t3
	lb $t1, 0($s0)
	sub $s0, $s0, $t3
	la $t2, ($s2)
	sb $t1, 0($t2)
	addi $t2, $t2, 1
	addi $s5, $s5, 1
	move $s2, $t2
	addi $a0, $a0, 3
	lb $t1, 0($a0)
	beqz $t1, FMCsuccess
	lb $t1, 1($a0)
	beqz $t1, FMCfailed
	lb $t1, 2($a0)
	beqz $t1, FMCfailed
	j FMCloop
	
	FMCsuccess:
	li $v1, 1
	j FMCdone
	
	FMCfailed:
	li $v1, 0
	
	FMCdone:
	sub $s2, $s2, $s5
	la $v0, ($s2)
	jr $ra
	
##############################
# EXTRA CREDIT FUNCTIONS
##############################

FMCDecrypt:
	#Define your code here
	############################################
	# DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
	la $v0, FMorseCipherArray
	############################################
	jr $ra

fromMorse:
	#Define your code here
	jr $ra



.data

MorseCode: .word MorseExclamation, MorseDblQoute, MorseHashtag, Morse$, MorsePercent, MorseAmp, MorseSglQoute, MorseOParen, MorseCParen, MorseStar, MorsePlus, MorseComma, MorseDash, MorsePeriod, MorseFSlash, Morse0, Morse1,  Morse2, Morse3, Morse4, Morse5, Morse6, Morse7, Morse8, Morse9, MorseColon, MorseSemiColon, MorseLT, MorseEQ, MorseGT, MorseQuestion, MorseAt, MorseA, MorseB, MorseC, MorseD, MorseE, MorseF, MorseG, MorseH, MorseI, MorseJ, MorseK, MorseL, MorseM, MorseN, MorseO, MorseP, MorseQ, MorseR, MorseS, MorseT, MorseU, MorseV, MorseW, MorseX, MorseY, MorseZ 

MorseExclamation: .asciiz "-.-.--"
MorseDblQoute: .asciiz ".-..-."
MorseHashtag: .ascii ""
Morse$: .ascii ""
MorsePercent: .ascii ""
MorseAmp: .ascii ""
MorseSglQoute: .asciiz ".----."
MorseOParen: .asciiz "-.--."
MorseCParen: .asciiz "-.--.-"
MorseStar: .ascii ""
MorsePlus: .ascii ""
MorseComma: .asciiz "--..--"
MorseDash: .asciiz "-....-"
MorsePeriod: .asciiz ".-.-.-"
MorseFSlash: .ascii ""
Morse0: .asciiz "-----"
Morse1: .asciiz ".----"
Morse2: .asciiz "..---"
Morse3: .asciiz "...--"
Morse4: .asciiz "....-"
Morse5: .asciiz "....."
Morse6: .asciiz "-...."
Morse7: .asciiz "--..."
Morse8: .asciiz "---.."
Morse9: .asciiz "----."
MorseColon: .asciiz "---..."
MorseSemiColon: .asciiz "-.-.-."
MorseLT: .ascii ""
MorseEQ: .asciiz "-...-"
MorseGT: .ascii ""
MorseQuestion: .asciiz "..--.."
MorseAt: .asciiz ".--.-."
MorseA: .asciiz ".-"
MorseB:	.asciiz "-..."
MorseC:	.asciiz "-.-."
MorseD:	.asciiz "-.."
MorseE:	.asciiz "."
MorseF:	.asciiz "..-."
MorseG:	.asciiz "--."
MorseH:	.asciiz "...."
MorseI:	.asciiz ".."
MorseJ:	.asciiz ".---"
MorseK:	.asciiz "-.-"
MorseL:	.asciiz ".-.."
MorseM:	.asciiz "--"
MorseN: .asciiz "-."
MorseO: .asciiz "---"
MorseP: .asciiz ".--."
MorseQ: .asciiz "--.-"
MorseR: .asciiz ".-."
MorseS: .asciiz "..."
MorseT: .asciiz "-"
MorseU: .asciiz "..-"
MorseV: .asciiz "...-"
MorseW: .asciiz ".--"
MorseX: .asciiz "-..-"
MorseY: .asciiz "-.--"
MorseZ: .asciiz "--.."


FMorseCipherArray: .asciiz ".....-..x.-..--.-x.x..x-.xx-..-.--.x--.-----x-x.-x--xxx..x.-x.xx-.x--x-xxx.xx-"
EndMorseChar: .asciiz "x"
FMC_mcmsg: .space 100
.align 2
FMC_size: .word 100
FMC_key: .space 26
.byte 0

