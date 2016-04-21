function [varargout] = persistent_(varargin)
%PERSISTENT Define persistent variable.
%   PERSISTENT X Y Z defines X, Y, and Z as variables that are local 
%   to the function in which they are declared yet their values are 
%   retained in memory between calls to the function.  Persistent 
%   variables are similar to global variables because MATLAB creates 
%   permanent storage for both.  They differ from global variables in 
%   that persistent variables are known only to the function in which 
%   they are declared.  This prevents persistent variables from being 
%   changed by other functions or from the MATLAB command line.
%
%   Persistent variables are cleared when the M-file is cleared from
%   memory or when the M-file is changed.  To keep an M-file in memory
%   until MATLAB quits, use MLOCK.
%
%   If the persistent variable does not exist the first time you issue
%   the PERSISTENT statement, it will be initialized to the empty matrix.
%
%   It is an error to declare a variable persistent if a variable with
%   the same name exists in the current workspace.
%
%   See also GLOBAL, CLEAR, MLOCK, MUNLOCK, MISLOCKED.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.2 $  $Date: 2003/10/24 23:26:12 $
%   Built-in function.

if nargout == 0
  builtin('persistent', varargin{:});
else
  [varargout{1:nargout}] = builtin('persistent', varargin{:});
end
