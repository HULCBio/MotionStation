function varargout = guideopts(varargin)
%GUIDEOPTS Modify or retrieve options from GUIDE fig file.
% OPTIONS = GUIDEOPTS(FIG) return the options struct on fig
% GUIDEOPTS(FIG, OPTIONS) set the options struct on fig
% GUIDEOPTS(FIG, 'edit') display the GUI Options dialog on fig

% Stores a struct in the GUIDE proxy figure's ApplicationData
% under the name 'GUIDEOptions', with the following fields:
%  options.access      = [ 'callback' | 'on' | 'off' | 'custom' ]       (omAccessibility)
%  options.syscolorfig = [ 1 | 0 ]                                      (cbBackground)
%  options.resize      = [ 'none' | 'simple' | 'custom' ]               (omResize)
%  options.mfile       = [ 1 | 0 ]                                      (rbFigOnly,rbFigM)
%  options.callbacks   = [ 1 | 0 ]                                      (cbCallbacks)
%  options.singleton   = [ 1 | 0 ]                                      (cbSingleton)

%   $Revision: 1.23.6.5 $  $Date: 2004/01/15 21:15:23 $
%   Copyright 1984-2003 The MathWorks, Inc.

if nargin == 0
    % Raise existing window, or open new one (only one allowed)
    fig = openfig(mfilename,'reuse','auto');
    movegui(fig,'center')
    
    % Use system color scheme for figure:
    set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
    
    guidata(fig, guihandles(fig));
    
    set(fig,'Visible','on');
    set(fig,'WindowStyle','modal');
    
    varargout{1} = fig;
    
elseif ischar(varargin{1})
    %%
    %% CALL THE CALLBACK SUBFUNCTION:
    %%
    [varargout{1:nargout}] = feval(varargin{:});
elseif ishandle(varargin{1})
    fig = getParentFigure(varargin{1});
    switch nargin
    case 1
        if nargout ==1
            varargout{1} = getOptions(fig);
        elseif nargout ==2
            [varargout{1}, varargout{2}]= getOptionPair(fig);
        end
    case 2
        if isstruct(varargin{2})
            setOptions(fig, varargin{2});
        elseif isequal(varargin{2}, 'edit')
            editOptions(fig);
        else
            error('second input argument must be an options structure or ''edit''');
        end
    otherwise
        error('too many input arguments');
    end
else
    error('Unrecognized input to GUIDEOPTS');
end

function pbHelp_Callback(h, eventdata, handles, varargin)
helpview([docroot '/mapfiles/creating_guis.map'],...
    'configuring_application_options','CSHelpWindow')

function pbOk_Callback(h, eventdata, handles, varargin)
%compare if anything change
needSave=0;
changeFlags.accessibility = 0;
changeFlags.resize = 0;
changeFlags.background = 0;
changeFlags.singleton = 0;
changeFlags.callback = 0;
changeFlags.guimode = 0;
options = getOptions(handles.guideFig);

%accessibility
vals = get(handles.omAccessibility,'userdata');
if (~strcmp(options.accessibility, vals{get(handles.omAccessibility,'value')}))
    needSave=1;
    changeFlags.accessibility = 1;
    options.accessibility = vals{get(handles.omAccessibility,'value')};
end

%resize
vals = get(handles.omResize,'userdata');
if (~strcmp(options.resize, vals{get(handles.omResize,'value')}))
    needSave = 1;
    changeFlags.resize = 1;
    options.resize = vals{get(handles.omResize,'value')};
end

%background
if (options.syscolorfig ~= get(handles.cbBackground,'value'))
    needSave = 1;
    changeFlags.background = 1;
    options.syscolorfig = get(handles.cbBackground,'value');
    if options.syscolorfig
        set(handles.guideFig,...
            'color', get(0, 'defaultuicontrolbackgroundcolor'));
    end
end

%Singleton
if (options.singleton ~= get(handles.cbSingleton,'value'))
    needSave = 1;
    changeFlags.singleton = 1;
    options.singleton = get(handles.cbSingleton,'value');
end

%callback
if (options.callbacks ~= get(handles.cbCallbacks,'value'))
    needSave = 1;
    changeFlags.callback = 1;
    options.callbacks = get(handles.cbCallbacks,'value');
end

%figure and M
if (get(handles.rbFigM,'value') & options.mfile==0)
    needSave = 1;
    changeFlags.guimode = 1;
    options.mfile = 1;
end

%figure only
if (get(handles.rbFigOnly,'value') & options.mfile==1)
    needSave = 1;
    changeFlags.guimode = 1;
    options.mfile = 0;
end

if needSave
    %set layout to dirty    
    layout_ed = getappdata(handles.guideFig, 'GUIDELayoutEditor');
    layout_ed.setDirty(1);

    % this signals SAVE to honor the new properties in options rather
    % than to honor the existing code in the Mfile
    options.override = 1;
    setOptions(handles.guideFig, options);
    
    if changeFlags.resize
    setResizePolicy(handles.guideFig, options.resize);
    end
    if changeFlags.callback
    setCallbackPolicy(handles.guideFig);
    end
    if changeFlags.accessibility
    setAccessibility(handles.guideFig, options.accessibility);
end

    com.mathworks.ide.inspector.Inspector.refreshIfOpen;
end

%close the figure
close(handles.figure1);

function rbFigM_Callback(h, eventdata, handles, varargin)
options = getOptions(handles.guideFig);
set([handles.rbFigOnly handles.rbFigM],{'value'},{0; 1})
enab = [handles.cbSingleton,
        handles.cbCallbacks,
        handles.cbBackground,
       ];
if isempty(options.singleton)
    enab(1) = [];
end
set(enab, 'enable','on');

function rbFigOnly_Callback(h, eventdata, handles, varargin)
set([handles.rbFigOnly handles.rbFigM],{'value'},{1; 0})
set([handles.cbSingleton,
     handles.cbCallbacks,
     handles.cbBackground,
    ], 'enable','off');

function options = getOptions(fig)
options = getappdata(fig, 'GUIDEOptions');

% data for GUIDE internal use:
if ~isfield(options,'active_h'),       options.active_h      = [];                    end
if ~isfield(options,'taginfo'),        options.taginfo       = [];                    end
if ~isfield(options,'override'),       options.override      = 0;                     end
if ~isfield(options,'release'),        options.release       = 12;                    end
% user preferences not related to M-file:
if ~isfield(options,'resize'),         options.resize        = getResizePolicy(fig);  end
if ~isfield(options,'accessibility'),  options.accessibility = getAccessibility(fig); end
% user preferences related to M-file:
if ~isfield(options,'mfile'),          options.mfile         = 1;                     end
if ~isfield(options,'callbacks'),      options.callbacks     = 1;                     end
if ~isfield(options,'singleton'),      options.singleton     = 1;                     end
if ~isfield(options,'syscolorfig'),    options.syscolorfig   = 1;                     end
if ~isfield(options,'blocking'),       options.blocking      = 0;                     end 

% store any updates
options = setOptions(fig, options); 

%---------------------------------------------------------------
function options = setOptions(fig, options)
oldoptions = getappdata(fig, 'GUIDEOptions');
if ~isequal(options, oldoptions)
    % flush out the nans before storing
    names = fieldnames(options);
    for i=1:length(names)
        if isnumeric(options.(names{i})) & isnan(options.(names{i}))
            options.(names{i}) = [];
        end
    end
    
    setappdata(fig, 'GUIDEOptions', options);
    layout_ed = getappdata(fig, 'GUIDELayoutEditor');
    if ~isempty(layout_ed)
        [names, values] = getOptionPair(fig,options);
        layout_ed.setLayoutOptions(names, values);
    end
end

function setCallbackPolicy(fig)
options = getOptions(fig);
if options.mfile & options.callbacks
    guidemfile('chooseAutoCallbacks',findall(fig));
else
    guidemfile('loseAutoCallbacks',findall(fig));
end

function r = getResizePolicy(fig)
%
% 'none', 'simple', or 'custom'
%
if strcmp(get(fig,'resize'),'off')
    r = 'none';
else
    kids = allchild(fig);
    kids = [findobj(kids,'flat','type','uicontrol')
        findobj(kids,'flat','type','axes')];
    u = get(kids,'units');
    if length(strmatch('normalized',u)) == length(kids)
        r = 'simple';
    else
        r = 'custom';
    end
end

function setResizePolicy(fig, r)
switch r
case 'none'
    set(fig,'resize','off');
    kids = guidemfile('findAllChildFromHere',fig);
    set(kids,'units','characters');
case 'simple'
    set(fig,'resize','on');
    kids = guidemfile('findAllChildFromHere',fig);
    set(kids,'units','normalized');
case 'custom'
    set(fig,'resize','on');
    options = getOptions(fig);
    if    options.mfile & ...
            options.callbacks & ...
            isempty(get(fig, 'resizefcn'))
        guidemfile('setAutoCallback',fig,'resizefcn');
    end
    
otherwise
    error(sprintf('unknown resize policy: %s',r))
end

function p = getAccessibility(fig)
%
% 'on', 'off', or 'custom'
%
switch [get(fig, 'integerhandle') get(fig, 'handlevisibility')]
case 'onon'
    p = 'on';
case 'offoff'
    p = 'off';
case 'offcallback'
    p = 'callback';
otherwise
    p = 'custom';
end

function setAccessibility(fig, p)
switch p
case 'on'
    set(fig, 'IntegerHandle', 'on', 'HandleVisibility', 'on');
case 'off'
    set(fig, 'IntegerHandle', 'off', 'HandleVisibility', 'off');
case 'callback'
    set(fig, 'IntegerHandle', 'off', 'HandleVisibility','callback');
end

function editOptions(fig)
% initialize and display the dialog box, and block until it is dismissed
guideFig = fig;
dialogFig = guideopts;
handles = guidata(dialogFig);
handles.guideFig = guideFig;
handles.dialogFig = dialogFig;

options = getOptions(guideFig);
filename = get(guideFig, 'filename');

% Update SINGLETON, SYSCOLOR to correctly reflect what in M-file
if ~isempty(filename)
    mname = [filename(1:end-3) 'm'];
    if exist(mname)
        mopts = guidemfile('getOptions', mname,[],options);
        if isfield(mopts, 'singleton')
            options.singleton = mopts.singleton;
            set(handles.cbSingleton, 'enable','on');
        else
            options.singleton = [];
            set(handles.cbSingleton, 'enable','off');
        end

        if isfield(mopts, 'syscolorfig')
            options.syscolorfig = mopts.syscolorfig;
        end
        setOptions(guideFig, options);
    end
end

set(handles.omResize,...
    'value',...
    strmatch(options.resize, get(handles.omResize,'userdata')));
set(handles.omAccessibility,...
    'value',...
    strmatch(options.accessibility, get(handles.omAccessibility,'userdata')));

if options.mfile
    on = handles.rbFigM;
else
    on = handles.rbFigOnly;
    set([handles.cbSingleton,
         handles.cbCallbacks,
         handles.cbBackground
        ],'enable','off');
end
set(on, 'value', 1);

on = [];
if options.callbacks,   on(end + 1) = handles.cbCallbacks;  end
if options.singleton,   on(end + 1) = handles.cbSingleton;  end
if options.syscolorfig, on(end + 1) = handles.cbBackground; end
set(on, 'value', 1);

guidata(dialogFig, handles);

waitfor(dialogFig);

% --------------------------------------------------------------------
function varargout = pbCancel_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pbCancel.
close(handles.figure1);


% --------------------------------------------------------------------
function [optionnames, optionvalues] = getOptionPair(fig,options_in)
if nargin == 2
    options = options_in;
else
    options = getOptions(fig);
end
optionnames =[];
optionvalues = [];
if ~isempty(options)
    names = fieldnames(options);
    if ~isempty(names)
        index =1;
        for i=1:length(names)
            value = options.(char(names(i)));
            if ~iscell(value) & ~isstruct(value)
                optionnames{index} = names{i};
                optionvalues{index}= value;
                index = index +1;
            end
        end         
    end
end


function fig = getParentFigure(fig)
% if the object is a figure or figure descendent, return the
% figure.  Otherwise return [].
while ~isempty(fig) & ~strcmp('figure', get(fig,'type'))
  fig = get(fig,'parent');
end
