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
    jsr PrintBoard
    jsr WinCheck
    jsr ComputersMove
    jsr PrintBoard
    jsr WinCheck

    jmp TryAgain















// =============================================================================

InitialiseTheGame:
    lda #CHR_ClearScreen
    jsr krljmp_CHROUT

    lda #'.'
    sta var_Empty
    lda #'C'
    sta var_Computer
    lda #'H'
    sta var_Human

    ldy #0
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
    rts

// =============================================================================

PrintBoard:
    lda #CHR_ClearScreen
    jsr krljmp_CHROUT
    lda #CHR_CursorDown
    jsr krljmp_CHROUT
    jsr krljmp_CHROUT

    lda #10
    sta var_K

!KOuterLoop:
    ldy #>txtTab
    lda #<txtTab
    jsr bas_PrintString

    lda #1
    sta var_J

!JInnerLoop:
    lda var_K
    clc
    adc var_J
    tay
    lda BoardArray,y
    jsr krljmp_CHROUT
    lda #CHR_Space
    jsr krljmp_CHROUT

    inc var_J
    lda var_J
    cmp #8
    bcc !JInnerLoop-
    lda #CHR_Return
    jsr krljmp_CHROUT
    lda var_K
    clc
    adc #10
    sta var_K
    cmp #79
    bcc !KOuterLoop-
    ldy #>txtBoardLine
    lda #<txtBoardLine
    jsr bas_PrintString
    lda #CHR_Return
    jsr krljmp_CHROUT
    jsr krljmp_CHROUT
    rts

// =============================================================================

GetUsersChoice:
    ldy #>txtYourMove
    lda #<txtYourMove
    jsr bas_PrintString    
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
    jsr bas_PrintString    
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

    // 730 IF A(B+1) = X AND A(B+2) = X AND A(B+3) = X THEN 800
BASICLine_730:
    lda #0
    sta var_Test            // Reset Test Variable

    ldy var_B
    iny
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test                // 0000 0001
    iny
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test                // 0000 0011
    iny
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test                // 0000 0111

    lda var_Test
    cmp #%00000111
    bne BASICLine_740
    jmp BASICLine_800

    // 740 IF B > 30 THEN IF A(B-10) = X AND A(B-20) = X AND A(B-30) = X THEN 800
BASICLine_740:
    lda #0
    sta var_Test            // Reset Test Variable

    lda var_B
    cmp #30
    bcc BASICLine_750
    lda var_B
    sec
    sbc #10
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test
    pla
    sec
    sbc #10             // -20
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test
    pla
    sec
    sbc #10             // -30
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000111
    bne BASICLine_750
    jmp BASICLine_800

    // 750 IF B > 33 THEN IF A(B-11) = X AND A(B-22) = X AND A(B-33) = X THEN 800
BASICLine_750:
    lda #0
    sta var_Test            // Reset Test Variable

    lda var_B
    cmp #33
    bcc BASICLine_760
    lda var_B
    sec
    sbc #11
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test
    pla
    sec
    sbc #11             // -22
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test
    pla
    sec
    sbc #11             // -33
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000111
    bne BASICLine_760
    jmp BASICLine_800

    // 760 IF B > 27 THEN IF A(B-9) = X AND A(B-18) = X AND A(B-27) = X THEN 800
BASICLine_760:
    lda #0
    sta var_Test            // Reset Test Variable

    lda var_B
    cmp #27
    bcc BASICLine_770
    lda var_B
    sec
    sbc #9
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test
    pla
    sec
    sbc #9              // -18
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test
    pla
    sec
    sbc #9              // -27
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000111
    bne BASICLine_770
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
    jsr PrintString

BASICLine_830:
    lda var_X
    cmp var_Computer
    bne BASICLine_840
    lda #<txtYouhaveWonComputer
    ldy #>txtYouhaveWonComputer
    jsr PrintString

BASICLine_840:
    rts


ComputersMove:
    // 120 PRINT:PRINT "stand by for my move *** "
    lda #<txtStandByForTheComputer
    ldy #>txtStandByForTheComputer
    jsr PrintString

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
    jsr ResetTestVar

    // 220 REM ACROSS
    // 230 IF A(B+1) = X AND A(B+2) = X AND A(B+3) = E AND A(B + 13) <> E THEN MV = B + 3 : GOTO 650

    ldy var_B
    iny
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    iny
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    iny
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    tya
    clc
    adc #10
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00001111
    bne BASICLine_240
    lda var_B
    clc
    adc #3
    sta var_MV
    jmp BASICLine_650

BASICLine_240:
    jsr ResetTestVar
    // 240 IF A(B-1) = X AND A(B-2) = X AND A(B-3) = E AND A(B + 7) <> E THEN MV = B - 3 : GOTO 650

    ldy var_B
    dey
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    dey
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    dey
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc #7
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00001111
    bne BASICLine_250
    lda var_B
    sec
    sbc #3
    sta var_MV
    jmp BASICLine_650

BASICLine_250:
    jsr ResetTestVar
    // 250 IF A(B+1) = X AND A(B+2) = X AND A(B-1) = E AND A(B + 9) <> E THEN MV = B - 1 : GOTO 650
    ldy var_B
    iny                             // B+1
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    iny                             // B+2
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    ldy var_B
    dey                             // B-1
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc #9
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00001111
    bne BASICLine_260
    ldy var_B
    dey
    sty var_MV
    jmp BASICLine_650

BASICLine_260:
    jsr ResetTestVar
    // 260 IF A(B-1) = X AND A(B+2) = X AND A(B+1) = E AND A(B + 11) <> E THEN MV = B + 1 : GOTO 650
    ldy var_B
    dey                             // B-1
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    iny
    iny
    iny                             // B+2
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    dey                             // B+1
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc #11
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00001111
    bne BASICLine_270
    ldy var_B
    iny
    sty var_MV
    jmp BASICLine_650

BASICLine_270:
    jsr ResetTestVar

    // 270 IF A(B+1) = X AND A(B-1) = X AND A(B+2) = E AND A(B + 12) <> E THEN MV = B + 2 : GOTO 650
    ldy var_B
    iny                             // B+1
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    dey
    dey                             // B-1
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    iny
    iny
    iny                             // B+2
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc #12
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00001111
    bne BASICLine_280
    ldy var_B
    iny
    iny
    sty var_MV
    jmp BASICLine_650

BASICLine_280:
    jsr ResetTestVar

    // 280 IF A(B+1) = X AND A(B-1) = X AND A(B-2) = E AND A(B + 8) <> E THEN MV = B - 2 : GOTO 650
    ldy var_B
    iny                             // B+1
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    dey
    dey                             // B-1
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    dey                             // B-2
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc #8
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00001111
    bne BASICLine_290
    ldy var_B
    dey
    dey
    sty var_MV
    jmp BASICLine_650

BASICLine_290:
    jsr ResetTestVar

    // 290 IF A(B-1) = X AND A(B-2) = X AND A(B+1) = E AND A(B + 11) <> E THEN MV = B + 1 : GOTO 650
    ldy var_B
    dey                             // B-1
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    dey                             // B-2
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    iny
    iny
    iny                             // B+1
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc #11
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00001111
    bne BASICLine_310
    ldy var_B
    iny
    sty var_MV
    jmp BASICLine_650

    // 300 REM DOWN

BASICLine_310:
    // 310 IF B > 20 THEN IF A(B-10) = X AND A(B-20) = X AND A(B+10) = E AND A(B+20) <> E THEN MV = B + 10 : GOTO 650
    ldy var_B
    cpy #21         // >=21 => >20
    bcc BASICLine_330

    jsr ResetTestVar

    lda var_B
    sec
    sbc #10                         // B-10
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    pla
    sec
    sbc #10                         // B-20
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc #10
    pha                             // B+10
    tay
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    pla
    clc
    adc #10                         // B + 20
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00001111
    bne BASICLine_330
    lda var_B
    clc
    adc #10
    sta var_MV
    jmp BASICLine_650

    // 320 REM DIAGONALS
BASICLine_330:
    jsr ResetTestVar
    // 330 IF A(B+11) = X AND A(B+22) = X AND A(B-11) = E AND A(B-1) <> E THEN MV = B-11 : GOTO 650
    lda var_B
    clc
    adc #11                         // B+11
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    pla
    clc
    adc #11                         // B+22
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    pla
    sec
    sbc #33                         // B-11
    tay
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    ldy var_B
    dey                             // B-1
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00001111
    bne BASICLine_340
    lda var_B
    sec
    sbc #11
    sta var_MV
    jmp BASICLine_650
    
BASICLine_340:
    jsr ResetTestVar
    // 340 IF A(B+9) = X AND A(B+18) = X AND A(B-9) = E AND A(B+1) <> E THEN MV = B - 9:GOTO 650
    lda var_B
    clc
    adc #9                          // B+9
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    pla
    clc
    adc #9                         // B+18
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    pla
    sec
    sbc #27
    tay
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    ldy var_B
    iny                             // B + 1
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00001111
    bne BASICLine_380
    lda var_B
    sec
    sbc #9
    sta var_MV
    jmp BASICLine_650

    // 350 REM *****************
    // 360 REM MAKE/BLOCK THREE?
    // 370 REM ACROSS
BASICLine_380:
    jsr ResetTestVar

    // 380 IF A(B+1) = X AND A(B+2) = E AND A(B+12) <> E THEN MV = B + 2 : GOTO 650
    ldy var_B
    iny                             // B+1
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    iny                             // B+2
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc #12
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000111
    bne BASICLine_390
    ldy var_B
    iny
    iny
    sty var_MV
    jmp BASICLine_650

BASICLine_390:
    jsr ResetTestVar

    // 390 IF A(B+1) = X AND A(B-1) = E AND A(B+9) <> E THEN MV = B - 1 : GOTO 650
    ldy var_B
    iny                             // B+1
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    dey
    dey                             // B-1
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc #9
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000111
    bne BASICLine_400
    ldy var_B
    dey
    sty var_MV
    jmp BASICLine_650

BASICLine_400:
    jsr ResetTestVar

    // 400 IF A(B-1) = X AND A(B-2) = E AND A(B+8) <> E THEN MV = B - 2 : GOTO 650
    ldy var_B
    dey                             // B-1
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    dey                             // B-2
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc #8
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000111
    bne BASICLine_420
    ldy var_B
    dey
    dey
    sty var_MV
    jmp BASICLine_650

BASICLine_420:
    jsr ResetTestVar
    // 410 REM VERTICAL
    // 420 IF A(B+10) = X AND A(B-10) = E AND A(B) <> E THEN MV = B - 10 : GOTO 650
    lda var_B
    clc
    adc #10                          // B+10
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    pla
    sec
    sbc #20                         // B-10
    tay
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    ldy var_B
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000111
    bne BASICLine_440
    lda var_B
    sec
    sbc #10
    sta var_MV
    jmp BASICLine_650

    // 430 REM DIAGONAL
BASICLine_440:
    jsr ResetTestVar

    // 440 IF A(B+9) = X AND A(B-9) = E AND A(B+1) <> E THEN MV = B - 9 : GOTO 650
    lda var_B
    clc
    adc #9                          // B+9
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    pla
    sec
    sbc #18                         // B-9
    tay
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    ldy var_B
    iny
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000111
    bne BASICLine_450
    lda var_B
    sec
    sbc #9
    sta var_MV
    jmp BASICLine_650

BASICLine_450:
    lda var_B
    cmp #12
    bcc BASICLine_460
    // 450 IF B > 11 THEN IF A(B+11) = X AND A(B-11) = E AND A(B-1) <> E THEN MV = B - 11 : GOTO 650

    jsr ResetTestVar

    lda var_B
    clc
    adc #11                          // B+11
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    pla
    sec
    sbc #22                         // B-11
    tay
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    ldy var_B
    dey
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000111
    bne BASICLine_460
    lda var_B
    sec
    sbc #11
    sta var_MV
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
    jsr ResetTestVar
    // 550 IF A(B+1) = E AND A(B+11) <> E THEN CT = CT + 1 : M(CT) = B + 1
    ldy var_B
    iny
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc #11                         // B+11
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000011
    bne BASICLine_560
    ldx var_CT
    ldy var_B
    iny
    tya
    sta MoveArray,x
    inc var_CT
    jmp BASICLine_600

BASICLine_560:
    jsr ResetTestVar
    // 560 IF A(B-1) = E AND A(B+9) <> E THEN CT = CT + 1 : M(CT) = B - 1
    ldy var_B
    dey
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc #9                         // B+11
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000011
    bne BASICLine_570
    ldx var_CT
    ldy var_B
    dey
    tya
    sta MoveArray,x
    inc var_CT
    jmp BASICLine_600

BASICLine_570:
    jsr ResetTestVar
    // 570 IF A(B-10) = E AND A(B) <> E THEN CT = CT + 1 : M(CT) = B - 10
    lda var_B
    sec
    sbc #10
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    ldy var_B
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000011
    bne BASICLine_580
    ldx var_CT
    lda var_B
    sec
    sbc #10
    tya
    sta MoveArray,x
    inc var_CT
    jmp BASICLine_600

BASICLine_580:
    jsr ResetTestVar
    // 580 IF A(B-11) = E AND A(B-1) <> E THEN CT = CT + 1 : M(CT) = B - 11
    lda var_B
    sec
    sbc #11
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    ldy var_B
    dey
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000011
    bne BASICLine_590
    ldx var_CT
    lda var_B
    sec
    sbc #11
    tya
    sta MoveArray,x
    inc var_CT
    jmp BASICLine_600

BASICLine_590:
    jsr ResetTestVar
    // 590 IF A(B-9) = E AND A(B+1) <> E THEN CT = CT + 1 : M(CT) = B - 9
    lda var_B
    sec
    sbc #9
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    ldy var_B
    iny
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000011
    bne BASICLine_600
    ldx var_CT
    lda var_B
    sec
    sbc #9
    tya
    sta MoveArray,x
    inc var_CT
    jmp BASICLine_600

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
    jsr bas_PrintString    

    // 630 PRINT:PRINT:PRINT:END
    brk

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