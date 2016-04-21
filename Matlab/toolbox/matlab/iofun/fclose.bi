function [varargout] = fclose(varargin)
%FCLOSE Close file.
%   ST = FCLOSE(FID) closes the file with file identifier FID,
%   which is an integer obtained from an earlier FOPEN.  FCLOSE 
%   returns 0 if successful and -1 if not.
%
%   ST = FCLOSE('all') closes all open files, except 0, 1 and 2.
%
%   See also FOPEN, FREWIND, FREAD, FWRITE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.9.4.2 $  $Date: 2004/04/10 23:29:21 $
%   Built-in function.

if nargout == 0
  builtin('fclose', varargin{:});
else
  [varargout{1:nargout}] = builtin('fclose', varargin{:});
end
