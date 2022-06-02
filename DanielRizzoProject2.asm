# Daniel Rizzo
# CSCI 26000
# Project 2
# Professor Shankar
# November 19th, 2020

# For this project, you will draw on two seven-segment LED displays using MARS’ “Digital Lab Sim” tool
# (instead of the bitmap tool from project 1). We will not use the hex keyboard part of the tool.
# The output of this assignment is to count a, a + 1, . . . , b in sequence on the LED displays. The numbers
# a and b are supplied as inputs in the data segment (make sure to use the labels a,b and put these at the
# beginning of the data segment).

.data # Reserves storage space in memory for program variables, 
        # and also allows for referring to these variables by name instead of address
A: .word 0 # Reserve one word of memory for a - 2^32 values
B: .word 99 # Reserve one word of memory for b - 2^32 values

.text
# Allocate data for a and b
Main: la $s0, A # load address of a into $s0
lw $s0, 0($s0) # load actual data of a into $s0
la $s1, B # load address of b into $s1
lw $s1, 0($s1) # load actual data of b into $s1

# Check if 0 <= a <= b <= 99
# Check if 0 <=a
addi $t0, $zero, -1 # t0 gets -1
slt $t1, $t0, $s0 # t1 gets 1 if t0 (-1) < a, 0 otherwise
beq $zero, $t1, End # if t1 = 0, end program
# Check if a <= b
beq $s0, $s1, Equal # if a = b, then skip this check
slt $t1, $s0, $s1 # t1 gets 1 if a < b, 0 otherwise
beq $t1, $zero, End # if t1 = 0, end program
# Check if b <= 99
Equal: addi $t0, $zero, 100 # t0 gets 100
slt $t1, $s1, $t0 # t1 gets 1 if b < t0 (100), 0 otherwise
beq $zero, $t1, End # if t1 = 0, end program

# Set up display loop
addi $t0, $s1, 1 # t0 gets b + 1
addi $t1, $zero, 10 # t1 gets 10
div $s0, $t1 # A/10. Lo gets quotient, Hi gets remainder
mflo $t2 # t2 gets quotient
mfhi $t3 # t3 gets remainder
sub $t4, $t0, $s0 # t4 gets t0 (b+1) - a, number of loops
add $t5, $zero, $zero # t5 gets 0, counter of number of loops done

# Start display loop
Loop: beq $t4, $t5, End # When t4 = t5, end program, b-a + 1 loops done

# Call to display function - t0-5 push on stack each time, s0-1 not needed anymore
# display(1, t3) _ #
addi $sp,$sp,-4 # Push t0
sw $t0,0($sp)
addi $sp,$sp,-4 # Push t1
sw $t1,0($sp)
addi $sp,$sp,-4 # Push t2
sw $t2,0($sp)
addi $sp,$sp,-4 # Push t3
sw $t3,0($sp)
addi $sp,$sp,-4 # Push t4
sw $t4,0($sp)
addi $sp,$sp,-4 # Push t5
sw $t5,0($sp)
addi $a0, $zero, 1 # a0 gets 1, right side of LED
add $a1, $zero, $t3 # a1 gets t3, the remainder/one's place
jal Display # Call Display function
lw $t5,0($sp) # Pop $t5 - top of stack starts with t5
addi $sp, $sp, 4
lw $t4,0($sp) # Pop $t4
addi $sp, $sp, 4
lw $t3,0($sp) # Pop $t3
addi $sp, $sp, 4
lw $t2,0($sp) # Pop $t2
addi $sp, $sp, 4
lw $t1,0($sp) # Pop $t1
addi $sp, $sp, 4
lw $t0,0($sp) # Pop $t0
addi $sp, $sp, 4
# display(0, t2) # _
addi $sp,$sp,-4 # Push t0
sw $t0,0($sp)
addi $sp,$sp,-4 # Push t1
sw $t1,0($sp)
addi $sp,$sp,-4 # Push t2
sw $t2,0($sp)
addi $sp,$sp,-4 # Push t3
sw $t3,0($sp)
addi $sp,$sp,-4 # Push t4
sw $t4,0($sp)
addi $sp,$sp,-4 # Push t5
sw $t5,0($sp)
add $a0, $zero, $zero # a0 gets 0, left side of LED
add $a1, $zero, $t2 # a1 gets t2, the quoitent/ten's place
jal Display # Call Display function
lw $t5,0($sp) # Pop $t5 - top starts with t5
addi $sp, $sp, 4
lw $t4,0($sp) # Pop $t4
addi $sp, $sp, 4
lw $t3,0($sp) # Pop $t3
addi $sp, $sp, 4
lw $t2,0($sp) # Pop $t2
addi $sp, $sp, 4
lw $t1,0($sp) # Pop $t1
addi $sp, $sp, 4
lw $t0,0($sp) # Pop $t0
addi $sp, $sp, 4

# Increment quotient and remainder
addi $t3, $t3, 1 # t3++
slt $t6, $t3, $t1 # t6 gets 1 if t3 (remainder) < t1 (10), 0 otherwise
bne $t6, $zero DecimalSkip # if t6 = 1, skip next few steps that account for decimal overflow
addi $t2, $t2, 1 # t2++, add to ten's place
add $t3, $zero, $zero #set t3 back to zero. Adjusting for overflow.

# Time Wasting Inner Loop - This took about a second each time on my machine. 
DecimalSkip: addi $t7, $zero, 80000 # t7 gets 80000
TimeWaster: addi $t6, $t6, 1 # t6++
slt $t8, $t6, $t7 # t8 gets 1 if t6 < t7, 0 otherwise
bne $t8, $zero, TimeWaster # iterate if t6 < t7

# Iterate display loop
addi $t5, $t5, 1 # add 1 to t5 to increment
j Loop # iterate


End: syscall


# Display function - a0 is flipped from addresses of LED's for some ungodly reason...
Display: addi $sp, $sp, -4 # Push: 
sw $ra, 0($sp) # Push $ra
addi $t0, $zero, 0xFFFF0011 # t0 gets address of left LED
sub $t0, $t0, $a0 # t0 gets t0 - a0, changes it to right side of LED if a0 is 1
andi $t2, $t0, 1 # copy last bit of address of LED into t2
# Zero/Blank
add $t1, $zero, $zero # t1 gets 0
bne $a1, $t1, One # if a1 isn't 0, jump to One
bne $t2, $zero Blank # if t2 (last bit of LED) = 1, jump to Blank, otherwise display 0.
addi $t3, $zero, 0x3F # t3 gets display bits for 0
sb $t3, 0($t0) # Display 0. store t3 in address stored in t0
j Done # jump to end of function
Blank: sb $zero 0($t0) # Display Blank. store 0 in address stored in t0
j Done # jump to end of function 
# One
One: addi $t1, $t1, 1 # t1 gets 1
bne $a1, $t1, Two # if a1 != 1, go to Two
addi $t3, $zero, 0x06 # t3 gets display bits for 1
sb $t3, 0 ($t0) # Display 1. store t3 in address stored in t0
j Done # jump to end of function
# Two
Two: addi $t1, $t1, 1 # t1 gets 2
bne $a1, $t1, Three # if a1 != 2, go to Two
addi $t3, $zero, 0x5B # t3 gets display bits for 2
sb $t3, 0 ($t0) # Display 2. store t3 in address stored in t0
j Done # jump to end of function
# Three
Three: addi $t1, $t1, 1 # t1 gets 3
bne $a1, $t1, Four # if a1 != 3, go to Four
addi $t3, $zero, 0x4F # t3 gets display bits for 3
sb $t3, 0 ($t0) # Display 3. store t3 in address stored in t0
j Done # jump to end of function
# Four
Four: addi $t1, $t1, 1 # t1 gets 4
bne $a1, $t1, Five # if a1 != 4, go to Five
addi $t3, $zero, 0x66 # t3 gets display bits for 4
sb $t3, 0 ($t0) # Display 4. store t3 in address stored in t0
j Done # jump to end of function
# Five
Five: addi $t1, $t1, 1 # t1 gets 5
bne $a1, $t1, Six # if a1 != 5, go to Six
addi $t3, $zero, 0x6D # t3 gets display bits for 5
sb $t3, 0 ($t0) # Display 5. store t3 in address stored in t0
j Done # jump to end of function
# Six
Six: addi $t1, $t1, 1 # t1 gets 6
bne $a1, $t1, Seven # if a1 != 6, go to Seven
addi $t3, $zero, 0x7D # t3 gets display bits for 6
sb $t3, 0 ($t0) # Display 6. store t3 in address stored in t0
j Done # jump to end of function
# Seven
Seven: addi $t1, $t1, 1 # t1 gets 7
bne $a1, $t1, Eight # if a1 != 7, go to Eight
addi $t3, $zero, 0x07 # t3 gets display bits for 7
sb $t3, 0 ($t0) # Display 7. store t3 in address stored in t0
j Done # jump to end of function
# Eight
Eight: addi $t1, $t1, 1 # t1 gets 8
bne $a1, $t1, Nine # if a1 != 8, go to Nine
addi $t3, $zero, 0x7F # t3 gets display bits for 8
sb $t3, 0 ($t0) # Display 8. store t3 in address stored in t0
j Done # jump to end of function
# Nine
Nine: addi $t1, $t1, 1 # t1 gets 9
bne $a1, $t1, Done # if a1 != 9, go to end of function
addi $t3, $zero, 0x6F # t3 gets display bits for 9
sb $t3, 0 ($t0) # Display 9. store t3 in address stored in t0
j Done # jump to end of function

Done: lw $ra 0($sp) # Pop $ra
addi $sp, $sp 4 # reclaim memory
jr $ra # Jump back to next instruction in main
