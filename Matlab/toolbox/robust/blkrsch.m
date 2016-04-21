function [v,t,m] = blkrsch(a,odtype,cut)
%BLKRSCH Block-ordered real Schur form.
%
% [V,T,M] = BLKRSCH(A,ODTYPE,CUT) produces a real block-ordered
%       decomposition of a square real matrix A
%
%               V'AV = T = |B1  B12|
%                          | 0   B2|
%
%               B1 = T(1:CUT,1:CUT)
%               B2 = T(CUT+1:END,CUT+1:END)
%                M = number of stable eigenvalues (s or z plane)
%
%     Six types of ordering can be selected:
%         odtype = 2 or 3 --- Re(eig(B1)) > Re(eig(B2)).
%         odtype = 1 or 4 --- Re(eig(B1)) < Re(eig(B2)).
%         odtype = 5 --- abs(eig(B1)) > abs(eig(B2)).
%         odtype = 6 --- abs(eig(B1)) < abs(eig(B2)).
%
%    If ODTYPE <3 & NARGIN<3, then CUT defaults to
%         odtype = 1 --->   CUT = M
%         odtype = 2 --->   CUT = size(A,1)-M


% R. Y. Chiang & M. G. Safonov 4/4/86
% REVISED by M. G. Safonov 10/9/96
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.



%

% ----- Ordered Complex Schur Decomposition :

%

[ra,ca] = size(a);
if odtype==1,
   cstype=4;
elseif odtype==2,
   cstype=3;
else
   cstype=odtype;
end


[qn,tn,m,swap] = cschur(a,cstype);

%

% ----- Find the Orthonomal basis :

%

if nargin<3,
   if odtype == 1

     cut = m;

   elseif odtype == 2

     cut = ra-m;
   else
     error('Too few input arguments')
   end
end

%

kk = -1;

if cut == ra,     v = eye(ra);     t = a;     kk = 1;  end

if cut == 0.,     v = eye(ra);     t = a;     kk = 1;  end

if kk < 0

     qord = [real(qn(:,1:cut)) imag(qn(:,1:cut))];

     [v,r] = qr(qord);

     t = v' * a * v;

end

%

% ----- End of BLKRSCH.M ---- RYC/MGS 4/4/86 (Rev. 10/9/96) %