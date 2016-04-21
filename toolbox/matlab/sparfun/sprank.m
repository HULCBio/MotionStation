function r = sprank(A)
%SPRANK Structural rank.
%   r = SPRANK(A) is the structural rank of the sparse matrix A.
%   Also known as maximum traversal, maximum assignment, and
%   size of a maximum matching in the bipartite graph of A.
%   Always sprank(A) >= rank(A), and in exact arithmetic
%   sprank(A) == rank(sprandn(A)) with probability one.
%
%   See also DMPERM.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10 $  $Date: 2002/04/15 04:11:56 $

r = sum(dmperm(A)>0);
