%  function delta=gap(sys1,sys2,ttol)
%
%  Computes the gap metric between two systems SYS1 and SYS2.
%
%  TTOL gives the tolerance to which the gap is calculated:
%  DELTA-TTOL < GAP =< DELTA.
%  The default for TTOL is 0.001.
%
%  See also NUGAP, NCFSYN, SNCFBAL, RIC_SCHR

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function delta = gap(sys1,sys2,ttol)

if ( nargin < 2  | nargin > 3 ),
  disp('usage: delta=gap(sys1,sys2)')
  return
end
delta = [];
if nargin == 2
  ttol = 1e-3;
end
epr = 1e-8;
hanktol = 1e-8;

[type1,p,m,dim1] = minfo(sys1);
[type2,p2,m2,dim2] = minfo(sys2);
 if ( m ~= m2 | p ~= p2 ),
   disp('SYS1 and SYS2 ought to have the same # of inputs and outputs')
   return
 end
pm = p+m;

% Compute the normalized rcf's, i.e. the graph symbols for SYS1 and SYS2.
if (strcmp(type1,'syst')),
  [sysnlcf1,sig1,grph1]=sncfbal(sys1,hanktol);
elseif (strcmp(type1,'cons')),
  grph1=[ sys1; eye(m) ]*inv( sqrtm(eye(m)+sys1'*sys1));
else
  disp('SYS1 ought to be a SYSTEM matrix')
  return
end
%
if (strcmp(type2,'syst')),
  [sysnlcf2,sig2,grph2]=sncfbal(sys2,hanktol);
elseif (strcmp(type2,'cons')),
  grph2=[sys2 ; eye(m) ]*inv(sqrtm(eye(m)+sys2'*sys2));
else
  disp('SYS2 ought to be a SYSTEM matrix')
  return
end

% Form the pieces of a Hamiltonian matrix to be used in the tests below.
P = sbs(grph2,grph1);
[aP,bP,cP,dP] = unpck(P);
[sizeaPc,sizeaPr] = size(aP);
A=[aP zeros(sizeaPc); -cP'*cP -aP'];
B=[bP;-cP'*dP]; Br=[dP'*cP bP'];
DD=dP'*dP;
eye12=[zeros(m) zeros(m); zeros(m) eye(m)];
eye21=[eye(m) zeros(m); zeros(m) zeros(m)];

% Check if, after the reduction in sncfbal, both systems are constant.
 [mattype,rowd,cold,num] = minfo(P);
 if strcmp(mattype,'cons')
   delta=sqrt(1-(min(svd(DD(1:m,m+1:2*m))))^2);
   return
 end

% Compare the values of the two directed gaps to 1-ttol.
d = 1-ttol;
dsquare = d*d;
%
H = A-B*inv(DD-dsquare*eye12)*Br;
[x1,x2,fail1] = ric_schr(H,epr);
if  min(real(eig(x2/x1)))<-epr
  fail1 = fail1+1;
end
%
H = A-B*inv(DD-dsquare*eye21)*Br;
[x1,x2,fail2] = ric_schr(H,epr);
if min(real(eig(x2/x1)))<-epr
  fail2 = fail2+1;
end
%
if ( fail1 + fail2 ~= 0),
  delta = 1;
  return
end
dmax = 1-ttol;

% Compute a lower bound for the gap.
dmin = sqrt(1-(min(svd(DD(1:m,m+1:2*m))))^2);

% Use bisection.
r = dmax-dmin;
n = ceil(log(r/ttol)/log(2));
for k=1:n,
  d = dmin;
  dmax = d+r;
  r = r/2;
  d = d+r;
  H = A-B*inv(DD-d*d*eye12)*Br;
  [x1,x2,fail] = ric_schr(H,epr);
  if fail~=0
    dmin = d;
  elseif min(real(eig(x2/x1)))<-epr
    dmin = d;
  end
end
delta = dmin+r;