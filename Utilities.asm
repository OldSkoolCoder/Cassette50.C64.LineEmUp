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

ResetTestVar:
    lda #0
    sta var_Test
    rts

//******************************************************
// Test 4 Elements in a row for possible moves
// Inputs   : 
//          : 
//******************************************************
// Output : Carry Set = Line Is True
//        : Carry Clear = Line Is False
//******************************************************
// IF A(x1) = X AND A(x2) = X AND A(x3) = E AND A(x4) <> E THEN MV = B .....
ComputerMove4LineTest:
    lda TestElements
    sta cml4tX1
    lda TestElements + 1
    sta cml4tX2
    lda TestElements + 2
    sta cml4tX3
    sta cml4tRes
    lda TestElements + 3
    sta cml4tX4

    // lda ResultElement
    // sta cml4tRes

    jsr ResetTestVar

    lda var_B
    clc
    adc cml4tX1: #$FF
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc cml4tX2: #$FF
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc cml4tX3: #$FF
    tay
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc cml4tX4: #$FF
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00001111
    bne !ClearCarry+

    lda var_B
    clc
    adc cml4tRes:#$FF
    sta var_MV
    sec
    jmp !Exit+

!ClearCarry:
    clc
!Exit:
    rts

//******************************************************
// Test 3 Elements in a row for possible moves
// Inputs   : Acc = Test 1
//          : Y = Test 2 and Result Add / Sub
//          : X = Test 3
//******************************************************
// Output : Carry Set = Line Is True
//        : Carry Clear = Line Is False
//******************************************************
// IF A(x1) = X AND A(x2) = E AND A(x3) <> E THEN ........
ComputerMove3LineTest:
    //lda TestElements
    sta cml3tX1
    //lda TestElements + 1
    sty cml3tX2
    sty cml3tRes
    //lda TestElements + 2
    stx cml3tX3

    jsr ResetTestVar

    // lda ResultElement
    // sta cml3tRes

    lda var_B
    clc
    adc cml3tX1: #$FF
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc cml3tX2: #$FF
    tay
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc cml3tX3: #$FF
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000111
    bne !ClearCarry+

    lda var_B
    clc
    adc cml3tRes:#$FF
    sta var_MV

    sec
    jmp !Exit+

!ClearCarry:
    clc
!Exit:
    rts

//******************************************************
// Test 4 Elements in a row for possible moves
// Inputs   : Acc = Test
//          : 
//          : 
//******************************************************
// Output : Carry Set = Line Is True
//        : Carry Clear = Line Is False
//******************************************************
// IF A(x1) = X AND A(x2) = X AND A(x3) = X THEN MV = B .....
WinCheck3LineTest:
    //lda TestElements
    sta wc3tX1
    sta wc3tX2
    sta wc3tX3

    jsr ResetTestVar

    lda var_B
    clc
    adc wc3tX1: #$FF
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    pla
    clc
    adc wc3tX2: #$FF
    pha
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    pla
    clc
    adc wc3tX3: #$FF
    tay
    ldx var_X
    jsr PositionEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000111
    bne !ClearCarry+

    sec
    jmp !Exit+

!ClearCarry:
    clc
!Exit:
    rts

//******************************************************
// Test 2 Elements in a row for possible moves
// Inputs   : Acc = Test 1
//          : Y = Test 2
//******************************************************
// Output : Carry Set = Line Is True
//        : Carry Clear = Line Is False
//******************************************************
// IF A(x1) = E AND A(x2) <> E THEN CT = CT + 1 : M(CT) = B .....
ComputerPossibleMove2LineTest:
    //lda TestElements
    sta cp2tX1
    sta cp2tRes
    //lda TestElements + 1
    sty cp2tX2

    jsr ResetTestVar

    lda var_B
    clc
    adc cp2tX1: #$FF
    tay
    ldx var_Empty
    jsr PositionEqualsCheck
    rol var_Test

    lda var_B
    clc
    adc cp2tX2: #$FF
    tay
    ldx var_Empty
    jsr PositionNotEqualsCheck
    rol var_Test

    lda var_Test
    cmp #%00000011
    bne !ClearCarry+

    ldx var_CT
    lda var_B
    clc
    adc cp2tRes:#$FF
    sta MoveArray,x
    inc var_CT

    sec
    jmp !Exit+

!ClearCarry:
    clc
!Exit:
    rts
