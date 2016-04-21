function pmod=paramod(mod1,mod2)

%PARAMOD Put two models in parallel by connecting their outputs.
%        pmod=paramod(mod1,mod2)
% PARAMOD mimics the "parallel" function of the Control Systems
% toolbox for system descriptions in the MPC format.  The
% output of "pmod" will be the sum of the outputs of "mod1"
% and "mod2".  The different input types (manipulated
% variables, measured disturbances (if any) and unmeasured
% disturbances (if any) are grouped in "pmod" such that those
% for "mod1" precede those for "mod2".
%
% Inputs:
%  mod1  is a plant model in the MPC mod format.
%  mod2  is a plant model in the MPC mod format.
%
% Output:
%  pmod  is the composite model in the mod MPC format.
%
% See also ADDMOD, ADDMD, ADDUMD, APPMOD, SERMOD.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0
   disp('USAGE:  pmod=paramod(mod1,mod2)')
   return
elseif nargin ~= 2
   error('Incorrect # of input arguments')
elseif nargout ~= 1
   error('Incorrect # of output arguments')
end

[a1,b1,c1,d1,minfo1]=mod2ss(mod1);
[a2,b2,c2,d2,minfo2]=mod2ss(mod2);

nym=minfo1(6);
nyu=minfo1(7);
T=minfo1(1);
p=sum(minfo1(6:7));
mtot1=sum(minfo1(3:5));
mtot2=sum(minfo2(3:5));
[n1,n1]=size(a1);
[n2,n2]=size(a2);
nu1=minfo1(3);nu2=minfo2(3);
nd1=minfo1(4);nd2=minfo2(4);
nw1=minfo1(5);nw2=minfo2(5);

% Error checks

if minfo2(1) ~= T
   error('Models have different sampling periods')
elseif any(minfo1(6:7) ~= minfo2(6:7))
   error('Models have different # or types of outputs')
end

a=[  a1            zeros(n1,n2)
   zeros(n2,n1)         a2       ];
b=[   b1                zeros(n1,mtot2)
   zeros(n2,mtot1)            b2       ];
c=[c1 c2];
d=[d1 d2];

% The columns of the b and d matrices must be rearranged to
% get the input variables in the correct position.  Create
% a mapping vector for this purpose.

map=[1:nu1 mtot1+1:mtot1+nu2 nu1+1:nu1+nd1 mtot1+nu2+1:mtot1+nu2+nd2 ...
     nu1+nd1+1:mtot1 mtot1+nu2+nd2+1:mtot1+mtot2];

% Now move the columns

if ~isempty(b)
   b=b(:,map);
end
d=d(:,map);

minfo=minfo1+minfo2;
minfo(1)=T;
minfo(6)=nym;
minfo(7)=nyu;
pmod=ss2mod(a,b,c,d,minfo);
