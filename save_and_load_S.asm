.data 

.text 

main:
	li $s0, 0
	li $s1, 1
	li $s2, 2
	li $s3, 3
	li $s4, 4
	li $s5, 5
	li $s6, 6
	li $s7, 7
	li $ra, 1234
	move $t7, $ra
	jal save_s
	move $ra, $t7
	li $s0, 99
	# function contents
	li  $v0, 1
    	move $a0, $s0
	syscall
	
	move $t7, $ra
	jal load_s
	move $ra, $t7
	
	li  $v0, 1
    	move $a0, $s0
	syscall
	
	li $v0, 10    #syscall to exit
        syscall
        
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
	