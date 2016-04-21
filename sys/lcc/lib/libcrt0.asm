	.text
	.extern	_RtlUnwind@16
	.extern	_printf
	.globl	_main
_main:
	mov	$1,%eax
	ret
_$unknownTrap:
	xor     %eax,%eax
	incl    %eax
	movl    4(%esp),%ecx
	testl   $6,4(%ecx)
	jz      _$unknownTrapLabel1
	movl    8(%esp),%eax
	movl    16(%esp),%edx
	movl    %eax,(%edx)
	movl    $3,%eax
_$unknownTrapLabel1:
	ret
_$local_unwind2:
	pushl   %ebx
	pushl   %esi
	pushl   %edi
	movl    16(%esp),%eax
	pushl   %eax
	pushl   $0xfffffffe
	pushl   $_$unknownTrap
	.byte   100
	.byte   255
	.byte   53
	.long   0
	.byte   100
	.byte   137
	.byte   37
	.long   0
_$local_unwindLabel0:
	movl    32(%esp),%eax
	movl    8(%eax),%ebx
	movl    12(%eax),%esi
	cmpl    $0xffffffff,%esi
	jz      _$local_unwindLabel1
	cmpl    36(%esp),%esi
	jz      _$local_unwindLabel1
	leal    (%esi,%esi,2),%esi
	movl    (%ebx,%esi,4),%ecx
	movl    8(%esp),%ecx
	movl    12(%eax),%ecx
	cmpl    $0,4(%ebx,%esi,4)
	jnz     _$local_unwindLabel0
	call    8(%ebx,%esi,4)
	jmp     _$local_unwindLabel0
_$local_unwindLabel1:
	.byte   100
	.byte   143
	.byte   5
	.long   0
	addl    $12,%esp
	pop     %edi
	pop     %esi
	pop     %ebx
	ret
__global_unwind2:
	pushl   %ebp
	movl    %esp,%ebp
	pushl   %ebx
	pushl   %esi
	pushl   %edi
	pushl   %ebp
	pushl   $0
	pushl   $0
	pushl   $_$beyond
	pushl   8(%ebp)
	call    _RtlUnwind@16
_$beyond:
	pop     %ebp
	pop     %edi
	pop     %esi
	pop     %ebx
	mov     %ebp,%esp
	pop     %ebp
	ret
	.globl	__except_handler3
__except_handler3:
	cld
	pushl   %ebp
	movl    %esp,%ebp
	subl    $8,%esp
	pushl   %ebx
	pushl   %esi
	pushl   %edi
	pushl   %ebp
	movl    12(%ebp),%ebx
	movl    8(%ebp),%eax
	testl   $6,4(%eax)
	jne     exceptionHandler3label2
	movl    %eax,-8(%ebp)
	movl    16(%ebp),%eax
	movl    %eax,-4(%ebp)
	leal    -8(%ebp),%eax
	movl    %eax,-4(%ebx)
	movl    12(%ebx),%esi
	movl    8(%ebx),%edi
_$exceptionHandler3LOOP:
	cmp      $0xffffffff,%esi
	jz      _$RetTr
	leal    (%esi,%esi,2),%ecx
	cmpl    $0,4(%edi,%ecx,4)
	jz      exceptionHandler3label3
	pushl   %esi
	pushl   %ebp
	leal    16(%ebx),%ebp
	call    4(%edi,%ecx,4)
	popl    %ebp
	popl    %esi
	movl    12(%ebp),%ebx
	orl     %eax,%eax
	jz      exceptionHandler3label3
	js      exceptionHandler3label4
	movl    8(%ebx),%edi
	pushl   %ebx
	call    __global_unwind2
	addl    $4,%esp
	leal    16(%ebx),%ebp
	pushl   %esi
	pushl   %ebx
	call    _$local_unwind2
	addl    $8,%esp
	leal    (%esi,%esi,2),%ecx
	movl    (%edi,%ecx,4),%eax
	movl    12(%ebx),%eax
	call    8(%edi,%ecx,4)
exceptionHandler3label3:
	movl    8(%ebx),%edi
	leal    (%esi,%esi,2),%ecx
	movl    (%edi,%ecx,4),%esi
	jmp     _$exceptionHandler3LOOP
exceptionHandler3label4:
	xorl    %eax,%eax
	jmp       exceptionHandler3Exit
exceptionHandler3label2:
	pushl   %ebp
	leal    16(%ebx),%ebp
	pushl   $0xffffffff
	pushl   %ebx
	call    _$local_unwind2
	addl    $12,%esp
_$RetTr:
	pushl	$11
	call	_raise
	addl	$4,%esp
exceptionHandler3Exit:
	popl    %ebp
	popl    %edi
	popl    %esi
	popl    %ebx
	movl    %ebp,%esp
	popl    %ebp
	ret

	.globl	__crtLibMain@12
__crtLibMain@12:
	push	%ebp
	mov	%esp,%ebp
	push    %ebx
	push    %esi
	push    %edi
        cmp     $1,12(%ebp)
        jne     _$skipit
	call	__init_stdhandles
_$skipit:
	cmp	$0,12(%ebp)
	jne	_$Skipit1
	call	__close_stdhandles
_$Skipit1:
	push	16(%ebp)
	push	12(%ebp)
	push	8(%ebp)
	mov	__UserEntryPoint,%eax
	call	%eax
_$FailedInit:
	pop	%edi
	pop	%esi
	pop	%ebx
	leave
	ret	$12
	.globl	__init_stdhandles
	.type	__init_stdhandles,function
__init_stdhandles:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	pushl	%edi
	pushl	$0
	pushl	$0xfffffff6
	call	_open_osfhandle
	movl	%eax,-8(%ebp)
	pushl	$0
	pushl	$0xfffffff5
	call	_open_osfhandle
	movl	%eax,-4(%ebp)
	pushl	$0
	pushl	$0xfffffff4
	call	_open_osfhandle
	movl	%eax,-12(%ebp)
	pushl	$_$73
	pushl	-8(%ebp)
	call	_fdopen
	movl	%eax,_stdin
	pushl	$_$74
	pushl	-4(%ebp)
	call	_fdopen
	movl	%eax,_stdout
	pushl	$_$74
	pushl	-12(%ebp)
	call	_fdopen
	addl	$48,%esp
	movl	%eax,_stderr
	movl	_stdout,%edi
	or	%edi,%edi
	je	_$75
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
	call	__Setenvironment
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
	pushl	%eax
	call	_fclose
	pop	%ecx
_$89:
	.line	159
	movl	_stdout,%eax
	or	%eax,%eax
	je	_$91
	pushl	%eax
	call	_fclose
	pop	%ecx
_$91:
	.line	161
	ret
	.align	2
	.globl	__ftol
__ftol:
	push	%ebp
	movl	%esp,%ebp
	addl	$0xfffffff4,%esp
	fnstcw	-2(%ebp)
	movw	-2(%ebp),%ax
	or	$0xc,%ah
	movw	%ax,-4(%ebp)
	fldcw	-4(%ebp)
	fistpl	-12(%ebp)
	fldcw	-2(%ebp)
	movl	-12(%ebp),%eax
	leave
	ret
	.align	2
_$93:
	.size	__close_stdhandles,_$93-__close_stdhandles
	.extern	_open_osfhandle

	.text
	.type	__Setenvironment,function
__Setenvironment:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$20,%esp
	pushl	%ebx
	pushl	%esi
	pushl	%edi
	.line	8
	.line	15
	movl	$0,-12(%ebp)
	.line	17
	call	_GetEnvironmentStringsA@0
	movl	%eax,%ebx
	movl	%ebx,-16(%ebp)
	jmp	_$SetEnv3
_$SetEnv2:
	.line	19
	cmpb	$61,(,%ebx)
	je	_$SetEnv5
	.line	20
	incl	-12(%ebp)
_$SetEnv5:
	.line	21
	movl	%ebx,%edi
	xor	%eax,%eax
	stc
	sbb	%ecx,%ecx
	repne
	scasb
	neg	%ecx
	leal	-2(%ecx),%eax
	movl	%eax,%edi
	incl	%edi
	leal	(%ebx,%edi),%ebx
_$SetEnv3:
	.line	18
	cmpb	$0,(,%ebx)
	jne	_$SetEnv2
	.line	24
	movl	-12(%ebp),%edi
	incl	%edi
	leal	(,%edi,4),%edi
	movl	%edi,-20(%ebp)
	.line	25
	pushl	-20(%ebp)
	call	_malloc
	pop	%ecx
	movl	%eax,-8(%ebp)
	movl	%eax,__environ
	.line	26
	cmpl	$0,-8(%ebp)
	jne	_$SetEnv7
	xor	%eax,%eax
	jmp	_$SetEnv1
_$SetEnv7:
	.line	29
	movl	-16(%ebp),%ebx
	jmp	_$SetEnv12
_$SetEnv9:
	.line	30
	movl	%ebx,%edi
	xor	%eax,%eax
	stc
	sbb	%ecx,%ecx
	repne
	scasb
	neg	%ecx
	leal	-2(%ecx),%eax
	movl	%eax,%edi
	incl	%edi
	movl	%edi,-4(%ebp)
	cmpb	$61,(,%ebx)
	je	_$SetEnv13
	pushl	-4(%ebp)
	call	_malloc
	pop	%ecx
	movl	-8(%ebp),%esi
	movl	%eax,(,%esi)
	or	%eax,%eax
	jne	_$SetEnv15
	jmp	_$SetEnv1
_$SetEnv15:
	.line	35
	pushl	%ebx
	movl	-8(%ebp),%edi
	pushl	(,%edi)
	call	_strcpy
	addl	$8,%esp
	.line	36
	addl	$4,-8(%ebp)
_$SetEnv13:
	.line	29
	movl	-4(%ebp),%edx
	leal	(%ebx,%edx),%ebx
_$SetEnv12:
	cmpb	$0,(,%ebx)
	jne	_$SetEnv9
	.line	41
	movl	-8(%ebp),%edx
	movl	$0,(,%edx)
	movl	$1,%eax
_$SetEnv1:
	.line	42
	popl	%edi
	popl	%esi
	popl	%ebx
	leave
	ret
_$SetEnv22:
	.size	__Setenvironment,_$SetEnv22-__Setenvironment
	.data
	.globl	__environ
	.bss
	.extern	_strcpy
	.extern	_malloc
	.extern	_GetEnvironmentStringsA@0
	.text
	.extern	_cexit
	.extern	_ExitProcess@4
	.extern	_setbuf
	.extern	_fdopen
	.extern	_fclose
	.extern	_raise
	.globl	_stdout
	.globl	_stdin
	.globl	_stderr
	.globl	__environ
	.data
	.align	4
__UserEntryPoint:
	.long	0
_stdout:
	.long	0
_stdin:
	.long	0
_stderr:
	.long	0
__environ:
	.long	0
_$ExcepData:
	.long	0
	.align	1
_$2:	.byte	37,115,0
	.align	1
_$74:
	.byte	119,0
	.align	1
_$73:
	.byte	114,0
	.section .idata$3
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
	.section .idata$6
	.long   0
	.section .rdata
	.long   0
	.long   0
	.long   1
	.long   1
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
