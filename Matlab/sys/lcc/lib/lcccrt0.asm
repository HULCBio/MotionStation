	.text
	.file "lcccrt0.c"
	.data
	.globl	_stdin
_stdin:
	.long	0x0
	.globl	_stdout
_stdout:
	.long	0x0
	.globl	_stderr
_stderr:
	.long	0x0
	.globl	__fmode
__fmode:
	.long	0x8000
	.globl	__ShadowStack
__ShadowStack:
	.long	0
__oldhandler:
	.long	00
	.globl	__InitialStack
__InitialStack:
	.long	0
	.globl	__lastKnownGoodEBP
__lastKnownGoodEBP:
	.long	0
_$ExcepData:
	.long	0
	.globl	___argc
	.align	4
	.type	___argc,object
	.size	___argc,4
___argc:
	.long	0
	.globl	___argv
	.align	4
	.type	___argv,object
	.size	___argv,4
___argv:
	.long	0x0
	.globl	__environ
	.align	4
	.type	__environ,object
	.size	__environ,4
__environ:
	.long	0x0
	.globl	__plccStackTrace
__plccStackTrace:
	.long	0
	.text
_$unknownTrap:
	xor	%eax,%eax
	incl	%eax
	movl	4(%esp),%ecx
	testl	$6,4(%ecx)
	jz	_$unknownTrapLabel1
	movl	8(%esp),%eax
	movl	16(%esp),%edx
	movl	%eax,(%edx)
	movl	$3,%eax
_$unknownTrapLabel1:
	ret
_$local_unwind2:
	pushl	%ebx
	pushl	%esi
	pushl	%edi
	movl	16(%esp),%eax
	pushl	%eax
	pushl	$0xfffffffe
	pushl	$_$unknownTrap
	.byte	100
	.byte	255
	.byte	53
	.long	0
	.byte	100
	.byte	137
	.byte	37
	.long	0
_$local_unwindLabel0:
	movl	32(%esp),%eax
	movl	8(%eax),%ebx
	movl	12(%eax),%esi
	cmpl	$0xffffffff,%esi
	jz	_$local_unwindLabel1
	cmpl	36(%esp),%esi
	jz	_$local_unwindLabel1
	leal	(%esi,%esi,2),%esi
	movl	(%ebx,%esi,4),%ecx
	movl	8(%esp),%ecx
	movl	12(%eax),%ecx
	cmpl	$0,4(%ebx,%esi,4)
	jnz	_$local_unwindLabel0
	call	8(%ebx,%esi,4)
	jmp	_$local_unwindLabel0
_$local_unwindLabel1:
	.byte	100
	.byte	143
	.byte	5
	.long	0
	addl	$12,%esp
	pop	%edi
	pop	%esi
	pop	%ebx
	ret
__global_unwind2:
	pushl	%ebp
	movl	%esp,%ebp
	pushl	%ebx
	pushl	%esi
	pushl	%edi
	pushl	%ebp
	pushl	$0
	pushl	$0
	pushl	$_$beyond
	pushl	8(%ebp)
	call	_RtlUnwind@16
_$beyond:
	pop	%ebp
	pop	%edi
	pop	%esi
	pop	%ebx
	mov	%ebp,%esp
	pop	%ebp
	ret
	.globl	__except_handler3
;; parameters:
;; _except_handler3(	struct EXCEPTION_RECORD *,       offset: 8(%ebp)
;;			struct EXCEPTION_REGISTRATION *, offset: 12(%ebp)
;;			struct _CONTEXT *
;;			void *pDispatcherContext
__except_handler3:
;; clear the direction flag No assumptions.
	cld
	pushl	%ebp
	movl	%esp,%ebp
	subl	$8,%esp
	pushl	%ebx
	pushl	%esi
	pushl	%edi
	pushl	%ebp
	movl	12(%ebp),%ebx
	movl	8(%ebp),%eax
	movl	%eax,__CurrentException
	movl	%ebx,__CurrentContext
	testl	$6,4(%eax)
	jne	exceptionHandler3label2
	movl	%eax,-8(%ebp)
	movl	16(%ebp),%eax
	movl	%eax,-4(%ebp)
	movl	%eax,__CurrentContext
	leal	-8(%ebp),%eax
	movl	%eax,-4(%ebx)
	movl	12(%ebx),%esi
	movl	8(%ebx),%edi
_$exceptionHandler3LOOP:
	cmp      $0xffffffff,%esi
	jz	_$RetTr
	leal	(%esi,%esi,2),%ecx
	cmpl	$0,4(%edi,%ecx,4)
	jz	exceptionHandler3label3
	pushl	%esi
	pushl	%ebp
	leal	16(%ebx),%ebp
	call	4(%edi,%ecx,4)
	popl	%ebp
	popl	%esi
	movl	12(%ebp),%ebx
	orl	%eax,%eax
	jz	exceptionHandler3label3
	js	exceptionHandler3label4
	movl	8(%ebx),%edi
	pushl	%ebx
	call	__global_unwind2
	addl	$4,%esp
	leal	16(%ebx),%ebp
	pushl	%esi
	pushl	%ebx
	call	_$local_unwind2
	addl	$8,%esp
	leal	(%esi,%esi,2),%ecx
	movl	(%edi,%ecx,4),%eax
	movl	12(%ebx),%eax
	call	8(%edi,%ecx,4)
exceptionHandler3label3:
	movl	8(%ebx),%edi
	leal	(%esi,%esi,2),%ecx
	movl	(%edi,%ecx,4),%esi
	jmp	_$exceptionHandler3LOOP
exceptionHandler3label4:
	xorl	%eax,%eax
	jmp       exceptionHandler3Exit
exceptionHandler3label2:
	pushl	%ebp
	leal	16(%ebx),%ebp
	pushl	$0xffffffff
	pushl	%ebx
	call	_$local_unwind2
	addl	$12,%esp
_$RetTr:
;	movl	$1,%eax
;	jmp	exceptionHandler3Exit
	pushl	__oldhandler
	pushl	$11
	call	_signal
	add	$8,%esp
	cmpl	%eax,__oldhandler
	jne	_$doit
	movl	$1,%eax
	jmp	exceptionHandler3Exit
_$doit:
	cmpl	$-1,%eax
	je	_$L45
	pushl	%eax
	pushl	$11
	call	_signal
	addl	$8,%esp
	pushl	$11
	call	_raise
	addl	$4,%esp
	movl	$1,%eax
exceptionHandler3Exit:
	popl	%ebp
	popl	%edi
	popl	%esi
	popl	%ebx
	movl	%ebp,%esp
	popl	%ebp
	ret
;; here we treat the case when signal returns -1...
_$L45:
	cmpl	$0,__plccStackTrace
	jne	_$L46
	movl	$1,%eax
	jmp	exceptionHandler3Exit
_$L46:
	movl	__plccStackTrace,%eax
	push	$11
	jmp	*%eax
	pop	%eax
	movl	$1,%eax
	jmp	exceptionHandler3Exit
	.type	_mainCRTStartup,function
_mainCRTStartup:
	.byte	100
	.byte	161
	.long	0
	pushl	%ebp
	movl	%esp,%ebp
	push	$0xffffffff
	pushl	$_$ExcepData
	pushl	$__except_handler3
	push	%eax
	.byte	100
	.byte	137
	.byte	37
	.long	0
	subl	$16,%esp
	push	%ebx
	push	%esi
	push	%edi
	mov	%esp,-24(%ebp)
	.line	64
	.line	70
	call	__init_stdhandles
	.line	75
	pushl	$__environ
	pushl	$___argv
	pushl	$___argc
	call	__GetMainArgs
	addl	$12,%esp
	pushl	$__signalHandler
	pushl	$11
	call	_signal
	addl	$8,%esp
	movl	%eax,__oldhandler
	movl	$__signalHandler,__oldhandler
	.line	83
	pushl	__environ
	pushl	___argv
	pushl	___argc
	movl	%esp,__InitialStack
	call	_main
	addl	$12,%esp
	movl	$0,-4(%ebp)
	push	%eax
	call	_exit
;	movl	-16(%ebp),%eax
;	.byte	100
;	.byte	163
;	.long	0x0
	.line	89
	call	_cexit
	.line	94
	call	__close_stdhandles
	.line	96
	call	_ExitProcess@4
_$67:
	.line	97
	popl	%edi
	leave
	ret
_$69:
	.size	_mainCRTStartup,_$69-_mainCRTStartup
	.globl	_mainCRTStartup
	.type	__ioinit,function
__ioinit:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$80,%esp
	pushl	%edi
	movw	$0,-24(%ebp)
	leal	-68(%ebp),%edi
	pushl	%edi
	call	_GetStartupInfoA@4
	xor	%eax,%eax
	testw	$256,-24(%ebp)
	je	_$127
	pushl	$0
	pushl	-12(%ebp)
	call	_open_osfhandle
	addl	$8,%esp
	movl	%eax,-72(%ebp)
	pushl	$0
	pushl	-8(%ebp)
	call	_open_osfhandle
	addl	$8,%esp
	movl	%eax,-76(%ebp)
	pushl	$0
	pushl	-4(%ebp)
	call	_open_osfhandle
	addl	$8,%esp
	movl	%eax,-80(%ebp)
	pushl	$_$133
	pushl	-72(%ebp)
	call	_fdopen
	addl	$8,%esp
	movl	%eax,_stdin
	pushl	$_$134
	pushl	-76(%ebp)
	call	_fdopen
	addl	$8,%esp
	movl	%eax,_stdout
	pushl	$_$134
	pushl	-80(%ebp)
	call	_fdopen
	addl	$8,%esp
	movl	%eax,_stderr
	movl	$1,%eax
_$127:
	popl	%edi
	leave
	ret
_$141:
	.size	__ioinit,_$141-__ioinit
	.globl	__init_stdhandles
	.type	__init_stdhandles,function
__init_stdhandles:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	call	__ioinit
	or	%eax,%eax
	jne	_$AfterStdHandlesInit
	pushl	%edi
	.line	120
	.line	123
	pushl	$0
	pushl	$0xfffffff6
	call	_open_osfhandle
	movl	%eax,-8(%ebp)
	.line	124
	pushl	$0
	pushl	$0xfffffff5
	call	_open_osfhandle
	movl	%eax,-4(%ebp)
	.line	125
	pushl	$0
	pushl	$0xfffffff4
	call	_open_osfhandle
	movl	%eax,-12(%ebp)
	pushl	$0x4000
	pushl	-8(%ebp)
	call	__setmode
	add	$8,%esp
	pushl	$_$73
	pushl	-8(%ebp)
	call	_fdopen
	movl	%eax,_stdin
	pushl	$0x4000
	pushl	-4(%ebp)
	call	__setmode
	addl	$8,%esp
	pushl	$0x4000
	pushl	-12(%ebp)
	call	__setmode
	addl	$8,%esp
	.line	128
	pushl	$_$74
	pushl	-4(%ebp)
	call	_fdopen
	movl	%eax,_stdout
	.line	129
	pushl	$_$74
	pushl	-12(%ebp)
	call	_fdopen
	addl	$48,%esp
	movl	%eax,_stderr
	.line	136
_$AfterStdHandlesInit:
	movl	_stdout,%edi
	or	%edi,%edi
	je	_$75
	.line	137
	pushl	$0x0
	pushl	%edi
	call	_setbuf
	addl	$8,%esp
_$75:
	.line	138
	movl	_stderr,%edi
	or	%edi,%edi
	je	_$77
	.line	139
	pushl	$0x0
	pushl	%edi
	call	_setbuf
	addl	$8,%esp
_$77:
_$72:
	.line	140
	popl	%edi
	leave
	ret
_$85:
	.size	__init_stdhandles,_$85-__init_stdhandles
	.type	__close_stdhandles,function
__close_stdhandles:
	movl	_stderr,%eax
	or	%eax,%eax
	je	_$87
	.line	156
	pushl	%eax
	call	_fclose
	pop	%ecx
_$87:
	movl	_stdin,%eax
	or	%eax,%eax
	je	_$89
	.line	158
	pushl	%eax
	call	_fclose
	pop	%ecx
_$89:
	.line	159
	movl	_stdout,%eax
	or	%eax,%eax
	je	_$91
	.line	160
	pushl	%eax
	call	_fclose
	pop	%ecx
_$91:
	.line	161
	ret
	.align	2
_$93:
	.size	__close_stdhandles,_$93-__close_stdhandles
; This returns %fs:0, but the assembler doesn't work for assembling that
; instruction, so it is written this way...
	.globl	_NtCurrentTeb
_NtCurrentTeb:
	.byte	100
	.byte	163
	.long	0
	ret
	.extern	_open_osfhandle
	.text
	.extern	_signal
	.extern	__GetMainArgs
	.extern	_flushall
	.extern	_cexit
	.extern	_main
	.extern	_ExitProcess@4
	.extern	_setbuf
	.extern	_fdopen
	.extern	_fclose
	.extern _RtlUnwind@16
	.extern __setmode
	.extern	_GetStartupInfoA@4
	.extern	_raise
	.extern	__signalHandler
	.extern	__imp___fmode_dll
	.extern _exit
	.data
__except_list:
	.long	__except_list
	.align	1
_$74:
	.byte	119,0
	.align	1
_$73:
	.byte	114,116,0
_$134:
	.byte	119,0
	.align	1
_$133:
	.byte	114,0
	.align	2
	.globl	__CurrentException
	.globl	__CurrentContext
__CurrentException:
	.long	0
__CurrentContext:
	.long	0
        .section .idata$3
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.section .idata$6
	.long	0
        .section .rdata
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
        .long   0
	.long	0
        .text
