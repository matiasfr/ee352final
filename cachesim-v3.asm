	.data 
newline: .asciiz "\n"
space: .asciiz " "

.align 4
cache: .word 0:1024
cachehead: .word 0:64
.text 

main:

li $t1, 0 # temp var counter for loop iteration
li $t2, 1000 # exit condition loop #
li $t3, 0 #array access counter, moves by 4 each time
la $t0, cache
add $t3, $t3, $t0
mainloop:
    beq $t2, $t1, escape #at $t2 exit
    #----------------Main loop
    
    	#generate random number
    	jal generate_address
    	
    	#Map memory address
    	#test
	jal map
	
	#PRINT
	li  $v0, 1           # service 1 is print integer
    	move $a0, $t0
	syscall
    	
    	#check if A is in cache
    	
    	#add A to the cache
    
    	#add newline
   	li $v0, 4
  	la $a0, newline
    	syscall
    
    #-------------------
    addi $t1, $t1, 1 #increment loop counter
    j mainloop #jumps back to the top of loop
escape: #exit main loop
		
exitpogram: #EXIT THE PROGRAM	
li $v0, 10    #syscall to exit
syscall


#FUNCTIONS
map:
# Method: Computes $t0 % 64
#	Inputs: $t0, address
#	Outputs: $t0, set # (address % 64)
	move $t7, $ra # save S registers to stack 
	jal save_s
	move $ra, $t7
	
	li $s0, 64 # function body
	rem $t0, $t0, $s0 # mods 
	
	move $t7, $ra # load back s registers
	jal load_s
	move $ra, $t7
	
	jr $ra
	
generate_address:
# Method: Generates a memory address
#	Inputs: none
#	Outputs: $t0, 32-bit memory address (2-4KB) 
	move $t7, $ra # save S registers to stack 
	jal save_s
	move $ra, $t7
	
	li $a1, 4097 # 2-4KB addresses
	li $v0, 42   #random
	syscall 
	
	move $t0, $a0
	
	move $t7, $ra # load back s registers
	jal load_s
	move $ra, $t7
	
	jr $ra

save_s:
	addi $sp, $sp, -32 # alot space for 8 registers
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	jr $ra
	
load_s:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	add $sp, $sp, 32 # move stack pointer back 
	jr $ra
