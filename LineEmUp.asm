#import "C64Constants.asm"

BasicUpstart2(start)

#import "Memory.asm"

* = * "Code Section"
// =============================================================================
start:
    jsr InitialiseTheGame
    jsr PrintBoard

TryAgain:
    jsr GetUsersChoice
    //jsr PrintBoard
    jsr ShowBoardState
    ldy #0
    ldx #20
    jsr ClearAt
    ldy #0
    ldx #22
    jsr ClearAt
    jsr WinCheck
    jsr ComputersMove
    //jsr PrintBoard
    jsr ShowBoardState
    ldy #0
    ldx #20
    jsr ClearAt
    jsr WinCheck
    ldy #0
    ldx #22
    jsr ClearAt


    lda var_Another
    beq TryAgain

    ldy #>txtPlayAgain
    lda #<txtPlayAgain
    jsr PrintAtString

!ReScanKeybaord:
    lda krljmpLSTX
    cmp #scanCode_SPACEBAR
    bne !ReScanKeybaord-
    lda #0
    sta 198

    jmp start














// =============================================================================

InitialiseTheGame:
    lda #CHR_ClearScreen
    jsr krljmp_CHROUT

    lda #BLACK
    sta VIC_EXTCOL
    sta VIC_BGCOL0

    lda #'.'
    sta var_Empty
    lda #'C'
    sta var_Computer
    lda #'H'
    sta var_Human

    ldy #0
    sty var_Another
    lda #255
!ArrayLoop:
    sta BoardArray,y
    iny
    cpy #110
    bne !ArrayLoop-

    lda var_Empty
    ldy #11
!OutSideLoop:
    ldx #0
!InSideLoop:
    sta BoardArray,y
    iny
    inx
    cpx #7
    bcc !InSideLoop-
    iny
    iny
    iny
    cpy #80
    bcc !OutSideLoop-

    ldy #0
    sty ZP1
    sty var_Another
    lda #$04
    sta ZP1 + 1
!ScreenRowLooper:
    lda ZP1
    sta scrRowLo,y
    lda ZP1 + 1
    sta scrRowHi,y
    clc
    lda ZP1
    adc #40
    sta ZP1
    bcc !ByPassInc+
    inc ZP1 + 1
!ByPassInc:
    iny
    cpy #25
    bne !ScreenRowLooper-

    rts

// =============================================================================

PrintBoard:
    lda #CHR_White
    jsr krljmp_CHROUT
    lda #CHR_ClearScreen
    jsr krljmp_CHROUT
    lda #CHR_CursorDown
    jsr krljmp_CHROUT
    jsr krljmp_CHROUT

    ldx #3
!RowLooper:
    lda scrRowLo,x
    sta ZP1
    lda scrRowHi,x
    sta ZP1 + 1
    ldy #1
!ColumnLooper:
    lda #207
    sta (ZP1),y
    iny
    lda #208
    sta (ZP1),y
    iny
    cpy #14
    bcc !ColumnLooper-
    inx
    inx
    cpx #16
    bcc !RowLooper-


    ldx #4
!RowLooper:
    lda scrRowLo,x
    sta ZP1
    lda scrRowHi,x
    sta ZP1 + 1
    ldy #1
!ColumnLooper:
    lda #204
    sta (ZP1),y
    iny
    lda #250
    sta (ZP1),y
    iny
    cpy #14
    bcc !ColumnLooper-
    inx
    inx
    cpx #17
    bcc !RowLooper-

    ldy #>txtBoardLine
    lda #<txtBoardLine
    jsr PrintAtString

    ldy #>TitleScreen
    lda #<TitleScreen
    jsr PrintAtString

    ldy #>txtComputerTile
    lda #<txtComputerTile
    jsr PrintAtString

    ldy #>txtHumanTile
    lda #<txtHumanTile
    jsr PrintAtString

    ldy #>txtCodedBy
    lda #<txtCodedBy
    jsr PrintAtString

    ldy #>txtOldSkoolCoder
    lda #<txtOldSkoolCoder
    jsr PrintAtString

    ldy #>txtVersionNumber
    lda #<txtVersionNumber
    jsr PrintAtString

    rts

// =============================================================================

GetUsersChoice:
    ldy #>txtYourMove
    lda #<txtYourMove
    jsr PrintAtString    
    jsr bas_INLINE
    lda #1
    ldx #$ff
    sta $7b
    stx $7a
    jsr bas_CHRGET
    jsr bas_GETBYTC
    stx var_J

!DecendPiece:
    txa
    clc
    adc #10
    sta var_Z
    tax

    clc
    adc #10
    tay
    // A(Z+10) = E
    lda BoardArray,y
    cmp var_Empty
    beq !DecendPiece-

    // A(Z) = E
    lda BoardArray,x
    cmp var_Empty
    bne !LocationTaken+
    lda var_Human
    sta BoardArray,x
    rts

!LocationTaken:
    ldy #>txtYouCantMoveThere
    lda #<txtYouCantMoveThere
    jsr PrintAtString    
    jmp GetUsersChoice


WinCheck:
    // 690 X = H
    lda var_Human
    sta var_X

    // 700 B = 10
BASICLine_700:
    lda #10
    sta var_B

    // 710 B = B + 1
BASICLine_710:
    inc var_B

    // 720 IF A(B) <> X THEN 770
BASICLine_720:
    ldy var_B
    ldx var_X
    jsr PositionNotEqualsCheck
    bcc BASICLine_730
    jmp BASICLine_770

BASICLine_730:
    // 730 IF A(B+1) = X AND A(B+2) = X AND A(B+3) = X THEN 800

    lda #1
    jsr WinCheck3LineTest
    bcc BASICLine_740
    jmp BASICLine_800

BASICLine_740:
    // 740 IF B > 30 THEN IF A(B-10) = X AND A(B-20) = X AND A(B-30) = X THEN 800

    lda var_B
    cmp #30
    bcc BASICLine_750

    lda #$F6
    jsr WinCheck3LineTest
    bcc BASICLine_750
    jmp BASICLine_800

BASICLine_750:
    // 750 IF B > 33 THEN IF A(B-11) = X AND A(B-22) = X AND A(B-33) = X THEN 800

    lda var_B
    cmp #33
    bcc BASICLine_760

    lda #$F5
    jsr WinCheck3LineTest
    bcc BASICLine_760
    jmp BASICLine_800

BASICLine_760:
    // 760 IF B > 27 THEN IF A(B-9) = X AND A(B-18) = X AND A(B-27) = X THEN 800

    lda var_B
    cmp #27
    bcc BASICLine_770

    lda #$F7
    jsr WinCheck3LineTest
    bcc BASICLine_770
    jmp BASICLine_800

    // 770 IF B < 77 THEN 710
BASICLine_770:
    lda var_B
    cmp #77
    bcs BASICLine_780
    jmp BASICLine_710

    // 780 IF X = H THEN X = C : GOTO 700
BASICLine_780:
    lda var_X
    cmp var_Human
    bne BASICLine_790
    lda var_Computer
    sta var_X
    jmp BASICLine_700

    // 790 RETURN
BASICLine_790:
    rts

BASICLine_800:
WinFound:
    lda var_X
    cmp var_Human
    bne BASICLine_830
    lda #<txtYouhaveWonHuman
    ldy #>txtYouhaveWonHuman
    jsr PrintAtString
    lda #$FF
    sta var_Another
    jmp BASICLine_840

BASICLine_830:
    lda var_X
    cmp var_Computer
    bne BASICLine_840
    lda #<txtYouhaveWonComputer
    ldy #>txtYouhaveWonComputer
    jsr PrintAtString
    lda #$FF
    sta var_Another

BASICLine_840:
    rts


ComputersMove:
    // 120 PRINT:PRINT "stand by for my move *** "
    lda #<txtStandByForTheComputer
    ldy #>txtStandByForTheComputer
    jsr PrintAtString

    // 130 B = 10
    lda #10
    sta var_B

BASICLine_140:
    // 140 B = B + 1
    inc var_B

    // 150 IF A(B) = - 9 THEN 180
    ldy var_B
    lda BoardArray,y
    cmp #$FF
    beq BASICLine_180

    // 160 IF A(B) = C THEN X = C : GOTO 210
    cmp var_Computer
    bne BASICLine_170
    lda var_Computer
    sta var_X
    jmp BASICLine_210

BASICLine_170:
    // 170 IF A(B) = H THEN X = H : GOTO 210
    cmp var_Human
    bne BASICLine_180
    lda var_Human
    sta var_X
    jmp BASICLine_210

BASICLine_180:
    // 180 IF B < 77 THEN 140
    lda var_B
    cmp #77
    bcc BASICLine_140
    
    // 190 GOTO 480
    jmp BASICLine_480

    // 200 REM **************************
BASICLine_210:
    // 210 REM FOUR IN ROW DANGER/CHANCE?
    // 220 REM ACROSS

    // 230 IF A(B+1) = X AND A(B+2) = X AND A(B+3) = E AND A(B + 13) <> E THEN MV = B + 3 : GOTO 650

    lda #1
    ldx #2
    ldy #3
    jsr ComputerMove4LineTest
    bcc BASICLine_240
    jmp BASICLine_650

BASICLine_240:
    // 240 IF A(B-1) = X AND A(B-2) = X AND A(B-3) = E AND A(B + 7) <> E THEN MV = B - 3 : GOTO 650

    lda #$FF
    ldx #$FE
    ldy #$FD
    jsr ComputerMove4LineTest
    bcc BASICLine_250
    jmp BASICLine_650

BASICLine_250:
    // 250 IF A(B+1) = X AND A(B+2) = X AND A(B-1) = E AND A(B + 9) <> E THEN MV = B - 1 : GOTO 650

    lda #1
    ldx #2
    ldy #$FF
    jsr ComputerMove4LineTest
    bcc BASICLine_260
    jmp BASICLine_650

BASICLine_260:
    // 260 IF A(B-1) = X AND A(B+2) = X AND A(B+1) = E AND A(B + 11) <> E THEN MV = B + 1 : GOTO 650

    lda #$FF
    ldx #$02
    ldy #$01
    jsr ComputerMove4LineTest
    bcc BASICLine_270
    jmp BASICLine_650

BASICLine_270:
    // 270 IF A(B+1) = X AND A(B-1) = X AND A(B+2) = E AND A(B + 12) <> E THEN MV = B + 2 : GOTO 650

    lda #$01
    ldx #$FF
    ldy #$02
    jsr ComputerMove4LineTest
    bcc BASICLine_280
    jmp BASICLine_650

BASICLine_280:
    // 280 IF A(B+1) = X AND A(B-1) = X AND A(B-2) = E AND A(B + 8) <> E THEN MV = B - 2 : GOTO 650

    lda #$01
    ldx #$FF
    ldy #$FE
    jsr ComputerMove4LineTest
    bcc BASICLine_290
    jmp BASICLine_650

BASICLine_290:
    // 290 IF A(B-1) = X AND A(B-2) = X AND A(B+1) = E AND A(B + 11) <> E THEN MV = B + 1 : GOTO 650

    lda #$FF
    ldx #$FE
    ldy #$01
    jsr ComputerMove4LineTest
    bcc BASICLine_310
    jmp BASICLine_650

    // 300 REM DOWN
BASICLine_310:
    // 310 IF B > 20 THEN IF A(B-10) = X AND A(B-20) = X AND A(B+10) = E AND A(B+20) <> E THEN MV = B + 10 : GOTO 650

    ldy var_B
    cpy #21         // >=21 => >20
    bcc BASICLine_330

    lda #$F6
    ldx #$EC
    ldy #$0A
    jsr ComputerMove4LineTest
    bcc BASICLine_330
    jmp BASICLine_650

    // 320 REM DIAGONALS
BASICLine_330:
    // 330 IF A(B+11) = X AND A(B+22) = X AND A(B-11) = E AND A(B-1) <> E THEN MV = B-11 : GOTO 650

    lda #$0B
    ldx #$16
    ldy #$F5
    jsr ComputerMove4LineTest
    bcc BASICLine_340
    jmp BASICLine_650
    
BASICLine_340:
    // 340 IF A(B+9) = X AND A(B+18) = X AND A(B-9) = E AND A(B+1) <> E THEN MV = B - 9:GOTO 650

    lda #$09
    ldx #$12
    ldy #$F7
    jsr ComputerMove4LineTest
    bcc BASICLine_380
    jmp BASICLine_650

    // 350 REM *****************
    // 360 REM MAKE/BLOCK THREE?
    // 370 REM ACROSS
BASICLine_380:
    // 380 IF A(B+1) = X AND A(B+2) = E AND A(B+12) <> E THEN MV = B + 2 : GOTO 650

    lda #1
    ldx #2
    jsr ComputerMove3LineTest
    bcc BASICLine_390
    jmp BASICLine_650

BASICLine_390:
    // 390 IF A(B+1) = X AND A(B-1) = E AND A(B+9) <> E THEN MV = B - 1 : GOTO 650

    lda #1
    ldx #$FF
    jsr ComputerMove3LineTest
    bcc BASICLine_400
    jmp BASICLine_650

BASICLine_400:
    // 400 IF A(B-1) = X AND A(B-2) = E AND A(B+8) <> E THEN MV = B - 2 : GOTO 650

    lda #$FF
    ldx #$FE
    jsr ComputerMove3LineTest
    bcc BASICLine_420
    jmp BASICLine_650

    // 410 REM VERTICAL
BASICLine_420:
    // 420 IF A(B+10) = X AND A(B-10) = E AND A(B) <> E THEN MV = B - 10 : GOTO 650

    lda #$0A
    ldx #$F6
    jsr ComputerMove3LineTest
    bcc BASICLine_440
    jmp BASICLine_650

    // 430 REM DIAGONAL
BASICLine_440:
    // 440 IF A(B+9) = X AND A(B-9) = E AND A(B+1) <> E THEN MV = B - 9 : GOTO 650

    lda #$09
    ldx #$F7
    jsr ComputerMove3LineTest
    bcc BASICLine_450
    jmp BASICLine_650

BASICLine_450:
    // 450 IF B > 11 THEN IF A(B+11) = X AND A(B-11) = E AND A(B-1) <> E THEN MV = B - 11 : GOTO 650
    lda var_B
    cmp #12
    bcc BASICLine_460

    lda #$0B
    ldx #$F5
    jsr ComputerMove3LineTest
    bcc BASICLine_460
    jmp BASICLine_650

BASICLine_460:
    jmp BASICLine_180
    // 460 GOTO 180
    // 470 REM ***************

BASICLine_480:
    // 480 REM SINGLE MVS
    // 490 FOR N = 1 TO 3
    // 500 M(N) = 0
    // 510 NEXT N
    ldy #0
    lda #0
!ForNLoop:
    sta MoveArray,y
    iny
    cpy #3
    bne !ForNLoop-

    // 520 CT = 0
    lda #0
    sta var_CT

    // 530 FOR B = 11 TO 77
    lda #11
    sta var_B

BASICLine_540:    
    jsr ResetTestVar
    // 540 IF A(B) <> C AND A(B) <> H THEN 600

    ldy var_B
    ldx var_Computer
    jsr PositionNotEqualsCheck
    rol var_Test

    ldx var_Human
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000011
    bne BASICLine_550
    jmp BASICLine_600

BASICLine_550:
    // 550 IF A(B+1) = E AND A(B+11) <> E THEN CT = CT + 1 : M(CT) = B + 1

    lda #1
    jsr ComputerPossibleMove2LineTest
    bcc BASICLine_560
    jmp BASICLine_600

BASICLine_560:
    // 560 IF A(B-1) = E AND A(B+9) <> E THEN CT = CT + 1 : M(CT) = B - 1

    lda #$FF
    jsr ComputerPossibleMove2LineTest
    bcc BASICLine_570
    jmp BASICLine_600

BASICLine_570:
    // 570 IF A(B-10) = E AND A(B) <> E THEN CT = CT + 1 : M(CT) = B - 10

    lda #$F6
    jsr ComputerPossibleMove2LineTest
    bcc BASICLine_580
    jmp BASICLine_600

BASICLine_580:
    // 580 IF A(B-11) = E AND A(B-1) <> E THEN CT = CT + 1 : M(CT) = B - 11

    lda #$F5
    jsr ComputerPossibleMove2LineTest
    bcc BASICLine_590
    jmp BASICLine_600

BASICLine_590:
    // 590 IF A(B-9) = E AND A(B+1) <> E THEN CT = CT + 1 : M(CT) = B - 9
    lda #$F7
    jsr ComputerPossibleMove2LineTest

BASICLine_600:
    // 600 NEXT B
    inc var_B
    lda var_B
    cmp #78
    bcs BASICLine_610
    jmp BASICLine_540

BASICLine_610:
    // 610 IF CT <> 0 THEN 640
    lda var_CT
    bne BASICLine_640

    // 620 PRINT:PRINT "i think we should call it a draw"
    ldy #>txtIThinkWeshouldCallItADraw
    lda #<txtIThinkWeshouldCallItADraw
    jsr PrintAtString    
    lda #$FF
    sta var_Another

    // 630 PRINT:PRINT:PRINT:END
    rts

BASICLine_640:
    // 640 MV = M(INT(RND(TI)*CT) + 1)
    lda $d012 
    eor $dc04
    cmp var_CT
    bcs BASICLine_640
    tay
    lda MoveArray,y
    sta var_MV

BASICLine_650:
    // 650 A(MV) = C
    lda var_Computer
    ldy var_MV
    sta BoardArray,y

    // 660 RETURN
    rts

#import "Utilities.asm"