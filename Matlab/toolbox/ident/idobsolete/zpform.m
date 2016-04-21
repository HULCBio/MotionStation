function zepo=zpform(zp1,zp2,zp3,zp4,zp5)
%ZPFORM Formats zero-pole matrices from different models for use in ZPPLOT.
%   The function is OBSOLETE.
%
%   ZEPO = zpform(ZEPO1,ZEPO2,....,KU)
%
%   ZEPO1, ZEPO2,... are matrices obtained from TH2ZP, which are
%   merged into ZEPO.
%
%   KU is an optional row vector containing the input numbers to be
%   picked out when forming ZEPO. The default value of KU is all inputs
%   present in ZEPO1, ZEPO2,....  A maximum of five input arguments to
%   zpform is possible.
%
%   Example: zpplot(zpform(ZPBJ1,ZPOE1,ZPBJ2)) compares the poles and
%   zeros obtained in different models of different orders.

%   L. Ljung 7-3-87
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2001/04/06 14:21:43 $

noch=1;
[r1,c1]=size(zp1);
if nargin<2,zp2=[];end
[r2,c2]=size(zp2);if r2==1,inpind=zp2; noch=0;zp2=[];r2=0;c2=0;end
if nargin<3,zp3=[];end
[r3,c3]=size(zp3);if r3==1,inpind=zp3; noch=0;zp3=[];r3=0;c3=0;end
if nargin<4,zp4=[];end
[r4,c4]=size(zp4);if r4==1,inpind=zp4; noch=0;zp4=[];r4=0;c4=0;end
if nargin<5,zp5=[];end
[r5,c5]=size(zp5);if r5==1,inpind=zp5; noch=0;zp5=[];r5=0;c5=0;end
r=max([r1 r2 r3 r4 r5]);
zepo=[[zp1;zeros(r-r1,c1)+inf],[zp2;zeros(r-r2,c2)+inf],[zp3;zeros(r-r3,c3)+inf]];
zepo=[zepo,[zp4;zeros(r-r4,c4)+inf],[zp5;zeros(r-r5,c5)+inf]];
if noch,return,end
info=zepo(1,:);colind=[];
[mi,ni]=size(info);
for k=inpind

colind=[ colind,find(rem(info,20*ones(mi,ni))==k)];
end
