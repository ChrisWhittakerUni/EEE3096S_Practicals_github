/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns
LDR R7, =LONG_DELAY_CNT @ store the address of the default delay cnt value to be used in the delay_loop if no button has been pressed yet
main_loop:
    MOVS R3, 0x0 @ reset R3 flag so the LEDs increment by only one at a time
    BL check_buttons @ button check. If a specific button is being pressed the necessary changes are made in 'check_buttons:'
    MOVS R6, #0x02 @ put value that R3 will be if button PA0 was pressed into R6.
    CMP R6, R3 @ check if R3 and R6 have the same values to freeze if PA0 was pressed
    BEQ main_loop @ branch back to main_loop to avoid continuing on to write_leds. This freezes the pattern because we do not increment in write_leds
    BL write_leds @ do the next thing in the LED pattern
    BL delay_loop @ delay between changes to LED pattern
    LDR R7, =LONG_DELAY_CNT @ reset to default long delay
	B main_loop



/*write_leds:

	MOVS R6, #0x1 @ put 0x1 into R6 to compare it to flag in R0
    CMP R0, R6 @ if equal then R2 was 0x0 and we need to set the ODR to that without letting the normal bitshift put it to 0x1 first
    BEQ first_after_reset

	MOVS R6, #0x1
    CMP R3, R6
    BNE _inc_1 @ do an extra increment (2 at a time), if R3 has been set to 0x1 meaning PA0 was pressed
    LSLS R2, R2, R6 @ left shift the bits in R2
    ORRS R2, R2, R6 @ bitwise or with 1. These above 2 steps take 0b11 -> 0b111, 0b111 -> 0b1111 etc
_inc_1:
    LSLS R2, R2, R6 @ left shift the bits in R2
    ORRS R2, R2, R6 @ bitwise or with 1. These above 2 steps take 0b11 -> 0b111, 0b111 -> 0b1111 etc
	STR R2, [R1, #0x14] @ put the new value of R2 into the ODR of GPIOB setting the LEDs to next in sequence

	MOVS R6, #0xFF @ put the value corresponding to all lights on into R3 to test against R2 and see if we are at the end of the sequence
	LDR R0, [R1, #0x14]
	CMP R0, R6 @ compare to see if the sequence is over (all lights on)
	BNE no_reset @ if the sequence is still going, skip reset, but if it is done, reset
	MOVS R2, #0x0 @ set the value in R2 to the value corresponding to the first light being on
    MOVS R0, #0x1

no_reset:
    BX LR

first_after_reset:
	STR R2, [R1, #0x14] @ put the new value of R2 into the ODR of GPIOB setting the LEDs to next in sequence
	MOVS R0, #0x0
*/
write_leds:
	MOVS R6, #0xFF @ put the value corresponding to all lights on into R3 to test against R2 and see if we are at the end of the sequence

	CMP R2, R6 @ compare to see if the sequence is over (all lights on)
	BNE no_reset @ if the sequence is still going, skip reset, but if it is done, reset
	MOVS R2, #0x0 @ set the value in R2 to the value corresponding to the first light being on
    STR R2, [R1, #0x14] @ put the new value of R2 into the ODR of GPIOB setting the LEDs all off
    MOVS R2, 0x1 @ set to 1 for next part of sequence
	B first_after_reset @ skip the steps of incrementing to the next LED since we want it to stay on all LEDs off for this round
no_reset:
    STR R2, [R1, #0x14] @ put the new value of R2 into the ODR of GPIOB setting the next LED in the sequence on.
    MOVS R6, #0x1
    CMP R3, R6
    BNE _inc_1 @ do an extra increment (2 at a time), if R3 has been set to 0x1 meaning PA0 was pressed
    LSLS R2, R2, R6 @ left shift the bits in R2
    ORRS R2, R2, R6 @ bitwise or with 1. These above 2 steps take 0b11 -> 0b111, 0b111 -> 0b1111 etc
_inc_1:
    LSLS R2, R2, R6 @ left shift the bits in R2
    ORRS R2, R2, R6 @ bitwise or with 1. These above 2 steps take 0b11 -> 0b111, 0b111 -> 0b1111 etc
first_after_reset:
	BX LR



check_buttons:
	LDR R5, [R0, 0x10] @ read in IDR of GPIOA into R5
check_PA0:
	MOVS R6, #0x01 @ store bitmask to compare IDR of GPIOA to to see if button 0 was pressed
	TST R5, R6 @ test IDR against the value that shows button on PA0 was pressed
	BNE check_PA1 @ if not equal to the bitmask, PA0 was not pressed so skip over and check PA1
	MOVS R3, 0x1 @ flag to say that you must increment by 2 LEDs every time not 1
check_PA1:
	MOVS R6, #0x02 @ store bitmask to compare IDR of GPIOA to to see if button 1 was pressed
	TST R5, R6 @ test IDR against the value that shows button on PA1 was pressed
    BNE check_PA2 @ if not equal to the bitmask then PA1 was also not pressed so skip over and go to check PA2
    LDR R7, =SHORT_DELAY_CNT
check_PA2:
	MOVS R6, #0x04 @ store bitmask to compare IDR of GPIOA to to see if button 2 was pressed
	TST R5, R6 @ test IDR against the value that shows button on PA2 was pressed
    BNE check_PA3 @ if not equal to the bitmask then PA2 was also not pressed so skip over and go to check PA3
    MOVS R2, 0xAA
check_PA3:
	MOVS R6, #0x08 @ store bitmask to compare IDR of GPIOA to to see if button 3 was pressed
	TST R5, R6 @ test IDR against the value that shows button on PA3 was pressed
    BNE done_checking @ if not equal to the bitmask then PA3 was also not pressed so skip over and go to the end of the check
    MOVS R3, #0x2 @ R3 set to value to flag a freeze

done_checking:
	BX LR @ return after button checks have been done and the appropriate updates have been made


delay_loop: @ start of delay function
    LDR R4, [R7] @ The address of either SHORT_DELAY_CNT or LONG_DELAY_CNT is stored in R4. Take this address and use it to load the actual value of the delay cnt (at this address) into R4
delay_loop_inner: @ start of loop
    SUBS R4, R4, #1 @ subtract 1 from the value in R4 (decrement the counter)
    BNE delay_loop_inner @ if R4 is still not at 0 redo the decrement else if it has reached zero move on
    BX LR @ counter has reached zero so return back from the delay function


@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 0x2AAE80 @ value that counter of delay loop must count till to have a delay of 0.7 seconds
SHORT_DELAY_CNT: 	.word 0x124F80 @ value that counter of delay loop must count till to have a delay of 0.3 seconds
