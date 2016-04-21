function [varargout] = mrdivide(varargin)
%/   Slash or right matrix divide.
%   A/B is the matrix division of B into A, which is roughly the
%   same as A*INV(B) , except it is computed in a different way.
%   More precisely, A/B = (B'\A')'. See MLDIVIDE for details.
%
%   C = MRDIVIDE(A,B) is called for the syntax 'A / B' when A or B is an
%   object.
%
%   See also MLDIVIDE, RDIVIDE, LDIVIDE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/16 22:07:55 $

if nargout == 0
  builtin('mrdivide', varargin{:});
else
  [varargout{1:nargout}] = builtin('mrdivide', varargin{:});
end
