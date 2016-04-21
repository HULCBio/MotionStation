/* $Revision: 1.1 $ */
#ifndef TOWAVEFILEEXCEPTION_H
#define TOWAVEFILEEXCEPTION_H

#include <stdexcpt.h>

class ToWaveFileException : public exception
{
private:
    int errorCode;

public:
    ToWaveFileException(int code)
    {
		errorCode = code;
    }

    int GetErrorCode()
    {
		return errorCode;
    }
};

#endif //TOWAVEFILEEXCEPTION_H