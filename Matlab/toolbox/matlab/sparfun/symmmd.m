function p = symmmd(S)
%SYMMMD Symmetric minimum degree permutation.
%
%   SYMMMD is obsolete. Use SYMAMD instead.
%
%   p = SYMMMD(S), for a symmetric positive definite matrix S,
%   returns the permutation vector p such that S(p,p) tends to have a
%   sparser Cholesky factor than S.  Sometimes SYMMMD works well
%   for symmetric indefinite matrices too.
%
%   See also COLAMD, COLPERM, SYMRCM.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.8.4.3 $  $Date: 2004/04/16 22:08:32 $

warning('MATLAB:symmmd:obsolete', ...
    ['SYMMMD is obsolete and will be removed in a future version.' ...
    ' Use SYMAMD instead.']);
p = sparsfun('symmmd',S);
[ignore,q] = sparsfun('symetree',S(p,p));
p = p(q);
