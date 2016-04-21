#ifndef ctfarchiver_tbx_compiler_h
#define ctfarchiver_tbx_compiler_h

bool ctfCreateZipFile(const char *zipFile, const char * const srcFiles[],
		      const char * const destFiles[], int numFiles);

bool ctfExtractZipFile(const char *zipFile);

#endif
