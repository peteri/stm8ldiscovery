stm8/
	.tab	0,8,16,60
	#include "mapping.inc"
	#include "constants.inc"
	#include "stm8l152c6.inc"
	#include "boardsetup.inc"
	#include "variables.inc"
	#include "videosync.inc"
	#include "linerender.inc"
	#include "demovideo.inc"
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
	call init_cpu	  ; speed up the cpu and turn on stuff
	call clear_memory ; Clear rest of ram
	call init_gpio	  ; setup the gpio pins
	call init_spi1	  ; setup the SPI
	call init_dma	  ; setup dma channels
	call init_timers  ; setup the timers.
; Lets do it	
	rim		  ; interrupts on
infinite_loop.l
	call demo_video
	jra infinite_loop
;==============================================
;	Interrupt handler for DMA channel
;	transaction complete.
;==============================================
	interrupt DMAChannel23Int
DMAChannel23Int.l
	btjt DMA1_GCSR,#2,dmachan2 ;Channel2?
; Channel 3 DMA	
	bres DMA1_C3CR,#0	;turn off channel
 	bres DMA1_C3SPR,#1	;clear transcation completed
	ldw x,syncdma		;Current value to DMA src
	ldw DMA1_C3M0ARH,x
	ld a,#$80		;How many bytes to transfer
	addw x,#$0100		;Next buffer
	cpw x,#synccompend	;gone off end?
	jrule syncnowrap
	ld a,#$62		;Only do $62 bytes
	ldw x,#synccomp		;Set us up wrapped for next 
syncnowrap	
	ldw syncdma,x
	ld DMA1_C3NDTR,a	;128 or (625*2) mod 128
	bset DMA1_C3CR,#0	;turn back on channel
	iret
; Channel 2 DMA	
dmachan2
 	bres DMA1_C2SPR,#1	;clear transaction completed
	iret
;==============================================
;	Interrupt handler for timer 3 comparator
;	Kicks off rendering the frame and outputting
;	data for screen via SPI.
;==============================================
	interrupt Timer3CompareInt
Timer3CompareInt.l
	mov TIM3_SR1,#%00000000 ;Clear frame interrupts
	mov TIM1_DER,#%00001100	;Turn on CC3 DMA
	mov linenumber,#$00
renderloop
	;Setup DMA and SPI ready for enable
	mov SPI1_ICR,#0		;Turn of DMA TX
	mov DMA1_C2CR,#%00101000  ; Disable DMA
	mov DMA1_C2NDTR,#{ScrWidth+2}	  ; 
	btjf linenumber,#0,oddline
	mov DMA1_C2M0ARL,#{low linebuffer1}
	ldw y,#linebuffer2
	jra turnonDMA2
oddline
	mov DMA1_C2M0ARL,#{low linebuffer2}
	ldw y,#linebuffer1
turnonDMA2
	mov DMA1_C2CR,#%00101001  ; Incrementing mem to periph
	;save away the current scan line (0..640)
	ld a,TIM3_CNTRH	;Save current line counter
	ld xh,a
	ld a,TIM3_CNTRL
	ld xl,a
	ldw tim3cntr,x
	call renderline
waitforcounterchange
	ld a,TIM3_CNTRH	;Read current line counter
	ld xh,a
	ld a,TIM3_CNTRL
	ld xl,a
	cpw x,tim3cntr ; Wait for line counter to change
	jreq waitforcounterchange
	
	inc linenumber	;Increment number of lines
	ld a,linenumber
	cp a,#{ScrLines + 2} 
	jrule renderloop	;Not done yet
	mov SPI1_ICR,#0		;Turn of DMA TX
	mov TIM1_DER,#%00000100	;Turn off CC3 DMA
	mov DMA1_C2CR,#%00101000  ; Disable DMA
	; call the demo 50Hz tick
	bcpl	PC_ODR,#7	;toggle led
	call demo_video_frame
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
	dc.l {$82000000+DMAChannel23Int}	; irq3
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
	dc.l {$82000000+NonHandledInterrupt}	; irq19
	dc.l {$82000000+NonHandledInterrupt}	; irq20
	dc.l {$82000000+NonHandledInterrupt}	; irq21
	dc.l {$82000000+Timer3CompareInt}	; Timer 3 capture/compare
	dc.l {$82000000+NonHandledInterrupt}	; irq23
	dc.l {$82000000+NonHandledInterrupt}	; irq24
	dc.l {$82000000+NonHandledInterrupt}	; irq25
	dc.l {$82000000+NonHandledInterrupt}	; irq26
	dc.l {$82000000+NonHandledInterrupt}	; irq27
	dc.l {$82000000+NonHandledInterrupt}	; irq28
	dc.l {$82000000+NonHandledInterrupt}	; irq29
	end
