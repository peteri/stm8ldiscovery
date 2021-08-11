no_sync		EQU 0
line_sync	EQU 75	 
short_sync	EQU 38
long_sync	EQU 437
;Use the external clock
;internal clock gives shaky video
EXT_CLOCK	EQU 1
ScrWidth 	EQU	40
ScrHeight	EQU	25
CellHeight	EQU	8
ScrLines	EQU	{ScrHeight mult CellHeight}
SyncPulses	EQU	640
; Where does video start vertically...
VideoStart	EQU	$40
; Video data starts 6uS (5.7us is front porch)
; after rising edge
spi_data_start	EQU $90
TIM1_CC3	EQU {spi_data_start+line_sync}
