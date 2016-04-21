function [varargout] = who(varargin)
%WHO    List current variables.
%   WHO lists the variables in the current workspace.
%   WHOS lists more information about each variable.
%   WHO GLOBAL and WHOS GLOBAL list the variables in the global workspace.
%   WHO -FILE FILENAME lists the variables in the specified .MAT file.
%
%   WHO ... VAR1 VAR2 restricts the display to the variables specified. The
%   wildcard character '*' can be used to display variables that match a
%   pattern.  For instance, WHO A* finds all variables in the current
%   workspace that start with A.
%
%   WHO -REGEXP PAT1 PAT2 can be used to display all variables matching the
%   specified patterns using regular expressions. For more information on
%   using regular expressions, type "doc regexp" at the command prompt.
%
%   Use the functional form of WHO, such as WHO('-file',FILE,V1,V2),
%   when the filename or variable names are stored in strings. 
%
%   S = WHO(...) returns a cell array containing the names of the variables
%   in the workspace or file. You must use the functional form of WHO when
%   there is an output argument.
%
%   Examples for pattern matching:
%       who a*                      % Show variable names starting with "a"
%       who -regexp ^b\d{3}$        % Show variable names starting with "b"
%                                   %   and followed by 3 digits
%       who -file fname -regexp \d  % Show variable names containing any
%                                   %   digits that exist in MAT-file fname
%
%   See also WHOS, SAVE, LOAD.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.11.4.2 $  $Date: 2003/12/19 22:58:56 $
%   Built-in function.

if nargout == 0
  builtin('who', varargin{:});
else
  [varargout{1:nargout}] = builtin('who', varargin{:});
end
