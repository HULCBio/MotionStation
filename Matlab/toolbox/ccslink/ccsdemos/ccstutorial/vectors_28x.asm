; $Revision: 1.1.4.1 $
;*
;*  Prototype Interrupt Vector Table for C28X C Runtime
;*  Copyright (c) 2000 Texas Instruments Incorporated
;*  
;*  
;*

	.ref  _c_int00
	.sect ".vectors"
RESET:	.long  _c_int00
