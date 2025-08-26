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
MOV R5, R1 @ store GPIOB_BASE in R5 for safe keeping if R1 is altered
main_loop:
    MOVS R2, #0x01
    BL write_leds
    BL delay_loop
    MOVS R2, #0x02
    BL write_leds
    BL delay_loop
	B main_loop
write_leds:
    STR R2, [R5, #0x14]
	BX LR

delay_loop: @ start of delay function
    LDR R4, =LONG_DELAY_CNT @ load LONG_DELAY_CNT value's adresss into R4 register
    LDR R4, [R4] @ load the actual value of LONG_DELAY_CNT into R4 from its address
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
LONG_DELAY_CNT: 	.word 0x2AAE80 @ value that counter of delay loop must count to to have a delay of 0.7 seconds
SHORT_DELAY_CNT: 	.word 0
