function [varargout] = type(varargin)
%TYPE List M-file.
%   TYPE foo.bar lists the ascii file called 'foo.bar'.
%   TYPE foo lists the ascii file called 'foo.m'. 
%
%   If files called foo and foo.m both exist, then
%      TYPE foo lists the file 'foo', and
%      TYPE foo.m list the file 'foo.m'.
%
%   TYPE FILENAME lists the contents of the file given a full pathname
%   or a MATLABPATH relative partial pathname (see PARTIALPATH).
%
%   See also DBTYPE, WHICH, HELP, PARTIALPATH, MORE.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.13.4.2 $  $Date: 2004/03/17 20:05:34 $
%   Built-in function.

if nargout == 0
  builtin('type', varargin{:});
else
  [varargout{1:nargout}] = builtin('type', varargin{:});
end
