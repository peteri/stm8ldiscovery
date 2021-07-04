stm8/
	.tab	0,8,16,60
;=============================================
; Contain all the varible definitions
;=============================================
	#include "constants.inc"
	#include "mapping.inc"

ram0_start.b	EQU $ram0_segment_start
ram0_end.b	EQU $ram0_segment_end
ram1_start.w	EQU $ram1_segment_start
ram1_end.w	EQU $ram1_segment_end	

	segment 'rom'
;=============================
; Helper routine to clear ram
;=============================
.clear_memory.w
	ldw X,#ram0_start
clear_ram0.l
	clr (X)
	incw X
	cpw X,#ram0_end	
	jrule clear_ram0
	; clear RAM1
	ldw X,#ram1_start
clear_ram1.l
	clr (X)
	incw X
	cpw X,#ram1_end	
	jrule clear_ram1
	ret
;==================================
;
; Variables in zero page start here
;
;==================================
	segment 'ram0'
.linebuffer1.w	ds.b	{ScrWidth+2}
.linebuffer2.w	ds.b	{ScrWidth+2}
;==================================
;
; Variables in rest of ram start here
;
;==================================
	segment 'ram1'
.syncdma.w	ds.w	1
.linenumber.w	ds.b	1
.enableSPI.w	ds.b	1	;Used to turn on SPI
.tim3cntr.w	ds.w	1
	end
	