function h = render(this,layerName,legend,ax,visibility)
%RENDER Render the point component.
%
%   H = RENDER(LAYERNAME,LEGEND,AX,VISIBILITY) renders all features 
%   of the point component into the axes AX using the symbolization 
%   defined in the legend, LEGEND. The point visibility is defined by 
%   VISIBILITY. 

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:56:16 $

h = handle([]);
features = this.Features;
for i=1:length(features)
  h(i) = MapGraphics.Line(layerName,...
                          'XData',features(i).xdata,...
                          'YData',features(i).ydata,...
                          'Marker','x',...
                          'LineStyle','None',...
                          'Parent',ax,...
                          'Visible','off');
  
  h(i).setAttributes(features(i).Attributes);
  
  % Use the legend to symbolize the vector data
  l = legend.getGraphicsProperties(features(i));
  set(h(i),'visible',visibility)
  set(double(h(i)),l)
end





