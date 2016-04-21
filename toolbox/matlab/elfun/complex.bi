function [varargout] = complex(varargin)
%   COMPLEX Construct complex result from real and imaginary parts.
%   C = COMPLEX(A,B) returns the complex result A + Bi, where A and B are
%   identically sized real N-D arrays, matrices, or scalars of the same data type.
%   Note: In the event that B is all zeros, C is complex with all zero imaginary
%   part, unlike the result of the addition A+0i, which returns a 
%   strictly real result.
%
%   C = COMPLEX(A) for real A returns the complex result C with real part A
%   and all zero imaginary part. Even though its imaginary part is all zero,
%   C is complex and so isreal(C) returns false.
%
%   Note that the expression A+i*B or A+j*B will give identical
%   results for nonzero B if A and B are double-precision and i or
%   j has not been assigned.  Use COMPLEX if ambiguity in the
%   variables "i" or "j" might arise, or if A and B are not
%   double-precision, or if B is all zero.
%
%   See also  I, J, IMAG, CONJ, ANGLE, ABS, REAL, ISREAL.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/16 22:05:54 $
%   Built-in function.

if nargout == 0
  builtin('complex', varargin{:});
else
  [varargout{1:nargout}] = builtin('complex', varargin{:});
end
