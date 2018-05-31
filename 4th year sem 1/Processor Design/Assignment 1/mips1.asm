	.data # data goes in data segment
D1: 	.word 1,2,3,4,5 # data stored in words
D2: 	.word 6,7,8,9,0
 	.text # code goes in text segment
 	.globl main # must be global symbol
 	
main: 	la $t0, D1 # load address pseudo-instruction
 	la $t1, D2
 	lw $t2, 0($t0)
 	lw $t3, 4($t0)
 	lw $t4, 8($t0)
 	lw $t5, 12($t0)
 	lw $t6, 16($t0)
 
 	sw $t6, 0($t1)
 	sw $t5, 4($t1)
 	sw $t4, 8($t1)
 	sw $t3, 12($t1)
 	sw $t2, 16($t1)
 	#
 	
 	li $v0, 10 # system call for exit
 	syscall # Exit!