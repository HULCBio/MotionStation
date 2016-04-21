function pointsUnits=normalized(c,normUnits)
%NORMALIZED transforms normalized to points units
%   P=NORMALIZED(C,N) where C is any component object
%   N is a 1x4 matrix of normalized coordinates.
%   NORMALIZED transforms N into points units P 
%   appropriate for an ATTRIBUTES method resize function.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:10 $

c=struct(c);

%set up coordinate system
pad=10;
xZero=c.x.xzero+pad;
xExt=c.x.xext-c.x.xzero-2*pad;
yOrig=c.x.yorig+pad;
yLim=c.x.ylim-c.x.yorig-2*pad;

%perform idiot checking
normUnits(1)=max(min(normUnits(1),.99),0);
normUnits(2)=max(min(normUnits(2),.99),0);
normUnits(3)=max(min(1-normUnits(1),...
   normUnits(3)),0.000001);
normUnits(4)=max(min(1-normUnits(2),...
   normUnits(4)),0.000001);

%transform coordinates
%could use .* for this....
pointsUnits=[xZero yOrig 0 0]+...
   [xExt*normUnits(1) yLim*normUnits(2) xExt+normUnits(3) yLim*normUnits(4)];
