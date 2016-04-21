function h = renderMapData(ax, mapdata)
%RENDERMAPDATA Render the mapdata structure onto the axes. 
%
%   H = RENDERMAPDATA(AX, MAPDATA) renders the MAPDATA structure onto the
%   axes AX.  MAPDATA will hold the rendering function name as well as the
%   function arguments. For a complete description of the MAPDATA structure
%   see PARSEMAPINPUTS.
%  
%   See also BUILDMAPDATA, MAPSHOW, MAPVIEW, PARSEMAPINPUTS, READMAPDATA.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:52:42 $

%-------------------------------------------------------------------------

% Render the map's data onto the axes.
h = feval(str2func(mapdata.fcn), mapdata.args{:});

% Set the Handle Graphics parameter value pairs,
%  including the Parent
if isfield(mapdata,'HGparams') && ~isempty(mapdata.HGparams)
  set(h,mapdata.HGparams);
end

% Set the axes to equal or image
setMapAxes(ax, mapdata);

%----------------------------------------------------------------------
function setMapAxes(ax, mapdata)
% Set the axes depending on the type of data being rendered.

% If hold is on, do nothing
if ishold
  return
end

% Set the map's axes according to its type.
if ~isempty(strfind(lower(mapdata.type),'image'))
  axis(ax,'image');

elseif ~isempty(strfind(lower(mapdata.type),'grid'))
  view(2);
  if ~strcmp(mapdata.fcn(end),'m')
    % Do not set for the 'm'  ending functions
    if strcmp(mapdata.fcn,'texturemap')
      axis(ax,'equal','fill') ;
    else
      axis(ax,'equal') ;
    end
  end

else
  % Set the axes equal for vector data
  axis(ax,'equal') ;
end

%----------------------------------------------------------------------
function h = renderComponent(component, layerName,rules,ax,vis)
% Renders a MapGraphics component onto the axes ax.

h = component.render(layerName,rules,ax,vis);

%----------------------------------------------------------------------
function h = contourwrap(varargin)
% Wraps the contour function to return the handle h.

[c,h] = feval(str2func(varargin{1}),varargin{2:end});

%----------------------------------------------------------------------
function h = renderImageComponent(I, XData, YData)
% Render an image using the Handle Graphics image function.

h = image('CData',I,'XData',XData,'YData',YData);

