function varargout = fdatool(varargin)
%FDATOOL Filter Design & Analysis Tool.
%   FDATOOL launches the Filter Design & Analysis Tool (FDATool).
%   FDATool is a Graphical User Interface (GUI) that allows you to
%   design or import, and analyze digital FIR and IIR filters.
%
%   If the Filter Design Toolbox is installed, FDATool seamlessly
%   integrates advanced filter design methods and the ability to
%   quantize filters.
%
% See also FVTOOL, SPTOOL.

%   Author(s): P. Pacheco, R. Losada, P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.104.4.11 $  $Date: 2004/04/23 19:09:55 $

feature ScopedAccelEnablement Off

% Boolean flag indicating if the Signal Processing Blockset called FDATool.
flags.calledby.dspblks = iscalledbydspblks;

opts = struct('visstate', 'On', 'usenewqpanel', true, 'flags', flags, ...
    'title', 'Filter Design & Analysis Tool - [untitled.fda]');

if nargin
    if ischar(varargin{1}),
        varargin{1} = cell2struct(varargin(2:2:end), lower(varargin(1:2:end)), 2);
    end
    if isstruct(varargin{1});
        opts = setstructfields(opts, varargin{1});
    end
end

hFDA = sigtools.fdatool;

setappdata(hFDA, 'UseNewQPanel', opts.usenewqpanel);

oldunits = get(0, 'Units');
set(0, 'Units', 'pixels');

screensize = get(0, 'ScreenSize');
set(0, 'Units', oldunits);
if any(screensize([3 4]) < [800 600]),
    error(hFDA, 'Screen resolution too low. The minimum required is 800x600.');
    delete(hFDA);
    return;
end

render(hFDA, opts);

status(hFDA, 'Initializing Filter Design and Analysis Tool .');

hFig = get(hFDA, 'FigureHandle');
sz   = fdatool_gui_sizes(hFDA);

% Install the context-sensitive help system:
help_cbs = fdatool_help;
feval(help_cbs.install_CSH,hFig);
status(hFDA, 'Initializing Filter Design and Analysis Tool ..');

% Add FDATool components.
% function addcomponents(hFDA)

% Install the Sidebar Object
% function hSB = fdatool_sidebar(hFDA)

% Instantiate the object
hSB = siggui.sidebar;

l = handle.listener(hSB, hSB.findprop('CurrentPanel'), 'PropertyPostSet', ...
    {@currentpanel_listener, hSB});
set(l, 'CallbackTarget', hFDA);
setappdata(hFDA, 'panel_listener', l);

render(hSB, hFig);

% Register the sidebar as a component of FDATool
% addcomponent(hFDA,hSB);

% Add the Design Panel
% function install_design_panel(hSB)

icons        = load('panel_icons');

% Remove the following line once geck # 110439 is addressed.
opts.icon    = color2background(icons.design);
% opts.icon    = icons.design; % See G122899
opts.tooltip = 'Design filter';
opts.csh_tag = 'fdatool_designfilter_tab';

% Register the Design Panel
registerpanel(hSB, @fdatool_design, 'design', opts);
% registerpanel(hSB,design_fcns,'design',opts);
% Add the Import Panel
% function install_import_panel(hSB)

% Create the Import Panel and Register it
opts.icon    = color2background(icons.import);
% opts.icon    = icons.import; % See G122899
opts.tooltip = 'Import filter from workspace';
opts.csh_tag = 'fdatool_importfilter_tab';

% Register the Import Panel
registerpanel(hSB,@fdatool_import,'import',opts);

% function addimportmenu(hSB)

hFM = findobj(hFig, 'type','uimenu','tag','file');
hEM = findobj(hFM, 'tag', 'export');

uimenu(hFM, 'Position', get(hEM, 'Position'), ...
    'Label', 'Import Filter From Workspace', ...
    'Separator', 'On', ...
    'tag', 'import', ...
    'Accelerator', 'i', ...
    'Callback', {@setpanel_cb, hSB, 'import'});
set(hEM, 'Separator', 'Off');

% function install_pzeditor_panel(hSB)

% Create the Import Panel and Register it
opts.icon    = color2background(icons.pzeditor);
opts.tooltip = 'Pole/Zero Editor';
opts.csh_tag = [];

% Register the Import Panel
registerpanel(hSB,@fdatool_pzeditor,'pzeditor',opts);

hEdit = findall(hSB.figurehandle, 'type', 'uimenu', 'tag', 'edit');

uimenu(hEdit, 'Label', 'Pole/Zero Editor', 'tag', 'pzeditor_tools_menu', ...
    'Enable', 'Off');

% Add plugins for the sidebar
addplugins(hSB);

status(hFDA, 'Initializing Filter Design and Analysis Tool ...');

set(hSB,'CurrentPanel',1);

status(hFDA, 'Initializing Filter Design and Analysis Tool ....');

% Install the Current Filter Information Object
% function varargout = fdatool_cfi(hFDA)

% Instantiate the object
hCFI = siggui.cfi;
set(hCFI, 'Order', 50, ...
    'FilterStructure', ...
    'Direct-Form FIR', ...
    'Section', 1, ...
    'isStable', true, ...
    'Source', 'Designed');

% Render the CFI
render(hCFI,hFig,[sz.fx1 sz.fy1 sz.fw1 sz.fh1]);
setunits(hCFI,'normalized');

% set(hCFI,'Visible','On');

% Add the Current Filter Information as a component to FDATool
% addcomponent(hFDA, hCFI);

% function install_menus(hFDA, hCFI)

cbs = menus_cbs(hFDA);

lbls = {xlate('Convert Structure ...'), ...
    xlate('Convert To Second-Order Sections'), ...
    xlate('Reorder and Scale Second-Order Sections ...'), ...
    xlate('Convert To Single Section'), ...
    xlate('Show Filter Structure')};
mcbs = {cbs.convertstruct, ...
    cbs.convert2sos, ...
    cbs.reordersos, ...
    {@convert2ss, hFDA}, ...
    {@showstructure_cb, hFDA}};
tags = {'convertstructure', ...
    'convert2sos', ...
    'reordersos', ...
    'convert2ss', ...
    'showstructure'};
enab  = {'on', 'off', 'off', 'off', 'on'};
seps = {'on','off', 'off', 'off', 'on'};

h  = handles2vector(hCFI);
hc = get(h(1), 'uicontextmenu');

hold = findobj(hc, 'Label', 'What''s This?');
set(hold, 'Separator', 'On');

hEdit = findobj(hFig, 'Type', 'Uimenu', 'Tag', 'edit');
hHelp = findobj(hFig, 'Type', 'Uimenu', 'tag', 'help');

hm = [];

for i = 1:4,
    hm(end+1) = uimenu(hEdit, ...
        'Label', lbls{i}, ...
        'Callback', mcbs{i}, ...
        'Tag', tags{i}, ...
        'Enable', enab{i}, ...
        'Position', 2+i, ...
        'Separator', seps{i});
end

hm(end+1) = uimenu(hHelp, ...
    'Label', lbls{end}, ...
    'Callback', mcbs{end}, ...
    'Tag', tags{end}, ...
    'Enable', enab{end}, ...
    'Position', 3, ...
    'Separator', 'On');

seps{1} = 'Off';

for i = 1:length(lbls),
    hm(end+1) = uimenu(hc, ...
        'Label', lbls{i}, ...
        'Callback', mcbs{i}, ...
        'Tag', tags{i}, ...
        'Enable', enab{i}, ...
        'Separator', seps{i}, ...
        'Position', i);
end

setappdata(hFDA, 'ConvertMenuHandles', hm);

% Install the FVTool
% function fdatool_fvtool(hFDA)

% Instantiate FVTool
hFVT = siggui.fvtool;

% Render FVTool
render(hFVT, hFig, [sz.fx2 sz.fy1 sz.fw2 sz.fh1]);

% Add plugins to FVTool
addplugins(hFVT);

h = get(hFVT, 'Handles');

hm = convert2vector(h.menu.analyses);
ht = convert2vector(h.toolbar.analyses);

for indx = 1:length(hm)
    setappdata(hm(indx), 'OldCallback', get(hm(indx), 'Callback'));
    setappdata(ht(indx), 'OldCallback', get(ht(indx), 'ClickedCallback'));
end
set(hm, 'Callback', {@fvtool_cb, hFVT, hFDA});
set(ht, 'ClickedCallback', {@fvtool_cb, hFVT, hFDA});

% Add the full view analysis menu item
% function addfullview(hFDA)

h = [];

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
    'Label', xlate('&Print To Figure'),...
    'Callback', cbs.fullviewanalysis_cb, ...
    'Tag', 'printtofigure', ...
    'Enable', 'On');

sigsetappdata(hFDA, 'fvtool', 'fullviewmenu', h);

% set(hFVT,'Visible','On');

% Add FVTool as a component of FDATool
% addcomponent(hFDA, hFVT);
addcomponent(hFDA, [hSB, hFVT, hCFI]);

% setopts.source    = 'Designed';
% setopts.filedirty = 0;
% setopts.fs        = 48000;
% reffilt = defaultfilter(hFDA);
% hFDA.setfilter(reffilt,setopts);

% Listen to the FilterUpdated and the NewAnalysis events of FDATool
addlistener(hFDA, 'FilterUpdated', {@filterupdated_eventcb, hCFI, hFVT}); %local_filter_listener, hFVT);
addlistener(hFDA, 'FastFilterUpdated', {@fastfilterupdated_eventcb, hCFI, hFVT}); %fast_local_filter_listener, hFVT);
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

status(hFDA, 'Initializing Filter Design and Analysis Tool .....');

% Add FDATool plugins.
addplugins(hFDA, 'fdaregister', 'fdatool');
status(hFDA, 'Initializing Filter Design and Analysis Tool ......');

% Render the "What's This?" help toolbar button after all plug-ins
% and components are rendered (because we cannot add toolbar buttons
% at any position).
hcshelpbtn = render_cshelpbtn(hFig);

% Set figure's position according to screen resol. etc., set default
% uicontrol background color, and make it visible.
status(hFDA, 'Initializing Filter Design and Analysis Tool ...... done');

set(hFDA.FigureHandle, ...
    'CloseRequestFcn', cbs.exit_cb, ...
    'Pointer', 'Arrow', ...
    'Resize', 'On', ...
    'tag','FilterDesigner');

% set(hFDA.FigureHandle, 'Visible', 'Off');

h = get(hFDA, 'Handles');

% 
%   Add the filtermanager to the CFI
%

pos = [sz.fx1+sz.hfus sz.fy1+sz.vfus sz.fw1-2*sz.hfus sz.uh];

% Enable this when a filter is saved.
h.recallfilter = uicontrol(hFig, ...
    'Visible', 'Off', ...
    'Style', 'Pushbutton', ...
    'Tag', 'addfilter', ...
    'String', 'Filter Manager ...', ...
    'Callback', {cbs.method, hFDA, 'filtermanager', [], 'recall'}, ...
    'Position', pos);

pos(2) = pos(2)+sz.uh+sz.vfus;

h.savefilter = uicontrol(hFig, ...
    'Visible', 'Off', ...
    'Style', 'Pushbutton', ...
    'Tag', 'addfilter', ...
    'String', 'Store Filter ...', ...
    'Callback', {cbs.method, hFDA, 'filtermanager', [], 'save'}, ...
    'Position', pos);

% pos(1) = pos(1)+pos(3)+sz.uuvs;

% h.savefilteras = uicontrol(hFig, ...
%     'Visible', 'Off', ...
%     'Style', 'Pushbutton', ...
%     'Tag', 'addfilter', ...
%     'String', 'Save as ...', ...
%     'Enable', 'Off', ...
%     'Callback', {cbs.method, hFDA, 'filtermanager', [], 'saveas'}, ...
%     'Position', pos);

set(hFDA, 'Handles', h);

set([h.recallfilter h.savefilter], 'Units', 'Normalized');

uimenu(findobj(h.menus.main, 'Tag', 'help'), ...
    'Label', 'About Plug-ins', ...
    'Callback', @aboutplugins_cb);

set(hFDA,'Visible', opts.visstate);

if nargout >= 1,
    varargout{1}=hFDA;
end

status(hFDA, 'Ready');

%----------------------------------------------------------------------
function currentpanel_listener(hFDA, eventData, hSB)

h = getpanelhandle(hSB, hSB.CurrentPanel);

hsr = get(hFDA, 'Handles');
hsr = hsr.toolbar.staticresponse;

if isprop(h, 'StaticResponse')
    set(h, 'StaticResponse', get(hsr, 'State'));
    set(hsr, 'Enable', 'On');
else
    set(hsr, 'Enable', 'Off', 'State', 'Off');
    send(hFDA, 'DefaultAnalysis', handle.EventData(hFDA, 'DefaultAnalysis'));
end

%----------------------------------------------------------------------
function aboutplugins_cb(hcbo, eventStruct)

plugins = findplugins('fdaregister');
pluginnames = {};
for indx = 1:length(plugins),
    if ~isfield(plugins{indx}, 'licenseavailable') | ...
            plugins{indx}.licenseavailable,
        for jndx = 1:length(plugins{indx}.name)
            pluginnames{end+1} = plugins{indx}.name{jndx};
        end
    end
end

uiwait(msgbox(sprintf('%s\n\n%s', 'Plug-ins installed from: ', ...
    sprintf('%s\n', pluginnames{:})), 'About Plug-ins'));

%----------------------------------------------------------------------
function fvtool_cb(hcbo, eventStruct, hFVT, hFDA)

hFVT.setfilter(getfilter(hFDA, 'wfs'));

fixcallbacks(hFVT);

cb = getappdata(hcbo, 'OldCallback');
feval(cb{1}, hcbo, [], cb{2:end});

%----------------------------------------------------------------------
function fixcallbacks(hFVT)

h  = get(hFVT, 'Handles');
hm = convert2vector(h.menu.analyses);
ht = convert2vector(h.toolbar.analyses);

for indx = 1:length(hm)
    set(hm(indx), 'Callback',        getappdata(hm(indx), 'OldCallback'));
    set(ht(indx), 'ClickedCallback', getappdata(ht(indx), 'OldCallback'));
end

%----------------------------------------------------------------------
function calledbydspblksFlag = iscalledbydspblks
% Set the flag that indicates if the Signal Processing Blockset called FDATool.

calledbydspblksFlag = 0;
stack = dbstack;
for i = 1:length(stack)

    % If 'dspblkdatool.m' exists in the stack then FDATool was called
    % from the DSK Blockset.  Change the calledby flag and the tabexist
    % flag.  We do not change the fdqexists because we still want the
    % methods and analysis tools
    if isequal(stack(i).name,'dspblkfdatool')
        calledbydspblksFlag = 1;
    end
end

% ----------------------------------------------------------------
function setpanel_cb(hcbo, eventStruct, hSB, newpanel)

if nargin == 3, newpanel = get(hcbo, 'Tag'); end
if ischar(newpanel), newpanel = string2index(hSB, newpanel); end

set(hSB, 'CurrentPanel', newpanel);

% -----------------------------------------------------------------------
function fastfilterupdated_eventcb(hFDA, eventData, hCFI, hFVT)

Hd   = getfilter(hFDA, 'wfs');

set(hCFI, ...
    'Order', order(Hd.Filter), ...
    'isStable',isstable(Hd.Filter));

set(hFVT, 'FastUpdate', 'On');

% Get the handle to FDATool and it's filter
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


% -----------------------------------------------------------------------
function filterupdated_eventcb(hFDA, eventData, hCFI, hFVT)
%FILTERUPDATED_EVENTCB

fixcallbacks(hFVT);

updatecfi(hFDA, hCFI);
updatemenus(hFDA);

set(hFVT, 'FastUpdate', 'Off');

% Get the handle to FDATool and it's filter
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


% -------------------------------------------------------------------------
function updatemenus(hFDA)

hm   = getappdata(hFDA, 'ConvertMenuHandles');
filt = getfilter(hFDA);

% Check the structures for those that we support converting to SOS.
if getflags(hFDA,'calledby','dspblks') & ~isa(filt, 'dfilt.df2t') | ...
        ~any(strcmpi(lclgetclass(filt), {'df1','df2','df1t','df2t'})),
    enabState = 'Off';
else
    enabState = 'On';
end

set(findobj(hm, 'tag', 'convert2sos'), 'Enable', enabState);

% If the filter is multisections enable the option
% STRCMP is faster than isa when the object hasnt been instantiated.
if isa(filt, 'dfilt.multisection') || isa(filt, 'dfilt.abstractsos'),
    enabState = 'On';
else,
    enabState = 'Off';
end
set(findobj(hm, 'tag', 'convert2ss'), 'Enable', enabState);

if isa(filt, 'dfilt.abstractsos'),
    enabState = 'On';
else,
    enabState = 'Off';
end
set(findobj(hm, 'tag', 'reordersos'), 'Enable', enabState);


% -------------------------------------------------------------------------
function updatecfi(hFDA, hCFI)

filt = getfilter(hFDA);
nsecs = nsections(filt);
source = get(hFDA, 'FilterMadeBy');
fname = get(filt, 'FilterStructure');

try,
    set(hCFI,'Order',order(filt));
    set(hCFI,'Sections',nsecs);
    set(hCFI,'Source',source);
    set(hCFI,'isStable',isstable(filt));
    set(hCFI,'FilterStructure',fname);
catch
    senderror(hCFI);
end

% -------------------------------------------------------------------------
function showstructure_cb(hcbo, eventStruct, hFDA)

filtobj = getfilter(hFDA);
tag     = fullfile(docroot, 'toolbox', 'signal', [class(filtobj), '.html']);

launchfv(hFDA.FigureHandle, tag, 'FDATool');

% -------------------------------------------------------------------------
function convert2ss(hcbo, eventStruct, hFDA)
%CONVERT2SS Convert to single section

% xxx This code needs to be a method.

filt = getfilter(hFDA);

str = { ...
    '% Get the transfer function values.', ...
    '[b, a] = tf(Hd);', ...
    '', ...
    '% Convert to a singleton filter.'};

[b, a] = tf(filt);

if isa(filt, 'dfilt.abstractsos'),

    fstruct = class(filt);
    filt = feval(str2func(fstruct(1:end-3)), b, a);
    str = { ...
        str{:}, ...
        sprintf('Hd = %s(b, a);', fstruct(1:end-3)), ...
        };
else

    s = filt.Section(1);

    % If they are all fir we cast to the first nonscalar section
    if isfir(filt),
        indx = 2;
        while isscalar(s),
            s = filt.Section(indx);
            indx = indx + 1;
        end
        filt = feval(str2func(class(s)), b/a);
        str = { ...
            str{:}, ...
            sprintf('Hd = %s(b/a);', class(s)), ...
            };
    else

        % If one is not FIR we cast to the first non FIR filter
        indx = 2;
        while isfir(s),
            s = filt.Section(indx);
            indx = indx + 1;
        end
        filt = feval(str2func(class(s)), b, a);
        str = { ...
            str{:}, ...
            sprintf('Hd = %s(b, a);', class(s)), ...
            };
    end
end

startrecording(hFDA, 'Convert to single section');

str = sprintf('%s\n', str{:}); str(end) = [];
opts.mcode = str;
opts.source = 'Converted'; %Since we lose precision we change the "source".

hFDA.setfilter(filt, opts);

stoprecording(hFDA);

% --------------------------------------------------------------------------
function c = lclgetclass(filtobj)

c = class(filtobj);
c = c(7:end);

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

% ----------------------------------------------------------------------
function local_analysis_listener(hFVT, eventData)

hFDA = getfdasessionhandle(hFVT.FigureHandle);
newAnalysis = get(eventData, 'Data');

switch lower(newAnalysis)
    case lower(get(hFVT.CurrentAnalysis, 'Name'))
        set(hFDA.Handles.toolbar.staticresponse, 'State', 'Off');
        hSB = find(hFDA, '-class', 'siggui.sidebar');
        h = getpanelhandle(hSB, hSB.CurrentPanel);
        if isprop(h, 'StaticResponse'),
            set(h, 'StaticResponse', 'Off');
        end
    otherwise
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

getfilter(get(eventData, 'Source'));

if isempty(get(hFVT, 'Analysis')),
    set(hFVT, 'Analysis', 'magnitude');
end

% [EOF] fdatool.m
