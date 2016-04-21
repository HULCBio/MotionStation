%-------------------------------------------------------------------
%
%	[p,q12,r12,fail] = hinffi_t(p,ncon)
%
%	scale the d12 matrix to satisfy the formulas
%	and check the rank conditions for full info case.
%
%	written:	Gary Balas      July, 1990.
%
% full info case:
%
%       p  =  | ap  | b1   b2  |
%             | ---------------|
%             | c1  | d11  d12 |
%
% with assumed c2, d21 and d22 :
%             | [I] | [0]  [0] |
%             | [0] | [I]  [0] |
%
%------------------------------------------------------------------

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [p,q12,r12,fail] = hinffi_t(p,ncon)

fail = 0;
[ap,bp,cp,dp,b1,b2,c1,d11,d12,ndata] = hinffi_p(p,ncon);
np1 = ndata(1);
np2 = ndata(2);
nm1 = ndata(3);
nm2 = ndata(4);
%
% determine if   |A-jwI  b2 | has full column rank at w=0
%                |  c1   d12|
%
tmp_col=[ap b2;c1 d12];
[nr,nc]=size(tmp_col);
irank = rank(tmp_col,eps);
% irank = nc;
 if irank ~= nc
  fprintf('\n')
  disp('*  [a b2;c1 d12] does not have full column rank at s=0 ')
   fail = 1;
   return
 end
%
%  scale the matrices to    q12*d12*r12 = | 0 |
%                                         | I |
%
[q12,r12] = qr(d12);
%
% determine if d12 has full column rank
%
irank = rank(r12,eps);
 if irank ~= nm2
   disp('  d12 does not have full column rank  ')
   fail = 1;
   return
 end
q12 = [q12(:,(nm2+1):np1),q12(:,1:nm2)]';
r12 = inv(r12(1:nm2,:));

c1 = q12*c1;
cp = [c1];
b2 = b2*r12;
bp = [b1,b2];
d11 = q12*d11;
d12 = q12*d12*r12;
dp = [d11 d12];
p = pck(ap,bp,cp,dp);

%---------------------------------------------------------------
%
%