function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'postlim') adjusts the HG object extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:06 $

if strcmp(Event,'postlim') & strcmp(cv.AxesGrid.YNormalization,'on')
   % Adjust final value line in normalized mode
   for ct=1:prod(size(cv.HLines))
      % Parent axes and limits
      ax = cv.HLines(ct).Parent;
      Xlim = get(ax,'Xlim');
      Yfinal = cd.FinalValue(ct);
      if isfinite(Yfinal)
         Yfinal = normalize(cd.Parent,Yfinal,Xlim,ct);
      end
      % Position objects
      set(double(cv.HLines(ct)),'XData',Xlim,'YData',[Yfinal,Yfinal],'ZData',[-10,-10])     
   end
end