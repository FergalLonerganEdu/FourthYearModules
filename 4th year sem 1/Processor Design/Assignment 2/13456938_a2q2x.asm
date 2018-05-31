# Processor Design - COMP30080 Fergal Lonergan 13456938 Assignment 2 question 2 #

.data
Mode:	.ascii "?"		#Choose which mode/setting.
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
	la $s0, Decrypt		#Loads address of Decrypt string
	la $s1, Encrypt 	#Loads address of Encrypt string
	lb $s2, Mode		#Loads Mode setting
	li $s3, '!'		# Loads register $s3 with decimal ASCII value for / (33)
	li $s4, '?'		# Loads register $s4 with decimal ASCII value for ? (63)
	li $t1 '.'		#Loads decimal ASCII value for a full stop.		
	li $t2 'A'		#Loads decimal ASCII value for A.
	li $t3 'Z'		#Loads decimal ASCII value for Z.
	li $t4 'a'		#Loads decimal ASCII value for a.
	li $t5 'z' 		#Loads decimal ASCII value for z.
	li $s5, 0xffff0000	#loads rdc
	li $s6, 0xffff0008	#loads rdr
	li $s7, 0xffff000c	#loads tdr
	li $t9, 52		#Loads integer 4 into s5	
	ReadKeypress:
		
		lw $v0, 0($s5)			#Keep looping and checking if there is a keyboard input
		andi $v0, $v0, 0x01	
		beq $v0, $zero, ReadKeypress
		lw $v0, 4($s5)		#If pressed, it reads the character.
		move $t0, $v0		#Moves contents of $v0 to $t0
		
		beq $t0, $s3 , ChangeModeEncrypt
		beq $t0, $s4 , ChangeModeDecrypt
	ChooseMode:
		beq $s2, $s3, ModeE 		#Checks which setting to use.
		beq $s2, $s4, ModeD
		j Subroutine  
	
	ModeE:	
		beq $t0, $t1, End	#If input char is a full stop, break to exit flag.
		addi $t6, $zero, 0	#Reset t6.
		addi $s1, $s1, 0	#Reset s1.
	
	UpperEncrypt:  
		blt $t0, $t2, Subroutine  	#If position is not in upper case ASCII range, break.
		bgt $t0, $t3, LowerEncrypt	
		sub $t6, $t0, $t2	#Get displacement of input char from 'A' ASCII value
	
		add $s1, $s1, $t6	#Get correct ENCR character to load
		lb $t7, 0($s1)		#Loads byte from ENCR string
	
		j Print
	
	LowerEncrypt:  
		blt $t0, $t4, Subroutine	#If position is not in lower case ASCII range, break.
		bgt $t0, $t5, Subroutine 
		sub $t6, $t0, $t4	#Get displacement of input char from 'a' ASCII value.
	
		add $s1, $s1, $t6 	#Get correct ENCR character to load.
		lb $t7, 0($s1)		#Load byte from ENCR string 

		j Print
				
	ModeD:
		beq $t0, $t1, End	#If input char is a full stop, break to exit flag.
		la $s0, Decrypt		#Reset addresses
		la $s1, Encrypt 		
		addi $s4, $zero, 0	#Reset loop counter variables
		addi $t9, $zero, 52
		addi $t6, $zero, 0	#Reset the displacement register
		la $t1, Encrypt		#Loads address of ENCR string.
		addi $t8, $t8 , 0	
	
	UpperDecrypt:
		blt $t0, $t2, Subroutine  	#If position is not in upper case ASCII range, break.
		bgt $t0, $t3, LowerDecrypt
	SwapLetterUC:	
		bgt $s4, $t9, Subroutine	#If loop counter exceeds 4.
	
		add $t1, $t1, $s4	#Move forward in ENCR string 1 place every loop iteration.
		addi $s4, $zero, 1	#Increase loop counter  
		lb $t7, 0($t1) 		#Load byte at current position in ENCR string. 
		bne $t7, $t0, SwapLetterUC    	#If the byte is not found, jump back to L1.
	
				#If the byte is found:
		#bnez $t8, NotLower
		#addi $t1, $t1, +26	#Translates the lower case encrypted letter to upper case.
	NotLower:
		sub $t6, $t1, $s1 	#Get displacement of encrypted character address from start of ENCR string address
		add $s0, $s0, $t6	#Get correct DECR character to load.
		lb $t7, 0($s0)		#Load byte from ENCR string.
	 
	j Print	
		
	LowerDecrypt:
		blt $t0, $t4, Subroutine	#If position is not in lower case ASCII range, break.
		bgt $t0, $t5, Subroutine 
		addi $s1, $s1, 26	#Translates the lower case encrypted letter to upper case.
		j SwapLetterUC

	#SwapLetterLC:		#Swap lower case values for their decrupted values
	#	bgt $s4, $t9, Subroutine	#If loop counter exceeds 4.
	#	
	#	add $t1, $t1, $s4	#Move forward in ENCR string 1 place every loop iteration.
	#	addi $s4, $zero, 1	#Increase loop counter  
	#	lb $t7, 0($t1) 		#Load byte at current position in ENCR string.
	#	bne $t7, $t0, SwapLetterLC 	#If the byte is not found, jump back to L1.
	#
	#			#If the byte is found:
	#	subi $t1, $t1, 26	#Translates the lower case encrypted letter to upper case.
	#	sub $t6, $t1, $s1 	#Get displacement of encrypted character address from start of ENCR string address
	#	add $s0, $s0, $t6	#Get correct DECR character to load.
	#	lb $t7, 0($s0)		#Load byte from ENCR string.
	#	 
	#	j Print	
	
	Print:
		lw $t0, 0xffff0008	#Transmitter control
		beq $t0, $zero, Print	#Keeps checking if a character is ready to be displayed.
		sw $t7, 0($s7)	#Stores word in the transmitter data address.
		j Subroutine

ChangeModeDecrypt:
	move $s2, $s4 # set our mode to decrypt
	j ChooseMode
	
ChangeModeEncrypt:
	move $s2, $s3 # set our mode to decrypt
	j ChooseMode

End:
	jr $ra # exit Subroutine
