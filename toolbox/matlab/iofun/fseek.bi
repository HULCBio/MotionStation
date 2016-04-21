function [varargout] = fseek(varargin)
%FSEEK Set file position indicator. 
%   STATUS = FSEEK(FID, OFFSET, ORIGIN) repositions the file position
%   indicator in the file with the given FID to the byte with the
%   specified OFFSET relative to ORIGIN.
%
%   FID is an integer file identifier obtained from FOPEN.
%
%   OFFSET values are interpreted as follows:
%       > 0    Move toward the end of the file.
%       = 0    Do not change position.
%       < 0    Move toward the beginning of the file.
%
%   ORIGIN values are interpreted as follows:
%       'bof' or -1   Beginning of file
%       'cof' or  0   Current position in file
%       'eof' or  1   End of file
%
%   STATUS is 0 on success and -1 on failure.  If an error occurs use
%   FERROR to get more information.
%
%   Example:
%
%       fseek(fid,0,-1)
%
%   "rewinds" the file.
%
%   See also FOPEN, FTELL, FREWIND.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.10.4.2 $  $Date: 2004/03/26 13:26:27 $
%   Built-in function.

if nargout == 0
  builtin('fseek', varargin{:});
else
  [varargout{1:nargout}] = builtin('fseek', varargin{:});
end
