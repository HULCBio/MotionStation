function B = transpose(A)
%TRANSPOSE Symbolic matrix transpose.
%   TRANSPOSE(A) overloads symbolic A.' .
%
%   Example: 
%      [a b; 1-i c].' returns [a 1-i; b c].
%
%   See also CTRANPOSE.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/16 22:23:16 $

if ndims(A) > 2
   error('symbolic:sym:transpose:errmsg1','Transpose on ND array is not definied.')
elseif all(size(A) == 1)
   B = A;
else
   B = maple('transpose',A);
end
