function draw(cv,cd,NormalRefresh)
%DRAW  Draws characteristic.
%
%  DRAW(cVIEW,cDATA) maps the characteristic data in cDATA to the HG
%  objects in cVIEW.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:20:08 $

if strcmp(cv.AxesGrid.YNormalization,'on')
   % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
   set(double(cv.HLines),'XData',[],'YData',[],'ZData',[])
else
   % Position dot and lines given finalized axes limits
   XData = infline(-Inf,Inf);
   ZData = repmat(-10,size(XData));
   for ct=1:prod(size(cv.HLines))
      % Parent axes and limits
      Yfinal = cd.FinalValue(ct);
      set(double(cv.HLines(ct)),'XData',XData,...
         'YData',Yfinal(ones(size(XData))),'ZData',ZData)     
   end
end