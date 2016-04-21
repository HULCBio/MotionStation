function [varargout] = mpower(varargin)
%^   Matrix power.
%   Z = X^y is X to the y power if y is a scalar and X is square. If y
%   is an integer greater than one, the power is computed by repeated
%   squaring. For other values of y the calculation involves
%   eigenvalues and eigenvectors.
%
%   Z = x^Y is x to the Y power if Y is a square matrix and x is a scalar.
%   Computed using eigenvalues and eigenvectors.
%
%   Z = X^Y, where both X and Y are matrices, is an error.
%
%   C = MPOWER(A,B) is called for the syntax 'A ^ B' when A or B is an
%   object.
%
%   See also POWER.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/16 22:07:54 $

if nargout == 0
  builtin('mpower', varargin{:});
else
  [varargout{1:nargout}] = builtin('mpower', varargin{:});
end
