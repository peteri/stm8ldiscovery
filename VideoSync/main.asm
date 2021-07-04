stm8/
	.tab	0,8,16,60
	#include "mapping.inc"
	#include "stm8l152c6.inc"
	#include "boardsetup.inc"
	#include "variables.inc"
	#include "videosync.inc"	
stack_start.w	EQU $stack_segment_start
stack_end.w	EQU $stack_segment_end
	segment 'rom'
main.l
	; initialize SP
	ldw X,#stack_end
	ldw SP,X
	; clear stack
	ldw X,#stack_start
clear_stack.l
	clr (X)
	incw X
	cpw X,#stack_end	
	jrule clear_stack
	; we have clear stack
	; time for more setup
	call init_cpu
	call clear_memory ; Clear rest of ram
	call init_gpio	;setup the gpio pins
	call init_timers
	call copydata
	call init_dma
	rim		; turn on interrupts
infinite_loop.l
	jra infinite_loop
;==============================================
;	Interrupt handler for timer 3 overflow
;	Resets the DMA start point for the 
;	Timer1 comparator registers.
;==============================================
	interrupt Timer3OverflowInt
Timer3OverflowInt.l
 	bres TIM3_SR1,#0
	bres DMA1_C0CR,#0	;turn off channel
	ldw x,#synccomptest	;reload dma memory
	ldw DMA1_C0M0ARH,x
		mov DMA1_C0NDTR,#$8	; 1 byte/word?

	bset DMA1_C0CR,#0	;turn back on channel
	iret
;==============================================
;	Interrupt handler for timer 3 comparator
;	Kicks off rendering the frame and outputting
;	data for screen via SPI.
;==============================================
	interrupt Timer3CompareInt
Timer3CompareInt.l
	bres TIM3_SR1,#1
	bcpl PC_ODR,#7	;toggle led
	iret
	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret

	segment 'vectit'
	dc.l {$82000000+main}			; reset
	dc.l {$82000000+NonHandledInterrupt}	; trap
	dc.l {$82000000+NonHandledInterrupt}	; irq0
	dc.l {$82000000+NonHandledInterrupt}	; irq1
	dc.l {$82000000+NonHandledInterrupt}	; irq2
	dc.l {$82000000+NonHandledInterrupt}	; irq3
	dc.l {$82000000+NonHandledInterrupt}	; irq4
	dc.l {$82000000+NonHandledInterrupt}	; irq5
	dc.l {$82000000+NonHandledInterrupt}	; irq6
	dc.l {$82000000+NonHandledInterrupt}	; irq7
	dc.l {$82000000+NonHandledInterrupt}	; irq8
	dc.l {$82000000+NonHandledInterrupt}	; irq9
	dc.l {$82000000+NonHandledInterrupt}	; irq10
	dc.l {$82000000+NonHandledInterrupt}	; irq11
	dc.l {$82000000+NonHandledInterrupt}	; irq12
	dc.l {$82000000+NonHandledInterrupt}	; irq13
	dc.l {$82000000+NonHandledInterrupt}	; irq14
	dc.l {$82000000+NonHandledInterrupt}	; irq15
	dc.l {$82000000+NonHandledInterrupt}	; irq16
	dc.l {$82000000+NonHandledInterrupt}	; irq17
	dc.l {$82000000+NonHandledInterrupt}	; irq18
	dc.l {$82000000+NonHandledInterrupt}	; Timer 2 Update/overflow
	dc.l {$82000000+NonHandledInterrupt}	; Timer 2 capture/compare
	dc.l {$82000000+Timer3OverflowInt}	; Timer 3 Update/overflow
	dc.l {$82000000+Timer3CompareInt}	; Timer 3 capture/compare
	dc.l {$82000000+NonHandledInterrupt}	; irq23
	dc.l {$82000000+NonHandledInterrupt}	; irq24
	dc.l {$82000000+NonHandledInterrupt}	; irq25
	dc.l {$82000000+NonHandledInterrupt}	; irq26
	dc.l {$82000000+NonHandledInterrupt}	; irq27
	dc.l {$82000000+NonHandledInterrupt}	; irq28
	dc.l {$82000000+NonHandledInterrupt}	; irq29

	end
