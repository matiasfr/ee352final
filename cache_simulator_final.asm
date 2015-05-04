	.data 
newline: .asciiz "\n"
space: .asciiz " "

.align 4
cache: .word 0:1024
cachehead: .word 0:256
.text 

main:
#t0 Memory address
#t1 Set number
#t2 boolean for cache hit (0 if hit, other if miss)
#t3 hit counter
#t4 miss counter
#t5 Main loop counter
#t6 exit main loop condition
#t7 nested return address (DO NOT CHANGE)
#Initialize cache values to 0
li $t3, 0
li $t4, 0#memory location
li $t5, 0 # temp var counter for loop iteration
li $t6, 256 #exit condition
loop1:
beq $t6, $t5, end1
sw $t3, cache($t4)
addi $t4, $t4, 4
addi $t5, $t5, 1 #increment loop counter
j loop1 #jumps back to the top of loop
end1:#initialize cache-head
li $t3, 0
li $t4, 0#memory location
li $t5, 0 # temp var counter for loop iteration
li $t6, 64 #exit condition
loop2:
beq $t6, $t5, end2
sw $t3, cachehead($t4)
addi $t4, $t4, 4
addi $t5, $t5, 1 #increment loop counter
j loop2 #jumps back to the top of loop
end2:


#initilization
la $t0, cache #load cache address into t0
li $t1, 0 #initialize set number
li $t2, 0 #initialize boolean
li $t3, 0#set hits to 0
li $t4, 0#set misses to 0
li $t5, 0 # temp var counter for loop iteration
li $t6, 10000 # exit condition loop/ number of iterations

mainloop:
    beq $t6, $t5, escape #at $t2 exit
    #----------------Main loop
    
    	#generate random number !!!
    	jal generate_address
    	#Map memory address !!!
    	#test
	jal map
	#check if A is in cache !!!
	jal check_cache
	
	#TESTPRINTS......
	#PRINT memory address
	#li  $v0, 1  
    	#move $a0, $t0
	#syscall
	#PRINT newline
   	#li $v0, 4
  	#la $a0, newline
    	#syscall
	#PRINT set number
	#li  $v0, 1 
    	#move $a0, $t1
	#syscall
	#PRINT newline
   	#li $v0, 4
  	#la $a0, newline
    	#syscall
	#PRINT cache hit?
	#li  $v0, 1 
    	#move $a0, $t2
	#syscall
    	#................
    	
    	beqz $t2, hit #branch to hit function if bool is 0
    	addi $t4, $t4, 1 # increment miss counter
    	jal add_to_cache
    	j end_of_loop
	hit:
	addi $t3, $t3, 1 #increment hit counter
	
    #-------------------
    end_of_loop:
    addi $t5, $t5, 1 #increment loop counter
    j mainloop #jumps back to the top of loop
escape: #exit main loop

#FINAL OUTPUT
	#PRINT hits
	li  $v0, 1 
    	move $a0, $t3
	syscall
	#PRINT newline
   	li $v0, 4
  	la $a0, newline
    	syscall
    	#PRINT misses
	li  $v0, 1 
    	move $a0, $t4
	syscall
		
		
		
		
exitprogram: #EXIT THE PROGRAM	
li $v0, 10    #syscall to exit
syscall


#FUNCTIONS

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
	
check_cache:
# Method: Checks to see if address is in cache
#	Inputs: $t0 - memory address to check, $t1 - set #
#	Outputs: $t2, 1 if in cache, 0 if not in cache 
	move $t7, $ra # save S registers to stack 
	jal save_s
	move $ra, $t7
	
	mul  $s4, $t1, 16 # move to the right index in mem (row * rowSize)
	
	# loop thru and access all 4 blocks in set to see if it's there
	li $s3, 1 # product of differences (will be 0 if there's a hit)
	
	# s1 will hold entry i, s0 will hold difference i, s3 running product
	lw $s1, cache($s4) # $s1 holds first entry
	sub $s0, $t0, $s1 # $s0 = $t0 - $s1 (s0 = memAddress - memAddressInTable)
	mul $s3, $s3, $s0 # multiply running product by difference
	addi $s4, $s4, 4  # increment pointer for array indexing
	
	lw $s1, cache($s4) # load 2nd entry
	sub $s0, $t0, $s1 # subtract entry from address and store in s0
	mul $s3, $s3, $s0 # multiply running product by difference
	addi $s4, $s4, 4 # increment pointer for array indexing
	 
	lw $s1, cache($s4) # store 3rd entry in s1
	sub $s0, $t0, $s1 # subtract entry from address and store in s0
	mul $s3, $s3, $s0 # multiply running product by difference
	addi $s4, $s4, 4 # increment pointer for array indexing
	
	lw $s1, cache($s4) # store 4th entry in s1
	sub $s0, $t0, $s1 # subtract entry from address and store in s0
	mul $s3, $s3, $s0 # multiply running product by difference
	
	move $t2, $s3
	
	move $t7, $ra # load back s registers
	jal load_s
	move $ra, $t7
	
	jr $ra
map:
# Method: Computes $t0 % 64
#	Inputs: $t0, address
#	Outputs: $t1, set # (address % 64)
	move $t7, $ra # save S registers to stack 
	jal save_s
	move $ra, $t7
	
	li $s0, 64 # function body
	rem $t1, $t0, $s0 # mods 
	
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
