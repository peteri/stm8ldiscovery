stm8/
	.tab	0,8,16,60

	#include "mapping.inc"
	#include "variables.inc"
	#include "stm8l152c6.inc"
	#include "videosync.inc"
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
; Timer 1 output on PD2	(used for SPI clock slave pin)
	bset PD_DDR,#2
	bset PD_CR1,#2
; Timer 2 out on PB0 (Sync)
	bset PB_DDR,#0
	bset PB_CR1,#0
; Timer 3 out on PB1 Frame
	bset PB_DDR,#1
	bset PB_CR1,#1
	ret
;=================================================
;
; Setup timers
;
;=================================================
.init_timers.w
;
; Timer 2 - Channel 1 is output on PB0
; Used for video sync.
;
; ARPE=1, CMS=Edge(00),DIR=Up(0),OPM=0,URS=???, UDIS=???, CEN=1
	mov TIM2_CR1, #%10000000  ; TIM2 Control register 1
; TI1S=0; MMS=010; CCDS=1; 000
	mov TIM2_CR2, #%00100000  ; TIM2 Control register 2
; Not in slave mode
	mov TIM2_SMCR,#$00	  ; TIM2 Slave Mode Control register
; No reason for an external trigger	
	mov TIM2_ETR,#$00	  ; TIM2 External trigger register
; DMA request on capture compare 1	
	mov TIM2_DER,#%00000010	  ; TIM2 DMA request enable register
; No interrupts	
	mov TIM2_IER,#$00	  ; TIM2 Interrupt enable register
; Set to PWM1, OC1PE, Capture compare is output
	mov TIM2_CCMR1,#%01111000 ; TIM2 Capture/Compare mode register 1
	mov TIM2_CCMR2,#$00	  ; TIM2 Capture/Compare mode register 2
; Capture compare is active high, output enable	
	mov TIM2_CCER1,#%00000001 ; TIM2 Capture/Compare enable register 1
	mov TIM2_PSCR,#$00	  ; TIM2 Prescaler register
; Period is 64*16 cycles $0200 	
	mov TIM2_ARRH,#$01	  ; TIM2 Auto-Reload Register High
	mov TIM2_ARRL,#$ff	  ; TIM2 Auto-Reload Register Low
; Compare register at 1/4	
	mov TIM2_CCR1H,#$00	  ; TIM2 Capture/Compare Register 1 High
	mov TIM2_CCR1L,#$80	  ; TIM2 Capture/Compare Register 1 Low
	mov TIM2_CCR2H,#$00	  ; TIM2 Capture/Compare Register 2 High
	mov TIM2_CCR2L,#$00	  ; TIM2 Capture/Compare Register 2 Low
	mov TIM2_BKR,#%11000100	  ; TIM2 Break register
	mov TIM2_OISR,#$00	; TIM2 Output idle state register
;
; Timer 3 counts frames....
; Output is PB1
;
; ARPE=1, CMS=Edge(00),DIR=Up(0),OPM=0,URS=???, UDIS=???, CEN=1
	mov TIM3_CR1, #%10000000  ; TIM3 Control register 1
; TI1S=0; MMS=010; CCDS=1; 000
	mov TIM3_CR2, #%00101000  ; TIM3 Control register 2
; Slave mode clock is TIM2
	mov TIM3_SMCR,#%10110111  ; TIM3 Slave Mode Control register
; No reason for an external trigger	
	mov TIM3_ETR,#$00	  ; TIM3 External trigger register
; No DMA 
	mov TIM3_DER,#%00000000	  ; TIM3 DMA request enable register
; Interrupts on compare and update
	mov TIM3_IER,#%00000011	  ; TIM3 Interrupt enable register
; Set to PWM1, OC1PE, Capture compare is output
	mov TIM3_CCMR1,#%01111000 ; TIM3 Capture/Compare mode register 1
	mov TIM3_CCMR2,#$00	  ; TIM3 Capture/Compare mode register 2
; Capture compare is active high, output enable	
	mov TIM3_CCER1,#%00000001 ; TIM3 Capture/Compare enable register 1
	mov TIM3_PSCR,#$00	  ; TIM3 Prescaler register
; No of lines to compare
	mov TIM3_ARRH,#$00	  ; TIM3 Auto-Reload Register High
	mov TIM3_ARRL,#$08	  ; TIM3 Auto-Reload Register Low
; Compare register at 3/4	
	mov TIM3_CCR1H,#$00	  ; TIM3 Capture/Compare Register 1 High
	mov TIM3_CCR1L,#$06	  ; TIM3 Capture/Compare Register 1 Low
	mov TIM3_CCR2H,#$00	  ; TIM3 Capture/Compare Register 2 High
	mov TIM3_CCR2L,#$00	  ; TIM3 Capture/Compare Register 2 Low
	mov TIM3_BKR,#%11000100	  ; TIM3 Break register
	mov TIM3_OISR,#$00	; TIM3 Output idle state register
	bset TIM3_CR1, #0  	; Enable timer 3
;
; Turn on timer 2
;
	bset TIM2_CR1, #0  	; Enable timer 2
	ret
;
; Setup CPU
;
.init_cpu.w
	mov CLK_CKDIVR,#$00	; Full speed 16Mhz
	bset CLK_PCKENR1,#$0	; Send the clock to timer 2
	bset CLK_PCKENR1,#$1	; Send the clock to timer 3
	bset CLK_PCKENR2,#$4	; Turn on DMA1
	ret
;
;	Setup DMA
;
.init_dma.w
; Timer 2 CC1 is on channel 0
	mov DMA1_C0SPR,#%00111000
	mov DMA1_C0NDTR,#$8	; 1 byte/word?
	ldw x,#TIM2_CCR1H
	ldw DMA1_C0PARH,x
	ldw x,#synccomptest
	incw x
	incw x
	ldw DMA1_C0M0ARH,x
; regular channel, memory increment, circ off,
; mem to periperal, no interrupts, channel enable
	mov DMA1_C0CR,#%00101001
; Turn on DMA
	mov DMA1_GCSR,#%00000001
	ret
	end
