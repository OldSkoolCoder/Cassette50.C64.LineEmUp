#import "Memory.asm"
#import "C64Constants.asm"

//******************************************************
// Inputs : X = Number to compare too
//        : Y = Index of BoardArray
// Output : Carry Clear = Not Equal Too
//        : Carry Set = Equal Too
//******************************************************
PositionEqualsCheck:
    stx EqualCheckByte
    lda BoardArray,y
    cmp EqualCheckByte: #$FF
    bne !NotEqualToo+
    sec
    rts
!NotEqualToo:
    clc
    rts

//******************************************************
// Inputs : X = Number to compare too
//        : Y = Index of BoardArray
// Output : Carry Set = Not Equal Too
//        : Carry Clear = Equal Too
//******************************************************
PositionNotEqualsCheck:
    jsr PositionEqualsCheck
    bcc !NotEqualToo+
    clc
    rts
!NotEqualToo:
    sec
    rts

//******************************************************
// Prints Text on the screen
// Inputs   : Acc = Low Byte of Target Text
//          : Y = Hi Byte of Target Text
//******************************************************
PrintString:
    jmp bas_PrintString

//******************************************************
// Prints Text at a certain point on the screen
// Inputs   : Acc = Low Byte of Target Text
//          : Y = Hi Byte of Target Text
//******************************************************
PrintAtString:
    sta ZeroPageLo
    sty ZeroPageHi
    ldy #0
    lda (ZeroPageLo),y
    pha
    iny
    lda (ZeroPageLo),y
    tax
    pla
    tay
    clc
    jsr krljmp_PLOT
    clc
    lda ZeroPageLo
    adc #2
    sta ZeroPageLo
    bcc !ByPassInc+
    inc ZeroPageHi
!ByPassInc:
    lda ZeroPageLo
    ldy ZeroPageHi
    jmp bas_PrintString

ResetTestVar:
    lda #0
    sta var_Test
    rts

//******************************************************
// WinCheck Line Test to check 3 elements of the grid
// for a 3 in a line senario
// Inputs   : Acc = Delta from var_B (1st Instance : x1)
//******************************************************
// IF A(dx1) = X AND A(2*dx2) = X AND A(3*dx3) = X
WinCheck3LineTest:
    sta wc3tdx1
    sta wc3tdx2
    sta wc3tdx3

    jsr ResetTestVar

    lda var_B
    clc
    adc wc3tdx1:#$FF
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test                // 0000 0001

    pla
    clc
    adc wc3tdx2:#$FF
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test                // 0000 0011

    pla
    clc
    adc wc3tdx3:#$FF
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test                // 0000 0111

    lda var_Test
    cmp #%00000111
    bne !LineFailedTest+
    // Line Passed Test
    sec
    jmp !Exit+

!LineFailedTest:
    clc

!Exit:
    rts

//******************************************************
// Works out all the possible moves the computer can take
// Inputs   : Acc = Delta from var_B (1st Instance : x1)
//******************************************************
// A(x1) = E and A(x1 + 10) <> E then CT = CT + 1 : M(CT) = B + x1

ComputerPossibleMove2LineTest:
    sta cp2tx1
    sta cp2tRes

    jsr ResetTestVar

    lda var_B
    clc
    adc cp2tx1:#$FF
    pha
    tay
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    pla
    clc
    adc #10
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000011
    bne !LineFailedTest+
    ldx var_CT
    lda var_B
    clc
    adc cp2tRes: #$FF
    sta MoveArray,x
    inc var_CT
    sec
    jmp !Exit+

!LineFailedTest:
    clc

!Exit:
    rts


//******************************************************
// Test 4 Elements in a row for possible moves
// Inputs   : Acc = X1
//          : X Reg = X2
//          : Y Reg = X3
//******************************************************
// Output : Carry Set = Line Is True
//        : Carry Clear = Line Is False
//******************************************************
// IF A(x1) = X AND A(x2) = X AND A(x3) = E AND A(x3+10) <> E THEN MV = B + x3
ComputerMove4LineTest:
    sta cm4ltx1
    stx cm4ltx2
    sty cm4ltx3
    sty cm4ltRes

    jsr ResetTestVar

    lda var_B
    clc
    adc cm4ltx1:#$FF
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc cm4ltx2:#$FF
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc cm4ltx3:#$FF
    pha
    tay
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    pla
    clc
    adc #10
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00001111
    bne !LineFailedTest+
    lda var_B
    clc
    adc cm4ltRes:#$FF
    sta var_MV
    sec
    jmp !Exit+

!LineFailedTest:
    clc

!Exit:
    rts


//******************************************************
// Test 3 Elements in a row for possible moves
// Inputs   : Acc = Test 1
//          : X = Test 2 and Result Add / Sub
//******************************************************
// Output : Carry Set = Line Is True
//        : Carry Clear = Line Is False
//******************************************************
// IF A(x1) = X AND A(x2) = E AND A(x2+10) <> E THEN MV = B + x2
ComputerMove3LineTest:
    sta cm3ltx1
    stx cm3ltx2
    stx cm3lRes

    jsr ResetTestVar

    lda var_B
    clc
    adc cm3ltx1:#$FF
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc cm3ltx2:#$FF
    pha
    tay
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    pla
    clc
    adc #10
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000111
    bne !LineFailedTest+
    lda var_B
    clc
    adc cm3lRes:#$FF
    sta var_MV
    sec
    jmp !Exit+

!LineFailedTest:
    clc

!Exit:
    rts

// =============================================================================
ShowBoardState:
    lda #11
    sta var_K
    lda #1
    sta var_X

!KOuterLoop:
    lda #0
    sta var_J

    lda var_X
    asl
    tax
    inx

    lda scrRowLo,x
    sta ZP1
    lda scrRowHi,x
    sta ZP1 + 1

    clc
    lda ZP1 + 1
    adc #$D4
    sta ZP1 + 1

!JInnerLoop:
    lda var_K
    clc
    adc var_J
    tay

    lda BoardArray,y
    pha

    lda var_J
    asl
    tay
    iny

    pla
    cmp var_Empty
    bne !NotEmpty+
    lda #WHITE
    jmp !PlaceCounter+

!NotEmpty:
    cmp var_Human
    bne !NotHuman+
    lda #BLUE
    jmp !PlaceCounter+

!NotHuman:
    lda #YELLOW

!PlaceCounter:
    pha
    sta (ZP1),y
    iny
    sta (ZP1),y
    tya
    clc
    adc #39
    tay
    pla
    sta (ZP1),y
    iny
    sta (ZP1),y

    inc var_J
    lda var_J
    cmp #8
    bcc !JInnerLoop-
    inc var_X
    lda var_K
    clc
    adc #10
    sta var_K
    cmp #79
    bcc !KOuterLoop-
    rts

//******************************************************
// Clears Line of the Screen
// Inputs   : X = Row
//          : Y = Column
//******************************************************
ClearAt:
    clc
    jsr krljmp_PLOT
    ldy #0
    lda #CHR_Space
!Looper:
    jsr krljmp_CHROUT
    iny
    cpy #39
    bne !Looper-
    rts
    
