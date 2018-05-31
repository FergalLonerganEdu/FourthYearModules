.data
Numbers: .space 3996 #(999*4=3996) 2-1000 is 999 elements
Primes: .space 672#(168*4 number of primes between 2 and 1000 inclusive)
 .text # code goes in text segment
 .globl main # must be global symbol
main: 
	la $s0, Numbers
	la $s1, Primes		# Load arrays addresses in to registers
	li $t0, 1			# Load a register with value 1 this indexes the first element of our array
	
SetLoop:
	li $t1, 0			# Set n back to 0 for new value of i
	addi $t0, $t0, 1		# Increase value of i by one
	
PrimeCheck: 
	#in C code algorithm is i^2+n*i. if this equals a number it is not prime
	mul $t2, $t0, $t0		# i*i
	mul $t3, $t1, $t0		# n*i
	add $t4, $t3, $t2		# i*i + n*i 
	
	sll $t4, $t4, 2			# Shift Left Logical to multiply by 4 for bytes in array
	add $t5, $s0, $t4		
	
	lw $t6, 0($t5)			# Load word (element from our array) from memory
	addi $t6, $t6,1			# Change value from 0 to 1 as it is not prime. 
	sw $t6, 0($t5)			# Store element back in to memory
	
	addi $t1, $t1, 1		# Increment n
	

	ble $t4, 4000, PrimeCheck		# Continue until all 1000 elements have been checked
	ble $t0, 32, SetLoop		# sqrt of 1000 is 31.something therefore iterate until get to 32 as 32^2 will cover all numbers
	
	#### Now we will store the values we calculated to be prime numbers in Primes
	
	li $t0, 0		# Set registers back to 0 so we can iterate through array again
	li $t1, 0
	
SortPrime: 
	sll $t1, $t0, 2			
	add $t2, $s0, $t1		
		
	lw $t4, 0($t2)			# LoadWrods from array t2
	
	bnez  $t4, NotPrime
	add $s1, $s1, 4			
  	sw $t0, 0($s1)			# If word value is a zero then this is a prime and is stored in Primes
  	
NotPrime:	
	addi $t0, $t0, 1		# Counter to determine index of element
	bne $t0, 1000, SortPrime	# Continue until counter reaches 1000

		
 li $v0, 10 # system call for exit
 syscall # Exit!
