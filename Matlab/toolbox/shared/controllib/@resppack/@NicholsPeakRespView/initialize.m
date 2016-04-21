function initialize(this,Axes)
%INITIALIZE  Initialization for @NicholsPeakRespView class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:59 $

[s1,s2] = size(Axes(:,:,1)); 
Points = zeros([s1 s2]);

for ct=1:s1*s2   
   %% Plot characteristic points
   Points(ct) = line(NaN,NaN,[5],...
      'Parent',Axes(ct),...
      'Visible','off',...
      'Marker','o',...
      'XLimInclude','off',...
      'YLimInclude','off',...
      'MarkerSize',6);
end

this.Points = handle(Points);
this.PointTips = cell([s1 s2]);