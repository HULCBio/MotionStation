function [varargout] = feof(varargin)
%FEOF   Test for end-of-file.
%   FEOF(FID) returns 1 if the end-of-file indicator for the
%   file with file identifier FID has been set, and 0 otherwise.
%
%   The end-of-file indicator is set when the file position
%   indicator reaches the end of the file.
%
%   See also FOPEN, FREAD, FGETL, FGETS, FERROR.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.8.4.2 $  $Date: 2004/03/26 13:26:23 $
%   Built-in function.

if nargout == 0
  builtin('feof', varargin{:});
else
  [varargout{1:nargout}] = builtin('feof', varargin{:});
end
