.data 
cache:    .word     0 : 1024      # (A) storage for 64x4 matrix of words
cachehead: .word 0:64
.text 

main:
	li $t0, 9999 # address
	li $t1, 2    # set 2
	
	# fill set 2 with 4 numbers
	li $s0, 32 # counter for array indexing (32 = 2 * (4*4))
	li $s1, 1234
	
	# store 1234 in 1st spot
	sw $s1, cache($s0)
	addi $s0, $s0, 4
	addi $s1, $s1, 10
	
	# store 1244 in 2nd spot
	sw $s1, cache($s0)
	addi $s0, $s0, 4
	addi $s1, $s1, 10
	
	# store 1254 in 3rd spot
	sw $s1, cache($s0)
	addi $s0, $s0, 4
	addi $s1, $s1, 10
	
	# store 1264 in 4th spot
	sw $s1, cache($s0)
	
	# store head counter (4) in cachehead at index 2
	li $s1, 12
	li $s2, 8 # 8 = index 2 * size 4
	sw $s1, cachehead($s2)
	
	jal add_to_cache
	
	move $a0, $t0
	li  $v0, 1    
	syscall
	
	li $v0, 10    #syscall to exit
        syscall
	
add_to_cache:
# Method: Adds memory address into cache
#	Inputs: $t0 - memory address to check, $t1 - set #
#	Outputs: none
	move $t7, $ra # save S registers to stack 
	jal save_s
	move $ra, $t7
	
	# s0 holds index
	# s1 holds cache head
	mul  $s0, $t1, 16 # move to the right index in mem (row * rowSize)
	# move to right spot (LRU)
	mul $s4, $t1, 4
	lw $s1, cachehead($s4)
	add $s0, $s0, $s1
	
	# put in cache at head spot
	sw $t0, cache($s0)
	
	# increment cache head
	addi $s1, $s1, 4
	rem $s1, $s1, 16
	sw $s1, cachehead($s4)
	
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
