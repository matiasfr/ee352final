.data 

.text 

main:
	jal generate_address
	
	move $a0, $t0
	li  $v0, 1           # service 1 is print integer
	syscall
	
	li $v0, 10    #syscall to exit
        syscall
	
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
