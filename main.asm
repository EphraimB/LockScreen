#include "kernel.inc"
    .db "KEXC"
    .db KEXC_ENTRY_POINT
    .dw start
    .db KEXC_STACK_SIZE
    .dw 20
    .db KEXC_NAME
    .dw name
    .db KEXC_HEADER_END

name:
    .db "LockScreen", 0

start:

    ; Get a lock on the devices we intend to use
    pcall(getLcdLock)
    pcall(getKeypadLock)

    ; Allocate and clear a buffer to store the contents of the screen
    pcall(allocScreenBuffer)
    pcall(clearBuffer)

    ; Draw `Passwordtxt` to 30, 20 (D, E = 30, 20)
    kld(hl, Passwordtxt)
    ld d, 30
    ld e, 15
    pcall(drawStr)

loop:
    kld(a, (firstDigitPin))
    ld d, 30
    ld e, 30
    pcall(drawDecA)

    kld(a, (secondDigitPin))
    ld d, 30
    ld e, 40

    kld(a, (thirdDigitPin))
    ld d, 30
    ld e, 50

    kld(a, (fourthDigitPin))
    ld d, 30
    ld e, 60

    kld(hl, passwordboxsprite)
    ld b, 8
    ld d, 28
    ld e, 30
    pcall(putSpriteOR)

    kld(hl, passwordboxsprite)
    ld b, 8
    ld d, 38
    ld e, 30
    pcall(putSpriteOR)

    kld(hl, passwordboxsprite)
    ld b, 8
    ld d, 48
    ld e, 30
    pcall(putSpriteOR)

    kld(hl, passwordboxsprite)
    ld b, 8
    ld d, 58
    ld e, 30
    pcall(putSpriteOR)

    kld(hl, upArrowSprite)
    ld b, 4
    ld d, 28
    ld e, 24
    pcall(putSpriteOR)

    kld(hl, downArrowSprite)
    ld b, 4
    ld d, 28
    ld e, 40
    pcall(putSpriteOR)

    kld(hl, batteryIndicatorSprite)
    ld b, 4
    ld de, 0x193b
    pcall(putSpriteOR)

    pcall(getBatteryLevel)
    ld d, b
    ld e, 85
    pcall(div8By8)
    ld b, d
    inc b
    xor a
    cp b
    jr z, ++_
    ld a, 26
_:  ld l, 60
    pcall(setPixel)
    inc l
    pcall(setPixel)
    inc a
    djnz -_

    ; Copy the display buffer to the actual LCD
    pcall(fastCopy)

    ; flushKeys waits for all keys to be released
    pcall(flushKeys)
    ; waitKey waits for a key to be pressed, then returns the key code in A
    pcall(waitKey)

    cp kUP
    jr z, increase

    cp kENTER
    jr nz, .loop

    ; Exit when the user presses "ENTER"

    ret

increase:
    ld a, (firstDigitPin)
    inc a
    ld (firstDigitPin), a
    kjp(loop)

Passwordtxt:
    .db "Password: ", 0

firstDigitPin:
    .db 0

secondDigitPin:
    .db 0

thirdDigitPin:
    .db 0

fourthDigitPin:
    .db 0

selectedPinField:
    .db 0

batteryIndicatorSprite: ; 8x4
    .db 0b11111100
    .db 0b10000110
    .db 0b10000110
    .db 0b11111100

passwordboxSprite: ; 8x8
    .db 0b11111111
    .db 0b10000001
    .db 0b10000001
    .db 0b10000001
    .db 0b10000001
    .db 0b10000001
    .db 0b10000001
    .db 0b11111111

upArrowSprite: ; 8x4
    .db 0b00010000
    .db 0b00111000
    .db 0b01111100
    .db 0b11111110

downArrowSprite: ; 8x4
    .db 0b11111110
    .db 0b01111100
    .db 0b00111000
    .db 0b00010000
