function vrmemb1_callbacks(varargin)
%VRMEMB1_CALLBACKS Process callbacks for VRMEMB1 demo.
%   VRMEMB1_CALLBACKS processes callbacks for VRMEMB1 demo.
%
%   Not to be called directly.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.4.1 $ $Date: 2003/04/12 23:26:25 $ $Author: batserve $


% the switchboard
feval(varargin{:});



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PostLoad

% get the handle to the model
h = get_param(gcs, 'handle');

% find and open ZOOM slider block, read its position, move it to the left and down a bit
zoomh = find_system(h, 'Name', 'ZOOM slider');
set_param(zoomh, 'UserData', []);    % clean any previous dialog
open_system(zoomh);
zoompos = get(get_param(zoomh, 'UserData'), 'Position');
zoompos(1:2) = [30 0.7*zoompos(2)];
zoomfigh = get_param(zoomh, 'UserData');
set(zoomfigh, 'Position', zoompos);

% find and open Rotation speed slider block, change its position
roth = find_system(h, 'Name', 'Rotation speed slider');
set_param(roth, 'UserData', []);    % clean any previous dialog
open_system(roth);
rotpos = [zoompos(1) zoompos(2)-1.3*zoompos(4) zoompos(3:4)];
set(get_param(roth, 'UserData'), 'Position', rotpos);

% hook slider callback so that zoom also works when model is not running
zoomslidh = findobj(zoomfigh, 'Type','UIControl', 'Style','Slider');
set(zoomslidh, 'Callback', sprintf('%s ; vrmemb1_callbacks(''ZoomSlider'',''%s'');', ...
                           get(zoomslidh, 'Callback'), gcs) );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ZoomSlider(sys)

% don't do anything if simulation running
if strcmpi(get_param(sys, 'SimulationStatus'), 'running')
  return;
end

% do the zoom as if simulation was running
udb = get_param([sys, '/VR Sink'], 'UserData');
udf = get(gcbf,'UserData');
udb.World.View1.fieldOfView = str2double(get(udf.GainEdit, 'String'));
