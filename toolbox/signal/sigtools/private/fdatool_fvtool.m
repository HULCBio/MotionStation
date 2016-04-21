function fdatool_fvtool(hFDA)
%FDATOOL_FVTOOL Add FVTool to FDATool

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.41.4.3 $  $Date: 2004/04/13 00:32:28 $ 

hFig = get(hFDA,'FigureHandle');

% Instantiate FVTool
hFVT = siggui.fvtool;

sz = fdatool_gui_sizes(hFDA); 

% Render FVTool
render(hFVT, hFig, [sz.fx2 sz.fy1 sz.fw2 sz.fh1]);

% Add plugins to FVTool
addplugins(hFVT);

% Add the full view analysis menu item
addfullview(hFDA);

% set(hFVT,'Visible','On');

% Add FVTool as a component of FDATool
addcomponent(hFDA, hFVT);

attach_listeners(hFDA, hFVT);

% ------------------------------------------------------------------
function addfullview(hFDA)

hFig = get(hFDA, 'FigureHandle');
cbs  = menus_cbs(hFDA);

% Add the Full View Analysis menu item
h.fvtool = uimenu(findobj(hFig, 'type', 'uimenu', 'tag', 'view'), ...
    'Label', 'Filter &Visualization Tool',...
    'Callback', cbs.fullviewanalysis_cb, ...
    'Tag', 'fullviewanalysis', ...
    'Enable', 'Off', ...
    'Separator', 'On');

% Add the Full View Analysis menu item

hFile = findobj(hFig, 'type', 'uimenu', 'tag', 'file');
pos   = get(findobj(hFile, 'Label', '&Print...'), 'Position');
h.printtofig = uimenu(hFile, ...
    'Position', pos+1, ...
    'Label', xlate('&Print to Figure'),...
    'Callback', cbs.fullviewanalysis_cb, ...
    'Tag', 'printtofigure', ...
    'Enable', 'On');

sigsetappdata(hFDA, 'fvtool', 'fullviewmenu', h);


% ------------------------------------------------------------------
function attach_listeners(hFDA, hFVT)

% Listen to the FilterUpdated and the NewAnalysis events of FDATool
addlistener(hFDA, 'FilterUpdated', @local_filter_listener, hFVT);
addlistener(hFDA, 'FastFilterUpdated', @fast_local_filter_listener, hFVT);
addlistener(hFDA, 'NewAnalysis', @local_analysis_listener, hFVT);
addlistener(hFDA, 'DefaultAnalysis', @default_analysis_listener, hFVT);
addlistener(hFDA, 'FullViewAnalysis', {@fullviewanalysis_eventcb, hFDA}, hFVT);
addlistener(hFDA, 'Print', @print_eventcb, hFVT);
addlistener(hFDA, 'PrintPreview', @printpreview_eventcb, hFVT);

% Listen to the CurrentAnalysis of FVTool to announce changes to other components
l = [ ...
        handle.listener(hFVT, hFVT.findprop('CurrentAnalysis'), ...
        'PropertyPostSet', {@lcl_ca_listener, hFDA}); ...
        handle.listener(hFVT, 'NewPlot', {@local_newplot_listener, hFDA}) ...
    ];

set(l,'CallbackTarget', hFVT);

sigsetappdata(hFDA, 'fvtool', 'analysis_listener', l);


% -----------------------------------------------------------------------
%
%                                Listeners
%
% -----------------------------------------------------------------------

% -----------------------------------------------------------------------
function print_eventcb(hFVT, eventData)

canal = get(hFVT, 'CurrentAnalysis');
if ~isempty(canal),
    print(canal);
end

% -----------------------------------------------------------------------
function printpreview_eventcb(hFVT, eventData)

canal = get(hFVT, 'CurrentAnalysis');

if ~isempty(canal),
    printpreview(canal);
end

% -----------------------------------------------------------------------
function fullviewanalysis_eventcb(hFVT, eventData, hFDA)

if ~isempty(get(hFVT, 'Analysis')),
    fullviewlink(hFDA);
end

% ---------------------------------------------------------------------
function fast_local_filter_listener(hFVT, eventData)

set(hFVT, 'FastUpdate', 'On');

% Get the handle to FDATool and it's filter
hFDA = get(eventData, 'Source');
Hd   = getfilter(hFDA, 'wfs');
fs   = get(Hd, 'Fs');

% Set the currentFs and the filter to FVTool.  Do this before setting the
% parameters 
hFVT.setfilter(Hd);

hprm = getparameter(hFVT, 'freqmode');
if isempty(fs),
    setvalue(hprm, 'on');
else
    setvalue(hprm, 'off');
end

% ---------------------------------------------------------------------
function local_filter_listener(hFVT, eventData)
% Fires when FDATool announces a new filter

set(hFVT, 'FastUpdate', 'Off');

% Get the handle to FDATool and it's filter
hFDA = get(eventData, 'Source');
Hd   = getfilter(hFDA, 'wfs');
fs   = get(Hd, 'Fs');

% Set the currentFs and the filter to FVTool.  Do this before setting the
% parameters 
hFVT.setfilter(Hd);

hprm = getparameter(hFVT, 'freqmode');
if isempty(fs),
    setvalue(hprm, 'on');
else
    setvalue(hprm, 'off');
end

% ----------------------------------------------------------------------
function local_analysis_listener(hFVT, eventData)

hFDA = getfdasessionhandle(hFVT.FigureHandle);
newAnalysis = get(eventData, 'Data');

if ~strcmpi(newAnalysis, get(hFVT.CurrentAnalysis, 'Name')), % The current Analysis String

    % Make FVTool's analysis invisible using FVTool's API
    % Cannot set visible off because this would affect the buttons and menu items
    set(hFVT, 'Analysis', '');
end

% ----------------------------------------------------------------------
function lcl_ca_listener(hFVT, eventData, hFDA)

% xxx hack to get undo working when going back to the static response.
if isempty(get(hFVT, 'CurrentAnalysis')),
    enab = 'Off';
    enab2 = 'On';
    hd = find(hFDA, '-class', 'siggui.designpanel');
    set(hd, 'staticresponse', 'on');
else
    enab = 'On';
    enab2 = 'Off';
end

h = siggetappdata(hFDA, 'fvtool', 'fullviewmenu');

set(h.fvtool, 'Enable', enab);
set(h.printtofig, 'Enable', enab2);

% ----------------------------------------------------------------------
function local_newplot_listener(hFVT, eventData, hFDA)

ca = get(hFVT, 'CurrentAnalysis');

analysis = get(ca, 'Name');

if ~isempty(analysis),

    % When the analysis is empty do not send the event.
    % An empty analysis means that FVTool has yielded the analysis area.
    send(hFDA, 'NewAnalysis', ...
        sigdatatypes.sigeventdata(hFDA, 'NewAnalysis', analysis));
end

if isa(ca, 'sigresp.analysisaxis'),
    set(ca, 'Title', 'On'); % xxx revisit, this fixes tworesps title reappearing.
    set(ca, 'Title', 'Off');
end

% -----------------------------------------------------------------------
function default_analysis_listener(hFVT, eventData)
%DEFAULT_ANALYSIS_LISTENER Fired when someone requests the default analysis

hFDA = get(eventData, 'Source');

if isempty(get(hFVT, 'Analysis')),
    set(hFVT, 'Analysis', 'magnitude');
end

% [EOF]
