function [aa,bb1,bb2,cc1,cc2,dd11,dd12,dd21,dd22] = lftf(varargin);
%LFTF Two-port linear fractional transformation.
%
% [TSS_] = LFTF(TSS_1,TSS_2); or [A,B1,B2,..] = LFTF(A11,B11,..,A21,B21,..);
% [SS_L] = LFTF(TSS_1,SS_2); or [AL,BL,CL,DL] = LFTF(A11,B11,..,AW,BW,CW,DW);
% [SS_L] = LFTF(SS_1,TSS_2);
%  Produces a linear fractional transform from [U1;U2] to [Y1;Y2]:
%                                P1(s)
%  optional              ---------------------                optional
%  U1 (nu1) -----------> | P11(s)     P12(s) | -------------> Y1 (ny1)
%               -------> | P21(s)     P22(s) | -------
%               |        ---------------------       |
%               |      (nx  no. of states of P s))   |
%               |        ---------------------       |
%  optional     -------- | P11(s)     P12(s) |<-------        optional
%  Y2 (ny2) <----------- | P21(s)     P22(s) |<---------------U2 (nu2)
%                        ---------------------
%                                P2(s)


% R. Y. Chiang & M. G. Safonov (revised 7/1/87, 8/12/91)
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------------
%

% Handle LTI's with fall through to LFT
if isa(varargin{1},'lti') | isa(varargin{2},'lti'),
   warning('LFTF is obsolete.  Consider using LFT instead.')
   if nargout<2 & nargin==2, 
      [varargin{:}]=rct2lti(varargin{:});
      sys1=varargin{1}; sys2=varargin{2};
      if istito(sys1) 
         [tito1,w1,u,z1,y]=istito(sys1);
         u=length(u); y=length(y);
      else
         [y,u]=size(sys1);
      end
      if istito(sys2)
         [tito2,yy,w2,uu,z2]=istito(sys2);
         yy=length(yy); uu=length(uu);
      else
         [uu,yy]=size(sys2);
      end
      if uu==u & yy==y,
         aa=lft(sys1,sys2,u,y);
      else
         error('Dimensions of interconnections must be equal');
      end
      return
   end
end

nag1 = nargin;
Ts=0;
[emsg,junk,junk,Ts,Z1,Z2,Z3,Z4,Z5,Z6,Z7,Z8,Z9,Z10,Z11,Z12,Z13,Z14,Z15,Z16,Z17,Z18]=mkargs5x('',varargin); error(emsg);
% First extract a,b1,b2,...,d22; at,bt1,bt2,...,dt22 from Z1,Z2,etc.

% If P1(s) or P2(s) is SS_ format, convert to TSS_ format by padding
% with empty matrices before extracting data and setting flags
ssflag2=0;
if issystem(varargin{2})
   if nag1>2,
       error('Only two input arguments allowed when any is a system')
   end
   if issame(branch(varargin{2},'ty'),'ss')
     ssflag2=1;
     [a,b,c,d]=branch(varargin{2});
     %% Fix dimension of empties
     [xx,junk]=size(a);
     [yy,uu]=size(d);
     Z2=mksys(a,b,zeros(xx,0),c,zeros(0,xx),d,zeros(yy,0),zeros(0,uu),[],Ts,'tss');
     varargin{2}=Z2;
   end
end

ssflag1=0;
if issystem(varargin{1})
   if nag1>2,
       error('Only two input arguments allowed when any is a system')
   end
   if issame(branch(varargin{1},'ty'),'ss')
     ssflag1=1;
     [a,b,c,d]=branch(varargin{1});
     %% Fix dimension of empties
     [xx,junk]=size(a);
     [yy,uu]=size(d);
     Z1=mksys(a,zeros(xx,0),b,zeros(0,xx),c,[],zeros(0,uu),zeros(yy,0),d,Ts,'tss');
     varargin{1}=Z1;
   end
   % if Z1 is a system, expand input arguments
   %inargs=...
   %'(a,b1,b2,c1,c2,d11,d12,d21,d22,at,bt1,bt2,ct1,ct2,dt11,dt12,dt21,dt22)';
   %eval(mkargs(inargs,nag1,'tss,tss'))
   [emsg,nag1,xsflag,Ts,a,b1,b2,c1,c2,d11,d12,d21,d22,at,bt1,bt2,ct1,ct2,dt11,dt12,dt21,dt22]=mkargs5x('tss,tss',varargin); error(emsg);
else
   xsflag=0;
   if nag1 == 13 | nag1==18
      a=Z1; b1=Z2; b2=Z3; c1=Z4; c2=Z5; d11=Z6; d12=Z7; d21=Z8; d22=Z9;
      if nag1==13; % input lftf(a,b1,b2,...,d22,at,bt2,ct1,dt11)
         ssflag2=1;
         % Fix empty matrix dimensions
         at =Z10; bt1 =Z11;
         ct1=Z12; dt11=Z13;
         [xx,junk]=size(at);
         [yy,uu]=size(dt11);
         bt2 =zeros(xx,0);
         dt12=zeros(yy,0);
         ct2=zeros(0,xx);  dt21=zeros(0,uu);  dt22=[];
      else  % input lftf(a,b1,b2,...,d22,at,bt1,...,dt22)
         ssflag2=0;
         at=Z10;  bt1 =Z11; bt2 =Z12; ct1 =Z13; ct2=Z14;
         dt11=Z15; dt12=Z16; dt21=Z17; dt22=Z18;
      end
   elseif nag1 == 6 |nag1==4
      [a,b1,b2,c1,c2,d11,d12,d21,d22] = asys2ss(Z1,Z2);
      if nag1==6  % input lftf(sysp,dimp,at,bt1,ct1,ct2)
         ssflag2=1;
         at = Z3;  bt1 =Z4;
         ct1 = Z5; dt11=Z6;
         [xx,junk]=size(at);
         [yy,uu]=size(dt11);
         bt2 =zeros(xx,0);
         dt12=zeros(yy,0);
         ct2=zeros(0,xx);  dt21=zeros(0,uu);  dt22=[];
      else       % input lftf(sysp1,dimp1,sysp1,dimp2)
          ssflag2=0;
          [at,bt1,bt2,ct1,ct2,dt11,dt12,dt21,dt22] = asys2ss(Z3,Z4);
      end
   else
      error('Incorrect number of input arguments')
   end
end

%  We now have the two state-spaces a,b1,b2,c1,c2,d11,d12,d21,d22 and
%  at,bt1,bt2,ct2,ct2,dt11,dt12,d21,dt22 and three true/false flags:
%      ssflag1  (true if P1(s) had no U1,Y1 present)
%      ssflag2  (true if P2(s) had no U2,Y2 present)
%      xsflag   (true input arguments were in system format)


% ------------------------------------------------------------------
% Next get the dimensions of states, inputs and outputs
% and check compatibility

n = size(a)*[1;0];
p1y1=size([c1 d11 d12])*[1;0];
p1y2=size([c2 d21 d22])*[1;0];
p1u1=size([b1; d11; d21])*[0;1];
p1u2=size([b2; d12; d22])*[0;1];
dimp=[n p1u1 p1u2 p1y1 p1y2];

nt = size(at)*[1;0];
p2y1=size([ct1 dt11 dt12])*[1;0];
p2y2=size([ct2 dt21 dt22])*[1;0];
p2u1=size([bt1; dt11; dt21])*[0;1];
p2u2=size([bt2; dt12; dt22])*[0;1];
dimpt=[nt p2u1 p2u2 p2y1 p2y2];

%
if p1u2 ~= p2y1
    error('SYSP1 input U2 must be same dimension as SYSP2 output Y1'); 
end
if p2u1 ~= p1y2
    error('SYSP2 input U1 must be same dimension as SYSP1 output Y2')
end
%


% Add fictitious nonminimal states if needed
% in order to overcome the MATLAB empty-matrix bug
if nt == 0
    at=-1;
    bt1=zeros(1,p2u1);
    bt2=zeros(1,p2u2);
    ct1=zeros(p2y1,1);
    ct2=zeros(p2y2,1);
end

if n == 0
   a=-1;
   b1=zeros(1,p1u1);
   b2=zeros(1,p1u2);
   c1=zeros(p1y1,1);
   c2=zeros(p1y2,1);
end

%  Now we compute the state-space aa,bb1,bb2,cc1,cc2,dd11,dd12,dd21,dd22
%  of the two-port lftf

id = inv(eye(size(d22*dt11)*[1 0]') - d22*dt11);
idt = inv(eye(size(dt11*d22)*[1 0]') - dt11*d22);

dd11 = d11+d12*dt11*id*d21;
dd22 = dt22+dt21*d22*idt*dt12;
dd12 = d12*idt*dt12;
dd21 = dt21*id*d21;

% now compute the lftf aa,bb1,bb2,cc1, and cc2 matrices

aa  = [a+b2*dt11*id*c2      b2*idt*ct1;
       bt1*id*c2            at+bt1*id*d22*ct1     ];
bb1 = [b1+b2*dt11*id*d21;
       bt1*id*d21       ];
bb2 = [b2*idt*dt12;
       bt2+bt1*d22*idt*dt12 ];
cc1 = [c1+d12*dt11*id*c2    d12*idt*ct1           ];
cc2 = [dt21*id*c2           ct2+dt21*d22*idt*ct1  ];

% Now remove the fictitious states, if  needed

if nt == 0
   s=1:n;
   aa=aa(s,s);
   if min(size(bb1))>0, bb1=bb1(s,:);end
   if min(size(bb2))>0, bb2=bb2(s,:);end
   if min(size(cc1))>0, cc1=cc1(:,s);end
   if min(size(cc2))>0, cc2=cc2(:,s);end
end
if n == 0
   t=(2:nt+1);
   aa=aa(t,t);
   if min(size(bb1))>0, bb1=bb1(t,:);end
   if min(size(bb2))>0, bb2=bb2(t,:);end
   if min(size(cc1))>0, cc1=cc1(:,t);end
   if min(size(cc2))>0, cc2=cc2(:,t);end
end

%  Done with computing aa,bb1,bb2, etc.

%----------------------------------------------------------------
%  Now reformat output if needed:
%
if xsflag
   if ssflag1                           % output [ss_l]
     aa=mksys(aa,bb2,cc2,dd22,Ts);
   elseif ssflag2 % output [ss_l]
     aa=mksys(aa,bb1,cc1,dd11,Ts);
   elseif ~ssflag1 & ~ssflag2           % output [tss_]
     aa = mksys(aa,bb1,bb2,cc1,cc2,dd11,dd12,dd21,dd22,Ts,'tss');
   end
   bb1=[];bb2=[];cc1=[];cc2=[];dd11=[];dd12=[];dd21=[];dd22=[];
else
   if nag1 == 4                         % output [sysp,dimp]
      sysp=[aa,bb1,bb2;cc1,dd11,dd12;cc2,dd21,dd22];
      dimp = [n+nt,p1u1,p2u2,p1y1,p2u2];
      aa = sysp;
      bb1 = dimp;
      bb2=[];cc1=[];cc2=[];dd11=[];dd12=[];dd21=[];dd22=[];
   elseif nag1==13 | nag1==6            %  output a[l,bl,cl,dl]
      bb2=cc1;
      cc1=dd11;
      cc2=[];dd11=[];dd12=[];dd21=[];dd22=[];
   end
end
%
% --------- End of LFTF.M --- RYC/MGS 7/1/87, 8/12/91 %
