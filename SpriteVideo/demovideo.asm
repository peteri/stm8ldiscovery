stm8/
	.tab	0,8,16,60
	#include "variables.inc"
	#include "constants.inc"
	#include "linerender.inc"
	segment 'ram1'
videoticks.w	ds.w 1
onscreen ds.b 1
temp	ds.b 1
	segment 'rom'
; Called every frame by the video code
; we just toggle an led and increment a counter for now.
.demo_video_frame.w
	ldw	y,videoticks
	incw	y
	ldw	videoticks,y
	call	display_video_ticks
	ret
;======================================
;
;	Main demo routine
;
;======================================
.demo_video.w
	call	clear_screen
	call	udg_copy
	call	display_welcome
	call	delay_1_sec
	call	display_charset
	call	delay_1_sec
	call	rolling_text_udg
	call	delay_1_sec
	ret
;========================================
;
;       Clear screen routine
;========================================
clear_screen
	ld	a,#$20
fill_screen	
	ldw	y,#screen
	ldw	x,#{ScrHeight mult ScrWidth}
clear_screen_loop
	ld	(y),a
	incw	y
	decw	x
	jrne	clear_screen_loop
	ret
;=========================================
;	Display welcome message
;=========================================
display_welcome
	ldw	x,#welcome_msg1
	call	display_message
	ldw	x,#welcome_msg2
	call	display_message
	ret
;=========================================
;	Display charset
;=========================================
display_charset
	ldw	x,#char_set1
	call	display_message
	ldw	x,#char_set2
	call	display_message
	ldw	x,#char_set3
	call	display_message
	ldw	x,#char_set4
	call	display_message
	ldw	y,#{ScrWidth mult 8+21}
	ldw	x,#$00
display_left_edge
	ld	a,xl
	add	a,#$30
	cp	a,#$3a
	jrult	hex_digit
	add	a,#$7
hex_digit	
	ld	(screen,y),a
	ld	a,#$B3
	ld	({screen+1},y),a
	ld	a,yl
	add	a,#ScrWidth
	ld	yl,a
	ld	a,yh
	adc	a,#0
	ld	yh,a
	incw	x
	cpw	x,#$10
	jrult	display_left_edge
	ldw	x,#$00
char_loop
	ld	a,#ScrWidth
	ld	yl,a
	ld	a,xl
	srl	a
	srl	a
	srl	a
	srl	a
	add	a,#8
	mul	y,a
	;On the right line now add our offset...
	ld	a,xl
	and	a,#$0f
	add	a,#23
	ld	temp,a
	ld	a,yl
	add	a,temp
	ld	yl,a
	ld	a,yh
	adc	a,#0
	ld	yh,a
	ld	a,xl
	ld	(screen,y),a
	pushw	x
	ldw	x,#5
	call	delay_x_frames
	popw	x
	incw	x
	cpw	x,#$100
	jrult	char_loop
	ret
rolling_text_udg
	ret
;=========================================
;
; Display message, called with x register
; pointing to message to display, message
; starts with y coord, x coord, messsage 
; bytes terminated by a zero.
;
;=========================================
display_message
	ld	a,#ScrWidth
	ld	yl,a
	ld	a,(x)
	incw	x
	mul	y,a
	ld	a,yl
	add	a,(x)
	incw	x
	ld	yl,a
	ld	a,yh
	adc	a,#$0
	ld	yh,a
	ld	a,(x)
display_message_loop
	incw	x
	ld	(screen,y),a
	incw	y
	ld	a,(x)
	jrne	display_message_loop
	ret
	
;=========================================
; Display number of video frames on screen
;=========================================
display_video_ticks
	ret
;========================================
;
; Delay routines
;
;========================================
delay_1_sec
	ldw x,#50
;
; delay for x frames
; destroys y.
;
delay_x_frames
	ldw	y,videoticks
wait_for_tick_change	
	cpw	y,videoticks
	jreq	wait_for_tick_change
	decw	x
	jrne	delay_x_frames
	ret
;	                    1234567890123456789012345678901234567890
welcome_msg1.w	DC.B 0,0,"Welcome to the STM8",0
welcome_msg2.w	DC.B 1,0,"PAL cheap video system",0
char_set1.w	DC.B 3,0,"Comes with complete code",0
char_set2.w	DC.B 4,0,"page 437 characters",0
char_set3.w	DC.B 6,21,$20,$B3,"0123456789ABCDEF",0
char_set4.w	DC.B 7,21,$C4,$C5
		DC.B $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4
		DC.B $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$00
udg_msg1.w	DC.B 6,0,"32 user defined graphics",0
udg_msg2.w	DC.B 7,0,"Time to scroll",0
	end
