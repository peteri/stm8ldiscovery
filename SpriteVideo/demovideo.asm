stm8/
	.tab	0,8,16,60
	#include "variables.inc"
	#include "stm8l152c6.inc"
	#include "constants.inc"
	segment 'ram1'
videoticks.w	ds.b 1
onscreen ds.b 1
	segment 'rom'
; Called every frame by the video code
; we just toggle an led and increment a counter for now.
.demo_video_frame.w
	bcpl	PC_ODR,#7	;toggle led
	inc	videoticks
;	call	display_video_ticks
	ret
.demo_video.w
	call	clear_screen
demo_video_loop	
	ld	a,onscreen
	call	fill_screen
	inc	onscreen
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
	ld	a,videoticks
wait_for_tick_change	
	cp	a,videoticks
	jreq	wait_for_tick_change
	decw	x
	jrne	delay_x_frames
	ret
	end
