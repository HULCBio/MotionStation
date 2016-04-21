function h = render(this,layerName,legend,ax,visibility)
%RENDER Render the polygon component.
%
%   RENDER(LAYERNAME, LEGEND, AX, VISIBILITY) renders all features 
%   of the polygon component into the axes AX using the symbolization 
%   defined in the legend, LEGEND, for the layer defined by LAYERNAME.
%   The polygon visibility is defined by VISIBILITY.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:56:17 $

% Create default handles
h = handle([]);

% Assign class features
features = this.Features;

% Initialize the count for the handles
count = 0;

% Loop over all the features and display
for i=1:length(features)

  % Obtain the legend of feature i
  l = legend.getGraphicsProperties(features(i));

  % Extract the NaN separated parts
  parts = mapgate('extractgeoparts',features(i).xdata,features(i).ydata);
  for j=1:length(parts)
    count = count + 1;
    idx = find(isnan(parts(j).X) | isnan(parts(j).X));
    if isempty(idx) 
      % If there is no NaN at the end, use the full arrays
      idx = length(parts(j).X) + 1;
    end
    h(count) = MapGraphics.Polygon(layerName,...
                             'XData',parts(j).X(1:(idx-1)), ...
                             'YData',parts(j).Y(1:(idx-1)), ...
                             'Parent',ax);

    % Set the attributes of this feature in the Polygon classs
    h(count).setAttributes(features(i).Attributes);

    % Set the visibility of the Polygon
    set(h(count),'Visible',visibility);

    % Set the legend rules
    set(double(h(count)),l);
  end
end
