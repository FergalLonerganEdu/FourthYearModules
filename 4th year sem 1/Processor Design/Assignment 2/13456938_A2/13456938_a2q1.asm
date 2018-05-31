# Processor Design - COMP30080 Fergal Lonergan 13456938 Assignment 2 question 1 #

# A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
# Q W E R T Y U I O P A S D F G H J K L Z X C V B N M
# 
#  F E R G A L L O N E R G A N : MESSAGE 
#  Y T K U Q S S G F T K U Q F : ENCRYPTED MESSAGE

.data
Input: .ascii "Fergal Lonergan\n" 		# My input string delimited by "\n" character to denote end of string.
Output: .space 40 				# Creating an ouput string of 160 bytes.
Cypher: .ascii "QWERTYUIOPASDFGHJKLZXCVBNM\n" 	# My Cypher. Organised characters according to QWERTY keyboard.
	.align 2
	
.text
.globl main

main:

	la $s0, Input		# Load the address of first element in Input string into register $s0.
	la $s1, Output		# Load the address of first element in Output string into register $s1.
	la $s2, Cypher		# Load the address of first element in Cypher string into register $s2.
	
	jal SubRoutine		# Run our SubRoutine to encrypt our Input.
	 
li $v0, 10
syscall

SubRoutine:
	li $s3, '\n'		# Loads register $s3 with decimal ASCII value for \n (10).
	li $s4, 'A'		# Loads register $s4 with decimal ASCII value for A (65).
	li $s5, 'Z'		# Loads register $s5 with decimal ASCII value for Z (90).
	li $s6, 'a'		# Loads register $s6 with decimal ASCII value for a (97).
	li $s7, 'z'		# Loads register $s7 with decimal ASCII value for z (122).
	
	lb $t0 , 0($s0)		# load ASCII address for Input string character into $t0.
	beq $t0, $s3, End 	# if the value equals the "\n" character end the program after printing output string.

UpperCase:
	blt  $t0, $s4, NextChar 	# If ASCII value is less than "A" then move to next character in string. Deals with the Space
					# who's ASCII value is 32.
	bgt $t0, $s5, LowerCase		# If the characters ASCII value is greater than "Z" it might be LowerCase so jump to that step.
	sub $t1, $t0, $s4		# Find the offset the Input Character is from "A" in decimal.
					# I'll then use this value to pick the correct Cypher letter to encrypt our message.
	
	add $s2, $s2, $t1 		# Finds correct letter address from our Cypher for the current UpperCase letter using offset. 
	lb  $t2, 0($s2)			# Loads $t2 with the correct encrypted ASCII letter.
	sb $t2, 0($s1)			# Stores the new encrypted ASCII letter into the output string.
	addi $s1, $s1, 1		# Move to next position in the Output string.
	j NextChar			# Move to next character in Input string.
	
LowerCase: 
	blt $t0, $s6, NextChar	# If ASCII value is less than ASCII value for "a" then it's not a letter. Move to NextChar in string.
	bgt $t0, $s7, NextChar	# If ASCII value is greater than ASCII value for "z" then it's not a letter. Move to NextChar in string.
	sub $t1, $t0, $s6	# Find the offset the Input Character is from "a" in decimal.
				# I'll then use this value to pick the correct Cypher letter to encrypt our message.
	
	add $s2, $s2, $t1 	# Finds correct letter address from our Cypher for the current LowerCase letter using offset.
	lb  $t2, 0($s2)		# Loads $t2 with the correct encrypted ASCII letter.
	sb $t2, 0($s1)		# Stores the new encrypted ASCII letter into the output string.
	addi $s1, $s1, 1	# Move to next position in the output string 
	
	j  NextChar		# Move to next character in Input string.
	
NextChar: 	
	la $s2, Cypher		# Load Cypher start address again as it has been changed.
	addi $s0, $s0, 1	# Move to next character in Input string. 
	j   SubRoutine 		# Jump back to beginning of Subroutine to Encrypt the next Input Character.

End:    
	sb $s3, 0($s1)		# adds a "\n" to output string
	li $v0, 4		# Call Instruction to print string
 	la, $a0, Input		# Load input string into $a0 to be printed
	syscall			# Call system to print
	li $v0, 4		# Call Instruction to print string
	la, $a0, Output		# Load output string into $a0 to be printed
	syscall			# Call system to print
	li $v0, 4		# Call Instruction to print string
	la, $a0, Cypher		# Load Cypher string into $a0 to be printed
	syscall			# Call system to print
	jr $ra # exit Subroutine
