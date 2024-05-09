.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.import read_controller

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA

  ;Update tiles *after* DMA transfer
  JSR update_player
  JSR draw_player
  JSR read_controller


  LDA scroll
  CMP #$00
  BNE set_scroll_positions

  LDA ppucrtl_settings
  EOR #%00000010
  STA ppucrtl_settings
  STA PPUCTRL
  LDA #240
  STA scroll

set_scroll_positions:
  LDA #$00
  STA PPUSCROLL
  DEC scroll
  LDA scroll
  STA PPUSCROLL

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
  LDA #$03
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

  LDA pad1
  AND #BTN_LEFT
  BEQ check_right
  DEC player_x
  DEC player_x
check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up
  INC player_x
  INC player_x
check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down
  DEC player_y
  DEC player_y

check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ done_checking
  INC player_y
  INC player_y
done_checking:
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

  LDA #239
  STA scroll

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

load_background:
  LDX PPUSTATUS
  LDX #$20
  STX PPUADDR
  LDX #$00
  STX PPUADDR

  LDA #<background
  STA pointerLo
  LDA #>background
  STA pointerHi

  LDX #$00
  LDY #$00

outsideloop:

insideloop:
  LDA (pointerLo), y
  STA PPUDATA
  INY
  BNE insideloop

  INC pointerHi

  INX
  CPX #$04
  BNE outsideloop

load_background2:
  LDX PPUSTATUS
  LDX #$28
  STX PPUADDR
  LDX #$00
  STX PPUADDR

  LDA #<background2
  STA pointerLo
  LDA #>background2
  STA pointerHi

  LDX #$00
  LDY #$00

outsideloop2:

insideloop2:
  LDA (pointerLo), y
  STA PPUDATA
  INY
  BNE insideloop2

  INC pointerHi

  INX
  CPX #$04
  BNE outsideloop2

  LDA #%10010000
  STA ppucrtl_settings
  STA PPUCTRL

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
pointerLo: .res 1
pointerHi: .res 1
scroll: .res 1
ppucrtl_settings: .res 1
pad1: .res 1
.exportzp player_x, player_y
.exportzp pad1

.segment "RODATA"
palettes: .incbin "background.pal"

sprite:
  .byte $70, $05, $00, $80
  .byte $70, $06, $00, $88
  .byte $78, $07, $00, $80
  .byte $78, $08, $00, $88

background: .incbin "background.nam"
background2: .incbin "background2.nam"

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "starfield.chr"