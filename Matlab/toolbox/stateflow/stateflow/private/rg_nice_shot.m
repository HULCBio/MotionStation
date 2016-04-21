function imageMaps = rg_nice_shot(id, targetFile, maxSize, format),
%
% Take a Stateflow object's most flattering picture highlighting it's most salient features.
%

%   Vladimir Kolesnikov
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.7.2.1 $  $Date: 2004/04/15 00:59:09 $

% preamble
GET = sf('method','get');
SET = sf('method','set');

bounds = [0 0 maxSize(1:2)];
ISA_STATE = sf(GET, 'default', 'state.isa');
ISA_CHART = sf(GET, 'default', 'chart.isa');
ISA_JUNCTION = sf(GET, 'default', 'junction.isa');
ISA_TRANS = sf(GET, 'default', 'trans.isa');

%
% Find/construct viewer axes.
%
viewAxes = findobj('type','axes', 'tag', 'RG_VIEWER');
if isempty(viewAxes), viewAxes = construct_viewer; end;

set(viewAxes, 'units','points', 'position', bounds);

%
% Construct the object view
%
switch(sf(GET, id, '.isa')),
	case ISA_CHART,
		ax = construct_chart_view(id, viewAxes);	
	case ISA_STATE, 
      ax = construct_state_view(id, viewAxes);	
   case ISA_TRANS, 
      ax = construct_state_view(id, viewAxes);
   case ISA_JUNCTION, 
		ax = construct_state_view(id, viewAxes);
	otherwise, error('other objects not handled yet!');
end;

[im, map] = getframe(ax);
imwrite(im, map, targetFile, format);

imageMaps = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ax = construct_chart_view(chartId, viewAxes),
%
% Given a chart id, construct a nice view
%
fig = sf('get', chartId, '.hg.figure');
set( fig, 'Position', get( viewAxes, 'Position' ) );
sf('Select',chartId, []);
sf('FitToView', chartId);
sf('Open', chartId);
ax = sf('get', chartId, '.hg.axes');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ax = construct_state_view(id, viewAxes),
%
% Given a state id, construct a nice view
%
chartId = sf('get', id, '.chart');

sf('Open', chartId);
sf('FitToView', chartId, id);
sf('Open', chartId);
ax = sf('get', chartId, '.hg.axes');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function viewAxes = construct_viewer
%
% 
%
fig = figure('vis','off');
viewAxes = axes('Tag', 'RG_VIEWER', 'parent', fig, 'units','points');
