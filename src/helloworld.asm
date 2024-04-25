.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA

  ;Update tiles *after* DMA transfer
  JSR update_player
  JSR draw_player

  LDA #$00
  STA $2005
  STA $2005
  RTI
.endproc

.import reset_handler


.proc draw_player
  ;save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ;write player ship tile numbers

  LDA #$05
  STA $0201
  LDA #$06
  STA $0205
  LDA #$07
  STA $0209
  LDA #$08
  STA $020D

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020A
  STA $020E

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ;top right tile (x+8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ;bottom left tile (y+8)
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020B

  ;bottom right tile (x+8, y+8)
  LDA player_y
  CLC
  ADC #$08
  STA $020C
  LDA player_x
  CLC
  ADC #$08
  STA $020F

  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc update_player
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player_x
  CMP #$e0
  BCC not_at_right_edge
  ; if BCC is not taken, we are greater than $e0
  LDA #$00
  STA player_dir    ; start moving left
  JMP direction_set ; we already chose a direction,
                    ; so we can skip the left side check
not_at_right_edge:
  LDA player_x
  CMP #$10
  BCS direction_set
  ; if BCS not taken, we are less than $10
  LDA #$01
  STA player_dir ; start moving right
direction_set:
  ; now, actually update player_x
  LDA player_dir
  CMP #$01
  BEQ move_right
  ; if player_dir minus $01 is not zero,
  ; that means player_dir was $00 and
  ; we need to move left
  DEC player_x
  JMP exit_subroutine
move_right:
  INC player_x
exit_subroutine:
  ; all done, clean up an return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP 
  RTS
.endproc

.export main
.proc main

  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR

  LDX #$00
load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes

  LDX #$00

  ; write a nametable
  ; Big Stars

  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$72
  STA PPUADDR
  LDX #$2F
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR
  LDA #$68
  STA PPUADDR
  LDX #$2F
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR
  LDA #$74
  STA PPUADDR
  LDX #$2F
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$5A
  STA PPUADDR
  LDX #$2F
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$CB
  STA PPUADDR
  LDX #$2F
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$64
  STA PPUADDR
  LDX #$2F
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$22
  STA PPUADDR
  LDA #$C7
  STA PPUADDR
  LDX #$2F
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$22
  STA PPUADDR
  LDA #$55
  STA PPUADDR
  LDX #$2F
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$22
  STA PPUADDR
  LDA #$B9
  STA PPUADDR
  LDX #$2F
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$6D
  STA PPUADDR
  LDX #$2F
  STX PPUDATA

  ; write a nametable
  ; Medium Stars

  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR
  LDA #$64
  STA PPUADDR
  LDX #$2D
  STX PPUDATA
  
  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR
  LDA #$4F
  STA PPUADDR
  LDX #$2D
  STX PPUDATA
  
  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR
  LDA #$B9
  STA PPUADDR
  LDX #$2D
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR
  LDA #$DD
  STA PPUADDR
  LDX #$2D
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$4D
  STA PPUADDR
  LDX #$2D
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR
  LDA #$D1
  STA PPUADDR
  LDX #$2D
  STX PPUDATA

  ; write a nametable
  ; Small Stars
  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR
  LDA #$3A
  STA PPUADDR
  LDX #$2E
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR
  LDA #$B9
  STA PPUADDR
  LDX #$2E
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$4D
  STA PPUADDR
  LDX #$2E
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$4D
  STA PPUADDR
  LDX #$2E
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$F0
  STA PPUADDR
  LDX #$2E
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$22
  STA PPUADDR
  LDA #$26
  STA PPUADDR
  LDX #$2E
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$22
  STA PPUADDR
  LDA #$E4
  STA PPUADDR
  LDX #$2E
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$22
  STA PPUADDR
  LDA #$CE
  STA PPUADDR
  LDX #$2E
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$36
  STA PPUADDR
  LDX #$2E
  STX PPUDATA

  ; finally, attribute table
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D4
	STA PPUADDR
	LDA #%01110000
	STA PPUDATA

vblankwait: ; wait for another vblank before continuing
  BIT PPUSTATUS 
  BPL vblankwait

  LDA #%10010000 ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110 ; turn on screen
  STA PPUMASK
forever:
  JMP forever
.endproc

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir: .res 1
.exportzp player_x, player_y

.segment "RODATA"
palettes:
  .byte $0f, $12, $23, $27
  .byte $0f, $2b, $3c, $39
  .byte $0f, $0c, $07, $13
  .byte $0f, $19, $09, $29

  .byte $0f, $2d, $10, $15
  .byte $0f, $19, $09, $29
  .byte $0f, $19, $09, $29
  .byte $0f, $19, $09, $29

sprite:
  .byte $70, $05, $00, $80
  .byte $70, $06, $00, $88
  .byte $78, $07, $00, $80
  .byte $78, $08, $00, $88

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "starfield.chr"