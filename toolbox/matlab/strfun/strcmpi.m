function [varargout] = strcmpi(varargin)
%STRCMPI Compare strings ignoring case.
%   STRCMPI(S1,S2) returns 1 if strings S1 and S2 are the same except for
%   case and 0 otherwise.  
%
%   STRCMPI(S,T), when either S or T is a cell array of strings, returns an
%   array the same size as S and T containing 1 for those elements of S
%   and T that match except for case, and 0 otherwise.  S and T must be
%   the same size (or one can be a scalar cell).  Either one can also be a
%   character array with the right number of rows.
%
%   STRCMPI supports international character sets.
%
%   See also STRCMP, STRNCMPI, FINDSTR, STRMATCH, REGEXPI.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.3 $  $Date: 2004/04/16 22:08:47 $
%   Built-in function.


if nargout == 0
  builtin('strcmpi', varargin{:});
else
  [varargout{1:nargout}] = builtin('strcmpi', varargin{:});
end
