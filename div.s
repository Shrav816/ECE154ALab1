##############################################################################
# File: div.s
# Skeleton for ECE 154a project
##############################################################################

	.data
student:
	.asciz "Shravya Salem Sathish, David Uzunov" 	# Place your name in the quotations in place of Student
	.globl	student
nl:	.asciz "\n"
	.globl nl


op1:	.word 7				# dividend for testing
op2:	.word 19			# divisor for testing


	.text

	.globl main
main:					# main has to be a global label
	addi	sp, sp, -4		# Move the stack pointer
	sw 	ra, 0(sp)		# save the return address

	mv	t0, a0			# Store argc
	mv	t1, a1			# Store argv
				
	li	a7, 4			# print_str (system call 4)
	la	a0, student		# takes the address of string as an argument 
	ecall	

	slti	t2, t0, 2		# check number of arguments
	bne     t2, zero, operands
	j	ready

operands:
	la	t0, op1
	lw	a0, 0(t0)
	la	t0, op2
	lw	a1, 0(t0)
		
ready:  addi	sp, sp, -8		# Move the stack pointer
	sw 	a0, 0(sp)		# save a0
	sw 	a1, 4(sp)		# save a1

	jal	divide			# go to divide code

	lw 	a0, 0(sp)		# load a0
	lw 	a1, 4(sp)		# load a1
	addi	sp, sp, 8		# Move the stack pointer

	jal	print_result		# print operands to the console

					# Usual stuff at the end of the main
	lw	ra, 0(sp)		# restore the return address
	addi	sp, sp, 4

	li      a7, 10
	ecall

divide:
##############################################################################
# Should have the same functionality as running
#	divu	a2, a0, a1
# 	remu    a3, a0, a1 
# a0 is 8-bit unsigned divident, a1 is 8-bit unsigned divisor
# a2 is 8-bit unsigned quotient, a3 is 8-bit unsigned remainder
##############################################################################
# Your code goes below

# Set initial values. The remainder is initially equal to the dividend.
add a3, zero, a0 # a3 = a0;

# If the divisor is zero, set the quotient to 0xFF and proceed to done.
bne a1, zero, divisorNonzero # if (a1 != 0) { divisorNonZero; }
addi a2, zero, 0x000000FF # a2 = 0x000000FF;
j done

divisorNonzero:
# For nonzero divisors, set the quotient to zero for now.
add a2, zero, zero # a2 = 0;

# If the dividend is lesser than the divisor, proceed to done.
bltu a0, a1, done # if (a0 < a1) { done; ]

# Dividend and divisor are valid, so calculate their bit lengths. Initially
# store the dividend in t0 and the divisor in t1. Store their current
# lengths in t2 and t3, respectively.
add t0, zero, a0 # t0 = a0;
add t1, zero, a1 # t1 = a1;
add t2, zero, zero # t2 = 0;
add t3, zero, zero # t3 = 0;

# Right shift t0 and increment t2 until t0 is zero for the dividend
# bit length.
whileDividendNonzero: # while (t0 > 0)
beq t0, zero, whileDivisorNonzero
srli t0, t0, 1 # t0 >>= 1;
addi t2, t2, 1 # t2 += 1;
j whileDividendNonzero

# Right shift t1 and increment t3 until t1 is zero for the divisor
# bit length.
whileDivisorNonzero: # while (t1 > 0)
beq t1, zero, lenDone
srli t1, t1, 1 # t1 >>= 1;
addi t3, t3, 1 # t3 += 1;
j whileDivisorNonzero

lenDone:
# Left shift the divisor by the difference in bit length between the
# dividend and the divisor.
sub t4, t2, t3 # t4 = t2 - t3
sll a1, a1, t4 # a1 <<= t4;

# Set up a for loop with t4 + 1 iterations for the division.
addi t4, t4, 1 # t4 += 1;
add t5, zero, zero # t5 = 0;

for: # for (; t5 < t4; t5++)
bge t5, t4, done

# If the remainder is greater than or equal to the divisor, subtract
# the divisor from the remainder, left shift the quotient by 1, and
# set the quotient LSB to 1.
bltu a3, a1, else # if (a3 >= a1) { ... }
sub a3, a3, a1 # a3 -= a1;
slli a2, a2, 1 # a2 <<= 1;
ori a2, a2, 1 # a2 |= 1;
j skip

# Else just left shift the quotient by 1, setting the LSB to 0.
else: # else { a2 <<= 1; }
slli a2, a2, 1

# Right shift the divisor by 1 and increment the for loop counter.
skip:
srli a1, a1, 1 # a1 >>= 1;
addi t5, t5, 1 # t5 += 1;
j for

done: # End of division.

##############################################################################
# Do not edit below this line
##############################################################################
	jr	ra


# Prints a0, a1, a2, a3
print_result:
	mv	t0, a0
	li	a7, 4
	la	a0, nl
	ecall

	mv	a0, t0
	li	a7, 1
	ecall
	li	a7, 4
	la	a0, nl
	ecall

	li	a7, 1
	mv	a0, a1
	ecall
	li	a7, 4
	la	a0, nl
	ecall

	li	a7, 1
	mv	a0, a2
	ecall
	li	a7, 4
	la	a0, nl
	ecall

	li	a7, 1
	mv	a0, a3
	ecall
	li	a7, 4
	la	a0, nl
	ecall

	jr ra
