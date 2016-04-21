/* $Revision: 1.1 $ */
#ifndef TOWAVEFILEEXCEPTION_H
#define TOWAVEFILEEXCEPTION_H

#include <stdexcpt.h>

class FromWaveFileException : public exception
{
private:
    int errorCode;

public:
    FromWaveFileException(int code)
    {
		errorCode = code;
    }

    int GetErrorCode()
    {
		return errorCode;
    }
};

#endif //TOWAVEFILEEXCEPTION_H