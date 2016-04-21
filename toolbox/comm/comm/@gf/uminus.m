function z = uminus(x);
%UMINUS  Unary minus - of GF array.
%   -A negates the elements of A.  Note that since in GF(2^M),
%   each field element is its own additive inverse, -A is equal
%   to A. Therefore this operation does nothing and is provided
%   only for completeness.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.3 $  $Date: 2002/03/27 00:16:48 $ 

z=x;  % in GF(2^m), since addition is over GF(2^m) 
   % each field element is its own inverse