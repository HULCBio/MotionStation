function [varargout] = dir(varargin)
%DIR List directory.
%   DIR directory_name lists the files in a directory. Pathnames and
%   wildcards may be used.  For example, DIR *.m lists all the M-files
%   in the current directory.
%
%   D = DIR('directory_name') returns the results in an M-by-1
%   structure with the fields: 
%       name  -- filename
%       date  -- modification date
%       bytes -- number of bytes allocated to the file
%       isdir -- 1 if name is a directory and 0 if not
%
%   See also WHAT, CD, TYPE, DELETE, LS, RMDIR, MKDIR.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.12.4.2 $  $Date: 2004/03/17 20:05:10 $
%   Built-in function.

if nargout == 0
  builtin('dir', varargin{:});
else
  [varargout{1:nargout}] = builtin('dir', varargin{:});
end
