/* This example shows how you can add 64 bit file I/O capability to a
 * MEX-file. 64 bit file I/O enables reading and writing data from/to
 * large files up to and greater than 2GB (2^31-1 bytes) in size.
 * Note that some operating systems or compilers may not yet support
 * files larger than 2GB.
 */

#include "io64.h" /* io64.h is required for 64 bit file I/O and it MUST be the
		FIRST include in your source file, before system includes */
#include "mex.h"

/* Some of the techniques used in 32 bit file I/O for files up to 2GB
 * do not work for files beyond 2GB in size. This file outlines the
 * differences between 32 and 64 bit file I/O and explains each one
 * along with examples.
 *
 * There are 11 important details (functions, integer types,
 * struct/data types, suffixes for hardcoded values, format specifiers)
 * which comprise 64 bit file I/O:
 *
 * (1)  int64_T, uint64_T - 64 bit signed and unsigned integer types
 *                          (defined in tmwtypes.h)
 * (2)  LL, LLU           - suffixes for literal int constants 64 bit values
 *                          (C Standard ISO/IEC 9899:1999(E) Section 6.4.4.1)
 * (3)  FMT64             - format specifier for printing 64 bit int values
 *                          (defined in tmwtypes.h)
 * (4)  fopen()           - function to open file and obtain file pointer
 *                          (alias for POSIX fopen(), defined in io64.h)
 * (5)  setFilePos(),     - function to set the file position for the next I/O
 *                          (alias for POSIX fsetpos(), defined in io64.h)
 * (6)  getFilePos(),     - function to get the file position for the next I/O
 *                          (alias for POSIX fgetpos(), defined in io64.h)
 * (7)  fpos_T,           - 64 bit int type for setFilePos() and getFilePos()
 *                          (alias for POSIX fpos_t type, defined in io64.h)
 * (8)  fileno()          - function to get file descriptor from FILE* pointer
 *                          (alias for POSIX fileno(), defined in io64.h)
 * (9)  structStat,       - struct to get file size given file pointer or name
 *                          (alias for POSIX struct stat, defined in io64.h)
 * (10) getFileFstat(),   - function to get file size given file pointer
 *                          (alias for POSIX fstat(), defined in io64.h)
 * (11) getFileStat()     - function to get file size given file name
 *                          (alias for POSIX stat(), defined in io64.h)
 */

void mexfio64cleanup(FILE *fp, char *filename)
{
	if ( NULL != fp )
	{
		mexPrintf("fclose()\n");
		fclose(fp);
	}

	if ( NULL != filename )
	{
		mexPrintf("remove() '%s'\n",filename);
		remove(filename);
	}
}

/* This is the main MEX function (MEX dynamic library entry point).
 */
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
	/* (1) int64_T, uint64_T
	 * (2) LL, LLU
	 *
	 * the following example shows how to specify literal 64 bit int
	 * constants. In UNIX, you must use the LL suffix for signed,
	 * and LLU for unsigned 64 bit int constants. Note that these suffixes
	 * are not required for hardcoded (literal) values less than 2GB
	 * (2^31-1) even if they are assigned to a 64 bit int type.
	 * These suffixes CANNOT be used in windows and are not necessary
	 * in windows.
	 * int64_T and uint64_T are defined in tmwtypes.h as the appropriate
	 * signed and unsigned 64 bit int types for your platform/OS.
	 */

#if defined(_MSC_VER) || defined(__BORLANDC__)
	int64_T large_offset_example = 9000222000;
#else
	/* use LL suffix for unix constants greater than 2^31-1 signed
	 * use LLU suffix for unix constants greater than 2^32-1 unsigned
	 */
	int64_T large_offset_example = 9000222000LL;
#endif
	int64_T offset   = 0;
	int64_T position = 0;
	char    str[256];
	char    filename[256];
	char   *mydata   = "hello";

	FILE   *fp;

	/* check inputs */
	{
		if ( nrhs != 1 )
		{
			mexErrMsgTxt("One input argument expected (temp filename).");
		}

		if ( nlhs > 0 )
		{
			mexErrMsgTxt("No output arguments expected.");
		}

		if ( !mxIsChar(prhs[0]) )
		{
			mexErrMsgTxt("Temp filename input argument must be a text string.");
		}

		if ( mxGetString(prhs[0], filename, sizeof(filename) / 2) )
		{
			mexErrMsgTxt("mxGetString() failed.");
		}
	}

	/* (3) FMT64
	 *
	 * Note that a 64 bit int cannot be printed with "%d".
	 * The appropriate format specifier for your platform is defined
	 * in FMT64, defined in tmwtypes.h
	 * The following example shows how to print out a large file size.
	 */

	mexPrintf("Example large file size: %" FMT64 "d bytes.\n",
		large_offset_example);

	/* (4) fopen()
	 *
	 * just use fopen normally after including io64.h which defines fopen
	 * correctly to support large file I/O for the platform you're on.
	 * You don't need to do anything else for fopen.
	 * No changes at all are required for fread, fwrite, fprintf, fscanf,
	 * fclose.
	 */

	/* open existing file for read and update in binary mode */
	mexPrintf("fopen() '%s' - ",filename);
	fp = fopen(filename,"r+b");
	if ( NULL == fp )
	{
		/* file does not exist - create new file
		 * for writing in binary mode
		 */
		fp = fopen(filename,"wb");
		if ( NULL == fp )
		{
			sprintf(str,"Failed to open/create test file '%s'",
				filename);
			mexErrMsgTxt(str);
			return;
		}
		else
		{
			mexPrintf("new test file '%s' created\n",filename);
		}
	}
	else mexPrintf("existing test file '%s' opened\n",filename);

	/* get file size - scroll down for getFileFstat() example */
	{
		structStat statbuf;
		int64_T fileSize = 0;

		mexPrintf("getFileFstat() - ");
		if ( 0 == getFileFstat(fileno(fp), &statbuf ) )
		{
			fileSize = statbuf.st_size;
			offset = fileSize;
			mexPrintf("file size is %" FMT64 "d bytes\n",fileSize);
		}
		else
		{
			mexfio64cleanup(fp,filename);
			mexErrMsgTxt("getFileFstat() failed.");
		}
	}

	/* (5) setFilePos(),
	 * (6) getFilePos(),
	 * (7) fpos_T,
	 *
	 * the following example shows how to use setFilePos instead of fseek,
	 * and getFilePos instead of ftell. The ANSI C fseek and ftell are not
	 * 64 bit file I/O capable on most platforms. setFilePos and getFilePos
	 * are defined as the corresponding POSIX fsetpos/fgetpos or
	 * fsetpos64/fgetpos64 as required by your platform/OS in io64.h
	 * These functions are 64 bit file I/O capable on all platforms.
	 * Note that the offset parameter to setFilePos and getFilePos is
	 * really a signed 64 bit int, int64_T, however, it MUST be cast to
	 * an (fpos_T*).
	 * fpos_T is defined as the appropriate fpos64_t or fpos_t as required
	 * by your platform/OS in io64.h
	 * Note that unlike fseek, setFilePos supports only absolute seeking
	 * relative to the beginning of the file.
	 */

	/* This note is only if you want to support relative seeking like
	 * with fseek SEEK_CUR and SEEK_END. If you want to support relative
	 * seeking, you should use getFileFstat as shown in the previous
	 * example to obtain the file size.
	 * This allows you to convert the relative offset you want to seek
	 * to into an absolute offset which you can pass to setFilePos.
	 */

	/* fp is the (FILE*) pointer to an already opened file.
	 * offset is defined above. If the file existed already, this
	 * will move the file pointer to the end of the file to prepare
	 * for adding data at the end of the file.
	 */

	mexPrintf("setFilePos() - ");
	if ( 0 == setFilePos( fp, (fpos_T*) &offset) )
	{
		mexPrintf("seek to zero-based byte offset %" FMT64 "d ok\n",offset);
	}
	else
	{
		mexfio64cleanup(fp,filename);
		mexErrMsgTxt("setFilePos() failed.");
	}

	mexPrintf("getFilePos() - ");
	if ( 0 == getFilePos( fp, (fpos_T*) &position ) )
	{
		mexPrintf("current zero-based byte offset is %" FMT64 "d\n",position);
	}
	else
	{
		mexfio64cleanup(fp,filename);
		mexErrMsgTxt("getFilePos() failed.");
	}

	/* fread() fwrite() fprintf() fscanf() and fclose() are used the
	 * same way as before with no changes required to enable 64 bit
	 * file I/O capability. Here a text string is written to the file
	 * and then the file is closed.
	 * If the file existed already, the string is appended at the end
	 * of the file.
	 */

	mexPrintf("fprintf() data: '%s'\n",mydata);
	fprintf(fp, "%s", mydata);

	/* get the current byte position of the file pointer and seek
	 * to that position. This does not change the position of the file
	 * pointer, but it updates the correct file size to be returned by
	 * getFileFstat() below.
	 */

	mexPrintf("getFilePos() - ");
	if ( 0 == getFilePos( fp, (fpos_T*) &position ) )
	{
		mexPrintf("current zero-based byte offset is %" FMT64 "d\n",position);
	}
	else
	{
		mexfio64cleanup(fp,filename);
		mexErrMsgTxt("getFilePos() failed.");
	}

	/* Before calling getFileFstat (which works on open files), you
	 * should setFilePos to the current file position.
	 * This does not move the file pointer, but it is necessary, as it
	 * updates the file size in getFileFstat. This is necessary due to
	 * the underlying C library implementation. If you call getFileFstat
	 * on a file opened for writing, the file size may be incorrect
	 * or 0 unless you call setFilePos before calling getFileFstat.
	 * It does not matter to which position in the file you seek as long
	 * as a seek is called before the fstat. Seeking to the current
	 * position is only a suggestion.
	 * Try commenting out the block of code with setFilePos() below
	 * and then recompile and rerun this example at the MATLAB command
	 * prompt to see that this causes the following getFileFstat() to not
	 * show the updated file size after it was increased by the above
	 * fprintf().
	 */

	{
		mexPrintf("setFilePos() - ");
		if ( 0 == setFilePos( fp, (fpos_T*) &position) )
		{
			mexPrintf("seek to zero-based byte offset %" FMT64 "d ok\n",position);
		}
		else
		{
			mexfio64cleanup(fp,filename);
			mexErrMsgTxt("setFilePos() failed.");
		}
	}

	/* (8)  fileno(),
	 * (9)  structStat,
	 * (10) getFileFstat()
	 *
	 * In 32 bit file I/O, for files less than 2GB in size, one
	 * technique that was sometimes used to obtain the size in bytes
	 * of an already opened file was to use fseek() with the SEEK_END
	 * parameter to seek to the end of the file, then call ftell() to
	 * get the current position of the file pointer, and hence the size
	 * of the file in bytes, and then fseek() back to the original
	 * position.
	 *
	 * /// this is a technique of getting the file size of the
	 * /// currently opened file in 32 bit file I/O
	 * {
	 *     FILE *fp;
	 *     int current_position = 0;
	 *     int file_size = 0;
	 *     char *filename = "myfile";
	 *
	 *     fp = fopen(filename,"rb");
	 *     current_position = ftell(fp); // save current position
	 *     fseek(fp,0,SEEK_END); // seek to end of file
	 *     file_size = ftell(fp); // get current position = file size
	 *     fseek(fp,current_position,SEEK_SET); // seek to end of file
	 *     printf("size of currently opened file is %d bytes\n",
	 *         file_size);
	 *     fclose(fp);
	 * }
	 *
	 * Since fseek() is not supported for 64 bit file I/O on most
	 * platforms, setFilePos() (the POSIX fsetpos()) will be used
	 * instead, as it supports 64 bit file I/O on all platforms.
	 * This function, however, supports only absolute seeking, the
	 * equivalent of using fseek() with SEEK_SET, thus, you cannot
	 * use the fseek() SEEK_END/ftell() technique to get the size of
	 * an already opened file. Instead, you should use getFileFstat()
	 * as shown below.
	 * The following example shows how to use structStat, getFileFstat,
	 * and fileno to get the size of an opened file in bytes, using the
	 * opened file pointer.
	 * structStat is defined in io64.h as the appropriate stat struct to
	 * support large file I/O as required on your platform.
	 * getFileFstat is defined in io64.h as the appropriate fstat
	 * function as required on your platform.
	 * fileno is defined in io64.h as required on your platform.
	 * fp is the (FILE*) pointer to an already opened file
	 */

	{
		structStat statbuf;
		int64_T fileSize = 0;

		mexPrintf("getFileFstat() - ");
		if ( 0 == getFileFstat(fileno(fp), &statbuf ) )
		{
			fileSize = statbuf.st_size;
			mexPrintf("file size is %" FMT64 "d bytes\n",fileSize);
		}
		else
		{
			mexfio64cleanup(fp,filename);
			mexErrMsgTxt("getFileFstat() failed.");
		}
	}

	/* close the file normally */

	mexPrintf("fclose()\n");
	fclose(fp);

	/* (11) getFileStat()
	 *
	 * the following example shows how to use getFileStat
	 * to get the size of an unopened file in bytes, using the name of
	 * the file on disk.
	 * getFileStat is defined in io64.h as the appropriate stat
	 * function as required on your platform.
	 */

	{
		structStat statbuf;
		int64_T fileSize = 0;

		mexPrintf("getFileStat() - ");
		if ( 0 == getFileStat(filename, &statbuf) )
		{
			fileSize = statbuf.st_size;
			mexPrintf("file size is %" FMT64 "d bytes\n",fileSize);
		}
		else
		{
			mexfio64cleanup(fp,filename);
			mexErrMsgTxt("getFileStat() failed.");
		}
	}

	/* delete the file */

	mexPrintf("remove() - deleting file '%s'\n",filename);
	remove(filename);

	return;
}
