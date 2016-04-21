#include "extcode.h"
#pragma pack(push)
#pragma pack(1)

#ifdef __cplusplus
extern "C" {
#endif

void __stdcall DLLWrapperForFileDialog(char WindowName[], 
	long FileFilterPairs, long FileBuffer, long FileBufferSize, long Title);

long __cdecl LVDLLStatus(char *errStr, int errStrLen, void *module);

#ifdef __cplusplus
} // extern "C"
#endif

#pragma pack(pop)

