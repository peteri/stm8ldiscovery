stm8/
	.tab	0,8,16,60
	#include "variables.inc"
	#include "constants.inc"
	#include "linerender.inc"
	segment 'ram1'
videoticks.w	ds.w 1
onscreen ds.b 1
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
demo_video_loop	
	call	udg_copy
	call	display_welcome
	call	delay_1_sec
	jra	demo_video_loop
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
welcomemsg1	DC.B 10,10,"Welcome to the STM8",0
welcomemsg2	DC.B 10,11," PAL video system",0
welcomemsg3	DC.B 10,12
	end
