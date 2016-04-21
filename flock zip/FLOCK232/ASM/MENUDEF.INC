;   menudef.inc     Menu Definition Include File
;
;   Modification History
;        10/18/90   jf - released
;        4/4/92     jf - added menu definitions
;
;
;   Misc Equates
;
TRUE            EQU     1
FALSE           EQU     0
ESC_SEL         EQU     -1

;
; Ascii Characters
;
BEL             EQU     07              ; character values
BS              EQU     08
TAB             EQU     09
LF              EQU     0ah
CR              EQU     0dh
XON				EQU		11h
XOFF			EQU		13h
ESCKEY          EQU     1bh
;SP             EQU     20h
SPACE           EQU     20h

ASCIIBUFSIZE    EQU     81              ; character buffer length
MENUBUFSIZE     EQU     81              ; menu line length

;
; File Handling definitions..
; ...file access codes for DOS int21 func 3Dh (version 2.0+ compatible)
;
FILEREAD        EQU     0               ; open for read only
FILEWRITE       EQU     1               ; open for write only
FILEREADWRITE   EQU     2               ; open for read/write