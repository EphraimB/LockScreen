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
      kld(de, inittab)
  pcall(openFileWrite)
  kld(hl, lockPath)
  ld bc, lockPathEnd - lockPath
  pcall(streamWriteBuffer)
  pcall(closeStream)
  
    ; Get a lock on the devices we intend to use
    pcall(getLcdLock)
    pcall(getKeypadLock)

    ; Allocate and clear a buffer to store the contents of the screen
    pcall(allocScreenBuffer)
    pcall(clearBuffer)

    ; Draw `Passwordtxt` to 30, 20 (D, E = 30, 20)
    kld(hl, Passwordtxt)
    ld d, 30
    ld e, 20
    pcall(drawStr)

    kld(hl, batteryIndicatorSprite)
    ld b, 4
    ld de, 0x193B
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

.loop:; ...
inittab:
  .db "/etc/inittab", 0
lockPath:
  .db "/bin/lockscreen", 0
lockPathEnd:
    ; Copy the display buffer to the actual LCD
    pcall(fastCopy)

    ; flushKeys waits for all keys to be released
    pcall(flushKeys)
    ; waitKey waits for a key to be pressed, then returns the key code in A
    pcall(waitKey)

    cp kENTER
    jr nz, .loop

    ; Exit when the user presses "ENTER"
    ret

Passwordtxt:
    .db "Password: ", 0

batteryIndicatorSprite: ; 8x4
    .db 0b11111100
    .db 0b10000110
    .db 0b10000110
    .db 0b11111100
    
; ...
inittab:
  .db "/etc/inittab", 0
lockPath:
  .db "/bin/lockscreen", 0
lockPathEnd:
