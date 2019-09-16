
########################################################################################################
# START OF PROG.S ######################################################################################
########################################################################################################
# COMP1521 19T2 assignment1
# Game of Life on a NxN grid MIPS version
# Written by Xingjian Li, z5190719, June/July 2019
# Written by XJ

# Requires (from `boardX.s'):
# - N (word): board dimensions
# - board (byte[N][N]): initial board state
# - newBoard (byte[N][N]): next board state

# Provides:
	.globl	main
	.globl	decideCell # decide a cell is dead or live
	.globl	neighbours # check for neighbours, return nn(number of neighbours)
	.globl	copyBackAndShow # update newBoard and print newBoard state
	
########################################################################################################
	.data
	.align 2 # for better CPU performance and avoid CPU crash

# public data
newline:
	.asciiz "\n"

# main data
str1:
	.asciiz "# Iterations: "

str2:
	.asciiz "=== After iteration "

str3:
	.asciiz " ===\n"

# copyBackAndShow data
str_live:
	.asciiz "#"

str_dead:
	.asciiz "."
	
########################################################################################################
	.text	
	.align 2 # for better CPU performance and avoid CPU crash	
	
	#---------------------- IMPORTANT NOTICE FROM XJ --------------------------------
	# all function variable registers are being used by the caller of main is assumed
	# however, three callee functions of main have no callee function
	# so, temporary variable registers will be used by three callee functions of main
	# and NO confilct register is expected in three callee functions of main

main:
	# main prologue
	# push return address onto stack
	addi    $sp, $sp, -4        
	sw  	$ra, ($sp)	
	# push function variable registers onto stack
	addi    $sp, $sp, -4
	sw		$s0, ($sp)
	addi    $sp, $sp, -4
	sw		$s1, ($sp)
	addi    $sp, $sp, -4
	sw		$s2, ($sp)
	addi    $sp, $sp, -4
	sw		$s4, ($sp)
	addi    $sp, $sp, -4
	sw		$s5, ($sp)
	addi    $sp, $sp, -4
	sw		$s6, ($sp)
	
	# main body
	# printf("# Iterations: ");
	la  	$a0, str1		
	li  	$v0, 4
	syscall
	# scanf ("%d", &maxiters);
	li		$v0, 5				
	syscall
	move	$s5, $v0 # max iterations

	# loop initialisations
	li   	$s0, 1 # iteration counter	
	li   	$s1, 0 # row index
	li   	$s2, 0 # column index
	li   	$s4, 0 # board cell index
	addi	$s5, $s5, 1 # halting iteration value
	lw   	$s6, N # board dimensions

# for (int n = 1; n <= maxiters; n++)
iter_loop:
	beq  	$s0, $s5, end_iter_loop
	li   	$s1, 0 # reset row index
	li   	$s4, 0 # board cell index

# for (int i = 0; i < N; i++)
row_loop:
	beq		$s1, $s6, end_row_loop
	li   	$s2, 0 # reset column index

# for (int j = 0; j < N; j++)
column_loop:
	beq		$s2, $s6, end_column_loop
	
	# int nn = neighbours (i, j);
	move 	$a1, $s1
	move	$a2, $s2
	move 	$a3, $s4
	jal 	neighbours # CALL neighbours
	nop # not necessary on MIPS simulator
	
	# newboard[i][j] = decideCell (board[i][j], nn);
	lb   	$a2, board($s4)
	move	$a3, $v1
	jal 	decideCell # CALL decideCell
	nop # not necessary on MIPS simulator
	sb   	$v1, newBoard($s4)
	addi	$s2, $s2, 1 # increment column index
	addi	$s4, $s4, 1 # increment board cell index
	j 		column_loop
	
# end of column loop
end_column_loop:
	addi	$s1, $s1, 1 # increment row index
	j  		row_loop

# end of row loop
end_row_loop:
	
	# printf("=== After iteration ");
	la  	$a0, str2		
	li  	$v0, 4
	syscall
	
	# print current iteration index
	move 	$a0, $s0
	li   	$v0, 1
	syscall
	
	# printf(" ===\n");
	la  	$a0, str3		
	li  	$v0, 4
	syscall

	jal  	copyBackAndShow # CALL copyBackAndShow
	nop # not necessary on MIPS simulator
	addi	$s0, $s0, 1 # increment iteration counter
	j    	iter_loop

# end of iteration loop
end_iter_loop:
	# main epilogue
	# restore function variable registers from stack
	lw 		$s6, 0($sp)
	addi    $sp, $sp, 4
	lw 		$s5, 0($sp)
	addi    $sp, $sp, 4
	lw 		$s4, 0($sp)
	addi    $sp, $sp, 4
	lw 		$s2, 0($sp)
	addi    $sp, $sp, 4
	lw 		$s1, 0($sp)
	addi    $sp, $sp, 4
	lw 		$s0, 0($sp)
	addi    $sp, $sp, 4
	# restore return address from stack 
	lw  	$ra, 0($sp)
	addi    $sp, $sp, 4
	# return 0
	li		$v0, 0
	jr   	$ra

########################################################################################################
decideCell: 
# current cell status in $a2, nn(number of neighbours) in $a3
# return new cell status in $v1
	# decideCell prologue
	# push return address onto stack
	addi    $sp, $sp, -4        
	sw  	$ra, 0($sp)	
	
	# decideCell body
	beq 	$zero, $a2, is_dead	  	

is_live:
	# if (nn == 2 || nn == 3) -> survive
	li 		$t0, 2
	beq 	$t0, $a3, survive
	li 		$t0, 3
	beq 	$t0, $a3, survive
	# if (nn < 2 || nn > 3) -> decease
	blt		$t0, $a3, decease
	li 		$t0, 2
	blt		$a3, $t0, decease
	
is_dead:
	# if (nn == 3) -> reproduce
	li 		$t0, 3
	beq 	$t0, $a3, reproduce
	# else -> rip
decease:
	li 		$v1, 0
	j 		decision

reproduce:
survive:
	li 		$v1, 1

decision:
	# decideCell epilogue
	# restore return address from stack and return to caller
	lw  	$ra, 0($sp)
	addi    $sp, $sp, 4
	jr   	$ra

########################################################################################################
neighbours: 
# row index in $a1, column index in $a2, board cell index in $a3
# return nn(number of neighbours) in $v1
	# neighbours prologue
	# push return address onto stack
	addi    $sp, $sp, -4        
	sw  	$ra, 0($sp)	
	
	# neighbours body
	# loop initialisations
	li		$v1, 0 # nn
	li		$t0, 2 # loop halting value
	li		$t1, -1 # x
	li		$t2, -1 # y
	lw   	$t3, N
    addi 	$t3, $t3, -1 # N - 1
	
x_loop:
	beq 	$t1, $t0, end_x_loop
	li		$t2, -1 # reset y

y_loop:
	beq 	$t2, $t0, end_y_loop

	# if (i + x < 0 || i + x > N - 1)
	li   	$t4, 0
	add  	$t4, $a1, $t1
	bltz 	$t4, continue_y_loop
	bgt  	$t4, $t3, continue_y_loop
	
	# if (j + y < 0 || j + y > N - 1)
	li   	$t4, 0
	add  	$t4, $a2, $t2 
	bltz 	$t4, continue_y_loop
	bgt  	$t4, $t3, continue_y_loop
	
	# if (x == 0 && y == 0)
	li   	$t4, 0
	bne		$t4, $t1, is_neighbour
	bne		$t4, $t2, is_neighbour
	j 		continue_y_loop

# if (board[i + x][j + y] == 1) nn++
is_neighbour:
	# neighbour cell index = (x * N) + y + board cell offset difference
	lw   	$t5, N
	mul  	$t5, $t1, $t5
	add  	$t5, $t5, $t2
	add  	$t5, $t5, $a3
	lb   	$t6, board($t5)
	li 		$t7, 1
	bne  	$t6, $t7, continue_y_loop
    addi 	$v1, $v1, 1

continue_y_loop:
	addi 	$t2, $t2, 1 # increment y
	j 		y_loop

end_y_loop:
	addi 	$t1, $t1, 1 # increment x
	j 		x_loop

end_x_loop:
	# neighbours epilogue
	# restore return address from stack and return to caller
	lw  	$ra, 0($sp)
	addi    $sp, $sp, 4
	jr   	$ra
	
########################################################################################################
copyBackAndShow:
	# copyBackAndShow prologue
	# push return address onto stack
	addi    $sp, $sp, -4        
	sw  	$ra, 0($sp)	
	
	# copyBackAndShow body
	# loop initialisations
	li 		$t1, 0 # row index
	li 		$t2, 0 # column index
	lw   	$t3, N # board dimensions
	li 		$t4, 0 # board cell index

# for (int i = 0; i < N; i++)
row_loop_c:
	beq		$t1, $t3, end_row_loop_c
	li   	$t2, 0 # reset column index
	
# for (int j = 0; j < N; j++)
column_loop_c:
	beq		$t2, $t3, end_column_loop_c
	# board[i][j] = newboard[i][j];
	lb   	$t5, newBoard($t4)
	sb   	$t5, board($t4)
	# print cell status
	addi	$t2, $t2, 1 # increment column index
	addi	$t4, $t4, 1 # increment board cell index
	beq 	$zero, $t5, print_dead

# putchar ('#')
print_live:
	la		$a0, str_live
	li   	$v0, 4
	syscall
	j		column_loop_c

# putchar ('.')
print_dead:
	la   	$a0, str_dead
	li   	$v0, 4
	syscall
	j		column_loop_c	

# end of column loop
end_column_loop_c:
	# print newline
	la   	$a0, newline
	li   	$v0, 4
	syscall
	
	addi	$t1, $t1, 1 # increment row index
	j  		row_loop_c

# end of rows
end_row_loop_c:
	# copyBackAndShow epilogue
	# restore return address from stack and return to caller
	lw  	$ra, 0($sp)
	addi    $sp, $sp, 4
	jr   	$ra
	
########################################################################################################
# END OF PROG.S ########################################################################################
########################################################################################################
