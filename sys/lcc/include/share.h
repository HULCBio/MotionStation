/* $Revision: 1.2 $ */
#ifndef SHARE_H
#define SHARE_H

#define _SH_DENYRW 0x10
#define _SH_DENYWR 0x20
#define _SH_DENYRD 0x30
#define _SH_DENYNO 0x40

#if !__STDC__
#define SH_DENYRW _SH_DENYRW
#define SH_DENYWR _SH_DENYWR
#define SH_DENYRD _SH_DENYRD
#define SH_DENYNO _SH_DENYNO
#endif

#endif   
