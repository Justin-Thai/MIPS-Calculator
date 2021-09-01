.include "./cs47_proj_macro.asm"
.text
.globl au_logical

# Justin Thai
# CS 47, Section 1
# 2 December 2019

# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
	# Store RTE - 5 * 4 = 20 bytes
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	# Body
	beq	$a2, '+', add_logical
	beq	$a2, '-', sub_logical
	beq	$a2, '*', mul_signed
	beq	$a2, '/', div_signed
	j	au_logical_return
# Addition and Subtraction Procedures
add_sub_logical: 
	extract_nth_bit($t0, $a0, $s0)		# $t0 = $a0[I] 			
	extract_nth_bit($t1, $a1, $s0)		# $t1 = $a1[I]
	# Computation of Y
	xor	$t2, $t0, $t1			# A xor B
	xor	$t3, $t2, $a2			# Result of Y
	# Computation of C
	and	$t4, $t0, $t1			# A and B
	and	$t5, $t2, $a2			# C and (A xor B)			
	or	$a2, $t4, $t5			# Result of C
	# Storing values to $v0(Sum) and $v1(Carry)
	la	$v1, ($a2)			# C is stored in $v1
	insert_to_nth_bit($v0, $s0, $t3, $t9)	# S[I] = Y
	addi	$s0, $s0, 1			# I = I + 1
	bne  	$s0, 32, add_sub_logical	# I == 32?
	jr	$ra
add_logical:
	# Store RTE - 6 * 4 = 24 bytes
	addi	$sp, $sp, -28
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$a2, 12($sp)
	sw	$s0, 8($sp)
	addi	$fp, $sp, 28
	# Preparing for add_sub_procedure
	la	$s0, ($zero)		# Initialization of I (Counter)
	la	$v0, ($zero)		# Initialization of S (Sum)
	la	$a2, ($zero)		# Initialization of C (Carry)
	jal	add_sub_logical	
	# Restore RTE
	lw	$fp, 28($sp)
	lw	$ra, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$a2, 12($sp)
	lw	$s0, 8($sp)
	addi	$sp, $sp, 28
	jr	$ra
sub_logical:
	# Store RTE - 6 * 4 = 24 bytes
	addi	$sp, $sp, -28
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$a2, 12($sp)
	sw	$s0, 8($sp)
	addi	$fp, $sp, 28
	# Preparing for add_sub_procedure
	la	$s0, ($zero)		# Initialization of I (Counter)
	la	$v0, ($zero)		# Initialization of S (Sum)
	la	$a2, ($zero)		# Initialization of C (Carry)
	not	$a2, $a2			
	not	$a1, $a1		# $a1 = ~$a1
	jal	add_sub_logical
	# Restore RTE
	lw	$fp, 28($sp)
	lw	$ra, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$a2, 12($sp)
	lw	$s0, 8($sp)
	addi	$sp, $sp, 28
	jr	$ra
# Two's Complement Procedures
twos_complement:
	# Store RTE - 5 * 4 = 20 bytes
	addi	$sp, $sp, -20
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1, 8($sp)
	addi	$fp, $sp, 20
	not	$a0, $a0		# $a0 is complemented
	la	$a1, ($zero)		# Loading $a1 with 0x1 in order to use add_logical
	li	$a1, 1	
	jal	add_logical		# ~$a0 + 1
	# Restore RTE
	lw	$fp, 20($sp)
	lw	$ra, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1, 8($sp)
	addi	$sp, $sp, 20
	jr	$ra
twos_complement_if_neg:
	# Store RTE - 3 * 4 = 12 bytes
	addi	$sp, $sp, -16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a0, 8($sp)
	addi	$fp, $sp, 16
	blt	$a0, $zero, twos_complement_negative	# Checks to see if value of $a0 is negative
	j	twos_complement_positive
twos_complement_negative:
	jal	twos_complement		# Changing $a0 to 2's complement
	la	$a0, ($v0)		# $a0 is loaded with $v0 from twos_complement 
twos_complement_positive:
	la	$v0, ($a0)		# $v0 is loaded with value of $a0
	# Restore RTE
	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$a0, 8($sp)
	addi	$sp, $sp, 16
	jr	$ra
twos_complement_64bit:
	# Store RTE - 6 * 4 = 24 bytes
	addi	$sp, $sp, -28
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$s0, 12($sp)
	sw	$s1, 8($sp)
	addi	$fp, $sp, 28

	not	$a0, $a0		# $a0 and $a1 are inverted
	not	$a1, $a1
	la	$s0, ($a1)		# Value of $a1 is temporarily saved to $s0
	li	$a1, 1			# $a1 is loaded with 0x1 
	jal	add_logical		# Calculates Lo part of 2's complement 64-bit	
	la	$s1, ($v0)		# Value of $v0 is temporarily saved to $s1  
	la	$a0, ($v1)		# Carry bit from add_logical is loaded as an argument	
	la	$a1, ($s0)		# Original value of $a1 is brought back
	jal	add_logical		# Calculates Hi part of 2's complement
	la	$v1, ($v0)		# Hi and Lo of 2's complement 64-bit is stored into $v1 and $v0 
	la	$v0, ($s1)
	# Restore RTE	
	lw	$fp, 28($sp)
	lw	$ra, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$s0, 12($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 28
	jr	$ra
# Bit Replicator Procedure			
bit_replicator:	
	# Store RTE - 3 * 4 = 12 bytes
	addi	$sp, $sp, -16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a0, 8($sp)
	addi	$fp, $sp, 16
	bnez	$a0, bit_replicator_inverse	# Checks to see if $a0 contains 0x1
	la	$v0, ($zero)			# $a0 contains 0x0 -> Changes $v0 to $zero
	j	bit_replicator_end
bit_replicator_inverse:
	la	$v0, ($zero)			# Changes $v0 to 0xFFFFFFFF
	not	$v0, $v0
bit_replicator_end:
	# Restore RTE	
	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$a0, 8($sp)
	addi	$sp, $sp, 16
	jr	$ra
# Multiplication Procedures
mul_unsigned:
	# Store RTE - 11 * 4 = 44 bytes
	addi	$sp, $sp, -48
	sw	$fp, 48($sp)
	sw 	$ra, 44($sp)
	sw	$a0, 40($sp)
	sw	$a1, 36($sp)
	sw	$a2, 32($sp)
	sw	$s0, 28($sp)
	sw	$s1, 24($sp)
	sw	$s2, 20($sp)
	sw	$s3, 16($sp)
	sw	$s4, 12($sp)
	sw	$s5, 8($sp)
	addi	$fp, $sp, 48
	# Preparation for mul_unsigned_loop	
	la	$s0, ($zero)			# Initialiation of I (Counter)
	la	$s1, ($zero)			# Initialiation of H (Hi)
	la	$s3, ($a1)			# Initialiation of L (Multiplier)
	la	$s2, ($a0)			# Initialiation of M (Multiplicand)
mul_unsigned_loop:
	extract_nth_bit($t4, $s3, $zero)	# $t4 = L[0]
	la 	$a0, ($t4)			# L[0] is moved to $a0 for bit_replicator
	jal	bit_replicator
	la	$s4, ($v0)			# R = {32{L[0]}}
	and	$s5, $s2, $s4			# X = M & R
	# Preparing for H = H + X
	la	$a0, ($s5)			# $a0 = X 
	la	$a1, ($s1)			# $a1 = H
	jal	add_logical
	la	$s1, ($v0)			# H = H + X
	srl	$s3, $s3, 1			# L = L >> 1
	extract_nth_bit($t7, $s1, $zero)	# H[0]	
	li	$t8, 31					
	insert_to_nth_bit($s3, $t8, $t7, $t9)	# L[31] = H[0]
	srl	$s1, $s1, 1			# H = H >> 1
	addi	$s0, $s0, 1			# I = I + 1
	bne  	$s0, 32, mul_unsigned_loop	# I == 32?
	la	$v0, ($s3)			# L is stored into $v0 (Lo)
	la	$v1, ($s1)			# H is stored into $v1 (Hi)
	# Restore RTE	
	lw	$fp, 48($sp)
	lw 	$ra, 44($sp)
	lw	$a0, 40($sp)
	lw	$a1, 36($sp)
	lw	$a2, 32($sp)
	lw	$s0, 28($sp)
	lw	$s1, 24($sp)
	lw	$s2, 20($sp)
	lw	$s3, 16($sp)
	lw	$s4, 12($sp)
	lw	$s5, 8($sp)
	addi	$sp, $sp, 48
	jr	$ra
mul_signed:	
	# Store RTE - 10 * 4 = 40 bytes
	addi	$sp, $sp, -36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$a0, 28($sp)
	sw	$a1, 24($sp)
	sw	$s0, 20($sp)
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3, 8($sp)
	addi	$fp, $sp, 36
	
	la	$s0, ($a0)			# $a0 is stored into $s0 to preserve value
	la	$s1, ($a1)			# $a1 is stored into $s1 to preserve value
	la	$s2, ($a0)			# N1 = $a0	
	la	$s3, ($a1)			# N2 = $a1
	# Changing arguments to 2's complement (if needed)
	jal	twos_complement_if_neg		
	la	$s2, ($v0)			# Outcome of twos_complement_if_neg is loaded to N1
	la	$a0, ($s3)			# N2 is stored into $a0
	jal	twos_complement_if_neg
	la	$s3, ($v0)			# Outcome of twos_complement_if_neg is loaded to N2
	# Preparing for multiplication step
	la	$a0, ($s2)			# N1 is loaded to $a0 
	la	$a1, ($s3)			# N2 is loaded to $a1
	# Muliplication step
	jal	mul_unsigned			# N1 and N2 are multiplied with each other
	la	$a0, ($v0)			# Lo is loaded to $a0
	la	$a1, ($v1)			# Hi is loaded to $a1
	# Determining sign (S) of multiplication result
	li	$t2, 31		
	extract_nth_bit($t0, $s0, $t2)		# $t0 = $a0[31]
	extract_nth_bit($t1, $s1, $t2)		# $t1 = $a1[31]
	xor	$t3, $t0, $t1 	 		# Result of S
	bne	$t3, 1, mul_signed_end		# Changing product to 2's complement if S is negative 
	jal	twos_complement_64bit
mul_signed_end:
	# Restore RTE	
	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$a0, 28($sp)
	lw	$a1, 24($sp)
	lw	$s0, 20($sp)
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3, 8($sp)
	addi	$sp, $sp, 36
	jr	$ra
# Division Procedures
div_unsigned:
	# Store RTE - 10 * 4 = 40 bytes
	addi	$sp, $sp, -44
	sw	$fp, 44($sp)
	sw 	$ra, 40($sp)
	sw	$a0, 36($sp)
	sw	$a1, 32($sp)
	sw	$a2, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	sw	$s2, 16($sp)
	sw	$s3, 12($sp)
	sw	$s4, 8($sp)
	addi	$fp, $sp, 44
	# Preparation for div_unsigned_loop
	la	$s0, ($zero)			# Initialiation of I (Counter)
	la	$s1, ($zero)			# Initialiation of R (Remainder)
	la	$s2, ($a0)			# Initialization of Q (Dividend)
	la	$s3, ($a1)			# Initialization of D (Divisor)
div_unsigned_loop:	
	sll	$s1, $s1, 1			# R = R << 1
	li	$t0, 31			
	extract_nth_bit($t1, $s2, $t0)		# $t1 = Q[31]
	insert_to_nth_bit($s1, $zero, $t1, $t9)	# R[0] = Q[31]
	sll	$s2, $s2, 1			# Q = Q << 1
	la	$a0, ($s1)			# $a0 = R
	la	$a1, ($s3)			# $a1 = D
	jal	sub_logical
	la	$s4, ($v0)			# S = R - D
	blt	$s4, $zero, div_loop_end 	# S < 0?
	la	$s1, ($s4)			# R = S
	li	$t2, 1
	insert_to_nth_bit($s2, $zero, $t2, $t9)	# Q[0] = 1
div_loop_end:
	addi	$s0, $s0, 1			# I = I + 1
	bne	$s0, 32, div_unsigned_loop	# I == 32?
	la	$v0, ($s2)			# Q is stored into $v0 (Quotient)
	la	$v1, ($s1)			# R is stored into $v1 (Remainder)
	# Restore RTE
	lw	$fp, 44($sp)
	lw 	$ra, 40($sp)
	lw	$a0, 36($sp)
	lw	$a1, 32($sp)
	lw	$a2, 28($sp)
	lw	$s0, 24($sp)
	lw	$s1, 20($sp)
	lw	$s2, 16($sp)
	lw	$s3, 12($sp)
	lw	$s4, 8($sp)
	addi	$sp, $sp, 44
	jr	$ra
div_signed:
	# Store RTE - 9 * 4 = 36 bytes
	addi	$sp, $sp, -44
	sw	$fp, 44($sp)
	sw	$ra, 40($sp)
	sw	$a0, 36($sp)
	sw	$a1, 32($sp)
	sw	$s0, 28($sp)
	sw	$s1, 24($sp)
	sw	$s2, 20($sp)
	sw	$s3, 16($sp)
	sw	$s4, 12($sp)
	sw	$s5, 8($sp)
	addi	$fp, $sp, 44
	
	la	$s0, ($a0)			# $a0 is stored into $s0 to preserve value
	la	$s1, ($a1)			# $a1 is stored into $s1 to preserve value
	la	$s2, ($a0)			# N1 = $a0	
	la	$s3, ($a1)			# N2 = $a1
	# Changing arguments to 2's complement (if needed)
	jal	twos_complement_if_neg		
	la	$s2, ($v0)			# Outcome of twos_complement_if_neg is loaded to N1
	la	$a0, ($s3)			# N2 is stored into $a0
	jal	twos_complement_if_neg
	la	$s3, ($v0)			# Outcome of twos_complement_if_neg is loaded to N2
	# Preparing for division step
	la	$a0, ($s2) 			# N1 is loaded to $a0
	la	$a1, ($s3)			# N2 is loaded to $a1
	# Division step
	jal	div_unsigned			# N1 is divided by N2 	
	la	$a0, ($v0)			# Q is loaded to $a0 
	la	$a1, ($v1)			# R is loaded to $a1
	# Determining sign (S) of Q
	li	$t2, 31
	extract_nth_bit($t0, $s0, $t2)		# $t0 = $a0[31]
	extract_nth_bit($t1, $s1, $t2)		# $t1 = $a1[31]
	xor	$t3, $t0, $t1			# Result of S
	la	$s4, ($a0)			# $a0 is loaded to $s4
	la	$s5, ($a1)			# $a1 is loaded to $s5
	bne	$t3, 1, div_remainder_sign	# Changing quotient to 2's complement if S is negative
	jal	twos_complement
	la	$s4, ($v0)			# 2's complement of quotient is loaded to $s4
div_remainder_sign:	# Determining sign (S) of R
	li	$t1, 31
	extract_nth_bit($t0, $s0, $t1)		# $t0 = $a0[31]
	la	$t2, ($t0)			# S = $a0[31]
	bne	$t2, 1, div_signed_end		# Changing remainder to 2's complement if S is negative
	la	$a0, ($s5)			# $s5 is loaded to $a0 for twos_complement 
	jal	twos_complement
	la	$s5, ($v0)			# 2's complement of remainder is loaded to $s5
div_signed_end:	
	la	$v0, ($s4)	# Q (Quotient) = $v0 
	la	$v1, ($s5)	# R (Remainder) = $v1
	# Restore RTE
	lw	$fp, 44($sp)
	lw	$ra, 40($sp)
	lw	$a0, 36($sp)
	lw	$a1, 32($sp)
	lw	$s0, 28($sp)
	lw	$s1, 24($sp)
	lw	$s2, 20($sp)
	lw	$s3, 16($sp)
	lw	$s4, 12($sp)
	lw	$s5, 8($sp)
	addi	$sp, $sp, 44
	jr	$ra
au_logical_return:
	# Restore RTE
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$fp, $sp, 24
	jr 	$ra
