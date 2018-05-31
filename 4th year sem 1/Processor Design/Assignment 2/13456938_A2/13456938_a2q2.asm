# Processor Design - COMP30080 Fergal Lonergan 13456938 Assignment 2 question 2 #

# A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
# Q W E R T Y U I O P A S D F G H J K L Z X C V B N M
# 
#  F E R G A L L O N E R G A N : DECRYPTED MESSAGE 
#  Y T K U Q S S G F T K U Q F : ENCRYPTED MESSAGE

.data
Mode:	.ascii "?"		#Choose which mode/setting. Default is decryption
				#[! (Encryption) / ? (Decryption)]
Decrypt: 	.ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
Encrypt:	.ascii "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm"
	.align 2
	.text
	.globl main	
main:
		jal Subroutine
li $v0, 10
syscall
	
Subroutine:
	la $s0, Decrypt		# Loads address of Decrypt string
	la $s1, Encrypt 	# Loads address of Encrypt string
	lb $s2, Mode		# Loads current Mode setting
	li $s3, '!'		# Loads register $s3 with decimal ASCII value for / (33)
	li $s4, '?'		# Loads register $s4 with decimal ASCII value for ? (63)
	li $t1 '.'		# Loads register $t1 with decimal ASCII value for a full stop (46).		
	li $t2 'A'		# Loads register $t2 with decimal ASCII value for A (65).
	li $t3 'Z'		# Loads register $t3 with decimal ASCII value for Z (90).
	li $t4 'a'		# Loads register $t4 with decimal ASCII value for a (97).
	li $t5 'z' 		# Loads register $t5 with decimal ASCII value for z (122).
	li $s5, 0xffff0000	# Loads rdc
	li $s6, 0xffff0008	# Loads rdr
	li $s7, 0xffff000c	# Loads tdr
	li $t9, 52		# Loads integer 52 into s5. Represents elements in Encrypt string	
	
	ReadKeypress:	
		lw $v0, 0($s5)			# Keep looping and checking if there is a keyboard input
		andi $v0, $v0, 0x01		# And with checkbit to see if user has input using keypress
		beq $v0, $zero, ReadKeypress 	# If a keypress is read move on.
		lw $v0, 4($s5)		#If pressed, it reads the character.
		move $t0, $v0		#Moves contents of $v0 to $t0
		
		beq $t0, $s3 , ChangeModeEncrypt #Checks to see if Keypress changes Mode to Encrypt
		beq $t0, $s4 , ChangeModeDecrypt #Checks to see if Keypress changes Mode to Decrypt
	ChooseMode:
		beq $s2, $s3, ModeE 		#Checks which setting to use.
		beq $s2, $s4, ModeD		
		j Subroutine  			# if neither mode is chosen return to Subroutine to read new keypress
	
	ModeE:	
		beq $t0, $t1, End	#If user inputs a full stop, end program.
		addi $t6, $zero, 0	# Set $t6 to 0. it will hold our String Position
		addi $s1, $s1, 0	# Set encrypt string to 0.
	
	UpperEncrypt:  
		blt $t0, $t2, Subroutine  	# If ASCII value is less than "A" then move to next character in string. Deals with the Space
						# who's ASCII value is 32.
		bgt $t0, $t3, LowerEncrypt	# If the characters ASCII value is greater than "Z" it might be LowerCase so jump to that step.
		sub $t6, $t0, $t2	# Find the offset the Input Character is from "A" in decimal.
					# I'll then use this value to pick the correct Cypher letter to encrypt our message.
	
		add $s1, $s1, $t6	# Finds correct letter address from our Encrupt Key for the current UpperCase letter using offset. 
		lb $t7, 0($s1)		# Loads $t7 with the correct encrypted ASCII letter.
	
		j Print # Print encrypted character to screen
	
	LowerEncrypt:  
		blt $t0, $t4, Subroutine	# If ASCII value is less than ASCII value for "a" then it's not a letter. Read in next character.
		bgt $t0, $t5, Subroutine 	# If ASCII value is greater than ASCII value for "z" then it's not a letter. Read in next character.
		sub $t6, $t0, $t4		# Find the offset the Input Character is from "a" in decimal.
						# I'll then use this value to pick the correct Cypher letter to encrypt our message.
	
		add $s1, $s1, $t6 	# Finds correct letter address from our Encrypt Key for the current LowerCase letter using offset
		lb $t7, 0($s1)		# Loads $t7 with the correct encrypted ASCII letter.

		j Print			# Print encrypted character
				
	ModeD:
		beq $t0, $t1, End	#If user inputs a full stop, end program.
		la $s0, Decrypt		# Load Decrypt string address
		la $s1, Encrypt 	# Load Encrypt string address	
		addi $s4, $zero, 0	# Create a loop that cycles through all elements of our strings
		addi $t9, $zero, 52	# 52 matches number of elements in encrypt string
		addi $t6, $zero, 0	# Reset our Offset value to 0
		la $t1, Encrypt		# Load address of first element in Encrypt string.
	
	UpperDecrypt:
		blt $t0, $t2, Subroutine  	# If ASCII value is less than "A" then move to next character in string. Deals with the Space
						# who's ASCII value is 32. 
		bgt $t0, $t3, LowerDecrypt	# If the characters ASCII value is greater than "Z" it might be LowerCase so jump to that step.
	SwapLetter:				# Swap our encrypted letter for our decrypted letter
		bgt $s4, $t9, Subroutine	# Return if we can't find letter in our strings.
	
		add $t1, $t1, $s4	# Move through our string 
		addi $s4, $zero, 1	# increase counter  
		lb $t7, 0($t1) 		#Load byte from our Encrypt string 
		bne $t7, $t0, SwapLetter    	#If character doesnt match this element move to next element in string.
						#When we match the characters
		sub $t6, $t1, $s1 	# Find the offset the Input Character is in decimal.
		add $s0, $s0, $t6	# Then use this offset to locate correct Decrypted value
		lb $t7, 0($s0)		# and load our value into our decrypted value into $t7 to be printed
	 
	j Print	#Print decrypted character
		
	LowerDecrypt:
		blt $t0, $t4, Subroutine	# If ASCII value is less than ASCII value for "a" then it's not a letter. Move to NextChar in string.
		bgt $t0, $t5, Subroutine 	# If ASCII value is greater than ASCII value for "z" then it's not a letter. Move to NextChar in string.
		addi $s1, $s1, 26		#Translates the lower case encrypted letter to upper case so we can use same print loop.
		j SwapLetter 			# go to swap letter to swap encrypted letter for decrypted letter
	
	
	Print:
		lw $t0, 0($s6)	# Read character from control register
		beq $t0, $zero, Print	# Keeps checking if a character is ready to be displayed.
		sw $t7, 0($s7)	# If it is we then store word in TCR.
		j Subroutine # read in new character

ChangeModeDecrypt:
	move $s2, $s4 # set our mode to decrypt
	j ChooseMode
	
ChangeModeEncrypt:
	move $s2, $s3 # set our mode to decrypt
	j ChooseMode

End:
	jr $ra # exit Subroutine
