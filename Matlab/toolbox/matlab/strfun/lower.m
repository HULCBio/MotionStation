function [varargout] = lower(varargin)
%LOWER  Convert string to lowercase.
%   B = LOWER(A) converts any uppercase characters in A to
%   the corresponding lowercase character and leaves all
%   other characters unchanged.
%
%   B = LOWER(A), when A is a cell array of strings, returns a cell array
%   the same size as A containing the result of applying LOWER to each
%   string in A.
%
%   Character sets supported:
%      PC   : Windows Latin-1
%      Other: ISO Latin-1 (ISO 8859-1)
%           : Also supports 16-bit character sets.
%
%   See also UPPER.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.14.4.2 $  $Date: 2004/04/10 23:32:42 $

%   Built-in function.

if nargout == 0
  builtin('lower', varargin{:});
else
  [varargout{1:nargout}] = builtin('lower', varargin{:});
end
