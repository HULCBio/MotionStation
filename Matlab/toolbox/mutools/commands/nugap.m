%  function gap = nugap(sys1,sys2,ttol)
%
%  Computes Vinnicombe's variation of the gap metric
%  between the systems SYS1 and SYS2.
%
%  TTOL gives the tolerance to which the gap is calculated.
%  The default is 0.001. This output GAP is Vinnicombe's
%  version of the gap metric.
%
%  See also: H2NORM, HINFNORM, and SNCFBAL

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

%  Reference: G. Vinnicombe, "Structured Uncertainty and
%  the Graph Topology", IEEE Trans. AC.  to appear.

function gap = nugap(sys1,sys2,ttol)

if nargin < 2,
  disp('usage: gap = nugap(sys1,sys2,ttol)');
  return;
 end;

[type1,p1,m1,n1]=minfo(sys1);
[type2,p2,m2,n2]=minfo(sys2);

if type1=='vary' | type2=='vary'
   disp('NUGAP error: SYS1 and SYS2 must be SYSTEM or CONSTANT');
  return;
 end;

if p1~=p2 | m1~=m2,
   disp('NUGAP error: SYS1 and SYS2 must have same I/O dimensions');
  return;
 end;

if nargin==2,
   ttol=0.001;
   end;

if type1=='syst' & type2=='syst',
  [a1,b1,c1,d1]=unpck(sys1);
  [a2,b2,c2,d2]=unpck(sys2);
  w=inv(eye(m1)+d2'*d1);
  y=inv(eye(p1)+d2*d1');
  Agp=[-(a1-b1*w*d2'*c1)', c1'*y*c2; b2*w'*b1', a2-b2*d1'*y*c2];
  evals=eig(Agp);
  poseig=sum(real(evals)>0);
  if poseig~=n1,
     gap=1;
   else
     sysnlcf1=sncfbal(sys1);
     sysnrcf2=sncfbal(transp(sys2));
     sysnrcf2=transp(sysnrcf2);
     nugap=hinfnorm(mmult(sysnlcf1,[zeros(m1,p1) -eye(m1);...
		  eye(p1) zeros(p1,m1)],sysnrcf2));
     gap=nugap(1);
   end; % if poseig~=n1
 end; %if type1=='syst'

if type1=='syst' & type2=='cons', % exchange sys1 and sys2
  sys3=sys1; sys1=sys2; sys2=sys3;
  type3=type1; type1=type2; type2=type3;
  n3=n1;n1=n2;n2=n3;
  end; %if type1=='syst'

if type1=='cons' & type2=='syst',
  d1=sys1;
  [a2,b2,c2,d2]=unpck(sys2);
  w=inv(eye(m1)+d2'*d1);
  y=inv(eye(p1)+d2*d1');
  Agp=[ a2-b2*d1'*y*c2];
  evals=eig(Agp);
  poseig=sum(real(evals)>0);
  if poseig~=0,
     gap=1;
   else
     [sysnlcf1,tmp]=qr([d1'; eye(p1)]);
     sysnlcf1=sysnlcf1(:,1:p1)';
     sysnrcf2=sncfbal(transp(sys2));
     sysnrcf2=transp(sysnrcf2);
     nugap=hinfnorm(mmult(sysnlcf1,[zeros(m1,p1) -eye(m1);...
		   eye(p1) zeros(p1,m1)],sysnrcf2));
     gap=nugap(1);
   end; % if poseig~=n1
 end; %if type1=='cons'

if type1=='cons' & type2=='cons',
   d1=sys1; d2=sys2;
   [sysnlcf1,tmp]=qr([d1'; eye(p1)]);
   sysnlcf1=sysnlcf1(:,1:p1)';
   [sysnrcf2,tmp]=qr([d2; eye(m1)]);
   sysnrcf2=sysnrcf2(:,1:m1);
   gap=norm(sysnlcf1*[zeros(m1,p1) -eye(m1);eye(p1) zeros(p1,m1)]*sysnrcf2);
 end; %if type1=='cons'
%
%