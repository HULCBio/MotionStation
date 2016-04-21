function [varargout] = strcmp(varargin)
%STRCMP Compare strings.
%   STRCMP(S1,S2) returns 1 if strings S1 and S2 are the same
%   and 0 otherwise.  
%
%   STRCMP(S,T), when either S or T is a cell array of strings, returns
%   an array the same size as S and T containing 1 for those elements
%   of S and T that match, and 0 otherwise.  S and T must be the same
%   size (or one can be a scalar cell).  Either one can also be a
%   character array with the right number of rows.
%
%   STRCMP supports international character sets.
%
%   See also STRNCMP, STRCMPI, STRFIND, STRMATCH, DEBLANK, REGEXP.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.17.4.4 $  $Date: 2004/04/16 22:08:46 $
%   Built-in function.


if nargout == 0
  builtin('strcmp', varargin{:});
else
  [varargout{1:nargout}] = builtin('strcmp', varargin{:});
end
