%
%   [p,r12,r21,fail,gmin] = hinf_st(p,nmeas,ncon,gmin,gmax,quiet)
%
%   scale the d12 and d21 matrices to satisfy the formulas
%   and check the rank conditions.
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [p,r12,r21,fail,gmin] = hinf_st(p,nmeas,ncon,gmin,gmax,quiet)

fail = 0;
[ap,bp,cp,dp,b1,b2,c1,c2,d11,d12,d21,d22,ndata] = hinf_sp(p,nmeas,ncon);
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
   if irank ~= nc
   fprintf('\n')
   disp('  [a b2;c1 d12] does not have full column rank at s=0 ')
   fail = 1;
   return
 end
%
% determine if   |A-jwI  b1 | has full row rank at w=0
%                |  c2   d21|
%
tmp_row=[ap b1;c2 d21];
[nr,nc]=size(tmp_row);
irank = rank(tmp_row,eps);
   if irank ~= nr
   fprintf('\n')
   disp('  [a b1;c2 d21] does not have full row rank at s=0 ')
   fail = 1;
   return
 end
%
% test D11 sigma max condition
%
norm1 = norm((eye(np1)-(d12/(d12'*d12))*d12')*d11);
norm2 = norm(d11*(eye(nm1)-(d21'/(d21*d21'))*d21));

if gmin < max(norm1,norm2),
 	if quiet~=0		% printing desired
        	disp('Resetting value of Gamma min based on D_11, D_12, D_21 terms');
        	fprintf('\n')
 	end
        gmin = max(norm1,norm2);
        if gmax<=gmin
 		if quiet~=0		% printing desired
        	  disp('Resetting value of Gamma Max based on Gamma Min');
        	  fprintf('\n')
 		end
		gmax = gmin*1.01;
	end
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
%
%   r21*d21*q21 = [0 I]
%
[q21,r21] = qr(d21');
%
% determine if d21 has full column rank
%
 irank = rank(r21,eps);
 if irank ~= np2
   disp('  d21 does not have full row rank  ')
   fail = 1;
   return
 end
q21 = [q21(:,(np2+1):nm1),q21(:,1:np2)];
r21 = inv(r21(1:np2,:))';
c1 = q12*c1;
c2 = r21*c2;
cp = [c1;c2];
b1 = b1*q21;
b2 = b2*r12;
bp = [b1,b2];
d11 = q12*d11*q21;
d12 = q12*d12*r12;
d21 = r21*d21*q21;
d22 = d22;
dp = [d11 d12;d21 d22];
p = pck(ap,bp,cp,dp);
%
%  partition d11
%
d1111=d11(1:(np1-nm2),1:(nm1-np2));
d1112=d11(1:(np1-nm2),(nm1-np2+1):nm1);
d1121=d11((np1-nm2+1):np1,1:(nm1-np2));
d1122=d11((np1-nm2+1):np1,(nm1-np2+1):nm1);