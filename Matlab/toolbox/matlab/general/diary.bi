function [varargout] = diary(varargin)
%DIARY Save text of MATLAB session.
%   DIARY FILENAME causes a copy of all subsequent command window input
%   and most of the resulting command window output to be appended to the
%   named file.  If no file is specified, the file 'diary' is used.
%
%   DIARY OFF suspends it. 
%   DIARY ON turns it back on.
%   DIARY, by itself, toggles the diary state.
%
%   Use the functional form of DIARY, such as DIARY('file'),
%   when the file name is stored in a string.
%
%   See also SAVE.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.12.4.3 $  $Date: 2004/03/17 20:05:09 $
%   Built-in function.

if nargout == 0
  builtin('diary', varargin{:});
else
  [varargout{1:nargout}] = builtin('diary', varargin{:});
end
