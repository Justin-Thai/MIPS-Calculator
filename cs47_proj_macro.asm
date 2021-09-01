# Add your macro definition here - do not touch cs47_common_macro.asm"

# Justin Thai
# CS 47, Section 1
# 2 December 2019

#<------------------ MACRO DEFINITIONS ---------------------->#
	# Macro: extract_nth_bit
	# Usage: Extracts nth bit from a bit pattern
	.macro extract_nth_bit($regD, $regS, $regT)
	srlv	$regD, $regS, $regT
	and	$regD, 1
	.end_macro
	
	# Macro: insert_to_nth_bit
	# Usage: Insert bit 1 or 0 at nth bit to a bit pattern
	.macro insert_to_nth_bit($regD, $regS, $regT, $maskReg)
	li	$maskReg, 1			
	sllv	$maskReg, $maskReg, $regS	# Shifting mask register by shift amount
	not 	$maskReg, $maskReg		
	and	$regD, $regD, $maskReg			
	sllv	$regT, $regT, $regS		# Shifting bit to be inserted by shift amount
	or	$regD, $regD, $regT		
	.end_macro
