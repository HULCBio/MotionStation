function [pmod,in1,in2,out1,out2]=appmod(mod1,mod2)

% APPMOD Append two models together to form an aggregate model.
%        pmod=appmod(mod1,mod2)
%   OR   [pmod,in1,in2,out1,out2]=appmod(mod1,mod2)
% Models "mod1" and "mod2" are appended to form a composite,
% "pmod".  All models are in the MOD format.  Inputs and
% outputs are grouped by type, with those from mod1 of a given
% type preceding those from mod2 of the same type.
%
% Inputs:
%  mod1  first model in the MPC mod format.
%  mod2   second model in the MPC mod format.
%
% Outputs:
%  pmod is the composite of mod1 and mod2 in the MPC mod format.
%  in1,in2,out1,out2 are optional index vectors that point to the
%       new locations of the original inputs and outputs in pmod.
%       For example, in1(i) is the "pmod" input number of
%       input i from mod1, and out2(j) is the pmod output number
%       of output j from mod2, etc.
%
% See also ADDMOD, ADDMD, ADDUMD, PARAMOD, SERMOD.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

%       Revised 12/95 to add optional outputs.

if nargin ~= 2
   disp('USAGE:  pmod=appmod(mod1,mod2)')
   return
end

[a1,b1,c1,d1,minfo1]=mod2ss(mod1);
[a2,b2,c2,d2,minfo2]=mod2ss(mod2);

T1=minfo1(1);     T2=minfo2(1);
n1=minfo1(2);     n2=minfo2(2);
nu1=minfo1(3);    nu2=minfo2(3);
nd1=minfo1(4);    nd2=minfo2(4);
nw1=minfo1(5);    nw2=minfo2(5);
nym1=minfo1(6);   nym2=minfo2(6);
nyu1=minfo1(7);   nyu2=minfo2(7);
ny1=nym1+nyu1;    ny2=nym2+nyu2;
nin1=nu1+nd1+nw1; nin2=nu2+nd2+nw2;

% +++ Error checking +++

if T1 ~= T2
   error('MOD1 and MOD2 have different sampling periods')
elseif nin1 < 1 | ny1 < 1
   error('MOD1 must have at least 1 input and 1 output')
elseif nin2 < 1 | ny2 < 1
   error('MOD2 must have at least 1 input and 1 output')
end

% +++ Define some indices to pick out desired parts of matrices +++

iu1=[1:nu1];                 % columns for u1 in b1 and d1
id1=[nu1+1:nu1+nd1];         % columns for d1
iw1=[nu1+nd1+1:nu1+nd1+nw1]; % columns for w1
iym1=[1:nym1];               % rows for measured outputs of mod1
iyu1=[nym1+1:nym1+nyu1];     % rows for unmeasured outputs of mod1
iu2=[1:nu2];                 % columns for u2 in b2 and d2
id2=[nu2+1:nu2+nd2];         % columns for d2
iw2=[nu2+nd2+1:nu2+nd2+nw2]; % columns for w2
iym2=[1:nym2];               % rows for measured outputs of mod2
iyu2=[nym2+1:nym2+nyu2];     % rows for unmeasured outputs of mod2

% +++ Now form the matrices for the composite system

a=zeros(n1+n2,n1+n2);
b=zeros(n1+n2,nin1+nin2);
c=zeros(ny1+ny2,n1+n2);
d=zeros(ny1+ny2,nin1+nin2);

if n1 > 0
   rows=[1:n1];
   a(rows,rows)=a1;
   if nu1 > 0
      b(rows,1:nu1)=b1(:,iu1);
   end
   if nd1 > 0
      b(rows,nu1+nu2+1:nu1+nu2+nd1)=b1(:,id1);
   end
   if nw1 > 0
      b(rows,nu1+nu2+nd1+nd2+1:nu1+nu2+nd1+nd2+nw1)=b1(:,iw1);
   end
   if nym1 > 0
      c(1:nym1,rows)=c1(iym1,:);
   end
   if nyu1 > 0
      c(nym1+nym2+1:nym1+nym2+nyu1,rows)=c1(iyu1,:);
   end
end

if n2 > 0
   rows=[n1+1:n1+n2];
   a(rows,rows)=a2;
   if nu2 > 0
      b(rows,nu1+1:nu1+nu2)=b2(:,iu2);
   end
   if nd2 > 0
      b(rows,nu1+nu2+nd1+1:nu1+nu2+nd1+nd2)=b2(:,id2);
   end
   if nw2 > 0
      b(rows,nu1+nu2+nd1+nd2+nw1+1:nu1+nu2+nd1+nd2+nw1+nw2)=b2(:,iw2);
   end
   if nym2 > 0
      c(nym1+1:nym1+nym2,rows)=c2(iym2,:);
   end
   if nyu2 > 0
      c(nym1+nym2+nyu1+1:nym1+nym2+nyu1+nyu2,rows)=c2(iyu2,:);
   end
end

if nym1 > 0
   rows=[1:nym1];
   if nu1 > 0
      d(rows,1:nu1)=d1(iym1,iu1);
   end
   if nd1 > 0
      d(rows,nu1+nu2+1:nu1+nu2+nd1)=d1(iym1,id1);
   end
   if nw1 > 0
      d(rows,nu1+nu2+nd1+nd2+1:nu1+nu2+nd1+nd2+nw1)=d1(iym1,iw1);
   end
end

if nym2 > 0
   rows=[nym1+1:nym1+nym2];
   if nu2 > 0
      d(rows,nu1+1:nu1+nu2)=d2(iym2,iu2);
   end
   if nd2 > 0
      d(rows,nu1+nu2+nd1+1:nu1+nu2+nd1+nd2)=d2(iym2,id2);
   end
   if nw2 > 0
      d(rows,nu1+nu2+nd1+nd2+nw1+1:nu1+nu2+nd1+nd2+nw1+nw2)=d2(iym2,iw2);
   end
end

if nyu1 > 0
   rows=[nym1+nym2+1:nym1+nym2+nyu1];
   if nu1 > 0
      d(rows,1:nu1)=d1(iyu1,iu1);
   end
   if nd1 > 0
      d(rows,nu1+nu2+1:nu1+nu2+nd1)=d1(iyu1,id1);
   end
   if nw1 > 0
      d(rows,nu1+nu2+nd1+nd2+1:nu1+nu2+nd1+nd2+nw1)=d1(iyu1,iw1);
   end
end

if nyu2 > 0
   rows=[nym1+nym2+nyu1+1:nym1+nym2+nyu1+nyu2];
   if nu2 > 0
      d(rows,nu1+1:nu1+nu2)=d2(iyu2,iu2);
   end
   if nd2 > 0
      d(rows,nu1+nu2+nd1+1:nu1+nu2+nd1+nd2)=d2(iyu2,id2);
   end
   if nw2 > 0
      d(rows,nu1+nu2+nd1+nd2+nw1+1:nu1+nu2+nd1+nd2+nw1+nw2)=d2(iyu2,iw2);
   end
end


% +++ Save the resulting matrices in the MOD format

minfo=minfo1+minfo2;
minfo(1)=T1;
pmod=ss2mod(a,b,c,d,minfo);

% Optional output arguments

if nargout > 1
   in1=[ [1:nu1], [1:nd1]+nu1+nu2, [1:nw1]+nu1+nu2+nd1+nd2 ];
   in2=[ [1:nu2]+nu1, [1:nd2]+nu1+nu2+nd1, [1:nw2]+nin1+nu2+nd2 ];
   out1=[ [1:nym1], [1:nyu1]+nym1+nym2 ];
   out2=[ [1:nym2]+nym1, [1:nyu2]+ny1+nym2 ];
end

% +++ END OF FUNCTION APPMOD +++
