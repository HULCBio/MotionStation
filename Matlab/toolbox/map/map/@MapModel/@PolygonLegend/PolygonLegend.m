function h = PolygonLegend(varargin)
%POLYGONLEGEND  Define symbolization for polygon data
%
%   L = POLYGONLEGEND constructs a polygonlegend with default values.
%
%   L =
%   POLYGONLEGEND('PropertyName1',PropertyValue1,'PropertyName2',PropertyValue2,...)
%   Constructs a polygonlegend and sets multiple property values.  Valid
%   PropertyNames are FaceColor, LineStyle, and LineWidth.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:49:14 $

h = MapModel.PolygonLegend;

% Default Polygon Properties
h.FaceColor = {'Default','',h.getColor};
h.LineStyle = {'Default','','-'};
h.LineWidth = {'Default','',0.5};
h.EdgeAlpha = {'Default','',1};
h.EdgeColor = {'Default','',[0 0 0]};
h.FaceAlpha = {'Default','',1};
h.Visible   = {'Default','','on'};

if nargin > 0
  % User defined properties
  fldnames = fieldnames(varargin{1});
  for i=1:length(fldnames)
    if isprop(h,fldnames{i})
      h.(fldnames{i}) = varargin{1}.(fldnames{i});
    else
      error('%s is not a property that can be set for a Polygon shape.', ...
            fldnames{i});
    end
  end
end