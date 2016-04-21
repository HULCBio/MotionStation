function [varargout] = filter(varargin)
%FILTER One-dimensional digital filter.
%   Y = FILTER(B,A,X) filters the data in vector X with the
%   filter described by vectors A and B to create the filtered
%   data Y.  The filter is a "Direct Form II Transposed"
%   implementation of the standard difference equation:
%
%   a(1)*y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb+1)*x(n-nb)
%                         - a(2)*y(n-1) - ... - a(na+1)*y(n-na)
%
%   If a(1) is not equal to 1, FILTER normalizes the filter
%   coefficients by a(1). 
%
%   FILTER always operates along the first non-singleton dimension,
%   namely dimension 1 for column vectors and non-trivial matrices,
%   and dimension 2 for row vectors.
%
%   [Y,Zf] = FILTER(B,A,X,Zi) gives access to initial and final
%   conditions, Zi and Zf, of the delays.  Zi is a vector of length
%   MAX(LENGTH(A),LENGTH(B))-1, or an array with the leading dimension 
%   of size MAX(LENGTH(A),LENGTH(B))-1 and with remaining dimensions 
%   matching those of X.
%
%   FILTER(B,A,X,[],DIM) or FILTER(B,A,X,Zi,DIM) operates along the
%   dimension DIM.
%
%   See also FILTER2 and, in the Signal Processing Toolbox, FILTFILT.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.18.4.2 $  $Date: 2004/04/16 22:04:45 $

%   Built-in function.

if nargout == 0
  builtin('filter', varargin{:});
else
  [varargout{1:nargout}] = builtin('filter', varargin{:});
end
