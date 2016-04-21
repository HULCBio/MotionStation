% [u,s,v,rk,using,vsing]=svdparts(M,tolabs,tolrel)
%
% Computes the rank, left and right null spaces, and nonzero
% singular values of the matrix M.
%
% A singular value S(i) is regarded as ``zero'' when it falls
% below the absolute tolerance TOLABS or the relative tolerance
% TOLREL. That is,
%       S (i)  <  TOLABS    or    S (i)  <  TOLREL * S (1)
% where S(1) is the largest singular value. TOLABS (TOLREL)
% should be set to zero to desactivate the corresponding
% thresholding.
%
% Output:
%   S            vector containing all ``nonzero'' singular values.
%   U, V         singular vectors associated with the nonzero
%                singular values:
%                              M = U diag(S) V'
%   RK           rank of M up to the tolerances TOLABS, TOLREL
%   USING,VSING  bases of the left and right null spaces of M
%
% See also  SVD.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [u,s,v,rk,using,vsing]=svdparts(M,tolabs,tolrel)

if isempty(M), u=[]; v=[]; s=[]; rk=0; using=[]; vsing=[]; return, end

[r,c]=size(M);
[u,s,v]=svd(M); s=xdiag(s);

rk=length(find(s > tolabs & s > tolrel*s(1,1)));
s=s(1:rk);

using=u(:,rk+1:r); u=u(:,1:rk);
vsing=v(:,rk+1:c); v=v(:,1:rk);
