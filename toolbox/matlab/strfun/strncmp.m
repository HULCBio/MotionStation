function [varargout] = strncmp(varargin)
%STRNCMP Compare first N characters of strings.
%   STRNCMP(S1,S2,N) returns 1 if the first N characters of
%   the strings S1 and S2 are the same and 0 otherwise.
%
%   TF = STRNCMP(S,T,N), when either S or T is a cell array of strings,
%   returns an array the same size as S and T containing 1 for those
%   elements of S and T that match (up to N characters), and 0
%   otherwise.  S and T must be the same size (or one can be a scalar
%   cell).  Either one can also be a character array with the
%   right number of rows.
%
%   STRNCMP supports international character sets.
%
%   See also STRCMP, STRNCMPI, FINDSTR, STRMATCH, REGEXP.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.16.4.3 $  $Date: 2004/04/16 22:08:51 $
%   Built-in function.


if nargout == 0
  builtin('strncmp', varargin{:});
else
  [varargout{1:nargout}] = builtin('strncmp', varargin{:});
end
