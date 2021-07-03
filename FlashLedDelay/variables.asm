stm8/
;=============================================
; Contain all the varible definitions
;=============================================
	#include "mapping.inc"

ram0_start.b	EQU $ram0_segment_start
ram0_end.b	EQU $ram0_segment_end
ram1_start.w	EQU $ram1_segment_start
ram1_end.w	EQU $ram1_segment_end	

	segment 'rom'
;=============================
; Helper routine to clear ram
;=============================
.clear_memory.l
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
; Variables in zero page stat here
;
;==================================
	segment 'ram0'
.led_state.b	ds.b	1
;==================================
;
; Variables in rest of ram stat here
;
;==================================
	segment 'ram1'
	end
	