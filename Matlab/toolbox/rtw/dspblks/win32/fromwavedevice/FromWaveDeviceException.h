/* $Revision: 1.1 $ */
#ifndef FROMWAVEDEVICEEXCEPTION_H
#define FROMWAVEDEVICEEXCEPTION_H

#include <stdexcpt.h>

class FromWaveDeviceException : public exception
{
private:
    int errorCode;

public:
    FromWaveDeviceException(int code)
    {
		errorCode = code;
    }

    int GetErrorCode()
    {
		return errorCode;
    }
};

#endif //FROMWAVEDEVICEEXCEPTION_H