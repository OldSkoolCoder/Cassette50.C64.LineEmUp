#importonce
#import "C64Constants.asm"

* = * "Data Section"

.label ZP1          = $C1
.label ZeroPageLo   = $C3
.label ZeroPageHi   = $C4

// .label ZP1          = $45
// .label ZeroPageLo   = $47
// .label ZeroPageHi   = $48

.label BoardArray   = $033C
.label MoveArray    = BoardArray + 110

.label var_B        = $02A7
.label var_N        = var_B + 1
.label var_CT       = var_N + 1
.label var_MV       = var_CT + 1
.label var_Human    = var_MV + 1
.label var_Computer = var_Human + 1
.label var_K        = var_Computer + 1
.label var_J        = var_K + 1
.label var_Z        = var_J + 1
.label var_Empty    = var_Z + 1
.label var_X        = var_Empty + 1
.label var_Test     = var_X + 1

.label scrRowLo     = var_Test + 1
.label scrRowHi     = scrRowLo + 25
.label var_Another  = scrRowHi + 25





// Format :
// .byte X, Y
// .text "message"
// .byte 0

TitleScreen:
.byte 14,1
.text "LINE 'EM UP"
.byte 0

txtBoardLine:
.byte 1,17
.text "1 2 3 4 5 6 7"
.byte 0

txtYourMove:
.byte 0, 20
.text "YOUR MOVE, WHICH COLUMN DO YOU WISH?"
.byte 0

txtYouCantMoveThere:
.byte 0,22
.text "YOU CANT MOVE THERE"
.byte 0

txtYouhaveWonHuman:
.byte 0,20
.text "YOU'VE BEATEN ME, HUMAN!!!"
.byte 0

txtYouhaveWonComputer:
.byte 0,20
.text "I'VE DEFEATED YOU, HUMAN!!!!"
.byte 0

txtStandByForTheComputer:
.byte 0,20
.text "STAND BY FOR MY MOVE"
.byte 0

txtIThinkWeshouldCallItADraw:
.byte 0,20
.text "I THINK WE SHOULD CALL IT A DRAW"
.byte 0

txtPlayAgain:
.byte 0, 22
.text "PRESS SPACE TO PLAY AGAIN"
.byte 0

txtComputerTile:
.byte 18, 6, CHR_Yellow ,CHR_ReverseOn, CHR_Space, CHR_ReverseOff, CHR_White
.text ": COMPUTERS TILE"
.byte 0

txtHumanTile:
.byte 18, 8, CHR_Blue ,CHR_ReverseOn, CHR_Space, CHR_ReverseOff, CHR_White
.text ": HUMANS TILE"
.byte 0

txtCodedBy:
.byte 18, 12
.text "CODED BY :"
.byte 0

txtOldSkoolCoder:
.byte 26, 13
.text "OLDSKOOLCODER"
.byte 0

txtVersionNumber:
.byte 30,23
.text "VSN 1.0.2"
.byte 0