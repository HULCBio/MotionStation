function pmod=sermod(mod1,mod2)
%SERMOD	Put two models in series.
%    	pmod=sermod(mod1,mod2)
% SERMOD mimics the "series" function of the Control Systems
% Toolbox for models in the MPC mod format.  "mod" is a combined
% model in which the MEASURED outputs of "mod1" are the manipulated
% variable inputs to "mod2".  The disturbance inputs to "mod1" and
% "mod2" are retained as disturbance inputs to "mod".
%
% Inputs:
%  mod1  is a plant model in the MPC mod format.
%  mod2  is a plant model in the MPC mod format.
%
% Output:
%  pmod  is the composite model in the MPC mod format.
%
% See also ADDMOD, ADDMD, ADDUMD, APPMOD, PARAMOD.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0
   disp('USAGE:  pmod=sermod(mod1,mod2)')
   return
elseif nargin ~= 2
   error('Incorrect # of input arguments')
elseif nargout ~= 1
   error('Incorrect # of output arguments')
end

[a1,b1,c1,d1,minfo1]=mod2ss(mod1);
[a2,b2,c2,d2,minfo2]=mod2ss(mod2);

[n1,n1]=size(a1);
[n2,n2]=size(a2);
nu1=minfo1(3);
nu2=minfo2(3);
nd1=minfo1(4);
nd2=minfo2(4);
nw1=minfo1(5);
nw2=minfo2(5);
nym=minfo2(6);
nyu=minfo2(7);

ndist2=nd2+nw2;
mtot1=sum(minfo1(3:5));
mtot2=sum(minfo2(3:5));
p=sum(minfo2(6:7));
dt=minfo1(1);

if minfo2(1) ~= dt
   error('Models have different sampling periods')
elseif minfo1(6) ~= nu2
   error('# measured outputs of mod1 not = # manipulated inputs of mod2')
elseif minfo1(7) ~= 0
   error('Mod1 may not have unmeasured outputs')
end

[nr,nc]=size(d2);
d2u=zeros(nr,nu2);
d2d=zeros(nr,ndist2);

[nr,nc]=size(b2);
b2u=zeros(nr,nu2);
b2d=zeros(nr,ndist2);

if isempty(b2)
   b2u=[];
   b2d=[];
else
   b2u=b2(:,1:nu2);
   if ndist2 > 0
      b2d=b2(:,nu2+1:nu2+ndist2);
   else
      b2d=[];
   end
end

if isempty(d2)
   d2u=[];
   d2d=[];
else
d2u=d2(:,1:nu2);
   if ndist2 > 0
      d2d=d2(:,nu2+1:nu2+ndist2);
   else
      d2d=[];
   end
end

a=[  a1       zeros(n1,n2)
    b2u*c1         a2       ];
b=[   b1    zeros(n1,ndist2)
    b2u*d1      b2d       ];
c=[d2u*c1   c2];
d=[d2u*d1  d2d];

% The columns of the b and d matrices must be rearranged to
% get the input variables in the correct position.  Create
% a mapping vector for this purpose.

map=[1:nu1+nd1 mtot1+1:mtot1+nd2 nu1+nd1+1:mtot1 mtot1+nd2+1:mtot1+ndist2];

% Now move the columns

if ~isempty(b)
   b=b(:,map);
end
if ~isempty(d)
   d=d(:,map);
end

minfo(1,1:7)=[dt n1+n2 nu1 nd1+nd2 nw1+nw2 nym nyu];
pmod=ss2mod(a,b,c,d,minfo);