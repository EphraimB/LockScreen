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
    .db "lockscreen", 0
start:
    kld(de, startupFile)
    pcall(openFileWrite)

    kld(hl, locatelockscreenForStartup)
    ld d, 15
    pcall(streamWriteWord)

    ld d, 15
    pcall(closeStream)

    ; Get a lock on the devices we intend to use
    pcall(getLcdLock)
    pcall(getKeypadLock)

    ; Allocate and clear a buffer to store the contents of the screen
    pcall(allocScreenBuffer)
    pcall(clearBuffer)

    ; Draw `message` to 0, 0 (D, E = 0, 0)
    kld(hl, passwordtext)
    ld d, 25
    ld e, 15
    pcall(drawStr)

    ld d, 23
    ld e, 25

    ld b, 8

    kld(hl, PINInputBox)

    pcall(putSpriteOR)

    ld d, 33
    ld e, 25

    ld b, 8

    kld(hl, PINInputBox)

    pcall(putSpriteOR)

    ld d, 43
    ld e, 25

    ld b, 8

    kld(hl, PINInputBox)

    pcall(putSpriteOR)

    ld d, 53
    ld e, 25

    ld b, 8

    kld(hl, PINInputBox)

    pcall(putSpriteOR)

loop:
    ; Copy the display buffer to the actual LCD
    pcall(fastCopy)

    ; flushKeys waits for all keys to be released
    pcall(flushKeys)
    ; waitKey waits for a key to be pressed, then returns the key code in A
    pcall(waitKey)

    cp k0
    jp z, key0Pressed

    cp k1
    jp z, key1Pressed

    cp k2
    jp z, key2Pressed

    cp k3
    jp z, key3Pressed

    cp k4
    jp z, key4Pressed

    cp k5
    jp z, key5Pressed

    cp k6
    jp z, key6Pressed

    cp k7
    jp z, key7Pressed

    cp k8
    jp z, key8Pressed

    cp k9
    jp z, key9Pressed

    jp loop

key0Pressed:
    ld a, (passwordInputBoxValue)
    inc a
    ld (passwordInputBoxValue), a

    ld a, 0
    ld (passwordValue), a

    jp passwordInput

key1Pressed:
    ld a, (passwordInputBoxValue)
    inc a
    ld (passwordInputBoxValue), a

    ld a, 1
    ld (passwordValue), a

    jp passwordInput

key2Pressed:
    ld a, (passwordInputBoxValue)
    inc a
    ld (passwordInputBoxValue), a

    ld a, 2
    ld (passwordValue), a

    jp passwordInput

key3Pressed:
    ld a, (passwordInputBoxValue)
    inc a
    ld (passwordInputBoxValue), a

    ld a, 3
    ld (passwordValue), a

    jp passwordInput

key4Pressed:
    ld a, (passwordInputBoxValue)
    inc a
    ld (passwordInputBoxValue), a

    ld a, 4
    ld (passwordValue), a

    jp passwordInput

key5Pressed:
    ld a, (passwordInputBoxValue)
    inc a
    ld (passwordInputBoxValue), a

    ld a, 5
    ld (passwordValue), a

    jp passwordInput

key6Pressed:
    ld a, (passwordInputBoxValue)
    inc a
    ld (passwordInputBoxValue), a

    ld a, 6
    ld (passwordValue), a

    jp passwordInput

key7Pressed:
    ld a, (passwordInputBoxValue)
    inc a
    ld (passwordInputBoxValue), a

    ld a, 7
    ld (passwordValue), a

    jp passwordInput

key8Pressed:
    ld a, (passwordInputBoxValue)
    inc a
    ld (passwordInputBoxValue), a

    ld a, 8
    ld (passwordValue), a

    jp passwordInput

key9Pressed:
    ld a, (passwordInputBoxValue)
    inc a
    ld (passwordInputBoxValue), a

    ld a, 9
    ld (passwordValue), a

passwordInput:
    ld a, (passwordInputBoxValue)

passwordInputLoop:
    cp 0
    jp z, passwordInput1

    cp 1
    jp z, passwordInput2

    cp 2
    jp z, passwordInput3

    cp 3
    jp z, passwordInput4

    cp 4
    jp z, unlock

    jp passwordInputLoop

passwordInput1:
    ld d, 23
    ld a, (passwordValue)
    ld (passwordInputBox1Value), a

    jp passwordInputSprite

passwordInput2:
    ld d, 33
    ld a, (passwordValue)
    ld (passwordInputBox2Value), a

    jp passwordInputSprite

passwordInput3:
    ld d, 43
    ld a, (passwordValue)
    ld (passwordInputBox3Value), a

    jp passwordInputSprite

passwordInput4:
    ld d, 53
    ld a, (passwordValue)
    ld (passwordInputBox4Value), a

    jp passwordInputSprite

passwordInputSprite:
    ld e, 27
    ld b, 4

    kld(hl, passwordHiddenSprite)

    pcall(putSpriteOR)

    jp loop

unlock:

    kld(de, unlockToCastle)
    pcall(openFileRead)
    ret

passwordtext:
    .db "Password:", 0

passwordInputBoxValue:
    .db 0

passwordInputBox1Value:
    .db 0

passwordInputBox2Value:
    .db 0

passwordInputBox3Value:
    .db 0

passwordInputBox4Value:
    .db 0

passwordValue:
    .db 0

startupFile:
  .db "/ect/inittab", 0

unlockToCastle:
    .db "/bin/castle", 0

locatelockscreenForStartup:
    .db "/bin/lockscreen", 0

PINInputBox:    ; 8x8
    .db 0b11111111
    .db 0b10000001
    .db 0b10000001
    .db 0b10000001
    .db 0b10000001
    .db 0b10000001
    .db 0b10000001
    .db 0b11111111

passwordHiddenSprite:  ;8x4
    .db 0b00111000
    .db 0b01111100
    .db 0b01111100
    .db 0b00111000
