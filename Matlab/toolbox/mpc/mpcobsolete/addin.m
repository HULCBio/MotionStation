function pmod=addin(mod1,mod2)

% The outputs of "mod2" are added to the manipulated inputs of "mod1"
% to form the composite model "pmod".  Thus, all inputs
% of "mod1" and "mod2" are retained in the composite model, but
%  its only outputs will be those of "mod1".
% The number of outputs of "mod2" must equal the number of manipulated
% variables of "mod1".  "mod1" and "mod2" must have been created using
% the same sampling period.
%
% --------usage------------------
%
%        pmod=addin(mod1,mod2)
%
% --------input arguments---------
%
%  mod1  is a plant model in the MPC mod format.
%  mod2  is a plant model in the MPC mod format.
%
% --------output arguments--------
%
%  pmod  is the composite model in the MPC mod format.

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

% Written by:  N. L. Ricker, U. of Washington

if nargin == 0
   disp('USAGE:  pmod=addin(mod1,mod2)')
   return
elseif nargin ~= 2
   error('Incorrect number of input arguments')
elseif nargout ~= 1
   error('Incorrect number of output arguments')
end

[a1,b1,c1,d1,minfo1]=mod2ss(mod1);
[a2,b2,c2,d2,minfo2]=mod2ss(mod2);

T1=minfo1(1);   T2=minfo2(1);
n1=minfo1(2);   n2=minfo2(2);
nu1=minfo1(3);  nu2=minfo2(3);
nd1=minfo1(4);  nd2=minfo2(4);
nw1=minfo1(5);  nw2=minfo2(5);
nym1=minfo1(6); nym2=minfo2(6);
nyu1=minfo1(7); nyu2=minfo2(7);
ny1=nym1+nyu1;  ny2=nym2+nyu2;

% +++ Error checking +++

if T1 ~= T2
   error('MOD1 and MOD2 have different sampling periods')
elseif nu1 ~= ny2
   error('# outputs of MOD2 not = # manipulated variables of MOD1')
elseif nu1 < 1 | nu2 < 1
   error('MOD1 and/or MOD2 has no manipulated variables.')
elseif ny1 < 0
   error('MOD1 must have at least one output.')
end

% +++ Define some indices to pick out desired parts of matrices +++

iu1=[1:nu1];                 % columns for u1 in b1 and d1
id1=[nu1+1:nu1+nd1];         % columns for d1
iw1=[nu1+nd1+1:nu1+nd1+nw1]; % columns for w1
iu2=[1:nu2];                 % columns for u2 in b2 and d2
id2=[nu2+1:nu2+nd2];         % columns for d2
iw2=[nu2+nd2+1:nu2+nd2+nw2]; % columns for w2

% +++ Now form the matrices for the composite system

if n1 > 0
   a=a1;
   if n2 > 0
      a=[a b1(:,iu1)*c2];
   end
   b=[b1(:,iu1) b1(:,iu1)*d2(:,iu2) ];
else
   a=zeros(n1,n1);
   b=zeros(n1,nu1);
end
if n2 > 0
   a=[ a; [zeros(n2,n1)   a2] ];
   b=[ b; [zeros(n2,nu1) b2(:,iu2)] ];
   c=[ c1   d1(:,iu1)*c2];
else
   c=c1;
end

d=[ d1(:,iu1)   d1(:,iu1)*d2(:,iu2) ];

if nd1 > 0
   if n1 > 0
      badd=[b1(:,id1); zeros(n2,nd1)];
   else
      badd= zeros(n2,nd1);
   end
   b=[b, badd ];
   d=[d,  d1(:,id1) ];
end
if nd2 > 0
   if n1 > 0
      badd=[b1(:,iu1)*d2(:,id2)];
   else
      badd=[];
   end
   if n2 > 0
      badd=[badd; b2(:,id2)];
   end
   b=[b, badd ];
   d=[d,  d1(:,iu1)*d2(:,id2) ];
end
if nw1 > 0
   if n1 > 0
      badd=[b1(:,iw1); zeros(n2,nw1)];
   else
      badd=zeros(n2,nw1);
   end
   b=[b,  badd];
   d=[d,  d1(:,iw1)];
end
if nw2 > 0
   if n1 > 0
      badd=[b1(:,iu1)*d2(:,iw2)];
   else
      badd=[];
   end
   if n2 > 0
      badd=[badd; b2(:,iw2)];
   end
   b=[b, badd ];
   d=[d,  d1(:,iu1)*d2(:,iw2) ];
end

% +++ Save the resulting matrices in the MOD format

pmod=ss2mod(a,b,c,d,[T1, n1+n2, nu1+nu2, nd1+nd2, nw1+nw2, nym1, nyu1]);

% +++ END OF FUNCTION ADDIN +++