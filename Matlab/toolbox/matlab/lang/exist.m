function [varargout] = exist(varargin)
%EXIST  Check if variables or functions are defined.
%   EXIST('A') returns:
%     0 if A does not exist
%     1 if A is a variable in the workspace
%     2 if A is an M-file on MATLAB's search path.  It also returns 2 when
%          A is the full pathname to a file or when A is the name of an
%          ordinary file on MATLAB's search path
%     3 if A is a MEX- or DLL-file on MATLAB's search path
%     4 if A is a MDL-file on MATLAB's search path
%     5 if A is a built-in MATLAB function
%     6 if A is a P-file on MATLAB's search path
%     7 if A is a directory
%     8 if A is a Java class
%
%   EXIST('A') or EXIST('A.EXT') returns 2 if a file named 'A' or 'A.EXT'
%   and the extension isn't a P or MEX function extension.
%
%   EXIST('A','var') checks only for variables.
%   EXIST('A','builtin') checks only for built-in functions.
%   EXIST('A','file') checks for files or directories.
%   EXIST('A','dir') checks only for directories.
%   EXIST('A','class') checks only for Java classes.
%
%   If A specifies a filename, MATLAB attempts to locate the file, 
%   examines the filename extension, and determines the value to 
%   return based on the extension alone.  MATLAB does not examine 
%   the contents or internal structure of the file.
%
%   EXIST returns 0 if the specified instance isn't found.
%
%   See also DIR, WHAT, ISEMPTY.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.21.4.2 $  $Date: 2004/04/10 23:29:50 $
%   Built-in function.

if nargout == 0
  builtin('exist', varargin{:});
else
  [varargout{1:nargout}] = builtin('exist', varargin{:});
end
