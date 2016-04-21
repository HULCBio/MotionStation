function [varargout] = ferror(varargin)
%FERROR Inquire file error status. 
%   MESSAGE = FERROR(FID) returns the error message for the
%   most recent file I/O operation associated with the specified file. 
%   FID is an integer file identifier obtained from FOPEN, or 0 for
%   standard input, 1 for standard output or 2 for standard error.
%
%   [MESSAGE,ERRNUM] = FERROR(FID) returns the error number as well.
%   If the most recent I/O operation was successful, MESSAGE is empty
%   and ERRNUM is 0.  A nonzero ERRNUM indicates that an error
%   occurred.  The values of ERRNUM match those returned by the C
%   library on your platform.
%
%   [...] = FERROR(FID,'clear') also clears the error indicator for
%   the specified file.
%
%   See also FOPEN, FCLOSE, FREAD, FWRITE, FEOF, ERROR.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.10.4.2 $  $Date: 2004/03/26 13:26:24 $
%   Built-in function.

if nargout == 0
  builtin('ferror', varargin{:});
else
  [varargout{1:nargout}] = builtin('ferror', varargin{:});
end
