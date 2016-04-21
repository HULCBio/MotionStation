// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:33:48 $

#ifndef _winsounderr_h
#define _winsounderr_h

#define DAQERROR_BASE  (-1000)
#define DEFINE_ERROR(_x) (_x+DAQERROR_BASE)
#define E_SAFEARRAY_FAILURE     DEFINE_ERROR(1)
#define E_INVALID_FORMAT        DEFINE_ERROR(2)
#define E_DEVICE_IN_USE         DEFINE_ERROR(3)
#define E_INVALID_CHANNEL       DEFINE_ERROR(4)
#define E_EXCEEDS_MAX_CHANNELS  DEFINE_ERROR(5)
#define E_NO_DEVICE		DEFINE_ERROR(6)
#define E_INV_SKEW_MODE         DEFINE_ERROR(7)
#define E_INV_SKEW_VALUE        DEFINE_ERROR(8)
#define E_DEL_CHAN_ERR          DEFINE_ERROR(9)
#define E_CHAN_INUSE		DEFINE_ERROR(10)
#define E_INV_INPUT_RANGE       DEFINE_ERROR(11)
#define E_INV_OUTPUT_RANGE      DEFINE_ERROR(12)
#define E_CHAN_ORDER            DEFINE_ERROR(13)
#define E_CHAN_INDEX            DEFINE_ERROR(14)
#define E_INV_BPS		DEFINE_ERROR(15)
#define E_INVALID_DEVICE_ID	DEFINE_ERROR(16)
#endif

