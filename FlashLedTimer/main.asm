stm8/

	#include "mapping.inc"
	#include "stm8l152c6.inc"
	#include "boardsetup.inc"
	#include "variables.inc"
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
	rim		; turn on interrupts
infinite_loop.l
	jra infinite_loop
;========================================
;
; Increments led_state and toggles 
; LEDs depending on the bottom two bits
;
;========================================
ledtoggle	
	inc led_state
	btjf led_state,#0,setblue
; turn blue off
	bres PC_ODR,#7
	jra testgreen
setblue
; turn blue on
	bset PC_ODR,#7
testgreen
	btjf led_state,#1,setgreen
	bres PE_ODR,#7
	jra exitledtoggle
setgreen
	bset PE_ODR,#7	
exitledtoggle
	ret
;=========================================
;	Interrupt handler for timer 2
;	toggles the led.
;=========================================
TimerTwoInterrupt.l
	bres TIM2_SR1,#0
	call ledtoggle
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
	dc.l {$82000000+TimerTwoInterrupt}	; irq19
	dc.l {$82000000+NonHandledInterrupt}	; irq20
	dc.l {$82000000+NonHandledInterrupt}	; irq21
	dc.l {$82000000+NonHandledInterrupt}	; irq22
	dc.l {$82000000+NonHandledInterrupt}	; irq23
	dc.l {$82000000+NonHandledInterrupt}	; irq24
	dc.l {$82000000+NonHandledInterrupt}	; irq25
	dc.l {$82000000+NonHandledInterrupt}	; irq26
	dc.l {$82000000+NonHandledInterrupt}	; irq27
	dc.l {$82000000+NonHandledInterrupt}	; irq28
	dc.l {$82000000+NonHandledInterrupt}	; irq29

	end
