;****************************************************************************
;****************************************************************************
;    hcint.asm       Interrupt Routines for the Metaware High C Compiler
;                    and Assember
;
;                    Assemble this with:
;     	                 386asm -twocase -nolist asmint.asm
;
;    written for:    Ascension Technology Corporation
;                    PO Box 527
;                    Burlington, Vermont  05402
;
;                    802-655-7879
;
;
;    written by:     Jeff Finkelstein
;
;    Modification History:
;
;    10/20/93        jf  - created
;
;           <<<< Copyright 1993 Ascension Technology Corporation >>>>
;****************************************************************************
;****************************************************************************

                    .386p

STACKSIZE           equ 1024

_DATA segment dword use32 'DATA'

; SETUP A TEMPORARY STACK EACH ISR

                    dd	STACKSIZE	dup(-1)
com_int_stack	    equ	$
com_stack_seg	    dw	0	;This saves the stack segment.
com_stack_pointer	dd	0	;This saves the stack pointer .

		            dd	STACKSIZE	dup(-1)
timer_int_stack	    equ	$
timer_stack_seg	    dw	0	    ;This saves the stack segment.
timer_stack_pointer	dd	0	;This saves the stack pointer .

app_ds  dw	0	;This contains the program's DS

_DATA  ends

DGROUP group _DATA
assume ds:DGROUP


_TEXT	segment	dword use32 public 'CODE'
CGROUP  group   _TEXT
        assume  cs:CGROUP

	extrn serialisr:near		; C interrupt handler
    extrn pctimer_irq0:near     ; C interrupt handler

	align	4

	public	save_ds, hc_serialisr, hc_pctimerisr

save_ds	proc	near
	mov	ax, ds
	mov	app_ds, ax
	ret
save_ds	endp

hc_serialisr	proc	far
	pushad
	push ds

	mov ax,cs:app_ds	; Get the stack segment set up.
	mov ds,ax			; Ditto for data segment.

	mov cx,ss			; Save stack pointer and segment.
	mov com_stack_seg,cx
	mov com_stack_pointer,esp

	mov ss,ax			; Note that even though the addresses
					    ; are different, they point to the same
					    ; physical memory, so we can assume that
					    ; cs == ds == ss.

    mov esp, offset com_int_stack	; Set esp to our temp stack.
	xor ebp,ebp

;
; CALL THE 'C' ISR
;
	call serialisr

	mov ax,com_stack_seg		    ; Restore the stack.
	mov ss,ax
	mov esp,com_stack_pointer

	pop ds
;
; Send End of Interrupt Command to the 8259
; .. done in 'C'
;
;    mov al,20h
;    out 20h,al
	popad
	iretd

hc_serialisr endp

hc_pctimerisr	proc	far
	pushad
	push ds

	mov ax,cs:app_ds	; Get the stack segment set up.
	mov ds,ax			; Ditto for data segment.

	mov cx,ss			; Save stack pointer and segment.
	mov timer_stack_seg,cx
	mov timer_stack_pointer,esp

	mov ss,ax			; Note that even though the addresses
					    ; are different, they point to the same
					    ; physical memory, so we can assume that
					    ; cs == ds == ss.

    mov esp, offset timer_int_stack	; Set esp to our temp stack.
	xor ebp,ebp

;
; CALL THE 'C' ISR
;
	call pctimer_irq0

	mov ax,timer_stack_seg		    ; Restore the stack.
	mov ss,ax
	mov esp,timer_stack_pointer

	pop ds
;
; Send End of Interrupt Command to the 8259
; .. done in 'C'
;
;    mov al,20h
;    out 20h,al
	popad
	iretd

hc_pctimerisr endp

_TEXT	ends
	end
