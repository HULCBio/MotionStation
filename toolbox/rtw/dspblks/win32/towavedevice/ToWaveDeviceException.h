/* $Revision: 1.1 $ */
#ifndef TOWAVEDEVICEEXCEPTION_H
#define TOWAVEDEVICEEXCEPTION_H

#include <stdexcpt.h>

class ToWaveDeviceException : public exception
{
private:
    int errorCode;

public:
    ToWaveDeviceException(int code)
    {
		errorCode = code;
    }

    int GetErrorCode()
    {
		return errorCode;
    }
};

#endif //TOWAVEDEVICEEXCEPTION_H