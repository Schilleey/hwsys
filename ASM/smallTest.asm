; Alle Befehle von ALU und LDIH und LDIL testen
; ---------------------------------------------

.org 0x000
.start

LDIH  r0, 0x00   ; => 1111111100000000
LDIL  r0, 0x00   ; => 1111111111111111
LDIH  r1, 0x00   ; => 1111111100000000
LDIL  r1, 0x00   ; => 1111111111111111
LDIH  r3, 0x00   ; => 1111111100000000
LDIL  r3, 0x00   ; => 1111111111111111
XOR   r0, r0, r0 ; Nur '0' in r0
LDIL  r0, 8      ; 1. Wert in r0
XOR   r1, r1, r1
LDIL  r1, 4

XOR   r3, r3, r3 ; Ergebnis Register leeren
ADD   r3, r0, r1 ; Addieren, r3 = r0 + r1     => 12

XOR   r3, r3, r3
SUB   r3, r0, r1 ; Subtrahieren, r3 = r0 - r1 => 4

XOR   r3, r3, r3
SAL   r3, r0     ; Shift nach links           => 16

XOR   r3, r3, r3
SAR   r3, r0     ; Shift nach rechts          => 4

XOR   r3, r3, r3
LDIH  r3, 0xFF   ; => 1111111100000000
LDIL  r3, 0xFF   ; => 1111111111111111
AND   r3, r0, r1 ; => 0

XOR   r3, r3, r3
OR    r3, r0, r1 ; => 12

XOR   r3, r3, r3
XOR   r3, r0, r1 ; => 12

XOR   r3, r3, r3
NOT   r3, r0     ; => 1111111111110111

.end
