function pmod=paramod1(mod1,iy1,mod2,iy2)

%PARAMOD1 Connect SPECIFIED outputs of two systems, MOD format.
%
%         pmod=paramod1(mod1,iy1,mod2,iy2)
%
%As for PARAMOD, but allows you to connect specified outputs
%of the two subsystems, rather than connecting all outputs.
%The different input types -- manipulated variables, measured
%disturbances, and unmeasured disturbances (if any) -- are
%grouped in "pmod" such that those for "mod1" precede those
%for "mod2".  Connected outputs must be of the same type (i.e.,
%measured or unmeasured).  All unconnected outputs from the two
%subsystems will be grouped as in APPMOD, i.e., measured outputs
%from "mod1", followed by measured outputs from "mod2",
%unmeasured outputs from "mod1", unmeasured outputs from "mod2".
%Connected outputs are ordered as they were in mod1.
%
% Inputs:
%  mod1  is a plant model in the MPC mod format.
%  iy1   is a list of outputs in mod1 to be connected to mod2.
%  mod2  is a plant model in the MPC mod format.
%  iy2   is a list of outputs in mod2 to be connected to mod1.
%
% Output:
%  pmod  is the composite model in the MPC mod format.
%
% See also PARAMOD, ADDMOD, ADDMD, ADDUMD, APPMOD, SERMOD, SERMOD1.
%
%Example:  mod1 contains 3 measured outputs and 2 unmeasured outputs.
%          mod2 contains 2 measured outputs and 2 unmeasured outputs.
% Then  pmod=paramod1(mod1,[2,4],mod2,[1,3])  connects 2 outputs
% in each subsystem, giving a composite model in which
% y1 is measured output 1 from mod1
% y2 is the connection of meas. outputs 2 from mod1 and 1 from mod2
% y3 is measured output 3 from mod1
% y4 is measured output 2 from mod2
% y5 is the connection of unmeas. outputs 4 from mod1 and 3 from mod2
% y6 is unmeasured output 5 from mod1
% y7 is unmeasured output 4 from mod2

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0
   disp('USAGE:  pmod=paramod1(mod1,iy1,mod2,iy2)')
   return
elseif nargin ~= 4
   error('Incorrect # of input arguments')
elseif nargout ~= 1
   error('Incorrect # of output arguments')
end

[a1,b1,c1,d1,minfo1]=mod2ss(mod1);
[a2,b2,c2,d2,minfo2]=mod2ss(mod2);

nym1=minfo1(6);
nyu1=minfo1(7);
nym2=minfo2(6);
nyu2=minfo2(7);
T=minfo1(1);
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
elseif length(iy1) ~= length(iy2)
   error('IY1 and IY2 must list the same number of outputs')
elseif isempty(iy1)
   error('IY1 and IY2 must be specified (non-empty)')
elseif any(iy1 < 1 | iy1 > nym1+nyu1)
   error('An element of IY1 is < 1 or > number of outputs in mod1')
elseif any(iy2 < 1 | iy2 > nym2+nyu2)
   error('An element of IY2 is < 1 or > number of outputs in mod2')
elseif any(diff(sort(iy1)) == 0)
   error('IY1 contains duplicate elements')
elseif any(diff(sort(iy2)) == 0)
   error('IY2 contains duplicate elements')
end

% Count the number of measured and unmeasured outputs to be connected

nymc=0;
nyuc=0;

for i=1:length(iy1)
   if iy1(i) <= nym1
      nymc=nymc+1;
      if iy2(i) > nym2
         error('Trying to connect a measured output to an unmeasured output')
      end
   else
      nyuc=nyuc+1;
      if iy2(i) <= nym2
         error('Trying to connect a measured output to an unmeasured output')
      end
   end
end

% We need to build up the C and D matrices according to the output ordering
% and connections.  First compute the number of outputs in the composite system,
% and initialize C and D to zero.

nym2uc=nym2-nymc;					% # of unconnected, meas. outputs in mod2
nyu2uc=nyu2-nyuc;					% # of unconnected, unmeas. outputs in mod2
ny=nym1+nyu1+nym2uc+nyu2uc;			% total outputs
c=zeros(ny,n1+n2);					% initialized C = 0
d=zeros(ny,mtot1+mtot2);			% initialized D = 0

% Map the outputs from mod1 to their correct locations in the new C and D.

i1=[1:nym1,[1:nyu1]+nym1+nym2uc];
c(i1,1:n1)=c1;
d(i1,1:mtot1)=d1;

% Map the connected mod2 outputs to the correct locations in C and D.

jx2=[n1+1:n1+n2];					% points to correct columns in C
ju2=[mtot1+1:mtot1+mtot2];			% points to correct columns in D
for i=1:length(iy1)
   if iy1(i) <= nym1
      c(iy1(i),jx2)=c2(iy2(i),:);
      d(iy1(i),ju2)=d2(iy2(i),:);
   else
      c(iy1(i)+nym2uc,jx2)=c2(iy2(i),:);
      d(iy1(i)+nym2uc,ju2)=d2(iy2(i),:);
   end
end

% Now map the unconnected outputs from mod2 (if any)

imuc=nym1+1;				% points to the row where the next unconnected,
							% measured output from mod2 should go.
iuuc=nym1+nym2uc+nyu1+1;	% as for imuc, but for the next unmeasured output.

for i=1:nym2+nyu2
   isuncon= ~any(iy2 == i);			% true if mod2 output i is unconnected
   if isuncon & i <= nym2
      c(imuc,jx2)=c2(i,:);
      d(imuc,ju2)=d2(i,:);
      imuc=imuc+1;
   elseif isuncon & i > nym2
      c(iuuc,jx2)=c2(i,:);
      d(iuuc,ju2)=d2(i,:);
      iuuc=iuuc+1;
   end
end

% Get A and B matrices of the composite system.

a=[  a1            zeros(n1,n2)
   zeros(n2,n1)         a2       ];
b=[   b1                zeros(n1,mtot2)
   zeros(n2,mtot1)            b2       ];

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
minfo(6)=nym1+nym2uc;
minfo(7)=nyu1+nyu2uc;
pmod=ss2mod(a,b,c,d,minfo);
