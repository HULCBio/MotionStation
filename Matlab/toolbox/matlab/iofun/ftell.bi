function [varargout] = ftell(varargin)
%FTELL Get file position indicator. 
%   POSITION = FTELL(FID) returns the location of the file position
%   indicator in the specified file.  Position is indicated in bytes
%   from the beginning of the file.  If -1 is returned, it indicates
%   that the query was unsuccessful; use FERROR to determine the nature
%   of the error.
%
%   FID is an integer file identifier obtained from FOPEN.
%
%   See also FOPEN, FSEEK.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.9.4.2 $  $Date: 2004/04/10 23:29:29 $
%   Built-in function.

if nargout == 0
  builtin('ftell', varargin{:});
else
  [varargout{1:nargout}] = builtin('ftell', varargin{:});
end
