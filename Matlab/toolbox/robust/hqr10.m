function [qn,tn,m,swap] = hqr10(a)
%HQR10 Ordered complex Schur decomposition.
%
% [QN,TN,M,SWAP] = HQR10(A) produces an ordered Complex Schur decom-
%          position such that the stable part is on the top of the
%          the diagonal of Tn, and the unstable part at the bottom,
%     where
%             Tn = Qn' * A * Qn
%              m = no. of stable poles.
%           swap = total no. of swaps.
%
%         The complex Givens rotation is used to swap the two adjacent
%    diagonal terms.
%

% R. Y. Chiang & M. G. Safonov 9/11/87
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.
%----------------------------------------------------------------------
%
[ma,na] = size(a);
%
% -------- Regular Schur Decomposition :
%
[q,t] = schur(a);
%
[mt,nt] = size(t);
dt = diag(t);
%
% -------- Find the no. of stable roots :
%
idm = find(real(dt) < zeros(mt,1));
[m,dum] = size(idm);
if (m==0) | (m==mt), qn = eye(mt); tn = t; swap = 0; return, end
%
% -------- Assign I.C. for the loop counter :
%
pcnt = 0.; kcnt = 0.; gcnt = 0.;
%
% -------- Begin major loop :
%
for p = 1 : (nt-m)*m
    pcnt = pcnt + 1;
    for k = 1 : (nt-1)
        kcnt = kcnt + 1;
        tkk = t(k,k); tkp1 = t(k+1,k+1);
        if (tkk>0.) & (tkp1<0.)
           gcnt = gcnt + 1;
           jb = eye(nt);
           jb(k:k+1,k:k+1) = givens(t(k,k+1),t(k,k)-t(k+1,k+1));
           t = jb' * t * jb;
           q = q*jb;
        end
    end
    dt = diag(t); ndt = dt(1:m,1);
    flag = find(real(ndt)<zeros(m,1)); [fm,dum] = size(flag);
    if fm == m & sum(size(q)) ~= 0
       qn = q; tn = t; swap = gcnt; break
    end
    if sum(size(q)) == 0 | sum(size(t)) == 0
       error('WARNING: the problem is ill-conditioned, no convergence!')
    end
end
%
% -------- End of HQR10.M ---- RYC/MGS %