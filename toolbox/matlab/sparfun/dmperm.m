function [p,q,r,s] = dmperm(A)
%DMPERM Dulmage-Mendelsohn permutation.
%   p = DMPERM(A) returns a row permutation p so that if A has full
%   column rank, A(p,:) is square with nonzero diagonal.  This is also
%   called a maximum matching.
%
%   [p,q,r,s] = DMPERM(A) finds a row permutation p and column
%   permutation q so that A(p,q) is in block upper triangular form.
%   The outputs r and s are integer vectors describing the boundaries
%   of the blocks:
%
%     the kth block of A(p,q) has indices (r(k):r(k+1)-1,s(k):s(k+1)-1).  
%
%   When A is square, r==s.
%
%   In graph theoretic terms, the diagonal blocks correspond to strong
%   Hall components of the adjacency graph of A.
%
%   See also SPRANK.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9 $  $Date: 2002/04/15 04:12:30 $

if nargout <= 1,
    p = sparsfun('dmperm',A);
elseif nargout == 2,
    [p,q] = sparsfun('dmperm',A);
elseif nargout == 3,
    [p,q,r] = sparsfun('dmperm',A);
else
    [p,q,r,s] = sparsfun('dmperm',A);
end;
