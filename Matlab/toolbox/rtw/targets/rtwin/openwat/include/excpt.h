/*
 *  excpt.h     Structured Exception Handling types, defines and routines
 *
 *                          Open Watcom Project
 *
 *    Portions Copyright (c) 1983-2002 Sybase, Inc. All Rights Reserved.
 *
 *  ========================================================================
 *
 *    This file contains Original Code and/or Modifications of Original
 *    Code as defined in and that are subject to the Sybase Open Watcom
 *    Public License version 1.0 (the 'License'). You may not use this file
 *    except in compliance with the License. BY USING THIS FILE YOU AGREE TO
 *    ALL TERMS AND CONDITIONS OF THE LICENSE. A copy of the License is
 *    provided with the Original Code and Modifications, and is also
 *    available at www.sybase.com/developer/opensource.
 *
 *    The Original Code and all software distributed under the License are
 *    distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 *    EXPRESS OR IMPLIED, AND SYBASE AND ALL CONTRIBUTORS HEREBY DISCLAIM
 *    ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF
 *    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR
 *    NON-INFRINGEMENT. Please see the License for the specific language
 *    governing rights and limitations under the License.
 *
 *  ========================================================================
 */
#ifndef _EXCPT_H_INCLUDED
#define _EXCPT_H_INCLUDED
#define _INC_EXCPT
#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#if defined(__OS2__)
#ifndef __BSEXCPT_H__
  #include <os2def.h>
  #include <bsexcpt.h>
#endif
#endif

/*
 * Exception disposition return values.
 */
typedef enum _EXCEPTION_DISPOSITION {
    ExceptionContinueExecution,
    ExceptionContinueSearch,
    ExceptionNestedException,
    ExceptionCollidedUnwind
} EXCEPTION_DISPOSITION;


/*
 * Prototype for SEH support function.
 */
struct _EXCEPTION_RECORD;
struct _CONTEXT;

EXCEPTION_DISPOSITION __cdecl _except_handler (
        struct _EXCEPTION_RECORD *ExceptionRecord,
        void * EstablisherFrame,
        struct _CONTEXT *ContextRecord,
        void * DispatcherContext
        );

#if defined(__OS2__)
 typedef struct _EXCEPTION_POINTERS {
     PEXCEPTIONREPORTRECORD ExceptionRecord;
     PCONTEXTRECORD ContextRecord;
 } EXCEPTION_POINTERS,*PEXCEPTION_POINTERS,*LPEXCEPTION_POINTERS;
#endif

/*
 * Keywords and intrinsics for SEH
 */
#define __try           _try
#define __except        _except
#define __finally       _finally
#define __leave         _leave
#define GetExceptionCode                _exception_code
#define exception_code                  _exception_code
#define GetExceptionInformation         (struct _EXCEPTION_POINTERS *)_exception_info
#define exception_info                  (struct _EXCEPTION_POINTERS *)_exception_info
#undef AbnormalTermination
#define AbnormalTermination             _abnormal_termination
#define abnormal_termination            _abnormal_termination

unsigned long __cdecl _exception_code(void);
void *        __cdecl _exception_info(void);
int           __cdecl _abnormal_termination(void);


/*
 * Legal values for expression in except().
 */
#define EXCEPTION_EXECUTE_HANDLER        1
#define EXCEPTION_CONTINUE_SEARCH        0
#ifndef EXCEPTION_CONTINUE_EXECUTION
#define EXCEPTION_CONTINUE_EXECUTION   (-1)
#endif

#ifdef __cplusplus
};
#endif /* __cplusplus */
#endif
