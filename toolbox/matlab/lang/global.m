function [varargout] = global_(varargin)
%GLOBAL Define global variable.
%   GLOBAL X Y Z defines X, Y, and Z as global in scope.
%
%   Ordinarily, each MATLAB function, defined by an M-file, has its
%   own local variables, which are separate from those of other functions,
%   and from those of the base workspace.  However, if several functions, 
%   and possibly the base workspace, all declare a particular name as 
%   GLOBAL, then they all share a single copy of that variable.  Any 
%   assignment to that variable, in any function, is available to all the 
%   other functions declaring it GLOBAL.
%
%   If the global variable doesn't exist the first time you issue
%   the GLOBAL statement, it will be initialized to the empty matrix.
%
%   If a variable with the same name as the global variable already exists
%   in the current workspace, MATLAB issues a warning and changes the
%   value of that variable to match the global.
%
%   Stylistically, global variables often have long names with all
%   capital letters, but this is not required.
%
%   For an example, run the commands "type tic.m" and "type toc.m".
%
%   See also ISGLOBAL, CLEAR, WHO, PERSISTENT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.12.4.3 $  $Date: 2004/02/14 14:22:01 $
%   Built-in function.

if nargout == 0
  builtin('global', varargin{:});
else
  [varargout{1:nargout}] = builtin('global', varargin{:});
end
