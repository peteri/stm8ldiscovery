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
maskedline.b	ds.b
	segment 'ram1'
	segment 'rom'
;================================================
;
; udg_copy
; Copy the first 32 characters from ROM into the
; user defined graphics.
;
;================================================
.udg_copy.w
	clrw x
udg_copy_loop
	;Set y to be our source
	ldw y,#characterrom
	ld a,xl
	srl a
	srl a
	srl a
	ld yl,a
udg_copy_char_loop
	ld a,(y)
	ld (udg,x),a
	incw x
	ld a,yh	;Add $100 to y
	inc a
	ld yh,a
	ld a,xl
	and a,#7
	jrne udg_copy_char_loop
	cpw x,#$100
	jrult udg_copy_loop
	ret
;================================================
; Render a line of video.
;
; On entry y is where to store the data.
;================================================
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
	ld maskedline,a
	add a,#{high characterrom}
	ld romhi,a
	mov count,#ScrWidth
;Render loop contains duplicated code so we don't take
;an extra pipeline flush.
renderloop
	ld a,(screen,x)	  ;Get character from screen
	incw x            ;
	bcp a,#$e0	  ;UDG?
	jrne renderchar   ;Nope normal character
	clrw y		  ;Render a user define
	sll a		  ;character
	sll a
	sll a
	add a,maskedline
	ld yl,a
	ld a,(udg,y)
 	ldw y,store       ;Save data to buffer
	ld (y),a          
	inc {store+1}     
	dec count         ;All done?
	jrne renderloop   ;Loop back again
	jra rendersprites
renderchar
	ld yl,a           ;Get the data from rom
	ld a,romhi        
	ld yh,a           
	ld a,(y)          
 	ldw y,store       ;Save data to buffer
	ld (y),a          
	inc {store+1}     
	dec count         ;All done? 
	jrne renderloop   ;Loop back again
rendersprites	
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
