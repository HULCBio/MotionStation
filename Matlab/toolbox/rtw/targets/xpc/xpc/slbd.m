function slbd(SL, flag2)
% SLBD Helper function for the xPC Target Simulink Viewer.
%
%   This function should not be called directly.
%
%   See also XPCSIMVIEW

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.11 $ $Date: 2003/04/24 18:23:12 $

if flag2 == 1
  [flag2, warnStr] = connectionOK(SL(1).Name);
end

% build char array of all subsystem names
subsysnames = {};

for i=1:length(SL)
  subsysnames{end + 1} = strrep(SL(i).Name, char(10), ' '); % 10 == '\n'
end
subsysnames=[subsysnames(1) strrep(subsysnames(2:end),[subsysnames{1},'/'],'')];
figColor = get(0, 'DefaultUIControlBackgroundColor');

sl = SL(1);
units = get(0, 'Units');
set(0, 'Units', 'pixels');
scr = get(0,'ScreenSize');
set(0, 'Units', units);
[X,map] = imread(sl.PNG);
[m,  n] = size(X);
hidden = get(0, 'ShowHiddenHandles');
set(0, 'ShowHiddenHandles', 'on');
figH = findobj('Type','Figure','Tag','xPCSLViewFigure');
set(0, 'ShowHiddenHandles', hidden);
if isempty(figH)
  figH = figure('IntegerHandle',    'off',             ...
                'Menubar',          'none',            ...
                'NumberTitle',      'off',             ...
                'Units',            'pixels',          ...
                'Visible',          'off',             ...
                'Tag',              'xPCSLViewFigure', ...
                'Resize',           'off',             ...
                'HandleVisibility', 'Callback',        ...
                'KeyPressFcn',      @keyPressed,       ...
                'Color',            figColor,          ...
                'Position',                            ...
                [(scr(3) - n) / 2, scr(4) - 200 - m, n, m + 30],...
                'CloseRequestFcn',@closeslbd,          ...
                'Resize','On');
  % Position it at top left
else                                  % existing figure; keep origin
  pos = get(figH, 'Position');
  set(figH, 'Position', [pos(1), pos(2) + pos(4) - m, n, m + 30]);
end
delete(get(figH, 'Children'));        % get rid of the axes and old images.

Menh=uimenu('Parent',figH,'label','Help');
uimenu(Menh,'Label','xPC Target Simulink Viewer Help','callback',@helpsimview);

set(0, 'ShowHiddenHandles', hidden);
figDim = get(figH, 'Position');

axH = axes('Parent',   figH,             ...
           'Units',    'pixels',         ...
           'Tag',      'Ax',             ...
           'Position', [0, 0, n, m], ...
           'Visible',  'off',            ...
           'Drawmode', 'Fast',           ...
           'YDir',     'reverse',        ...
           'XLim',     [0.5 n + 0.5],    ...
           'YLim',     [0.5 m + 0.5]);
imH = image('Parent', axH);

activeMenu = uicontextmenu('Parent', figH, 'Callback', @setupUIMenu);
dummyMenu  = uicontextmenu('Parent', figH);
moveUpMenu = uicontextmenu('Parent', figH);
menuItems  = [];
for i = 1 : 10
  menuItems(i) = uimenu('Parent',   dummyMenu,                     ...
                        'Label',    sprintf('Add to Scope %d', i), ...
                        'UserData', i,                             ...
                        'Enable',   'on',                          ...
                        'Callback', @addRemoveSignals);
end
uimenu('Parent',  moveUpMenu,        ...
       'Label',   'Go up one level', ...
       'Tag',     'UpOneLevelMenu',  ...
       'Callback', @gouponelevel);

setappdata(figH, 'MenuData', struct('active', activeMenu, ...
                                    'dummy',  dummyMenu,  ...
                                    'items',  menuItems,  ...
                                    'moveup', moveUpMenu));
set(axH,'UserData', {SL, struct('OldObject', 0, 'CurrPatch', []) , ...
                    subsysnames, 1, imH});
%uistack(statH, 'top');
setappdata(figH, 'Handles', guihandles(figH));
setappdata(figH, 'SystemStack', {SL(1).Name});
drawImage(imH, SL(1).PNG);

set(figH,'WindowButtonMotionFcn', {@xpcslbd_buttonmotion, flag2}, ...
         'WindowButtonDownFcn',   {@xpcslbd_buttondown, flag2},   ...
         'Name',[SL(1).Name ': xPC Target Simulink Viewer'],      ...
         'Renderer', 'zbuffer', ...
         'Visible', 'on');

if ~isempty(warnStr)
  warndlg(warnStr{:});
end
drawnow;
%%%%%%%%%%%%%%%%%%%%%% slbd %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xpcslbd_buttonmotion(figH, eventData, flag2)
handles     = getappdata(figH, 'Handles');
axH         = handles.Ax;
usrdata     = get(axH, 'UserData');
SL          = usrdata{1};
subsysindex = usrdata{4};
sl          = SL(subsysindex);
draw        = usrdata{2};
subsysnames = usrdata{3};
imH         = usrdata{5};
ttiph=findobj(figH,'type','text','tag','sigtooltip');
ttiph1=findobj(figH,'type','text','tag','nosigtooltip');

index = getMouseIndex(axH, sl.Object.DrawPosition);
if draw.OldObject ~= index
  if draw.OldObject ~= 0
    try
      delete(draw.CurrPatch);
      delete(ttiph);
      delete(ttiph1);
    end
    draw.CurrPatch = [];
  end
  draw.OldObject = index;
  if index ~= 0
    draw.CurrPatch = [];
    cluster = sl.Object(index).ObjectCluster;
    drawpos = cat(1,sl.Object.DrawPosition);
    for i = 1:length(cluster)
      tmp = drawpos(cluster(i),:);

      if strcmp(sl.Object(cluster(i)).ObjectType,'nLine')
        draw.CurrPatch(i) = patch([tmp(1),tmp(3)], ...
                                  [tmp(2),tmp(4)], 'b','parent',axH);
        set(draw.CurrPatch(i), 'EraseMode', 'normal', ...
                          'EdgeColor','b','FaceColor','none', ...
                          'LineWidth', 2);
      elseif  strcmp(sl.Object(cluster(i)).ObjectType,'Block')
        draw.CurrPatch(i) = ...
            patch([tmp(1), tmp(3) + 2, tmp(3) + 2, tmp(1)    ], ...
                  [tmp(2), tmp(2),     tmp(4) + 2, tmp(4) + 2], ...
                  'b', 'parent',axH);
        if strcmp(sl.Object(cluster(i)).ObjectTypeInfo,'SubSystem')
          set(draw.CurrPatch(i), 'EraseMode','normal', ...
                            'EdgeColor','black','FaceColor','none',...
                            'LineWidth', 2);
        elseif (isempty(strmatch(sl.Object(cluster(i)).Name,SL(1).xpcparam.blockname,'exact')))
          set(draw.CurrPatch(i), 'EraseMode','normal', ...
                            'EdgeColor','r','FaceColor','none',...
                            'LineWidth', 2);
        else
          set(draw.CurrPatch(i), 'EraseMode','normal', ...
                            'EdgeColor','b','FaceColor','none',...
                            'LineWidth', 2);
        end
      else % object is of type linexy
        draw.CurrPatch(i) = ...
            patch([tmp(1), tmp(3) + 2, tmp(3) + 2, tmp(1)    ], ...
                  [tmp(2), tmp(2),     tmp(4) + 2, tmp(4) + 2], ...
                  'b', 'parent',axH);
        set(draw.CurrPatch(i), 'EraseMode','normal', ...
                          'EdgeColor','b','FaceColor','none',...
                          'LineWidth', 2);
      end
    end
    draw.OldObject = cluster;
  end
end

% check if it is a signal
if draw.OldObject ~= 0
  if ~strcmp(sl.Object(draw.OldObject(1)).ObjectType,'Block')
    % it's not a block, so has to be a signal
    idx = draw.OldObject(1);
    name= sl.Object(idx).Name;
    % replace \n by ' '
    name(find(name==10))=32;
    id = 0;
    if flag2 == 1
      tmpName = name;
      if sl.Object(idx).sigtwidth > 1
        tmpName(end + 1 : end + 3) = '/s1';
      end
      id = xpcgate('getsignalid', tmpName,SL(1).Name);
      tmpName = name;
      if ~isempty(id)
        tmpName(tmpName == ' ') = '_';
        if sl.Object(idx).sigtwidth == 1
          string = sprintf('%g', xpcgate('getmonsignals',id));
        else
          string = sprintf('[Width %d]', sl.Object(idx).sigtwidth);
        end
        %---signal tooltip---------
        sigtipstr=[tmpName,': ',string];
        mspt=get(figH,'CurrentPoint');
        ttiph=findobj(figH,'type','text','tag','sigtooltip');
        if isempty(ttiph)
          pms=get(figH,'CurrentPoint');
          tooltiph=text(mspt(1)+5,mspt(2)+5,' ','Parent',axH);
          set(tooltiph,'visible','off',...
                       'tag','sigtooltip',...
                       'backgroundcolor', [1 1 0.933333],...
                       'EdgeColor',[0.8 0.8 0.8],...
                       'Editing','off',...
                       'Interpreter','none');
        else
          set(ttiph,'visible','on','units','pixels',...
                    'Position',[mspt(1)+5 mspt(2)+5],...
                    'string',sigtipstr);
        end
        scopes = sort(xpcgate('getscopes'));
        scType = xpcgate('getsctype', scopes);
        menu   = getappdata(figH, 'MenuData');

        set(menu.items,         'Parent', menu.dummy);
        set(menu.items(scopes), 'Parent', menu.active);
        set(menu.active, 'UserData', ...
                         struct('SignalWidth', sl.Object(idx).sigtwidth, ...
                                'SignalId',    id,                       ...
                                'SignalName',  name,                     ...
                                'ScopeList',   scopes,                   ...
                                'ScopeType',   scType));
        set(draw.CurrPatch, 'uicontextmenu', menu.active);
      else
        mspt=get(figH,'CurrentPoint');
        ttiph=findobj(figH,'type','text','tag','nosigtooltip');
        if isempty(ttiph)
          pms=get(figH,'CurrentPoint');
          tooltiph=text(mspt(1)+5,mspt(2)+5,' ','Parent',axH);
          set(tooltiph,'visible','off',...
                       'tag','nosigtooltip',...
                       'backgroundcolor', [1 1 0.933333],...
                       'EdgeColor',[0.8 0.8 0.8],...
                       'Editing','off',...
                       'Interpreter','none');
        else
          set(ttiph,'visible','on','units','pixels',...
                    'Position',[mspt(1)+5 mspt(2)+5],...
                    'string','Signal cannot be monitored or added to scopes');
        end
        set(draw.CurrPatch, 'EdgeColor', 'r');
      end
    end
  end
end
usrdata{2}=draw;
usrdata{4}= subsysindex;
set(axH,'UserData',usrdata);
%%%%%%%%%%%%%%%%%%%%%% xpcslbd_buttonmotion %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xpcslbd_buttondown(figH, eventData, flag2)
handles     = getappdata(figH, 'Handles');
axH         = handles.Ax;
usrdata     = get(axH,'UserData');
SL          = usrdata{1};
subsysindex = usrdata{4};
sl          = SL(subsysindex);
draw        = usrdata{2};
subsysnames = usrdata{3};
imH         = usrdata{5};
stack       = getappdata(figH, 'SystemStack');

index = getMouseIndex(axH, sl.Object.DrawPosition);

% check if it is a subsystem
if index > 0
  index1 = strmatch(sl.Object(index).Name,subsysnames,'exact');
  if ~isempty(index1) % subsystem selected
    delete(draw.CurrPatch);
    draw.CurrPatch = [];
    stack{end + 1} = subsysnames{index1};
    setappdata(figH, 'SystemStack', stack);
    drawImage(imH, SL(index1).PNG);
    draw.OldObject = 0;
    subsysindex = index1;
    menus = getappdata(figH, 'MenuData');
    set(imH, 'UIContextMenu', menus.moveup);
  end
else
end

% check if it is a block
if draw.OldObject~=0
  if strcmp(sl.Object(draw.OldObject(1)).ObjectType,'Block')
    blockInfo.BlockName = sl.Object(draw.OldObject(1)).Name;
    blockInfo.BlockType = sl.BlockType{draw.OldObject(1)};
    blockInfo.Dialog    = sl.DialogParameters{draw.OldObject(1)};
    blockInfo.isSrc     = sl.Object(draw.OldObject(1)).isSrc;
    xpctuneptdlg(blockInfo,flag2, SL(1).xpcparam, figH);
  end
end

usrdata{2}=draw;
usrdata{4}= subsysindex;
set(axH,'UserData',usrdata);
%%%%%%%%%%%%%%%%%%%%%% xpcslbd_buttondown %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function addRemoveSignals(h, eventdata)
contMenu  = get(h, 'Parent');
scId      = get(h, 'UserData');
menuData  = get(contMenu, 'UserData');
scopes    = menuData.ScopeList;

menuData.PopupItems = {};
for i = 1 : length(scopes)
  menuData.PopupItems{end + 1} = sprintf('Scope %d', scopes(i));
end
scSelFigH    = xpcscopeselect('create', 'Data', menuData);
scSelHandles = guidata(scSelFigH);
scSelCb      = getappdata(scSelFigH, 'Callbacks');
scSelPopup   = scSelHandles.xPCScopeSelPopup;

idx = find(scId == menuData.ScopeList);
set(scSelPopup, 'Value', idx);
% execute the popup callback
feval(scSelCb.xPCScopeSelPopup, scSelPopup, [], scSelHandles);

if menuData.SignalWidth == 1
  set(scSelFigH, 'Visible', 'off');
  feval(scSelCb.xPCScopeSelButton, scSelHandles.xPCScopeSelButton, ...
        [], scSelHandles);
else
  set(scSelFigH, 'Visible', 'on');
end

%%%%%%%%%%%%%%%%%%%%%% addRemoveSignals %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function setupUIMenu(h, eventdata)
ud       = get(h, 'UserData');
menuH    = get(h, 'Children')';
sigId    = ud.SignalId;
sigWidth = ud.SignalWidth;

for m = menuH
  scId = get(m, 'UserData');
  if sigWidth > 1
    set(m, 'Label', sprintf('Scope %d: add/remove', scId));
  else
    scSigs  = xpcgate('getscsignals', scId);
    if ismember(sigId, scSigs)
      string = sprintf('Remove from scope %d', scId);
    else
      string = sprintf('Add to scope %d', scId);
    end
    set(m, 'Label', string);
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%% setupUIMenu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function keyPressed(figH, eventdata)
stack = getappdata(figH, 'SystemStack');
if length(stack) > 1 & get(figH, 'CurrentCharacter') == 27
  h = getappdata(figH, 'Handles');
  gouponelevel(h.UpOneLevelMenu, []);
end
%%%%%%%%%%%%%%%%%%%%%%%% keyPressed %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function drawImage(imH, fName)
[X, map] = imread(fName);
[m, n]   = size(X);
axH      = get(imH, 'Parent');
figH     = get(axH, 'Parent');
uData    = get(axH, 'UserData');
draw     = uData{2};
stack    = getappdata(figH, 'SystemStack');

set(figH, 'Name',     [stack{end} ': xPC Target Simulink Viewer']);
set(axH,  'UserData', uData);
set(imH,  'CData',    X, 'XData', [1, n], 'YData', [1, m]);
colormap(axH, map);
set(axH, 'XLim',     [0.5, n + 0.5], ...
         'YLim',     [0.5, m + 0.5], ...
         'Position', [0, 0, n, m]);

pos = get(figH, 'Position');
offset = pos(4) - (m + 30);
set(figH, 'Position', [pos(1), pos(2) + offset, n, m + 30]);
h = getappdata(figH, 'Handles');
%moveElements([h.SignalLabel, h.SignalValue, h.StatusText], 0, - offset);
%%%%%%%%%%%%%%%%%%%%% drawImage %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function gouponelevel(h, eventdata)
figH    = get(get(h, 'Parent'), 'Parent');
handles = getappdata(figH, 'Handles');
axH     = handles.Ax;
ud      = get(axH, 'UserData');
SL      = ud{1};
draw    = ud{2};
subsys  = ud{3};
imH     = ud{5};

stack   = getappdata(figH, 'SystemStack');

if length(stack) > 1
  stack(end) = [];
  setappdata(figH, 'SystemStack', stack);
  index = strmatch(stack{end}, subsys, 'exact');
  drawImage(imH, SL(index).PNG);
  if ~isempty(draw.CurrPatch)
    delete(draw.CurrPatch);
    draw.CurrPatch = [];
    draw.OldObject = 0;
    ud{2} = draw;
  end
  ud{4} = index;
  set(axH, 'UserData', ud);
  if length(stack) == 1
    set(imH, 'UIContextMenu', []);
  end
end

%%%%%%%%%%%%%%%%%%% gouponelevel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function index = getMouseIndex(varargin)
extra   = 1;                            % extra pixels to look at

axH     = varargin{1};
mPos    = get(axH, 'CurrentPoint');
posList = cat(1, varargin{2:end});
if ~isempty(posList)
  index = find(mPos(1,1) >= (posList(:, 1) - extra) & ...
               mPos(1,1) <= (posList(:, 3) + extra) & ...
               mPos(1,2) >= (posList(:, 2) - extra) & ...
               mPos(1,2) <= (posList(:, 4) + extra));
else
  index =[];
end
if isempty(index)
  index = 0;
end
index = index(1);
%%%%%%%%%%%%%%%%%% getMouseIndex %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function moveElements(handles, xoff, yoff, units)
for h = handles
  if nargin == 4,
    oldUnits = get(h, 'Units');
    set(h, 'Units', units);
  end
  set(h, 'Position', get(h, 'Position') + [xoff, yoff, 0, 0]);
  if nargin == 4
    set(h, 'Units', oldUnits);
  end
end
%%%%%%%%%%%%%%%%%% moveElements %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [flag, warnStr] = connectionOK(name)
flag = 1;
try
  connect = strcmp(xpctargetping, 'success');
catch
  connect = 0;
end
modelOk = 0;
if connect
  tgMdlname = xpcgate('getname');
  modelOk = strcmp(tgMdlname, name);
end
if ~connect
  warnStr = {{['Unable to connect to target. Please check if the'],   ...
              ['xPC Target environment settings are correct.']},      ...
             'Target not connected', 'modal'};
elseif ~modelOk % not the correct model
  warnStr = {{['The model loaded on the target is ', tgMdlname],      ...
              ['while the signal viewer is for ', name, '.'],         ...
              ['Connection to the target will not be established.']}, ...
             'Incorrect Model', 'modal'};
else
  warnStr = [];
end
if ~(connect | modelOk)
  flag = 0;
end
%%%%%%%%%%%%%%%%%% connectionOK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function helpsimview(h,eventdata)
helpwin xpcsimview
%%%%%%%%%%%%%%%%%% helpsimview %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function closeslbd(h,eventdata)
hidden = get(0, 'ShowHiddenHandles');
set(0, 'ShowHiddenHandles', 'on');
figH = findobj('Type','Figure','Tag','xPCTunedlg');
set(0, 'ShowHiddenHandles', hidden);
if figH
  close(figH)
end
delete(h)

%%%%%%%%%%%%%%%%%% closeslbd %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
