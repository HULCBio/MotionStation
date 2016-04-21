function [varargout] = cd(varargin)
%CD     Change current working directory.
%   CD directory-spec sets the current directory to the one specified.
%   CD .. moves to the directory above the current one.
%   CD, by itself, prints out the current directory.
%
%   WD = CD returns the current directory as a string.
%
%   Use the functional form of CD, such as CD('directory-spec'),
%   when the directory specification is stored in a string.
%
%   See also PWD.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2003/06/09 05:57:51 $
%   Built-in function.

if nargout == 0
  builtin('cd', varargin{:});
else
  [varargout{1:nargout}] = builtin('cd', varargin{:});
end
