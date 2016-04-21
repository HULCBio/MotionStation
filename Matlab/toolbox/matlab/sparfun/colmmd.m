function p = colmmd(S)
%COLMMD Column minimum degree permutation.
%
%   COLMMD is obsolete. Use COLAMD instead.
%
%   P = COLMMD(S) returns the column minimum degree permutation vector
%   for the sparse matrix S. For a non-symmetric matrix S, S(:,P)
%   tends to have sparser LU factors than S.
%
%   See also COLAMD, SYMAMD, SYMRCM, COLPERM.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.11.4.2 $  $Date: 2004/04/16 22:08:20 $

warning('MATLAB:colmmd:obsolete', ...
    ['COLMMD is obsolete and will be removed in a future version.' ...
    ' Use COLAMD instead.']);
p = sparsfun('colmmd',S);
[ignore,q] = sparsfun('coletree',S(:,p));
p = p(q);
