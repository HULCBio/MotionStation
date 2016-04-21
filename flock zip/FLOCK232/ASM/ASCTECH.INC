;
;   asctech.h       - Ascension Technology Header
;
;   Modification History
;
;      10/18/90     jf  -   released
;      9/17/91      jf  - added POSK36 and POSK72
;      4/7/92       jf  - added POSK144
;      10/12/92     jf  - modified matrix display format to 3 sig. digits
;      3/6/93       jf  - modified matrix conversion to 1000
;
;
;   General Purpose Macros
;
DOSINT      MACRO   intno
            mov     ah, intno
            int     21h
            ENDM
;
; Number Conversions    result = (rawdata * conv_const)/32768
;
POSK36          EQU     3600                ; convert to position
POSK72          EQU     7200                ; convert to position
POSK144         EQU     1440                ; convert to position for ER Controller
ANGK            EQU     18000               ; convert to angle
MATK            EQU     1000                ; convert to matrix
INTK            EQU     -32768              ; convert to integer
UNITK			EQU		10000				; convert to -1.00000 to 0.99996
VOLTK			EQU		50000				; convert to -5.00000 to 4.9996
CRYSTALRATEK	EQU		12500				; convert to crystal counts/10

;
; Number Conversion formats...places past the decimal point
;
TBUFSIZE        EQU     10                  ; number of chars in formated output
POSFORMAT       EQU     2                   ; for Flock          
POSFORMAT144    EQU     1                   ; for ER Controller
ANGFORMAT       EQU     2
MATRIXFORMAT    EQU     3
INTFORMAT       EQU     0

;
; Output Mode defintions
;
POINT           EQU     0
CONTINUOUS      EQU     1
STREAM          EQU     2
