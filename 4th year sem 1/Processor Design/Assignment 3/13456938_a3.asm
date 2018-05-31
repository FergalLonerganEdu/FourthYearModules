# Fergal Lonergan - 13456938 - Processor Design - COMP30080 - Assignment 3 - Ulam Spiral
	.data 
Display:.word 0:65536
Numbers:  .space 65025     		#Creates a binary array for our prime and not prime numbers from 0 - 62025
	.eqv White 0x00FFFFFF		#Everywhere I type White it will substitute it for the hex value for the colour white.
	.eqv Black 0x00000000		#Everywhere I type Black it will substitute it for the hex value for the colour Black.
	.eqv Blue  0x000000FF		#Everywhere I type Blue it will substitute it for the hex value for the colour Blue.
	.eqv MaxNumber 65025		#Everywhere I type MaxNumbers it will substitute it for the max number to be texted for primes
	.eqv RootMax 253		#Everywhere I type RootMax it will substitute it for the square root of 62025. 
					#Max Number we'll need to check is 251 as the sqrt of 62025 is 255 so any number above that will
					#already have been checked, and seeing as 252,253,254 and 255 aren't prime, anything they are  
					#multiples of will already have been set to not prime by their factors for using the sieve method chosen
	.eqv MaxDisplay 65536		#Everywhere I type MaxDisplay it will substitute it for the max elements in our BitMap display
	.eqv TopLeft 0x10010000		#Everywhere I type TopLeft it will substitute it for the address of the Topleft bit in the BitMap
	.eqv Centre 0x10030200		#Everywhere I type Centre it will substitute it for thecentre of our Bitmap display in hex
	.eqv X 4			#The value needed to shift in the X direction. 4 as we want to move right first.
	.eqv Y -1024			#The value needed to shift in the Y direction. -1024 as we want to move up first.
	.align 2
	.text
	.globl main
main:					#Main contains the subroutines. 

jal Seive				#Run the Seive subroutine
jal LoadDisplay				#Run the LoadDisplay subroutine
jal ClearScreen				#Run the ClearScreen subroutine
jal DisplayBitMap			#Run the DispayBitMap subroutine

exit:
li $v0, 10	 #System call for exit  
syscall

#This is my seive which will create a binary array called numbers where 1 denotes a prime and 0 a non prime	
Seive:
la $s6, Numbers		#Loads address of the first element in the binary array of numbers into $s6
sb $zero, 0($s6)	#First two elements [0 and 1] are not prime.
sb $zero, 1($s6)
li $t1, 0		#Stores the integer 0 into $t1. This will be used as a counter.
li $t4, 1		#Stores the integer 1 into $t4. Will be used to fill binary Numbers array	

# Sets entire binary array Numbers to 1. 																						
SetTo1:	add $t0, $s6, $t1       #iterates to next address in our Numbers array.
	sb  $t4, 0($t0)		#Set each element of Number to 1 for each loop iteration.
	addi $t1, $t1, 1	#Adds 1 to $t1 each loop iteration, acting as a loop counter.
	blt $t1, MaxNumber, SetTo1	#Loop will keep iterating until our entire number array is a binary array of 1s.
 
	li $t3, RootMax		#Loads the integer 253 (sqrt(62025)=255, 251 is max prime number needed to run seive). 
				#This is the max number that needs to be checked using the Seive fo Eratosthenes method for primes
	li $t6, 2 		#Loads the integer 2 into $t6. This will be our current factor. we want to start checking primes from 2

#Checks to see if the number is prime or not, if not it will pass to not prime which will change corresponding binary value to 0	
CheckPrime:  	
					#The sieve will be perfomed over the 65025 bytes for each factor from 2-255.
	add $t1, $s6, $t6 		#Stores address of current factor in Numbers array into $t1
	lb $t0, 0($t1) 			#Loads the byte the value at $t1 into $t0.
	bne $t0, $t4, NextFactor	#Branches to "NextFactor" if element is not prime. as it's redundant checking its multiples that 
					#are already set to not prime by the factors of current element.			
	mul $t7, $t6, $t6		#Stores the value of our current "factor" squared into register $t7 
					#ie [4, 9, 16, 25... etc for 2, 3, 4, 5... respectively]. 
					
#Changes the values of numbers that are not prime to 0
NotPrime:			
	add $t8, $t7, $s6		#Adds current number to Numbers start address to get the new address of current element.
	sb $zero, 0($t8)		#Stores a 0 in the new address location to indicate number isn't a Prime.
	bge $t7, MaxNumber, NextFactor	#If the current number becomes greater than or equal to 65025, our MaxNumber, branch to "Next".
	add $t7, $t7, $t6		#While the current number < 65025, add t6 to t7 in preparation for another iteration. 
	j NotPrime			#Jump to L3 to iterate again.
	
NextFactor:				#Once the end of the Numbers array is reached [address does not contain 1]
	beq $t6, $t3, End		#if our factors reaches 251, we have checked all possibilities. so prime seive is complete
	addi $t6, $t6, 1		#While it has not tested every factor from 2-251, add 1 to factors and jump back to CheckPrime.
	j CheckPrime
	
End:
jr $ra										
															
# Following code clears our bitmap display to white and then fills in primes. it also sets the display bit correcponding to the number 1 
# blue so it is easy to find when testing if the corrct display has been shown

LoadDisplay:			
li $t0, 1 			#Register to hold value to move in X direction on display.
li $t1, 1			#Register to hold value to move in Y direction on display.
				#Above registers increase by 1 for each spiral loop so that we dont overwrite our display.
li $s0, 0			#Counter to ensure all pixels in diplay have been set to correct colour.
li $s1, MaxDisplay		#The Number of pixels in the bitmap display. (256^2)
li $s4, TopLeft			#Topleft pixel of bitmap display.
la $s6, Numbers			#Load address of the first element in the binary array Numbers
addi $s6, $s6, 2		#Corrected address

jr $ra

ClearScreen:			#This loop sets the bitmap display to white.
li $s5, White			#Hex value of white
sw $s5, 0($s4)			#Set current pixel to white
addi $s4, $s4, 4		#Iterate pixel counter
addi $s0, $s0, 1		#Increase pixel counter
bne $s0, $s1, ClearScreen	#If we haven't reached the last pixel in the display, iterate to next pixel
addi $s0, $zero, 0		#If entire display is white move set pixel counter to 0 to be reused below.

CentreBlue: # Set the corresponding pixel display for integer 1 at centre of display blue so it's easy to find
li $s7, Centre			#Center of the 256^2 bitmap display.
li $t6, Blue			#Hex value of blue
sw $t6, 0($s7)			#Set the corresponding pixel display for integer 1 at centre of display blue so it's easy to find
li $s5, Black 			#Change $s5 to Hex value of black 

jr $ra

DisplayBitMap:
li $s2, X			#Load the value needed to move in the x direction one pixel (an offset of 4)
li $s3, Y			#Load the value needed to move in the y direction one pixel (an offset of 1024)

FillDisplay:#Fill display in X and Y direction with correct colours depending on whether theyre prime or not
li $t9, 0 			#Reset counter for how many pixels we've moved in x direction to 0 each iteration
jal XDirection			#Jump to "XDirection" subroutine.

li $t9, 0 			#Reset counter for how many pixels we've moved in y direction to 0 each iteration
jal YDirection			#Jump to "YDirection" subroutine.

j FillDisplay# Run program until entire display is filled
jr $ra
 
XDirection:# Subroutine to fill in pixels in the X plane.
	lb $t7, 0($s6)			#Loads byte value of current element in Numbers array.
	add $s7, $s7, $s2		#Move in x direction 1 pixel on display
	beqz $t7, NextX			#If element value is zero, ie not prime, move to next value in X direction. 
	sw $s5, 0($s7)			#if the corresponding number is a prime make the pixel black.
	j NextX

	NextX:
	addi $s6, $s6, 1		#Move to next element in Numbers array
	addi $s0, $s0, 1		#Increase the numbers of pixels checked
	beq $s0, $s1, exit 		#if it has checked the entire display exit the program
	addi $t9, $t9, 1		#Increase counter that tells you how many pixels to check in this section of the spiral.
	bne $t9, $t0, XDirection	#Keep checking pixels until all the pixels in this direction have been checked.
	addi $t0, $t0, 1		#Increase the amount of pixels to be processed in opposite direction by 1 so that you wont overlap
	mul $s2, $s2, -1 		#Multiply by -1 so now the spiral will move in the opposite direction
	
jr $ra

YDirection:# Subroutine to fill in pixels in the Y plane.
	lb $t7, 0($s6)			#Loads byte value of current element in Numbers array.
	add $s7, $s7, $s3		#Move in x direction 1 pixel on display
	beq $t7, $zero, NextY		#If element value is zero, ie not prime, move to next value in Y direction. 
	sw $s5, 0($s7)			#if the corresponding number is a prime make the pixel black.
	j NextY	#move to next element in Y direction

NextY:
	addi $s6, $s6, 1		#Move to next element in Numbers array
	addi $s0, $s0, 1		#Increase the numbers of pixels checked
	beq $s0, $s1, exit 		#if it has checked the entire display exit the program
	addi $t9, $t9, 1		#Increase counter that tells you how many pixels to check in this section of the spiral.
	bne $t9, $t1, YDirection	#Keep checking pixels until all the pixels in this direction have been checked.
	addi $t1, $t1, 1		#Increase the amount of pixels to be processed in opposite direction by 1 so that you wont overlap
	mul $s3, $s3, -1		#Multiply by -1 so now the spiral will move in the opposite direction
	
jr $ra