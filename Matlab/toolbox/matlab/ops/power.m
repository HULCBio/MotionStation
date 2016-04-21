function [varargout] = power(varargin)
%.^  Array power.
%   Z = X.^Y denotes element-by-element powers.  X and Y
%   must have the same dimensions unless one is a scalar. 
%   A scalar can operate into anything.
%
%   C = POWER(A,B) is called for the syntax 'A .^ B' when A or B is an
%   object.
%
%   See also MPOWER, NTHROOT.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.3 $  $Date: 2004/04/16 22:08:01 $

if nargout == 0
  builtin('power', varargin{:});
else
  [varargout{1:nargout}] = builtin('power', varargin{:});
end
