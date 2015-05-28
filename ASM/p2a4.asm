; Praktikum 2, Aufgabe 4
; ----------------------

; 0x100 => 0000 0001 0000 0000
; 0x101 => 0000 0001 0000 0001
; 0x102 => 0000 0001 0000 0010

	  .org 0x000
	  .start
	  
	  ;LDIH  r0, 0x00
	  ;LDIL  r0, 0x00
	  ;LDIH  r1, 0x00 
	  ;LDIL  r1, 0x00
	  ;LDIH  r2, 0x00 
	  ;LDIL  r2, 0x00 
	  ;LDIH  r3, 0x00
	  ;LDIL  r3, 0x00
	  ;LDIH  r4, 0x00
	  ;LDIL  r4, 0x00
	  ;LDIH  r5, 0x00
	  ;LDIL  r5, 0x00
		  
	  ;XOR   r0, r0, r0
	  ;LDIL  r0, result & 255 
	  ;LDIH  r0, result >> 8
	  ;XOR   r1, r1, r1
	  ;LDIH  r1, 0x00 
	  ;LDIL  r1, 0x02
	  ;ST    [r0], r1

	  ;XOR   r0, r0, r0
	  ;LDIL  r0, 0x01
	  ;LDIH  r0, 0x01
	  ;XOR   r1, r1, r1
	  ;LDIH  r1, 0x00 
	  ;LDIL  r1, 0x04
	  ;ST    [r0], r1 
	  
	  XOR   r0, r0, r0 ; Nur '0' in r0
	  LDIH  r0, 0x01   ; r0 => 0x100
	  LD    r1, [r0]   ; 1. Faktor in r1
	  XOR   r0, r0, r0
	  LDIL  r0, 0x01
	  LDIH  r0, 0x01   ; r0 => 0x101
	  LD    r2, [r0]   ; 2. Faktor in r2
	  XOR   r0, r0, r0
	  LDIL  r0, 0x02
	  LDIH  r0, 0x01   ; r0 => 0x102
	  XOR   r3, r3, r3
	  XOR   r4, r4, r4
	  LDIL  r4, 1
	  XOR   r5, r5, r5
	  LDIL  r5, loop
	  LDIH  r5, loop>>8
loop: ADD   r3, r3, r1 ; Addieren, r3 = r3 + r1
	  SUB   r2, r2, r4
	  JZ    r2, r5
	  ST    [r0], r3   ; Ergebnis speichern
	  
	  HALT
	  
	  .org 0x100
	  result: .res 4
	  
	  .end
