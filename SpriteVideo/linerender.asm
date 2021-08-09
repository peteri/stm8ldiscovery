stm8/
	.tab	0,8,16,60
	#include "mapping.inc"
	#include "constants.inc"
	#include "variables.inc"
	#include "characterrom.inc"
	segment 'ram0'
store.b		ds.w
romhi.b		ds.b
count.b		ds.b	
	segment 'rom'
;
; On entry y is where to store the data.
;
.renderline.w
	incw y		;Skip first byte (always zero)
	ldw store,y
	; make x the start of the line
	; x=(linenumber/8) * ScrWidth
	ld a,linenumber
	cp a,#ScrLines
	jruge blankline
	srl a
	srl a
	srl a
	ldw x,#ScrWidth
	mul x,a
	
	;Where is our character data for this line.
	ld a,linenumber
	and a,#7
	add a,#{high characterrom}
	ld romhi,a
	
	mov count,#ScrWidth
renderloop
	ld a,(screen,x)	  ;1 - Get character from screen
	incw x            ;1
	ld yl,a           ;1 - Get the data from rom
	ld a,romhi        ;1
	ld yh,a           ;1
	ld a,(y)          ;1
 	ldw y,store       ;2 - Save data to buffer
	ld (y),a          ;1
	inc {store+1}     ;1
	dec count         ;1 - Loop 
	jrne renderloop   ;2 - 13 cycles per character
	ret
	;Blank routine if we're off the bottom
blankline	
	mov count,#ScrWidth
	ld a,#0
blankloop
	ld (y),a
	incw y
	dec count         
	jrne blankloop   
	ret
	end
