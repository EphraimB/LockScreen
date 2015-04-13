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
    kld(de, inittab)
    pcall(openFileWrite)

    kld(hl, lockPath)
    kld(bc, lockPathEnd - lockPath)
    pcall(streamWriteBuffer)

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

    kld(hl, PINInputBox)
    ld b, 8
    ld d, 23
    ld e, 25
    pcall(putSpriteOR)

    kld(hl, PINInputBox)
    ld b, 8
    ld d, 33
    ld e, 25
    pcall(putSpriteOR)

    kld(hl, PINInputBox)
    ld b, 8
    ld d, 43
    ld e, 25
    pcall(putSpriteOR)

    kld(hl, PINInputBox)
    ld b, 8
    ld d, 53
    ld e, 25
    pcall(putSpriteOR)

loop:
    ; Copy the display buffer to the actual LCD
    pcall(fastCopy)

    ; flushKeys waits for all keys to be released
    pcall(flushKeys)
    ; waitKey waits for a key to be pressed, then returns the key code in A
    pcall(waitKey)

    cp k0
    kjp(z, key0Pressed)

    cp k1
    kjp(z, key1Pressed)

    cp k2
    kjp(z, key2Pressed)

    cp k3
    kjp(z, key3Pressed)

    cp k4
    kjp(z, key4Pressed)

    cp k5
    kjp(z, key5Pressed)

    cp k6
    kjp(z, key6Pressed)

    cp k7
    kjp(z, key7Pressed)

    cp k8
    kjp(z, key8Pressed)

    cp k9
    kjp(z, key9Pressed)

    kjp(loop)

key0Pressed:
    kld(a, (passwordInputBoxValue))
    inc a
    kld((passwordInputBoxValue), a)

    ld a, 0
    kld((passwordValue), a)

    kjp(passwordInput)

key1Pressed:
    kld(a, (passwordInputBoxValue))
    inc a
    kld((passwordInputBoxValue), a)

    ld a, 1
    kld((passwordValue), a)

    kjp(passwordInput)

key2Pressed:
    kld(a, (passwordInputBoxValue))
    inc a
    kld((passwordInputBoxValue), a)

    ld a, 2
    kld((passwordValue), a)

    kjp(passwordInput)

key3Pressed:
    kld(a, (passwordInputBoxValue))
    inc a
    kld((passwordInputBoxValue), a)

    ld a, 3
    kld((passwordValue), a)

    kjp(passwordInput)

key4Pressed:
    kld(a, (passwordInputBoxValue))
    inc a
    kld((passwordInputBoxValue), a)

    ld a, 4
    kld((passwordValue), a)

    kjp(passwordInput)

key5Pressed:
    kld(a, (passwordInputBoxValue))
    inc a
    kld((passwordInputBoxValue), a)

    ld a, 5
    kld((passwordValue), a)

    kjp(passwordInput)

key6Pressed:
    kld(a, (passwordInputBoxValue))
    inc a
    kld((passwordInputBoxValue), a)

    ld a, 6
    kld((passwordValue), a)

    kjp(passwordInput)

key7Pressed:
    kld(a, (passwordInputBoxValue))
    inc a
    kld((passwordInputBoxValue), a)

    ld a, 7
    kld((passwordValue), a)

    kjp(passwordInput)

key8Pressed:
    kld(a, (passwordInputBoxValue))
    inc a
    kld((passwordInputBoxValue), a)

    ld a, 8
    kld((passwordValue), a)

    kjp(passwordInput)

key9Pressed:
    kld(a, (passwordInputBoxValue))
    inc a
    kld((passwordInputBoxValue), a)

    ld a, 9
    kld((passwordValue), a)

passwordInput:
    kld(a, (passwordInputBoxValue))

passwordInputLoop:
    cp 1
    kjp(z, passwordInput1)

    cp 2
    kjp(z, passwordInput2)

    cp 3
    kjp(z, passwordInput3)

    cp 4
    kjp(z, passwordInput4)

    cp 5
    kjp(z, unlock)

    kjp(passwordInputLoop)

passwordInput1:
    ld d, 23
    kld(a, (passwordValue))
    kld((passwordInputBox1Value), a)

    kjp(passwordInputSprite)

passwordInput2:
    ld d, 33
    kld(a, (passwordValue))
    kld((passwordInputBox2Value), a)

    kjp(passwordInputSprite)

passwordInput3:
    ld d, 43
    kld(a, (passwordValue))
    kld((passwordInputBox3Value), a)

    kjp(passwordInputSprite)

passwordInput4:
    ld d, 53
    kld(a, (passwordValue))
    kld((passwordInputBox4Value), a)

    kjp(passwordInputSprite)

passwordInputSprite:
    kld(hl, passwordHiddenSprite)
    ld e, 27
    ld b, 4
    pcall(putSpriteOR)

    kjp(loop)

unlock:

    kld(de, unlockToCastle)
    pcall(openFileRead)

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

unlockToCastle:
    .db "/bin/castle", 0

inittab:
    .db "/etc/inittab", 0

lockPath:
    .db "/bin/lockscreen", 0

lockPathEnd:

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
