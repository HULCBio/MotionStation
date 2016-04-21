function [varargout] = matlabpath(varargin)
%MATLABPATH Search path.
%   MATLABPATH is the built-in function that gets/sets the search path.
%   Please use the M-file PATH instead since it validates the path
%   elements and provides a much easier way to change the path. The path
%   is a PATHSEP character separated list of directories that MATLAB
%   searches when looking for functions and other files.
%
%   MATLABPATH, by itself, prettyprints MATLAB's current search path. 
%   P = MATLABPATH returns a string containing the path in P.
%   MATLABPATH(P) changes the path to P. 
%
%   See also PATH, PATHSEP.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2003/06/09 05:58:16 $
%   Built-in function.

if nargout == 0
  builtin('matlabpath', varargin{:});
else
  [varargout{1:nargout}] = builtin('matlabpath', varargin{:});
end
