function h = PointLegend(varargin)
%POINTLEGEND Define symbolization for point data.
%
%   L = POINTLEGEND constructs a pointlegend with default values.
%
%   L = POINTLEGEND('PropertyName1',PropertyValue1,...
%                    'PropertyName2',PropertyValue2,...) Constructs a
%   PointLegend and sets multiple property values.  Valid PropertyNames are
%   Marker, MarkerSize, Color, MarkerFaceColor, and MarkerEdgeColor.
%   PropertyValue may be a function handle.  The function must have one input,
%   typically an attribute value, and the function must return a valid property
%   value for the associated PropertyName.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:49:12 $

h = MapModel.PointLegend;

% Default Point Properties
h.Marker          = {'Default','','x'};
h.Color           = {'Default','',h.getColor};
h.MarkerEdgeColor = {'Default','','auto'};
h.MarkerFaceColor = {'Default','','auto'};
h.MarkerSize      = {'Default','',6};
h.Visible         = {'Default','','on'};

% User defined properties
if nargin > 0
  % User defined properties
  fldnames = fieldnames(varargin{1});
  for i=1:length(fldnames)
    if isprop(h,fldnames{i})
      h.(fldnames{i}) = varargin{1}.(fldnames{i});
    else
      error('%s is not a property that can be set for a Point shape.', ...
            fldnames{i});
    end
  end
end