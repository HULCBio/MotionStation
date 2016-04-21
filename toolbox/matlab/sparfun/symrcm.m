function p = symrcm(S)
%SYMRCM Symmetric reverse Cuthill-McKee permutation.
%   p = SYMRCM(S) returns a permutation vector p such that S(p,p)
%   tends to have its diagonal elements closer to the diagonal than S.
%   This is a good preordering for LU or Cholesky factorization of
%   matrices that come from "long, skinny" problems.  It works for
%   both symmetric and asymmetric S.
%
%   See also SYMMMD, COLMMD, COLPERM.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.8 $  $Date: 2002/04/15 04:12:02 $

p = sparsfun('symrcm',S|(S'));
