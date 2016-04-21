function [pmod,in1,in2,out1,out2]=sermod1(mod1,iy1,mod2,iu2)
%SERMOD1	Series connection of SPECIFIED signals.
%
%    	pmod=sermod1(mod1,iy1,mod2,iu2)
%  OR  [pmod,in1,in2,out1,out2]=sermod1(mod1,iy1,mod2,iu2)
%
%A generalization of SERMOD.  Here, the "mod1" outputs
%specified by "iy1" are connected to the "mod2" inputs specified
%by "iu2".  Unconnected mod1 outputs and mod2 inputs appear in the
%composite model, as do all mod1 inputs and mod2 outputs.
%All such inputs and outputs are grouped by type (manipulated,
%measured, unmeasured), with those from mod1 coming first.
%Connection of "measured" and "unmeasured" signals is allowed.
%
% Inputs:
%  mod1  plant model in the MPC mod format.
%  iy1   list of mod1 outputs to be connected.
%  mod2  plant model in the MPC mod format.
%  iu2   list of mod2 inputs to be connected.
%
% Output:
%  pmod  is the composite model in the MPC mod format.
%  in1,in2,out1,out2 are optional pointers to the locations
%      of the original inputs and outputs in the composite model.
%      For example, in1(i) is the pmod input number of input i
%      from mod1, etc.  Elements of out1 and in2 will be zero
%      for signals that have been connected.
%
% See also ADDMOD, ADDMD, ADDUMD, APPMOD, PARAMOD, PARAMOD1.
%
%Example:  mod1 has 1 man. var, 1 measured disturbance input,
%                   2 measured outputs, 1 unmeasured output.
%          mod2 has 2 man. vars., 1 measured and 1 unmeasured
%                   disturb. input, 1 meas. and 1 unmeas. output.
%  Then   pmod=sermod1(mod1,[1 3],mod2,[2 3])  gives pmod with
% input 1 = first manipulated variable from mod1
% input 2 = first manipulated variable from mod2
% input 3 = first measured disturbance from mod1
% input 4 = first unmeasured disturbance from mod2
%output 1 = second measured output from mod1
%output 2 = first measured output from mod2
%output 3 = first unmeasured output from mod2

% N. L. Ricker

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0
   disp('USAGE:  pmod=sermod1(mod1,iy1,mod2,iu2)')
   return
elseif nargin ~= 4
   error('Incorrect # of input arguments')
end

if isempty(iy1)
   error('IY1 and IU2 must be specified (non-empty)')
elseif length(iy1) ~= length(iu2)
   error('Lists IY1 and IU2 must be same length')
end

% Use APPMOD to combine the two models -- unconnected.
% This gets the inputs and outputs in the desired order.

[pmod,in1,in2,out1,out2]=appmod(mod1,mod2);

if any(iy1 < 1 | iy1 > length(out1))
   error('An element of IY1 is < 1 or > # outputs in MOD1')
elseif any(iu2 < 1 | iu2 > length(in2))
   error('An element of IU2 is < 1 or > # inputs in MOD2')
elseif any(diff(sort(iy1)) == 0)
   error('IY1 contains duplicate elements')
elseif any(diff(sort(iu2)) == 0)
   error('IU2 contains duplicate elements')
end

% Extract the state-space description of the unconnected system.

[a,b,c,d,minfo]=mod2ss(pmod);
nu=minfo(3);
nd=minfo(4);
nw=minfo(5);
nym=minfo(6);
nyu=minfo(7);

% Make appropriate modifications for each element of
% the IY1 and IU2 lists.

rowlist=zeros(1,length(iy1));
collist=zeros(size(rowlist));
for i=1:length(iy1)
   irow=out1(iy1(i));	% output # to be deleted in new model
   rowlist(i)=irow;
   out1(iy1(i))=0;
   jcol=in2(iu2(i));	% input # to be deleted in new model
   collist(i)=jcol;
   in2(iu2(i))=0;
   a=a+b(:,jcol)*c(irow,:);
   b=b+b(:,jcol)*d(irow,:);
   c=c+d(:,jcol)*c(irow,:);
   d=d+d(:,jcol)*d(irow,:);
   if irow <= nym
      minfo(6)=minfo(6)-1;
   else
      minfo(7)=minfo(7)-1;
   end
   if jcol <= nu
      minfo(3)=minfo(3)-1;
   elseif jcol <= nu+nd
      minfo(4)=minfo(4)-1;
   else
      minfo(5)=minfo(5)-1;
   end
end

% Delete the selected rows and columns for the B, C, and D
% matrices.

b(:,collist)=[];
c(rowlist,:)=[];
d(:,collist)=[];
d(rowlist,:)=[];

%		Decrement pointers to account for deleted input and output

collist=sort(collist);
rowlist=sort(rowlist);
for i=length(rowlist):-1:1
   irow=rowlist(i);
   jcol=collist(i);
   igt=find(in1 > jcol);
   if ~isempty(igt)
      in1(igt)=in1(igt)-1;
   end
   igt=find(in2 > jcol);
   if ~isempty(igt)
      in2(igt)=in2(igt)-1;
   end
   igt=find(out1 > irow);
   if ~isempty(igt)
      out1(igt)=out1(igt)-1;
   end
   igt=find(out2 > irow);
   if ~isempty(igt)
      out2(igt)=out2(igt)-1;
   end
end

% Put back into mod format

pmod=ss2mod(a,b,c,d,minfo);
