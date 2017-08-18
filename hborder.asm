BasicUpstart2(begin)				// <- This creates a basic sys line that can start your program
* = $1000 "Main Program"    // <- The name 'Main program' will appear in the memory map when assembling   jsr clear

// Const
.const ENTER = $C202
.const MOVE  = $C203
.const HALF  = $C204

// Main
begin:
  sei							// Disable interrupts
  
  lda #%01111111	// Switch off interrupts from the CIA-1
  sta $dc0d
  and $d011				// Clear most significant bit in VIC raster register
  sta $d011
  lda #252				// Set raster line to interrupt on
  sta $d012
  lda #<irq_25		// Set the interrupt vector to point to the service routine
  sta $0314
  lda #>irq_25
  sta $0315
  lda #%00000001	// Enable raster interrupt to VIC
  sta $d01a
  
  asl $d019				// Ack any previous raster interrupt
  bit $dc0d				// reading the interrupt control registers 
  bit $dd0d				// clears them

	lda #00					// Clear border garbage
	sta $3fff

	lda #13					// Initialize the Sprite registers
	sta ENTER

	lda #$0D				// Using block 13 for Sprite 0
	sta $7f8
	lda #$0E				// Using block 13 for Sprite 0
	sta $7f9
	lda #$0F				// Using block 13 for Sprite 0
	sta $7fA



	lda #%00000111					// Enable sprite 0
	sta $D015

	lda #$07				// multicolor register 0 to yellow
	sta $d025
	lda #$0e				// multicolor register 1 to blue
	sta $d026

	lda #%00000111	// Enable sprite 0-2
	sta $d01c

	lda #0					// Sprite MSB X to 0
	sta $D010

	ldx #100				// Set X position of sprite 0
	stx $D000
	ldx #148				// Set X position of sprite 1
	stx $D002			
	ldx #196				// Set X position of sprite 2
	stx $D004

	ldy #70					// Set Y position of sprite
	sty $D001				// Set y for sprite 0
	sty $D003				// Set y for sprite 1
	sty $D005				// Set y for sprite 2

	lda #%00000111	// sprite 0-2 double size 
	sta $D01D				// Double X
	sta $D017				// Double Y

	ldx #0					// Copy sprite into sprite memory
!loop:
	lda defeest_sprite0, x
	sta $0340, x
	lda defeest_sprite1, x
	sta $0340+64, x
	lda defeest_sprite2, x
	sta $0340+128, x
	inx 
	cpx #63
	bne !loop-

  cli

	rts

	jmp *			// Endless loop

// Interrupt handler set screen to 25 colums
irq_25:
	lda #7					// Border to yellow
	sta $d020

	lda $d011				// Set bit 3 to enable 25 line mode
	ora #%00001000
	sta $d011

	lda #249				// raster interrupt at the end of the screen
	sta $d012 
	lda #<irq_24
	ldx #>irq_24
	sta $0314
	stx $0315

	lda #0					// Border to black
	sta $d020

  asl $d019				// Acknowledge interrupt 
  jmp $ea81				// Jump to kernal interrupt routine

// Interrupt handler set screen to 24 columns 
irq_24:
	lda #1					// Border to white
	sta $d020

	lda $d011				// Clear bit 3 to enable 24 line mode
	and #%11110111
	sta $d011

	lda #252				// raster interrupt at the beginning of the screen
	sta $d012
	lda #<irq_25
	ldx #>irq_25
	sta $0314
	stx $0315

	lda #0					// Border to black
	sta $d020

	inc $D001				// Sprite position Y inc 0
	inc $D003				// Sprite position Y inc 1
	inc $D005				// Sprite position Y inc 2

  asl $d019				// Acknowledge interrupt 
  jmp $ea81				// Jump to kernal interrupt routine

// define the sprite data
.pc = $3000 "Sprite"
.align $40

data_balloon:
// Baloon sprite 
//.byte 1,254,0
//.byte 6,1,128
//.byte 8,0,64
//.byte 13,85,192
//.byte 16,0,32
//.byte 19,128,32
//.byte 18,64,32
//.byte 18,73,32
//.byte 19,149,160
//.byte 18,157,96
//.byte 10,85,64
//.byte 4,0,128
//.byte 6,171,128
//.byte 2,1,0
//.byte 1,2,0
//.byte 0,252,0
//.byte 0,132,0
//.byte 0,164,0
//.byte 1,254,0
//.byte 1,86,0
//.byte 1,254,0

;// sprite0
defeest_sprite0:
.byte $00,$15,$55
.byte $05,$55,$55
.byte $05,$55,$55
.byte $15,$55,$55
.byte $15,$55,$5F
.byte $15,$55,$7F
.byte $15,$55,$F7
.byte $15,$57,$F7
.byte $15,$5F,$D7
.byte $15,$5F,$D7
.byte $05,$5F,$D7
.byte $05,$5F,$FF
.byte $01,$57,$FF
.byte $00,$57,$FF
.byte $00,$55,$FF
.byte $00,$15,$7F
.byte $00,$05,$57
.byte $00,$00,$55
.byte $00,$00,$15
.byte $00,$00,$05
.byte $00,$00,$00
.byte 0
;// sprite1
defeest_sprite1:
.byte $55,$54,$00
.byte $55,$55,$50
.byte $55,$55,$54
.byte $FF,$F5,$55
.byte $FF,$FF,$D5
.byte $FF,$FF,$FF
.byte $FF,$FF,$FF
.byte $5F,$FF,$FF
.byte $5F,$FF,$FF
.byte $7F,$FF,$FF
.byte $5D,$75,$D7
.byte $FD,$F7,$DF
.byte $FD,$F7,$DF
.byte $FD,$75,$D7
.byte $FD,$F7,$DF
.byte $FD,$F7,$DF
.byte $FD,$F5,$D7
.byte $7F,$FF,$FF
.byte $55,$FF,$FF
.byte $55,$55,$55
.byte $00,$55,$55
.byte 0
;// sprite2
defeest_sprite2:
.byte $00,$00,$00
.byte $00,$00,$00
.byte $00,$00,$00
.byte $40,$00,$00
.byte $50,$00,$00
.byte $55,$00,$00
.byte $F5,$40,$00
.byte $FD,$50,$00
.byte $FF,$50,$00
.byte $FF,$D4,$00
.byte $D5,$75,$00
.byte $7D,$F5,$00
.byte $7D,$FD,$00
.byte $5D,$FD,$00
.byte $DD,$F5,$00
.byte $DD,$F5,$00
.byte $7D,$D4,$00
.byte $FF,$50,$00
.byte $55,$40,$00
.byte $55,$00,$00
.byte $40,$00,$00
.byte 0

