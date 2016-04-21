function [varargout] = whos(varargin)
%WHOS List current variables, long form. 
%   WHOS is a long form of WHO.  It lists all the variables in the current
%   workspace, together with information about their size, bytes, class,
%   etc.
%   
%   WHOS GLOBAL lists the variables in the global workspace.
%   WHOS -FILE FILENAME lists the variables in the specified .MAT file.
%   WHOS ... VAR1 VAR2 restricts the display to the variables specified.
%
%   The wildcard character '*' can be used to display variables that match
%   a pattern.  For instance, WHOS A* finds all variables in the current
%   workspace that start with A.
%
%   WHOS -REGEXP PAT1 PAT2 can be used to display all variables matching
%   the specified patterns using regular expressions. For more information
%   on using regular expressions, type "doc regexp" at the command prompt.
%
%   Use the functional form of WHOS, such as WHOS('-file',FILE,V1,V2), when
%   the filename or variable names are stored in strings. 
%
%   S = WHOS(...) returns a structure with the fields:
%       name  -- variable name
%       size  -- variable size
%       bytes -- number of bytes allocated for the array
%       class -- class of variable
%   You must use the functional form of WHOS when there is an output
%   argument. 
%
%   Examples for pattern matching:
%      whos a*                      % Show variable names starting with "a"
%      whos -regexp ^b\d{3}$        % Show variable names starting with "b"
%                                   %   and followed by 3 digits
%      whos -file fname -regexp \d  % Show variable names containing any
%                                   %   digits that exist in MAT-file fname
%
%   See also WHO, SAVE, LOAD.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.13.4.3 $  $Date: 2004/04/10 23:26:08 $
%   Built-in function.

if nargout == 0
  builtin('whos', varargin{:});
else
  [varargout{1:nargout}] = builtin('whos', varargin{:});
end
