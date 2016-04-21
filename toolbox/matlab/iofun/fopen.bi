function [varargout] = fopen(varargin)
%FOPEN  Open file.
%   FID = FOPEN(FILENAME) opens the file FILENAME for read access.
%   (On PC systems, fopen opens files for binary read access.)
%
%   FILENAME can be a MATLABPATH relative partial pathname.  If the
%   file is opened for reading and it is not found in the current
%   working directory, FOPEN searches down MATLAB's search path.
%
%   FID is a scalar MATLAB integer, called a file identifier. You
%   use the fid as the first argument to other file input/output
%   routines. If FOPEN cannot open the file, it returns -1.
%
%   FID = FOPEN(FILENAME,PERMISSION) opens the file FILENAME in the
%   mode specified by PERMISSION.  PERMISSION can be:
%   
%       'r'     read
%       'w'     write (create if necessary)
%       'a'     append (create if necessary)
%       'r+'    read and write (do not create)
%       'w+'    truncate or create for read and write
%       'a+'    read and append (create if necessary)
%       'W'     write without automatic flushing
%       'A'     append without automatic flushing
%   
%   Files can be opened in binary mode (the default) or in text mode.
%   In binary mode no characters get singled out for special treatment.
%   In text mode on the PC, the carriage return character preceding
%   a newline character is deleted on input and added before the newline
%   character on output.  To open in text mode, add 't' to the
%   permission string, for example 'rt' and 'wt+'.  (On Unix, text and
%   binary mode are the same so this has no effect.  But on PC systems
%   this is critical.)
%
%   If the file is opened in update mode ('+'), an input command like
%   FREAD, FSCANF, FGETS, or FGETL cannot be immediately followed by 
%   an output command like FWRITE or FPRINTF without an intervening 
%   FSEEK or FREWIND.  The reverse is also true.  Namely, an output 
%   command like FWRITE, or FPRINTF cannot be immediately followed by 
%   an input command like FREAD, FSCANF, FGETS, or FGETL without an 
%   intervening FSEEK or FREWIND.
%
%   Two file identifiers are automatically available and need not be
%   opened.  They are FID=1 (standard output) and FID=2 (standard error).
%   
%   [FID, MESSAGE] = FOPEN(FILENAME,PERMISSION) returns a system 
%   dependent error message if the open is not successful.
%
%   [FID, MESSAGE] = FOPEN(FILENAME,PERMISSION,MACHINEFORMAT) opens the
%   specified file with the specified PERMISSION and treats data read
%   using FREAD or data written using FWRITE as having a format given
%   by MACHINEFORMAT. MACHINEFORMAT is one of the following strings:
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
%   [FILENAME,PERMISSION,MACHINEFORMAT] = FOPEN(FID) returns the filename,
%   permission, and machineformat associated with the given file
%   identifier. If FID does not exist then an empty string is returned for
%   each variable.
%
%   FIDS = FOPEN('all') returns a row vector, the file identifiers for 
%   all the files currently opened by the user (but not 1 or 2).
%   
%   The 'W' and 'A' permissions are designed for use with tape drives and
%   do not automatically perform a flush of the current output buffer
%   after output operations. For example, open a 1/4" cartridge tape on a
%   SPARCstation for writing with no auto-flush:
%
%           fid = fopen('/dev/rst0','W')
%   
%   See also FCLOSE, FREWIND, FREAD, FWRITE, FPRINTF, FGETS, FGETL.

%   FID = FOPEN(FILENAME) assumes a permission of 'r'.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.17.4.3 $  $Date: 2004/04/10 23:29:25 $
%   Built-in function.

if nargout == 0
  builtin('fopen', varargin{:});
else
  [varargout{1:nargout}] = builtin('fopen', varargin{:});
end
