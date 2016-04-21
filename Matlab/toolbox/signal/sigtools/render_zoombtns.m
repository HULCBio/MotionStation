function varargout = render_zoombtns(hFig)
%RENDER_ZOOMBTNS Render the Zoom In and Zoom Out toggle buttons.
%
%   Input:
%     hut - Handle to the Toolbar
%     cbstruct - Structure of function handles for the CallBacks.
%
%   Output:
%     htoolbar - Vector containing handles to the zoom buttons.

%   Author(s): P. Costa 
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/13 00:32:44 $ 

hut  = findall(hFig,'type','uitoolbar');

if isempty(hut),
    hut = uitoolbar(hFig);
end

% Load the MAT-file with the icons 
icons = load('zoom_icons.mat');

% Cell array of cdata (properties) for the toolbar icons 
btns = {icons.zoomplusCData,...
        icons.zoomxCData,...
        icons.zoomyCData,...
        icons.fullviewCData};
    
tooltips = {'Zoom in',...
        'Zoom x-axis',...
        'Zoom y-axis',...
        'Zoom to full view'};

tags = {'zoomin',...
        'zoomx',...
        'zoomy',...
        'fullview'};

% Define all Callbacks
cbstruct = zoom_cbs(hFig);

% Separator flags
sep = {'On','Off','Off','Off'};

% Render the ToggleButtons
for i = 1:length(btns)-1,
   hbtns(i) = uitoggletool('Cdata',btns{i},...
        'Parent', hut,...
        'ClickedCallback',cbstruct.zoom_clickedcb,...
        'Tag',            tags{i},...
        'Tooltipstring',  xlate(tooltips{i}),...
        'Separator',      sep{i});
end

% Render the FullView PushTool Button
hbtns(end+1) = uipushtool('Cdata',btns{i+1},...
    'Parent', hut,...
    'ClickedCallback','',...
    'Tag',            tags{i+1},...
    'Tooltipstring',  xlate(tooltips{i+1}),...
    'Separator',      sep{i+1});

sigsetappdata(hFig, 'siggui', 'ZoomBtns', hbtns);

if nargout>0,
    varargout{1} = hbtns;
end

% Render hidden zoom buttons that will respond to the zoom commands.
if strcmpi(get(hFig,'HandleVisibility'),'on')
    render_hiddenzoombtns(hFig);
end

% [EOF]
