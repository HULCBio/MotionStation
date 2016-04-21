function [varargout] = fread(varargin)
%FREAD  Read binary data from file.
%   A = FREAD(FID) reads binary data from the specified file 
%   and writes it into matrix A.  FID is an integer file 
%   identifier obtained from FOPEN.  MATLAB reads the entire 
%   file and positions the file pointer at the end of the file 
%   (see FEOF for details).
%
%   A = FREAD(FID,SIZE) reads the number of elements specified 
%   by SIZE.  Valid entries for SIZE are:
%       N      read N elements into a column vector.
%       inf    read to the end of the file.
%       [M,N]  read elements to fill an M-by-N matrix, in column order.
%              N can be inf, but M can't.
%
%   A = FREAD(FID,SIZE,PRECISION) reads the file according to
%   the data format specified by the string PRECISION.  The 
%   PRECISION input commonly contains a datatype specifier like 
%   'int' or 'float', followed by an integer giving the size in
%   bits.  The SIZE argument is optional when using this syntax.
%
%   Any of the following strings, either the MATLAB version, or 
%   their C or Fortran equivalent, may be used.  If not specified, 
%   the default precision is 'uchar'.
%       MATLAB    C or Fortran     Description
%       'uchar'   'unsigned char'  unsigned character,  8 bits.
%       'schar'   'signed char'    signed character,  8 bits.
%       'int8'    'integer*1'      integer, 8 bits.
%       'int16'   'integer*2'      integer, 16 bits.
%       'int32'   'integer*4'      integer, 32 bits.
%       'int64'   'integer*8'      integer, 64 bits.
%       'uint8'   'integer*1'      unsigned integer, 8 bits.
%       'uint16'  'integer*2'      unsigned integer, 16 bits.
%       'uint32'  'integer*4'      unsigned integer, 32 bits.
%       'uint64'  'integer*8'      unsigned integer, 64 bits.
%       'single'  'real*4'         floating point, 32 bits.
%       'float32' 'real*4'         floating point, 32 bits.
%       'double'  'real*8'         floating point, 64 bits.
%       'float64' 'real*8'         floating point, 64 bits.
%
%   The following platform dependent formats are also supported but
%   they are not guaranteed to be the same size on all platforms.
%
%       MATLAB    C or Fortran     Description
%       'char'    'char*1'         character,  8 bits (signed or unsigned).
%       'short'   'short'          integer,  16 bits.
%       'int'     'int'            integer,  32 bits.
%       'long'    'long'           integer,  32 or 64 bits.
%       'ushort'  'unsigned short' unsigned integer,  16 bits.
%       'uint'    'unsigned int'   unsigned integer,  32 bits.
%       'ulong'   'unsigned long'  unsigned integer,  32 bits or 64 bits.
%       'float'   'float'          floating point, 32 bits.
%
%   The following formats map to an input stream of bits rather than
%   bytes.
%
%       'bitN'                     signed integer, N bits  (1<=N<=64).
%       'ubitN'                    unsigned integer, N bits (1<=N<=64).
%
%   If the input stream is bytes and FREAD reaches the end of file
%   (see FEOF) in the middle of reading the number of bytes required
%   for an element, the partial result is ignored. However, if the
%   input stream is bits, then the partial result is returned as the
%   last value.  If an error occurs before reaching the end of file,
%   only full elements read up to that point are used.
%
%   By default, numeric values are returned in class 'double' arrays.
%   To return numeric values stored in classes other than double,
%   create your PRECISION argument by first specifying your source
%   format, then following it by '=>', and finally specifying your
%   destination format. If the source and destination formats are the
%   same then the following shorthand notation may be used:
%
%       *source
%
%   which means:
%
%       source=>source
%
%   For example,
%
%       uint8=>uint8               read in unsigned 8-bit integers and
%                                  save them in an unsigned 8-bit integer
%                                  array
%
%       *uint8                     shorthand version of previous example
%
%       bit4=>int8                 read in signed 4-bit integers packed
%                                  in bytes and save them in a signed
%                                  8-bit integer array (each 4-bit
%                                  integer becomes one 8-bit integer)
%
%       double=>real*4             read in doubles, convert and save
%                                  as a 32-bit floating point array
%
%   A = FREAD(FID,SIZE,PRECISION,SKIP) includes a SKIP argument that
%   specifies the number of bytes to skip after each PRECISION value
%   is read. If PRECISION specifies a bit source format, like 'bitN' or 
%   'ubitN', the SKIP argument is interpreted as the number of bits to
%   skip.  The SIZE argument is optional when using this syntax.
%
%   When SKIP is used, the PRECISION string may contain a positive
%   integer repetition factor of the form 'N*' which prepends the source
%   format of the PRECISION argument, like '40*uchar'.  Note that 40*uchar
%   for the PRECISION alone is equivalent to '40*uchar=>double', not 
%   '40*uchar=>uchar'.  With SKIP specified, FREAD reads in, at most, a 
%   repetition factor number of values (default of 1), does a skip of 
%   input specified by the SKIP argument, reads in another block of values
%   and does a skip of input, etc. until SIZE number of values have been 
%   read.  If a SKIP argument is not specified, the repetition factor is 
%   ignored.  Repetition with skip is useful for extracting data in 
%   noncontiguous fields from fixed length records.
%
%   For example,
%
%       s = fread(fid,120,'40*uchar=>uchar',8);
%
%   reads in 120 characters in blocks of 40 each separated by 8 
%   characters.
%
%   A = FREAD(FID,SIZE,PRECISION,SKIP,MACHINEFORMAT) treats the data 
%   read as having a format given by the string MACHINEFORMAT. You 
%   can obtain the MACHINEFORMAT argument from the output of the 
%   FOPEN function.   The SIZE and SKIP arguments are optional when
%   using this syntax.
%   
%   MACHINEFORMAT is one of the following strings:
%
%   'native'      or 'n' - local machine format - the default
%   'ieee-le'     or 'l' - IEEE floating point with little-endian
%                          byte ordering
%   'ieee-be'     or 'b' - IEEE floating point with big-endian
%                          byte ordering
%   'vaxd'        or 'd' - VAX D floating point and VAX ordering
%   'vaxg'        or 'g' - VAX G floating point and VAX ordering
%   'cray'        or 'c' - Cray floating point with big-endian
%                          byte ordering
%   'ieee-le.l64' or 'a' - IEEE floating point with little-endian
%                          byte ordering and 64 bit long data type
%   'ieee-be.l64' or 's' - IEEE floating point with big-endian byte
%                          ordering and 64 bit long data type.
%   
%   See FOPEN on how to read Big and Little Endian files.
%
%   [A, COUNT] = FREAD(...) Optional output argument COUNT returns
%   the number of elements successfully read.
%
%   See also FWRITE, FSEEK, FSCANF, FGETL, FGETS, LOAD, FOPEN, FEOF.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.20.4.2 $  $Date: 2004/04/10 23:29:27 $
%   Built-in function.

if nargout == 0
  builtin('fread', varargin{:});
else
  [varargout{1:nargout}] = builtin('fread', varargin{:});
end
