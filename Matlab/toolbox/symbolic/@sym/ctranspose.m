function B = ctranspose(A)
%TRANSPOSE Symbolic matrix complex conjugate transpose.
%   CTRANSPOSE(A) overloads symbolic A' .
%
%   Example: 
%      [a b; 1-i c]' returns  [ conj(a),     1+i]
%                             [ conj(b), conj(c)].
%
%   See also TRANPOSE.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $  $Date: 2004/04/16 22:22:13 $

if ndims(A) > 2
   error('symbolic:sym:ctranspose:errmsg1','Transpose on ND array is not defined.')
elseif all(size(A) == 1)
   B = maple('conjugate',A);
else
   B = maple('htranspose',A);
end
