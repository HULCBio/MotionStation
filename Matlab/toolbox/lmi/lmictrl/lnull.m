%  Nl = lnull(M,tolabs,tolrel)
%
%  Computes the left null space of a matrix M based on its SVD.
%
%  A singular value S(i) is regarded as ``zero'' when it falls
%  below the absolute tolerance TOLABS or the relative tolerance
%  TOLREL.  That is,
%        S (i)  <  TOLABS    or    S (i)  <  TOLREL * S (1)
%  where S(1) is the largest singular value.
%
%  TOLABS (TOLREL) should be set to zero to deactivate the
%  corresponding thresholding.

%  Author: P. Gahinet  6/94
%  Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function  Nl=lnull(M,tolabs,tolrel)

if isempty(M), Nl=[]; return, end

[u,s,v]=svd(M);
s=xdiag(s);

rk=length(find(s > tolabs & s > tolrel*s(1,1)));

Nl=u(:,rk+1:size(M,1));
