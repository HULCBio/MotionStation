function ret=plotedittoolbar(hfig,varargin)
%PLOTEDITTOOLBAR Annotation toolbar.

%   Copyright 1984-2003 The MathWorks, Inc.

Udata = getUdata(hfig);
r = [];

if nargin==1
    r = plotedittoolbar(hfig,'show');
    arg = '';
elseif nargin==2
    arg = lower(varargin{1});
    if ~strcmp(arg, 'init') && isempty(Udata)
        r = plotedittoolbar(hfig,'init');
        Udata = getUdata(hfig);
    end
elseif nargin==3
    arg = 'settoggprop';
elseif nargin==4
    arg = 'set';
else
    return;
end
emptyUdata = isempty(Udata);
switch arg
    case 'init'
        stb = findall(hfig, 'tag', 'PlotEditToolBar');
        if isempty(stb)
            r = createToolbar(hfig);
        end
        initUdata(hfig);
        Udata = getUdata(hfig);
        setUdata(hfig,Udata)
    case 'show'
        set(Udata.mainToolbarHandle, 'visible', 'on');
    case 'hide'
        set(Udata.mainToolbarHandle, 'visible', 'off');
    case 'toggle'
        if emptyUdata
            plotedittoolbar(hfig,'init');
        else
            h = Udata.mainToolbarHandle;
            val = get(h,'visible');
            if strcmpi(val,'off')
                set(h,'visible','on');
            else
                set(h,'visible','off');
            end
        end
    case 'getvisible'
        if isempty(Udata)
            r = 0;
        else
            h = Udata.mainToolbarHandle;
            r = strcmp(get(h, 'visible'), 'on');
        end
    case 'close'
        if ishandle(Udata.mainToolbarHandle) 
            delete(Udata.mainToolbarHandle); 
        end
        setUdata(hfig,[]);
    case 'settoggprop'
        if isnumeric(varargin{2}) || ...
                (ischar(varargin{2}) && ...
                (strcmpi(varargin{2},'none') || ...
                strcmpi(varargin{2},'auto') || ...
                strcmpi(varargin{2},'flat') || ...
                strcmpi(varargin{2},'interp')))
            % set cdata
            setColortoggleCdata(hfig,varargin{1},varargin{2})
        elseif ischar(varargin{2})
            % set tooltip
            setToggleTooltip(hfig,varargin{1},varargin{2})
        end
    case 'set'
        % ploteditToolbar(item,prop,onoff);
        setToolbarItemProperties(hfig,varargin{:})
    otherwise
        processItem(hfig,arg);
end

if nargout>0
    ret = r;
end
%--------------------------------------------------------------%
function h=createToolbar(hfig)

% if no scribeaxes for this figure create one.
scribeax = getappdata(hfig,'Scribe_ScribeOverlay');
if isempty(scribeax) || ~ishandle(scribeax)
    scribeax = scribe.scribeaxes(hfig);
end
scribeax = handle(scribeax);

h = uitoolbar(hfig, 'HandleVisibility','off');
Udata.mainToolbarHandle = h;
mlroot = matlabroot;
iconroot = [mlroot '/toolbox/matlab/icons/'];
uicprops.Parent = h;
uicprops.HandleVisibility = 'off';

utogg = [];

% Face Color
uicprops.ClickedCallback = '';
uicprops.OnCallback = 'plotedit({''plotedittoolbar'',gcbf,''facecolor''})';
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Face Color';
uicprops.Tag = 'figToolScribeFaceColor';
uicprops.CData = loadgif([iconroot 'tool_facecolor.gif']);
utogg(end+1) = uitoggletool(uicprops);

% Edge/Line Color
uicprops.ClickedCallback = '';
uicprops.OnCallback = 'plotedit({''plotedittoolbar'',gcbf,''edgecolor''})';
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Edge Color';
uicprops.Tag = 'figToolScribeEdgeColor';
uicprops.CData = loadgif([iconroot 'tool_edgecolor.gif']);
utogg(end+1) = uitoggletool(uicprops);

% Text Color
uicprops.ClickedCallback = '';
uicprops.OnCallback = 'plotedit({''plotedittoolbar'',gcbf,''textcolor''})';
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Text Color';
uicprops.Tag = 'figToolScribeTextColor';
load ([iconroot 'textcolor']);
uicprops.CData = textcolorCData;
utogg(end+1) = uitoggletool(uicprops,'Separator','on');

% Font
uicprops.ClickedCallback = '';
uicprops.OnCallback = 'plotedit({''plotedittoolbar'',gcbf,''textfont''})';
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Font';
uicprops.Tag = 'figToolScribeTextFont';
load ([iconroot 'font']);
uicprops.CData = fontCData;
utogg(end+1) = uitoggletool(uicprops);

% Text Bold
uicprops.ClickedCallback = '';
uicprops.OnCallback = 'plotedit({''plotedittoolbar'',gcbf,''textbold''})';
uicprops.OffCallback = 'plotedit({''plotedittoolbar'',gcbf,''textnobold''})';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Bold';
uicprops.Tag = 'figToolScribeTextBold';
load ([iconroot 'boldfont']);
uicprops.CData = boldfontCData;
utogg(end+1) = uitoggletool(uicprops,'Separator','on');

% Text Italic
uicprops.ClickedCallback = '';
uicprops.OnCallback = 'plotedit({''plotedittoolbar'',gcbf,''textitalic''})';
uicprops.OffCallback = 'plotedit({''plotedittoolbar'',gcbf,''textnoitalic''})';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Italic';
uicprops.Tag = 'figToolScribeTextItalic';
load ([iconroot 'italicfont']);
uicprops.CData = italicfontCData;
utogg(end+1) = uitoggletool(uicprops);

% Left Align
uicprops.ClickedCallback = '';
uicprops.OnCallback = 'plotedit({''plotedittoolbar'',gcbf,''textleft''})';
uicprops.OffCallback = 'plotedit({''plotedittoolbar'',gcbf,''textnoleft''})';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Align Left';
uicprops.Tag = 'figToolScribeLeftTextAlign';
load ([iconroot 'lefttextalign']);
uicprops.CData = lefttextalignCData;
utogg(end+1) = uitoggletool(uicprops,'Separator','on');

% Center Align
uicprops.ClickedCallback = '';
uicprops.OnCallback = 'plotedit({''plotedittoolbar'',gcbf,''textcenter''})';
uicprops.OffCallback = 'plotedit({''plotedittoolbar'',gcbf,''textnocenter''})';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Align Center';
uicprops.Tag = 'figToolScribeCenterTextAlign';
load ([iconroot 'centertextalign']);
uicprops.CData = centertextalignCData;
utogg(end+1) = uitoggletool(uicprops);

% Right Align
uicprops.ClickedCallback = '';
uicprops.OnCallback = 'plotedit({''plotedittoolbar'',gcbf,''textright''})';
uicprops.OffCallback = 'plotedit({''plotedittoolbar'',gcbf,''textnoright''})';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Align Right';
uicprops.Tag = 'figToolScribeRightTextAlign';
load ([iconroot 'righttextalign']);
uicprops.CData = righttextalignCData;
utogg(end+1) = uitoggletool(uicprops);

% Standard scribe annotations
u =uitoolfactory(h,'Annotation.InsertLine');
set(u,'Separator','on');
u =uitoolfactory(h,'Annotation.InsertArrow');
u =uitoolfactory(h,'Annotation.InsertDoubleArrow');
u =uitoolfactory(h,'Annotation.InsertTextArrow');
u =uitoolfactory(h,'Annotation.InsertTextbox');
u = uitoolfactory(h,'Annotation.InsertRectangle');
u = uitoolfactory(h,'Annotation.InsertEllipse');
% Standard scribe actions
u = uitoolfactory(h,'Annotation.Pin');
set(u,'Separator','on');
u = uitoolfactory(h,'Annotation.AlignDistribute');

% Save handle arrays
Udata.handles = utogg;

set(Udata.mainToolbarHandle, 'tag', 'PlotEditToolBar', 'visible', 'off','serializable','off');
setUdata(hfig,Udata);

scribeax.methods('update_current_shape_toolbar');

%--------------------------------------------------------------%
function setToolbarItemProperties(hfig,item,prop,onoff)
switch item
    case 'facecolor'
        togg = findall(hfig,'tag','figToolScribeFaceColor');
    case 'edgecolor'
        togg = findall(hfig,'tag','figToolScribeEdgeColor');
    case 'textcolor'
        togg = findall(hfig,'tag','figToolScribeTextColor');
    case 'font'
        togg = findall(hfig,'tag','figToolScribeTextFont');
    case 'bold'
        togg = findall(hfig,'tag','figToolScribeTextBold');
    case 'italic'
        togg = findall(hfig,'tag','figToolScribeTextItalic');
    case 'leftalign'
        togg = findall(hfig,'tag','figToolScribeLeftTextAlign');
    case 'centeralign'
        togg = findall(hfig,'tag','figToolScribeCenterTextAlign');
    case 'rightalign'
        togg = findall(hfig,'tag','figToolScribeRightTextAlign');
    case 'all'
        Udata = getUdata(hfig);
        togg = Udata.handles;
end
set(togg,prop,onoff);

%--------------------------------------------------------------%
function setColortoggleCdata(hfig,item,color)

switch item
    case 'facecolor'
        togg = findall(hfig,'tag','figToolScribeFaceColor');
    case 'edgecolor'
        togg = findall(hfig,'tag','figToolScribeEdgeColor');
    case 'textcolor'
        togg = findall(hfig,'tag','figToolScribeTextColor');
    otherwise
        return;
end

% sets bottom 3 rows to new color
cdata = get(togg,'cdata');
emptycolor = cdata(1,1,:);
if ischar(color)
    for k=1:3
        cdata(15,:,k) = emptycolor(k);
    end
    cdata(14,:,:) = 0;
    cdata(16,:,:) = 0;
    cdata(15,1,:) = 0;
    cdata(15,16,:) = 0;
else
    for k=1:3
        cdata(14:16,:,k) = color(k);
    end
end
set(togg,'cdata',cdata);

%--------------------------------------------------------------%
function setToggleTooltip(hfig,item,tip)

switch item
    case 'facecolor'
        togg = findall(hfig,'tag','figToolScribeFaceColor');
    case 'edgecolor'
        togg = findall(hfig,'tag','figToolScribeEdgeColor');
    case 'textcolor'
        togg = findall(hfig,'tag','figToolScribeTextColor');
    otherwise
        return;
end

set(togg,'tooltip',tip);

%--------------------------------------------------------------%
function processItem(hfig,item)

% if no scribeaxes for this figure create one.
scribeax = getappdata(hfig,'Scribe_ScribeOverlay');
if isempty(scribeax) || ~ishandle(scribeax)
    return;
end
scribeax = handle(scribeax);

switch item
    case 'facecolor'
        color=uisetcolor;
        if ~isequal(color,0)
            scribeax.methods('set_current_object_color',color,'face');
            plotedittoolbar(hfig,'facecolor',color);
        end
        plotedittoolbar(hfig,'facecolor','state','off');
    case 'edgecolor'
        color=uisetcolor;
        if ~isequal(color,0)
            scribeax.methods('set_current_object_color',color,'edge');
            plotedittoolbar(hfig,'edgecolor',color);
        end
        plotedittoolbar(hfig,'edgecolor','state','off');
    case 'textcolor'
        color=uisetcolor;
        if ~isequal(color,0)
            scribeax.methods('set_current_object_color',color,'text');
            plotedittoolbar(hfig,'textcolor',color);
        end
        plotedittoolbar(hfig,'textcolor','state','off');
    case 'textfont'
        font=uisetfont;
        if ~isequal(font,0)
            scribeax.methods('set_current_object_font',font);
        end
        plotedittoolbar(hfig,'font','state','off');
    case 'textbold'
        scribeax.methods('set_current_object_fontweight','bold');
    case 'textnobold'
        scribeax.methods('set_current_object_fontweight','normal');
    case 'textitalic'
        scribeax.methods('set_current_object_fontangle','italic');
    case 'textnoitalic'
        scribeax.methods('set_current_object_fontangle','normal');
    case 'textleft'
        scribeax.methods('set_current_object_text_horizontal_alignment','left');
    case 'textcenter'
        scribeax.methods('set_current_object_text_horizontal_alignment','center');
    case 'textright'
        scribeax.methods('set_current_object_text_horizontal_alignment','right');
end

%-------------------------------------------------------%
function Udata = getUdata(hfig)

uddfig = handle(hfig);

if isprop(uddfig,'PlotEditToolbarHandles')
  Udata = get(uddfig,'PlotEditToolbarHandles');
else
  Udata = [];
end
     
%--------------------------------------------------------------%
function setUdata(hfig,Udata)

uddfig = handle(hfig);
if ~isprop(uddfig,'PlotEditToolbarHandles')
  hprop = schema.prop(uddfig,'PlotEditToolbarHandles','MATLAB array');
  hprop.AccessFlags.Serialize = 'off'; 
  hprop.Visible = 'off'; 
end
set(uddfig, 'PlotEditToolbarHandles', Udata);

%--------------------------------------------------------------%
function initUdata(hfig)

Udata = getUdata(hfig);
setUdata(hfig,Udata);

function cdata = loadgif(filename)
[cdata,map] = imread(filename);
% Set all white (1,1,1) colors to be transparent (nan)
ind = find(map(:,1)+map(:,2)+map(:,3)==3);
map(ind) = nan;
cdata = ind2rgb(cdata,map);
