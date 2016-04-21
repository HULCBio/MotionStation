function [varargout] = isletter(varargin)
%ISLETTER True for letters of the alphabet.
%   For a string S, ISLETTER(S) is 1 for letters of the alphabet
%   and 0 otherwise.
%
%   Character sets supported:
%      PC   : Windows Latin-1
%      Other: ISO Latin-1 (ISO 8859-1)
%
%   See also ISSPACE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.10.4.2 $  $Date: 2004/04/10 23:32:39 $


%   Built-in function.

if nargout == 0
  builtin('isletter', varargin{:});
else
  [varargout{1:nargout}] = builtin('isletter', varargin{:});
end
