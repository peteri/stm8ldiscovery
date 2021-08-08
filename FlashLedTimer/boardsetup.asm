stm8/
	.tab	0,8,16,60

	#include "mapping.inc"
	#include "variables.inc"
	#include "stm8l152c6.inc"
ram0_start.b	EQU $ram0_segment_start
ram0_end.b	EQU $ram0_segment_end
ram1_start.w	EQU $ram1_segment_start
ram1_end.w	EQU $ram1_segment_end	
	segment 'rom'
;
; Setup up the gpio ports
;
.init_gpio.w
; set everything to have a pullup resistor in input mode
	mov PA_CR1,#$FF
	mov PB_CR1,#$FF
	mov PC_CR1,#$FF
	mov PD_CR1,#$FF
	mov PE_CR1,#$FF
	mov PA_CR2,#$00
	mov PB_CR2,#$00
	mov PC_CR2,#$00
	mov PD_CR2,#$00
	mov PE_CR2,#$00
	mov PA_DDR,#$00
	mov PB_DDR,#$00
	mov PC_DDR,#$00
	mov PD_DDR,#$00
	mov PE_DDR,#$00
; setup for LEDs	
	bset PE_DDR,#7
	bset PE_CR1,#7
	bset PC_DDR,#7
	bset PC_CR1,#7
	ret
;
; Setup timers
;
.init_timers.w
	mov TIM2_PSCR,#$07	;timer 2 prescaler div by 128
	mov TIM2_ARRH,#$F4	;msb must be loaded first
	mov TIM2_ARRL,#$24	;we need we need 62500 for about 1hz
	bset TIM2_IER,#0	;set bit 0 for update irq's on irq19
	bset TIM2_EGR,#0	;Trigger update event so preload-registers copy
	bset TIM2_CR1,#0        ;set CEN bit to enable the timer
	ret
;
; Setup CPU
;
.init_cpu.w
	mov CLK_CKDIVR,#$00	; Full speed 16Mhz
	bset CLK_PCKENR1,#0	; Send the clock to timer 2
	ret	
	end
