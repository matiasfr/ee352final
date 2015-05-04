.data 
data:    .word     0 : 1024      # (A) storage for 64x4 matrix of words
.text 

main:
	li $t0, 1244 # address
	li $t1, 2 # set 2
	
	# fill set 2 with 4 numbers
	li $s0, 32 # counter for array indexing (32 = 2 * (4*4))
	li $s1, 1234
	
	# store 1234 in 1st spot
	sw $s1, data($s0)
	addi $s0, $s0, 4
	addi $s1, $s1, 10
	
	# store 1244 in 2nd spot
	sw $s1, data($s0)
	addi $s0, $s0, 4
	addi $s1, $s1, 10
	
	# store 1254 in 3rd spot
	sw $s1, data($s0)
	addi $s0, $s0, 4
	addi $s1, $s1, 10
	
	# store 1264 in 4th spot
	sw $s1, data($s0)
	
	jal check_cache
	
	move $a0, $t0
	li  $v0, 1    
	syscall
	
	li $v0, 10    #syscall to exit
        syscall
	
check_cache:
# Method: Checks to see if address is in cache
#	Inputs: $t0 - memory address to check, $t1 - set #
#	Outputs: $t0, 1 if in cache, 0 if not in cache 
	move $t7, $ra # save S registers to stack 
	jal save_s
	move $ra, $t7
	
	mul  $t1, $t1, 16 # move to the right index in mem (row * rowSize)
	
	# loop thru and access all 4 blocks in set to see if it's there
	li $s3, 1 # product of differences (will be 0 if there's a hit)
	
	# s1 will hold entry i, s0 will hold difference i, s3 running product
	lw $s1, data($t1) # $s1 holds first entry
	sub $s0, $t0, $s1 # $s0 = $t0 - $s1 (s0 = memAddress - memAddressInTable)
	mul $s3, $s3, $s0 # multiply running product by difference
	addi $t1, $t1, 4  # increment pointer for array indexing
	
	lw $s1, data($t1) # load 2nd entry
	sub $s0, $t0, $s1 # subtract entry from address and store in s0
	mul $s3, $s3, $s0 # multiply running product by difference
	addi $t1, $t1, 4 # increment pointer for array indexing
	 
	lw $s1, data($t1) # store 3rd entry in s1
	sub $s0, $t0, $s1 # subtract entry from address and store in s0
	mul $s3, $s3, $s0 # multiply running product by difference
	addi $t1, $t1, 4 # increment pointer for array indexing
	
	lw $s1, data($t1) # store 4th entry in s1
	sub $s0, $t0, $s1 # subtract entry from address and store in s0
	mul $s3, $s3, $s0 # multiply running product by difference
	
	move $t0, $s3
	
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
