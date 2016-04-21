function varargout = symbol_wiz(varargin),
%
% Stateflow Symbol Wizard
%

%
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.17.2.5 $  $Date: 2004/04/15 01:00:53 $
%
[prevErrMsg, prevErrId] = lasterr;
try,
    switch nargin,
        case 2,
            cmdEvent = varargin{1};
            arg      = varargin{2};
            ss = [];
            if ~isempty(arg),
                ss = broadcast_l(cmdEvent, arg);
            end;
        otherwise,
            bad_args_l;
    end;

catch,
   disp(['Error in symbol_wiz:',lasterr]);
   lasterr(prevErrMsg, prevErrId);
end;
switch nargout,
    case 1, varargout{1} = 0;
end;


%-------------------------------------------------------------------
function ss = broadcast_l(cmdEvent, arg),
%
%
%
    ss = [];

    switch lower(cmdEvent),
        case 'new',
            id = arg;
            ss = constructor_l(id);
        case 'resize',
            ss = arg;
            ss = resize_l(ss);
        case 'add',
            ss = arg;
            ss = add_l(ss);
            if isempty(ss.symbols), return; end;
        case 'checkall',
            ss = arg;
            ss = checkall_l(ss);
        case 'uncheckall',
            ss = arg;
            ss = uncheckall_l(ss);
        case 'checktoggle',
            ss = arg;
            ss = check_toggle_l(ss);
        case 'scopecycle',
            ss = arg;
            ss = scope_cycle_l(ss);
        case 'objtypecycle',
            ss = arg;
            ss = obj_type_cycle_l(ss);
        case 'parentcycle',
            ss = arg;
            ss = parent_cycle_l(ss);
        case 'sortbychecked',
            ss = arg;
            ss = sort_l(ss, 'checked');
        case 'sortbysymbol',
            ss = arg;
            ss = sort_l(ss, 'symbol');
        case 'sortbytype',
            ss = arg;
            ss = sort_l(ss, 'type');
        case 'sortbyscope',
            ss = arg;
            ss = sort_l(ss, 'scope');
        case 'sortbyparent',
            ss = arg;
            ss = sort_l(ss, 'parent');
        case 'bd',
            ss = arg;
            ss = bd_l(ss);
        case 'scroll',
            ss = arg;
            ss = scroll_l(ss);
        case 'delete',
            ss = arg;
            ss = delete_l(ss);
            return;
        case 'hyperlink',
            ss = arg;
            ss = hyperlink_l(ss);
        case 'view',
            id = arg;
            if isempty(sf('get', id, 'machine.id')),
                bad_args_l;
            end;

            symbolWiz = sf('get', id, '.symbolWiz');
            if isequal(0, symbolWiz) | ~ishandle_l(symbolWiz),
               return;
            end;
            ss = get(symbolWiz, 'userdata');
            ss = view_l(ss);
        case 'ok',
            fig = gcbf;
            machineId = arg;
            checkBoxH = findall(fig, 'style','checkbox');

            if ishandle_l(checkBoxH),
                 x = get(checkBoxH, 'value');
                 if x,
                    setpref('Stateflow','hideSymbolWizardAlert', 1);
                 end;
            end;

            set(fig,'visible','off');
            close(fig);
            return;

    otherwise,
    end;

    set(ss.fig, 'userdata', ss);


%-------------------------------------------------------------------
function ss = constructor_l(id),
%
% Construct the Symbol Wizard
%

ISA = isa_l(id);

switch ISA,
    case 'machine',
        ss.chart   = 0;
        ss.machine = id;
    case 'chart',
        ss.chart   = id;
        ss.machine = sf('get', ss.chart, '.machine');
    otherwise,    error('Symbol Wizard Constructor only accepts a valid machine or chart id');
end;

% if the machine is hanging on to an old Symbol Wizard, waste it.
h = sf('get', ss.machine, '.symbolWizard');

if ishandle_l(h),
    figPos = get(h,'pos');
    delete(h);
    sf('set', ss.machine, '.symbolWizard', 0);
end;

ss = collect_unresolved_symbols_l(ss);

ss.activeItemInd = 0;
ss.fig = [];

if isempty(ss.symbols), return; end;

% -----------------------------------------
% Allocate and configure graphics resources
% -----------------------------------------

dataIcon    = sf('Private', 'sf_get_icon_data', 'data');
eventIcon   = sf('Private', 'sf_get_icon_data', 'event');
chartIcon   = sf('Private', 'sf_get_icon_data', 'chart');
machineIcon = sf('Private', 'sf_get_icon_data', 'machine');


ss.backgroundColor = [255 245 225]/255;
ss.eventIcon = set_icon_background_l(eventIcon, ss.backgroundColor*255);
ss.dataIcon  = set_icon_background_l(dataIcon,  ss.backgroundColor*255);

screenUnits = get(0,'units');
set(0,'units','pixel');
screenSize = get(0,'screenSize');
set(0, 'units', 'points');
pPos = get(0,'screenSize');
ss.ppp = screenSize(3)/pPos(3);
set(0, 'units', screenUnits);

W = 323;
H = 390;
X = (screenSize(3)-W)/2;
Y = (screenSize(4)-H)/2;
figPos = [X Y W H];

ss.titleHeight = 20;

defaultBGColor = get(0,'defaultuicontrolbackground');

ss.fig    = figure('Name', 'Stateflow Symbol Wizard' ...
                  ,'NumberTitle','off' ...
                  ,'menubar', 'none' ...
                  ,'toolbar', 'none' ...
                  ,'doublebuff', 'on' ...
                  ,'handlevis', 'off' ...
                  ,'units','pixels' ...
                  ,'deleteFcn', 'sf(''Private'', ''symbol_wiz'', ''DELETE'', get(gcbf, ''userdata''));' ...
                  ,'vis', 'off' ...
                  ,'integerHandle','off' ...
                  ,'color', defaultBGColor ...
                  ,'position', figPos ...
                  );

ss.overlay = axes( ...
    'parent', ss.fig ...
   ,'ydir', 'rev' ...
   ,'units','pixel'...
   ,'xgrid','off' ...
   ,'ygrid', 'off' ....
   ,'xtick', [] ...
   ,'ytick', [] ...
   ,'vis','off'...
   ,'drawmode','fast' ...
   ,'units','normal' ...
   ,'pos',  [0 0 1 1] ...
   ,'xlim', [0 W]...
   ,'ylim', [0 H]....
   );

ss.axes = axes( ...
    'parent', ss.fig ...
   ,'ydir', 'rev' ...
   ,'units','pixel'...
   ,'xgrid','off' ...
   ,'ygrid', 'off' ....
   ,'xtick', [] ...
   ,'ytick', [] ...
   ,'vis','on'...
   ,'drawmode','fast' ...
   ,'xcolor', ss.backgroundColor ...
   ,'ycolor', ss.backgroundColor ...
   ,'xlim',[0 figPos(3)]...
   ,'ylim', [0 figPos(4)]...
   ,'buttondownfcn', 'ss = get(gcbf, ''userdata''); sf(''Private'', ''symbol_wiz'',''BD'', ss);'  ...
   ,'color', ss.backgroundColor ...
   );

ss.lightAntique = [255 250 245]/255;
ss.gray = [.3 .3 .3];
ss.lightGray = [.7 .7 .7];
ss.itemHeight   = 18;
figColor = get(ss.fig, 'color');

ss.columnRect = rectangle('vis','off','facecolor',ss.lightAntique,'edgecolor','none','parent', ss.axes);
ss.titleRect  = rectangle('vis','off' ...
                         ,'facecolor',figColor ...
                         ,'edgecolor','none' ...
                         ,'buttondownfcn', 'ss = get(gcbf, ''userdata''); sf(''Private'', ''symbol_wiz'',''BD'', ss);'  ...
                         ,'parent', ss.axes);
lightFigColor = 1.08*figColor;
lightFigColor(lightFigColor > 1) = 1;

ss.titleSelector = rectangle('vis','off' ...
                         ,'facecolor',lightFigColor ...
                         ,'edgecolor','none' ...
                         ,'buttondownfcn', 'ss = get(gcbf, ''userdata''); sf(''Private'', ''symbol_wiz'',''BD'', ss);'  ...
                         ,'parent', ss.axes);

typeStr = ISA;

if(ss.chart==0)
   name     = sf('get',ss.machine,'machine.name');
else
   name     = sf('FullNameOf',ss.chart,ss.machine,'/');
end

preamble = ['Place a check by the data/events you wish to CREATE in the Stateflow Explorer'];

blurbStr      = sprintf('Unresolved symbols found in: %s (%s)\n%s', name, typeStr, preamble);
ss.blurb = text(0,0, blurbStr ...
               ,'parent', ss.overlay ...
               ,'vis','off' ...
               ,'vert','top' ...
               ,'color', ss.gray ...
...               ,'fontangle','italic' ...
               ,'interp','none');
ss.title.check = text(0,0, '\surd' ...
                     ,'parent', ss.axes ...
                     ,'vis','off' ...
                     ,'vert','middle' ...
                     ,'interp','tex' ...
                     ,'buttondownfcn', 'ss = get(gcbf, ''userdata''); sf(''Private'', ''symbol_wiz'',''SortByChecked'', ss);'  ...
...                  ,'fontweight', 'bold' ...
                     ,'tag',tag_l);
ss.title.type = text(0,0, 'T' ...
                     ,'parent', ss.axes ...
                     ,'vis','off' ...
                     ,'vert','middle' ...
                     ,'interp','tex' ...
                     ,'buttondownfcn', 'ss = get(gcbf, ''userdata''); sf(''Private'', ''symbol_wiz'',''SortByType'', ss);'  ...
                     ,'fontweight', 'bold' ...
                     ,'tag',tag_l);
ss.title.symbol = text(0,0, 'Symbol' ...
                     ,'parent', ss.axes ...
                     ,'vis','off' ...
                     ,'vert','middle' ...
                     ,'interp','none' ...
                     ,'buttondownfcn', 'ss = get(gcbf, ''userdata''); sf(''Private'', ''symbol_wiz'',''SortBySymbol'', ss);'  ...
...                  ,'fontweight', 'bold' ...
                     ,'tag',tag_l);
ss.title.scope  = text(0,0, 'Scope' ...
                     ,'parent', ss.axes ...
                     ,'vis','off' ...
                     ,'vert','middle' ...
                     ,'interp','none' ...
                     ,'buttondownfcn', 'ss = get(gcbf, ''userdata''); sf(''Private'', ''symbol_wiz'',''SortByScope'', ss);'  ...
 ...                    ,'fontweight', 'bold' ...
                     ,'tag',tag_l);
ss.title.parent = text(0,0, 'Proposed Parent', 'parent', ss.axes,'vis','off','vert','middle' ...
                     ,'interp','none' ...
                     ,'buttondownfcn', 'ss = get(gcbf, ''userdata''); sf(''Private'', ''symbol_wiz'',''SortByParent'', ss);'  ...
              ...       , 'fontweight', 'bold' ...
                     , 'tag',tag_l);

ss.swath  = uicontrol('style','text','units','pixel','vis','off', 'parent', ss.fig);
ss.scroll = uicontrol('style','slider','units','pixel','vis','off', 'min', -1, 'max', 0 ...
                    ,'callback', 'ss = get(gcbf, ''userdata''); sf(''Private'', ''symbol_wiz'',''Scroll'', ss);' ...
                    , 'parent', ss.fig);


%
% allocate pens
ss.pens.black.h  = line('color',[ 0   0   0],  'clipping','off', 'vis','off', 'parent', ss.axes);
ss.pens.white.h  = line('color',[ 1   1   1], 'clipping', 'off', 'vis','off', 'parent', ss.axes);
ss.pens.dark.h   = line('color',[.5  .5  .5], 'clipping', 'off', 'vis','off', 'parent', ss.axes);
ss.pens.medium.h = line('color',[.75 .75 .75],'clipping', 'off', 'vis','off', 'parent', ss.axes);
ss.pens.light.h  = line('color',[.9  .9  .9], 'clipping', 'off', 'vis','off', 'parent', ss.axes);

hs = [ss.pens.black.h ss.pens.white.h ss.pens.dark.h ss.pens.medium.h ss.pens.light.h];
set(hs,'buttondownfcn', 'ss = get(gcbf, ''userdata''); sf(''Private'', ''symbol_wiz'',''BD'', ss);');



ss.extObj = text(0,0,'xyz', 'vert','top','horiz','left','vis','off','parent', ss.axes, 'interp','none');

%
% widen the display if necessary --blurbStr contains the path to the parsed obj (good metric).
%
ext = compute_string_extent_l(blurbStr, ss.extObj);
minW = ext(3)/ss.ppp + 25;
if figPos(3) < minW,
    W = min(minW, .8*screenSize(3)); % NEVER go larger than 80% ofthe screen.
    H = 390;
    X = (screenSize(3)-W)/2;
    Y = (screenSize(4)-H)/2;
    figPos = [X Y W H];
    set(ss.fig, 'pos', figPos);
end;


sf('set', ss.machine, '.symbolWizard', ss.fig);

ss.cancelH     = uicontrol('style','push' ...
                          ,'string', 'Cancel' ...
                          ,'callback','close(gcbf);' ...
                          ,'enable','on' ...
                          ,'parent',ss.fig ...
                          );
ss.addH        = uicontrol('style','push' ...
                          ,'string', 'Create' ...
                          ,'enable', 'off' ...
                          ,'callback', 'sf(''Private'', ''symbol_wiz'', ''ADD'', get(gcbf,''userdata''));' ...
                          ,'tooltip', 'Auto CREATES data/event objects in the Stateflow Explorer under the "Proposed Parent"' ...
                          ,'parent',ss.fig ...
                          );
ss.checkAllH   = uicontrol('style','push' ...
                          ,'string', 'CheckAll' ...
                          ,'enable','on' ...
                          ,'callback', 'sf(''Private'', ''symbol_wiz'', ''CHECKALL'', get(gcbf,''userdata''));' ...
                          ,'parent',ss.fig ...
                          );
ss.uncheckAllH = uicontrol('style','push' ...
                          ,'string', 'UnCheckAll' ...
                          ,'enable','on' ...
                          ,'callback', 'sf(''Private'', ''symbol_wiz'', ''UNCHECKALL'', get(gcbf,''userdata''));' ...
                          ,'parent',ss.fig ...
                          );
ss.lastSortOp = 'none';
ss.sorted     = 'not';
ss.startInd   = 1;
ss.endInd     = length(ss.symbols);
ss = compute_row_render_x_offsets_l(ss);
ss = resize_l(ss);

%
% Render (sort'ing renders)
%
ss = sort_l(ss, 'parent');

set(ss.fig, 'userdata', ss);
set(ss.fig, 'resizefcn', 'sf(''Private'', ''symbol_wiz'',''RESIZE'', get(gcbf,''userdata''));');
set(ss.fig, 'userdata', ss);


%-------------------------------------------------------------------
function str = get_parent_name_l(ss, id),
%
%
%
    ISA = isa_l(id);

    switch ISA,
        case 'machine',  str = [sf('get', id,'.name'), ' (machine)'];
        case 'chart',    str = [sf('FullNameOf', id, ss.machine, '.'), ' (chart)'];
        case 'state',    str = [sf('FullNameOf', id, ss.machine, '.'), ' (state)'];
        case 'function', str = [sf('FullNameOf', id, ss.machine, '.'), ' (function)'];
        case 'box',      str = [sf('FullNameOf', id, ss.machine, '.'), ' (box)'];
    end;



%-------------------------------------------------------------------
function ss = collect_unresolved_symbols_l(ss),
%
% collect unresolved symbols for given machine or chart
%
    ss.symbols   = [];

    if(ss.chart==0), charts = sf('get',ss.machine,'machine.charts');
    else             charts = ss.chart;
    end;

    for chart = charts(:).',
        %
        % collect unresolved data symbols
        %
        unData = sf('get', chart, '.unresolved.data');
        for i=1:length(unData),
            parent = unData(i).tentativeParentId;
            unData(i).type        = 'data';

            %
            % Guess a good default scope value for this unresolved symbol.
            %
            % Rule 1) if the symbol is in all caps, it's a constant
            % Rule 2) if it's tentative parent is a function, it's temporary
            % Rule 3) otherwise, it's a local
            %
                   if isequal(unData(i).symbolName, upper(unData(i).symbolName)),
                       unData(i).scope = 'CONSTANT';
                   else,
                switch isa_l(parent),
                    case 'function',  unData(i).scope   = 'TEMPORARY'; % default is temp data in functions
                    otherwise,        unData(i).scope   = 'LOCAL';     % default is locco
                   end;
            end;

            unData(i).parentName  = get_parent_name_l(ss, parent);
            unData(i).parentCache = ss.machine;
            unData(i).checked     = logical(1); % default is checked
            unData(i).checkBoxH   = 0;
            unData(i).iconH       = 0;
            unData(i).nameH       = 0;
            unData(i).scopeH      = 0;
            unData(i).parentH     = 0;
        end;

        %
        % collect unresolved event symbols
        %
        unEvents = sf('get', chart, '.unresolved.events');
        for i=1:length(unEvents),
            unEvents(i).type        = 'event';
            unEvents(i).scope       = 'LOCAL';    % default is locco
            unEvents(i).parentName  = get_parent_name_l(ss, unEvents(i).tentativeParentId);
            unEvents(i).parentCache = ss.machine;
            unEvents(i).checked     = logical(1); % default is checked
            unEvents(i).checkBoxH   = 0;
            unEvents(i).iconH       = 0;
            unEvents(i).nameH       = 0;
            unEvents(i).scopeH      = 0;
            unEvents(i).parentH     = 0;
    end;

        % snuff out empty unitilzed struct arrays before concatination
        if isempty(unEvents), unEvents = []; end;
        if isempty(unData),   unData   = []; end;

        ss.symbols = [ss.symbols unEvents unData];
    end;


%-------------------------------------------------------------------
function ss = render_unresolved_symbols_l(ss),
%
% Render unresolved symbols for given machine.
%

    Y = 4+ss.titleHeight;
    H = ss.itemHeight;

    flush_display_l(ss);

    ss = compute_row_render_x_offsets_l(ss);
    ss = render_framework_l(ss);

    %
    % render each symbol item
    %
    for i=ss.startInd:ss.endInd,
        switch ss.symbols(i).type,
            case 'data',
                icon = ss.dataIcon;
                iconW = 14;
                iconH = 14;
            case 'event',
                icon  = ss.eventIcon;
                iconW = 16;
                iconH = 16;
            otherwise, error('Bad symbol type detected in Symbol Wizard.');
        end;
        ss.symbols(i) = render_item_l(ss.symbols(i), ss.axes, Y, icon, iconW, iconH, ss.rowS, i);
        Y = Y + H;

        ss = symbol_validate_scope_l(ss, i);
    end;



%-------------------------------------------------------------------
function ss = compute_row_render_x_offsets_l(ss),
%
%
%
    buff = 4;
    X=4;
    rowS.checkX = X;
    rowS.iconX  = rowS.checkX + 17;
    rowS.nameX  = rowS.iconX + 22;

    ext = compute_string_extent_l('Symbol', ss.extObj);
    maxNameFieldW = max(10, ext(3));
    for i=1:length(ss.symbols),
        ext = compute_string_extent_l(ss.symbols(i).symbolName, ss.extObj);
        maxNameFieldW = max(maxNameFieldW, ext(3));
    end;

    rowS.scopeX  = rowS.nameX + maxNameFieldW + buff + 10;

    ext = compute_string_extent_l('Temporary', ss.extObj); % temporary is the widest of all allowed scopes
    rowS.parentX = rowS.scopeX + ext(3) + 3*buff;

    ss.rowS = rowS;


%-------------------------------------------------------------------
function ext = compute_string_extent_l(str, h),
%
%
%
    set(h, 'string', str);
    ext = get(h,'ext');



%-------------------------------------------------------------------
function item = render_item_l(item, ax, Y, icon, iconW, iconH, rowS, ind),
%
% Render an item
%

    name     = item.symbolName;
    parent   = item.parentName;
    scope    = lower(item.scope);
    scope(1) = upper(scope(1));
        color = 'black';

    if item.checked, checkStr = '\surd'; else checkStr = '  '; end;
    X = rowS.checkX;

    % kludge misdrawing of check marks
    if ispc
        checkY = Y;
        checkX = X;
    else
        checkY = Y+6;
        checkX = X+2;
    end

    item.checkBoxH = text(checkX, checkY, checkStr ...
    ,'userdata', ind ...
    ,'buttondownfcn', 'ss = get(gcbf, ''userdata''); ss.activeItemInd = get(gcbo, ''userdata''); sf(''Private'', ''symbol_wiz'',''CheckToggle'', ss);'  ...
    ,'parent', ax ...
    ,'interp', 'tex' ...
    ,'vert', 'top' ...
    ,'horiz', 'left' ...
    );

    X = rowS.iconX;
    xd    = [X X+iconW];
    yd    = [Y Y+iconH];
    item.iconH = image('xdata', xd ...
                      ,'ydata', yd ...
                      ,'cdata', icon ...
                      ,'parent', ax ...
                      ,'buttondownfcn', 'ss = get(gcbf, ''userdata''); ss.activeItemInd = get(gcbo, ''userdata''); sf(''Private'', ''symbol_wiz'',''ObjTypeCycle'', ss);'  ...
                      , 'userdata', ind);

    X = rowS.nameX;
    if isequal(name,'default'),
        name = '\default';
    end;
    item.nameH   = text('pos', [X Y 0],   ...
                        'color','blue', ...
    'buttondownfcn', 'ss = get(gcbf, ''userdata''); ss.activeItemInd = get(gcbo, ''userdata''); sf(''Private'', ''symbol_wiz'',''HyperLink'', ss);', ...
                        'string', name,  ...
                        'vert','top', ...
                        'horiz','left', ...
                        'parent', ax,  ...
                        'interp','none', ...
                        'userdata',ind);
    X = rowS.scopeX;
    item.scopeH  = text('pos', [X Y 0] ...
    ,  'string', scope ...
    , 'color', color ...
    ,'buttondownfcn', 'ss = get(gcbf, ''userdata''); ss.activeItemInd = get(gcbo, ''userdata''); sf(''Private'', ''symbol_wiz'',''ScopeCycle'', ss);'  ...
    , 'vert','top','horiz','left','parent', ax,'interp','none', 'userdata', ind);

    X = rowS.parentX;
    item.parentH = text('pos', [X Y 0] ...
    ,'buttondownfcn', 'ss = get(gcbf, ''userdata''); ss.activeItemInd = get(gcbo, ''userdata''); sf(''Private'', ''symbol_wiz'',''ParentCycle'', ss);'  ...
    , 'string', parent,'vert','top','horiz','left','parent', ax,'interp','none', 'userdata', ind);

    set([item.nameH item.scopeH item.parentH item.checkBoxH], 'clipping', 'on', 'vis','on');


%-------------------------------------------------------------------
function icon = set_icon_background_l(icon, color),
%
%
%
    x1 = icon(:,:,1);
    x2 = icon(:,:,2);
    x3 = icon(:,:,3);
    m  = (x2==245);

    x1(m) = color(1);
    x2(m) = color(2);
    x3(m) = color(3);

    icon(:,:,1) = x1;
    icon(:,:,2) = x2;
    icon(:,:,3) = x3;


%-------------------------------------------------------------------
function ss = update_focus_l(ss),
%
% update focus state
%
    cp = get(ss.axes, 'currentpoint');
    x = cp(1);
    y = cp(3);

    if y > 0 & y < ss.titleHeight+2,
        if     x < ss.rowS.iconX,   ss.focus = 'check';
        elseif x < ss.rowS.nameX,   ss.focus = 'type';
        elseif x < ss.rowS.scopeX,  ss.focus = 'symbol';
        elseif x < ss.rowS.parentX, ss.focus = 'scope';
        else                        ss.focus = 'parent';
        end;
    else,
        ss.focus = 'random';
    end;

%-------------------------------------------------------------------
function ss = bd_l(ss),
%
% BD happened over the axes, check for title hits and sort them.
%
    ss = update_focus_l(ss);

    switch ss.focus,
        case 'check',  ss = sort_l(ss, 'checked');
        case 'type',   ss = sort_l(ss, 'type');
        case 'symbol', ss = sort_l(ss, 'symbol');
        case 'scope',  ss = sort_l(ss, 'scope');
        case 'parent', ss = sort_l(ss, 'parent');
        otherwise,  % do nothing.
    end;


%-------------------------------------------------------------------
function ss = resize_l(ss),
%
% Bad arguments error
%
    bottomH = 40;
    buttonW = 70;
    buttonH = 25;
    buff    = 10;
    buffy   = 7;
    miniBuff = 1;
    topH     = 4;

    figPos = get(ss.fig, 'pos');

    X = figPos(1);
    Y = figPos(2);
    W = figPos(3);
    H = figPos(4);

    str = get(ss.blurb, 'str');
    ext = compute_string_extent_l(str, ss.extObj);
    strH = ext(4);

    if H<strH+bottomH+40,
        x = miniBuff;
        y = bottomH;
        w = max(1,W-miniBuff);
        h = max(1, H-bottomH);
        set(ss.blurb, 'vis','off'),
    else,
        x = miniBuff;
        y = strH + topH;
        w = max(1,W-miniBuff);

        set(ss.blurb, 'position', [3 topH 0], 'vis','on');

        h = max(1, H-bottomH-y-topH);
        y = bottomH;
    end;

    set(ss.overlay, 'xlim', [0 W], 'ylim', [0 H]);
    set(ss.axes, 'pos', [x y w h],'xlim', [0 w], 'ylim', [0 h]);
    set(ss.columnRect, 'pos', [0 0 ss.rowS.iconX-4 h]);
    set(ss.titleRect, 'pos', [0 0 w ss.titleHeight]);


    start  = ss.startInd;
    ending = ss.endInd;
    N = length(ss.symbols);
    V = h-ss.titleHeight;   % viewed
    P = ss.itemHeight*N;    % panable
    R = P - V;              % range
    if N > 2 & R > 0 ,
        scrollW = 20;
        scrollX = W-scrollW-2;
        scrollY = bottomH;
        scrollH = h-ss.titleHeight-1;
        L = V/R;                          % large step
        S = ss.itemHeight/R;
        S = min(1, S);                 % small step
        set(ss.swath, 'pos', [scrollX+2 scrollY scrollW scrollH], 'vis','on');
        set(ss.scroll,'pos', [scrollX scrollY scrollW scrollH], 'vis' ,'on'...
          ,'value', -(ss.startInd-1)*ss.itemHeight/P, 'sliderstep', [S L] );
        ss = update_start_end_ind_wrt_scrollbar_l(ss);

    else,
        ss.startInd = 1;
        ss.endInd   = min(V/ss.itemHeight, N);
        set([ss.scroll ss.swath], 'vis','off');
    end;

    w = max(1, W);

    x = w-buff-buttonW;
    y = (bottomH-buttonH)/2;
    w = buttonW;
    h = buttonH;
    set(ss.cancelH, 'pos', [x y w h]);

    x = x - buffy - buttonW;
    set(ss.addH, 'pos', [x y w h]);

    x = buff;
    set(ss.checkAllH, 'pos', [x y w h]);

    x = x + buttonW + buffy;
    set(ss.uncheckAllH, 'pos', [x y w h]);
%    x = x - buffy - buttonW;
%    set(ss.uncheckAllH, 'pos', [x y w h]);

%    x = x - buffy - buttonW;
%    set(ss.checkAllH, 'pos', [x y w h]);

    ss = render_framework_l(ss);
    if ~isequal(start, ss.startInd) | ~isequal(ending, ss.endInd), ss = render_unresolved_symbols_l(ss); end;


%-------------------------------------------------------------------
function ss = render_framework_l(ss),
%
%
%
    ss.pens = pens_flush_l(ss.pens);

    %
    % render blurb outline
    %
    % pens_draw_frame_l(ss.pens, [x y w h]);
    %

    %
    % render framework
    %
    pos = get(ss.axes, 'pos');

    border = [0 0 pos(3) pos(4)];
    ss.pens = pens_draw_bevel_in_l(ss.pens, border);

    %
    % render the field titles
    %

    ty = ss.titleHeight/2;
    x = 2;
    y = 2;
    w = ss.rowS.iconX - x -2;
    h = ss.titleHeight-2;
    ss.pens = pens_draw_bevel_out_l(ss.pens, [x y w h]);

    % kludge misdrawing of check marks
    if ispc
        checkY = ty;
        checkX = x+2;
    else
        checkY = ty+6;
        checkX = x+4;
    end
    set(ss.title.check, 'pos', [checkX checkY 0],'vis','on');

    x = ss.rowS.iconX-2;
    w = ss.rowS.nameX - x - 2;
    ss.pens = pens_draw_bevel_out_l(ss.pens, [x y w h]);
    set(ss.title.type, 'pos', [x+w/3 ty+1 0],'vis','on');

    x = ss.rowS.nameX-2;
    w = ss.rowS.scopeX - x -2;
    ss.pens = pens_draw_bevel_out_l(ss.pens, [x y w h]);
    set(ss.title.symbol, 'pos', [x+2 ty 0],'vis','on');

    x = ss.rowS.scopeX-2;
    w = ss.rowS.parentX - x - 2;
    ss.pens = pens_draw_bevel_out_l(ss.pens, [x y w h]);
    set(ss.title.scope, 'pos', [x+2 ty 0],'vis','on');

    x = ss.rowS.parentX-2;
    w = max(pos(3) - x - 1, 10);
    ss.pens = pens_draw_bevel_out_l(ss.pens, [x y w h]);
    set(ss.title.parent, 'pos', [x+2 ty 0],'vis','on');

    % for i=1:length(ss.tableS.fieldS);
    %    field = ss.tableS.fieldS(i);
    %    fieldRect = [x 2 field.width H];
    %    x = x + field.width;
    %
    %end;

    set([ss.columnRect ss.titleRect], 'vis','on');
    pens_render_l(ss.pens);

   %
   % place sort selector
   %
    switch ss.sorted,
        case 'not',     set(ss.titleSelector, 'vis','off');
        case 'checked',
            x = ss.rowS.checkX-1;
            w = ss.rowS.iconX - x - 2;
            set(ss.titleSelector, 'pos', [x y w h], 'vis','on');
        case 'type',
            x = ss.rowS.iconX-1;
            w = ss.rowS.nameX - x - 2;
            set(ss.titleSelector, 'pos', [x y w h], 'vis','on');
        case 'symbol',
            x = ss.rowS.nameX-1;
            w = ss.rowS.scopeX - x; -2;
            set(ss.titleSelector, 'pos', [x y w h], 'vis','on');
        case 'scope',
            x = ss.rowS.scopeX-1;
            w = ss.rowS.parentX - x - 2;
            set(ss.titleSelector, 'pos', [x y w h], 'vis','on');
        case 'parent',
            x = ss.rowS.parentX-1;
            w = max(pos(3) - x - 2, 10);
            set(ss.titleSelector, 'pos', [x y w h], 'vis','on');
        otherwise,     set(ss.titleSelector, 'vis','off');
    end;

%-------------------------------------------------------------------
function ss = add_l(ss),
%
% add all checked symbols
%

    if isempty(ss.symbols), return; end;

    m = [ss.symbols.checked];

    addableInds = find(m);
    addableSyms = ss.symbols(addableInds);

    for sym = addableSyms(:).',
        switch sym.type
            case 'data',  add_data_l(sym);
            case 'event', add_event_l(sym);
            otherwise, error('bad symbol type!');
       end;
    end;

    % snuff out created symbols
    ss.symbols(m) = [];

    ss = update_create_button_enable_state_l(ss);
    slsfnagctlr('Dismiss');

    %
    % The set of resolved symbols is most likely been changed,
    % refresh the display.
    %
    if ~isempty(ss.symbols), ss = scroll_l(ss);
    else                     ss = delete_l(ss);
    end;

%-------------------------------------------------------------------
function add_data_l(sym),
%
%
%
    parentId = sym.tentativeParentId;
    name = sym.symbolName;
    d = sf('find',sf('DataOf',parentId), 'data.linkNode.parent', parentId, 'data.name', name);
    switch length(d),
        case 0,
            id = sf('Private', 'new_data', parentId, sym.scope);
            sf('set', id, '.name', name);
        otherwise,
            disp(sprintf('Warning: data symbol %s, already exists, not creating.', name));
    end;


%-------------------------------------------------------------------
function add_event_l(sym),
%
%
%
    parentId = sym.tentativeParentId;
    name = sym.symbolName;
    e = sf('find', sf('EventsOf',parentId), 'event.linkNode.parent', parentId, 'event.name', name);
    switch length(e),
        case 0,
            id = sf('Private', 'new_event', parentId, sym.scope);
            sf('set', id, '.name', name);
        otherwise,
            disp(sprintf('Warning: event symbol %s, already exists, not creating.', name));
    end;

%-------------------------------------------------------------------
function tag = tag_l
%
%
%
    tag = 'SYM_WIZ_PERSISTENT';


%-------------------------------------------------------------------
function bad_args_l
%
% Bad arguments error
%
    error('Bad arguments passed to symbol_wiz');

%-------------------------------------------------------------------
function flush_display_l(ss),
%
%
%
   ch = get(ss.axes, 'child');
   ch = findobj(ch,'vis','on');
   t = findobj(ch, 'type','text');
   i = findobj(ch, 'type', 'image');

   deletables = [t; i];

   persistentObjs = findobj(deletables, 'tag', tag_l);
   deletables = vset(deletables, '-', persistentObjs);

delete(deletables);

for i=1:length(ss.symbols),
    ss.symbols(i).checkBoxH = 0;
end;

%-------------------------------------------------------------------
function ss = delete_l(ss),
%
%
%
  set(ss.fig, 'deleteFcn','');

  % if a machine is still referring to you, fix it.
  if sf('ishandle', ss.machine),
     if isequal(sf('get', ss.machine, '.symbolWiz'), ss.fig),
        sf('set', ss.machine, '.symbolWiz', 0);
     end;
  end;

  delete(ss.fig);

  kill_alert_dialog_l;


%-------------------------------------------------------------------
function ss = view_l(ss),
%
%
%

    ss = resize_l(ss);
    ss = uncheckall_l(ss);
    set(ss.fig, 'vis','on');

    if(ispref('Stateflow','hideSymbolWizardAlert'))
        hideAlert = getpref('Stateflow','hideSymbolWizardAlert');
    else
        hideAlert = 0;
    end
    if (~hideAlert),
        ss = alert_dialog_l(ss);
    end;



%-------------------------------------------------------------------
function b = ishandle_l(h),
%
% validate that h is a good handle
%
   if isempty(h) | isequal(h, 0) | ~ishandle(h),
       b = logical(0);
   else
       b = logical(1);
   end;


%-------------------------------------------------------------------
function ss = checkall_l(ss),
%
%
%
    for i=1:length(ss.symbols),
        ss.symbols(i).checked = logical(1);
        h = ss.symbols(i).checkBoxH;
        if ishandle_l(h),
            set(h, 'str', '\surd');
        end;
    end;

    set(ss.addH, 'enable', 'on');


%-------------------------------------------------------------------
function ss = uncheckall_l(ss),
%
%
%
    for i=1:length(ss.symbols),
        ss.symbols(i).checked = logical(0);
        h = ss.symbols(i).checkBoxH;
        if ishandle_l(h),
            set(h, 'str', '  ');
        end;
    end;

    set(ss.addH, 'enable', 'off');



%-------------------------------------------------------------------
function ss = check_toggle_l(ss),
%
%
%
    ind = ss.activeItemInd;

    if (ss.symbols(ind).checked),
        ss.symbols(ind).checked = logical(0);
        h = ss.symbols(ind).checkBoxH;
        if ishandle_l(h),
            set(h, 'str', '  ');
        end;

        ss = update_create_button_enable_state_l(ss);
    else,
        ss.symbols(ind).checked = logical(1);
        h = ss.symbols(ind).checkBoxH;
        if ishandle_l(h)
            set(h, 'str', '\surd');
        end;
        set(ss.addH, 'enable', 'on');
    end;


%-------------------------------------------------------------------
function ss = update_create_button_enable_state_l(ss),
%
%
%
        hasCheckedItem = logical(0);
        for i = 1:length(ss.symbols),
            h = ss.symbols(i).checkBoxH;
            if ~ishandle_l(h) & ~isequal(get(h, 'str'), '  '),
                hasCheckedItem = logical(1);
                break;
            end;
        end;

        if ~hasCheckedItem,
            set(ss.addH, 'enable', 'off');
        else,
            set(ss.addH, 'enable', 'on');
        end;

%-------------------------------------------------------------------
function ss = obj_type_cycle_l(ss),
%
%
%
    ind = ss.activeItemInd;

    switch ss.symbols(ind).type,
        case 'data',
            h = ss.symbols(ind).iconH;
            ss.symbols(ind).type = 'event';
            xd = get(h,'xdata');
            yd = get(h,'ydata');
            xd(2) = xd(1) + 16;
            yd(2) = yd(1) + 16;

            set(h,'cdata', ss.eventIcon, 'xdata', xd, 'ydata', yd);

            ss = event_validate_scope_l(ss, ind);

        case 'event',
            h = ss.symbols(ind).iconH;
            ss.symbols(ind).type = 'data';
            xd = get(h,'xdata');
            yd = get(h,'ydata');
            xd(2) = xd(1) + 14;
            yd(2) = yd(1) + 14;
            set(h,'cdata', ss.dataIcon, 'xdata', xd, 'ydata', yd);

            ss = data_validate_scope_l(ss, ind);
            set(ss.symbols(ind).scopeH, 'color', 'black'); % always set this back to black
        otherwise,
            error ('bad scope value detected');
    end;


%-------------------------------------------------------------------
function ss = scope_cycle_l(ss),
%
%
%
    ind = ss.activeItemInd;

    switch ss.symbols(ind).type,
        case 'data',  ss = data_scope_cycle_l(ss);
        case 'event', ss = event_scope_cycle_l(ss);
        otherwise,    error('bad symbol type');
    end;



%-------------------------------------------------------------------
function ss = hyperlink_l(ss),
%
%
%
    ind = ss.activeItemInd;
    sf('Open', ss.symbols(ind).contextObjectId); % the context object is guaranteed to be graphical!


%-------------------------------------------------------------------
function ss = data_scope_cycle_l(ss),
%
%
%
    ind = ss.activeItemInd;

    if ~isequal(ss.symbols(ind).type, 'data') error ('bad type passed'); end;

    switch isa_l(ss.symbols(ind).tentativeParentId),
        %
        % CHART
        %
        case 'chart',
            switch ss.symbols(ind).scope,
                case 'LOCAL',
                    ss.symbols(ind).scope = 'CONSTANT';
                    set(ss.symbols(ind).scopeH,'str', 'Constant');
                case 'CONSTANT',
                    ss.symbols(ind).scope = 'PARAMETER';
                    set(ss.symbols(ind).scopeH,'str', 'Parameter');
                case 'PARAMETER',
                    ss.symbols(ind).scope = 'INPUT';
                    set(ss.symbols(ind).scopeH,'str', 'Input');
                case 'INPUT',
                    ss.symbols(ind).scope = 'OUTPUT';
                    set(ss.symbols(ind).scopeH,'str', 'Output');
                case 'OUTPUT',
                    ss.symbols(ind).scope = 'LOCAL';
                    set(ss.symbols(ind).scopeH,'str', 'Local');
                otherwise,
                    error ('bad scope value detected');
            end;

        %
        % FUNCTION
        %
        case 'function',
            switch ss.symbols(ind).scope,
                case 'LOCAL',
                    ss.symbols(ind).scope = 'CONSTANT';
                    set(ss.symbols(ind).scopeH,'str', 'Constant');
                case 'CONSTANT',
                    ss.symbols(ind).scope = 'PARAMETER';
                    set(ss.symbols(ind).scopeH,'str', 'Parameter');
                case 'PARAMETER',
                    ss.symbols(ind).scope = 'FUNCTION_INPUT';
                    set(ss.symbols(ind).scopeH,'str', 'Input');
                case 'FUNCTION_INPUT',
                    ss.symbols(ind).scope = 'FUNCTION_OUTPUT';
                    set(ss.symbols(ind).scopeH,'str', 'Output');
                case 'FUNCTION_OUTPUT',
                    ss.symbols(ind).scope = 'TEMPORARY';
                    set(ss.symbols(ind).scopeH,'str', 'Temporary');
                case 'TEMPORARY',
                    ss.symbols(ind).scope = 'LOCAL';
                    set(ss.symbols(ind).scopeH,'str', 'Local');
                otherwise,
                    error ('bad scope value detected');
            end;
        %
        % MACHINE, STATE, BOX
        %
        case {'machine', 'state', 'box'},
        switch ss.symbols(ind).scope,
            case 'LOCAL',
                ss.symbols(ind).scope = 'CONSTANT';
                set(ss.symbols(ind).scopeH,'str', 'Constant');
            case 'CONSTANT',
                ss.symbols(ind).scope = 'PARAMETER';
                set(ss.symbols(ind).scopeH,'str', 'Parameter');
            case 'PARAMETER',
                ss.symbols(ind).scope = 'LOCAL';
                set(ss.symbols(ind).scopeH,'str', 'Local');
            otherwise,
                error ('bad scope value detected');
        end;

        otherwise,
            error('bad parent type for data sybmol');
    end;


function ss = event_scope_cycle_l(ss),
%
%
%
    ind = ss.activeItemInd;

    if ~isequal(ss.symbols(ind).type, 'event') error ('bad type passed'); end;

    switch isa_l(ss.symbols(ind).tentativeParentId),
        %
        % CHART
        %
        case 'chart',
            switch ss.symbols(ind).scope,
                case 'LOCAL',
                    ss.symbols(ind).scope = 'INPUT';
                    set(ss.symbols(ind).scopeH,'str', 'Input');
                case 'INPUT',
                    ss.symbols(ind).scope = 'OUTPUT';
                    set(ss.symbols(ind).scopeH,'str', 'Output');
                case 'OUTPUT',
                    ss.symbols(ind).scope = 'LOCAL';
                    set(ss.symbols(ind).scopeH,'str', 'Local');
                otherwise,
                    error ('bad event scope value detected');
            end;
        otherwise,
            % force local for safety
            ss.symbols(ind).scope = 'LOCAL';
            set(ss.symbols(ind).scopeH,'str', 'Local');
    end;

%-------------------------------------------------------------------
function ss = parent_cycle_l(ss),
%
%
%
    ind = ss.activeItemInd;

    % just one cycle for now.
    tmp = ss.symbols(ind).parentCache;
    ss.symbols(ind).parentCache = ss.symbols(ind).tentativeParentId;
    ss.symbols(ind).tentativeParentId = tmp;

    ss = symbol_validate_scope_l(ss, ind);

    ss.symbols(ind).parentName = get_parent_name_l(ss, ss.symbols(ind).tentativeParentId);
    set(ss.symbols(ind).parentH, 'str', ss.symbols(ind).parentName);


%-------------------------------------------------------------------
function ss = symbol_validate_scope_l(ss, ind),
%
%
%
    switch ss.symbols(ind).type,
        case 'data',  ss = data_validate_scope_l(ss, ind);
        case 'event', ss = event_validate_scope_l(ss, ind);
        otherwise, error('bad symbol type');
    end;

%-------------------------------------------------------------------
function ss = data_validate_scope_l(ss, ind),
        %
        %
        %
    switch isa_l(ss.symbols(ind).tentativeParentId),
        case {'machine', 'state', 'box'},
              switch ss.symbols(ind).scope,
                case {'LOCAL', 'CONSTANT', 'PARAMETER'}, % ALLOWED
                otherwise,
                    ss.symbols(ind).scope = 'LOCAL';
                    set(ss.symbols(ind).scopeH,'str', 'Local');
            end;
        case 'chart',
        switch ss.symbols(ind).scope,
                case {'LOCAL', 'INPUT', 'OUTPUT', 'CONSTANT', 'PARAMETER'}, % ALLOWED
                case 'FUNCTION_INPUT',  ss.symbols(ind).scope = 'INPUT';
                case 'FUNCTION_OUTPUT', ss.symbols(ind).scope = 'OUTPUT';
                otherwise,
                    ss.symbols(ind).scope = 'LOCAL';
                    set(ss.symbols(ind).scopeH,'str', 'Local');
            end;
        case 'function',
              switch ss.symbols(ind).scope,
                case {'LOCAL', 'FUNCTION_INPUT', 'FUNCTION_OUTPUT', 'CONSTANT', 'TEMPORARY', 'PARAMETER'}, % ALLOWED
                case 'INPUT',  ss.symbols(ind).scope = 'FUNCTION_INPUT';
                case 'OUTPUT', ss.symbols(ind).scope = 'FUNCTION_OUTPUT';
                otherwise,
                    ss.symbols(ind).scope = 'TEMPORARY';
                    set(ss.symbols(ind).scopeH,'str', 'Temporary');
            end;
        otherwise, error('bad symbol parent type');
    end;

%-------------------------------------------------------------------
function ss = event_validate_scope_l(ss, ind),
%
%
%
    switch isa_l(ss.symbols(ind).tentativeParentId),
        case {'machine', 'state', 'function', 'box'},
                ss.symbols(ind).scope = 'LOCAL';
            set(ss.symbols(ind).scopeH,'str', 'Local', 'color', ss.lightGray);
        case 'chart',
            switch ss.symbols(ind).scope,
                case {'LOCAL', 'INPUT', 'OUTPUT'}, % ALLOWED
                otherwise,
                    ss.symbols(ind).scope = 'LOCAL';
                set(ss.symbols(ind).scopeH,'str', 'Local');
            end;
            set(ss.symbols(ind).scopeH, 'color', 'black');
        otherwise, error('bad symbol parent type');
    end;

%-------------------------------------------------------------------
function objType = isa_l(id),
%
%
%
    objType = 'unknown';

    ISA     = sf('get', id, '.isa');
    MACHINE = sf('get', 'default', 'machine.isa');
    CHART   = sf('get', 'default', 'chart.isa');
    STATE   = sf('get', 'default', 'state.isa');

    switch ISA,
        case MACHINE, objType = 'machine';
        case CHART,   objType = 'chart';
        case STATE,
            if ~isempty(sf('find', id, 'state.type', 'OR_STATE')) | ~isempty(sf('find', id, 'state.type', 'AND_STATE')),
                objType = 'state';
            elseif ~isempty(sf('find', id, 'state.type', 'FUNC_STATE')),
                objType = 'function';
            elseif ~isempty(sf('find', id, 'state.type', 'GROUP_STATE')),
                objType = 'box';
            end;
            otherwise,
        end;


%-------------------------------------------------------------------
function x = isa_function(id),
%
%
%
    x = logical(0);

    if ~isempty(sf('get', id, 'state.id')) & isequal(sf('get', id, 'state.type'), 2),
        x = logical(1);
    end;


%-------------------------------------------------------------------
function ss = sort_l(ss, sortBy)
%
%
%
    if isequal(length(ss.symbols), 0), return; end;

    allTheSame = logical(0);

    switch sortBy,
        case 'checked', sortee = ~[ss.symbols.checked];
        case 'type',    sortee = {ss.symbols(:).type};
        case 'symbol',  sortee = {ss.symbols(:).symbolName};
        case 'scope',   sortee = {ss.symbols(:).scope};
        case 'parent',  sortee = {ss.symbols(:).parentName};
        otherwise,      bad_args_l;
    end;

   switch sortBy,
        case 'checked', allTheSame = ~any(~sortee);
        otherwise,      allTheSame = all(strcmp(sortee{1}, sortee));
   end;

   if ~allTheSame,
       [y, sorted] = sort(sortee);
       ss.symbols = ss.symbols(sorted);
   end;

   if isequal(sortBy, ss.lastSortOp) & ~allTheSame,
       ss.symbols = fliplr(ss.symbols);
       ss.lastSortOp = 'inverse';
   else,
       ss.lastSortOp = sortBy;
   end;

   ss.sorted = sortBy;

   % refresh display
   ss = render_unresolved_symbols_l(ss);


%-------------------------------------------------------------------
function ss = scroll_l(ss),
%
%
%
    % stop the silly hg slider from flashing focus junk;
    figure(ss.fig);

    startInd = ss.startInd;
    endInd   = ss.endInd;

    ss = update_start_end_ind_wrt_scrollbar_l(ss);

    if ~isequal(startInd, ss.startInd) | ~isequal(endInd, ss.endInd),
        ss = render_unresolved_symbols_l(ss);
    end;



%-------------------------------------------------------------------
function ss = update_start_end_ind_wrt_scrollbar_l(ss),
%
%
%
% compute new ss.startInd based on slider value
    ylim   = get(ss.axes, 'ylim');
    val   = get(ss.scroll,'value');
    N     = length(ss.symbols);
    P     = N*ss.itemHeight;
    V     = ylim(2) - ylim(1) - ss.titleHeight;
    R     = P - V;
    NUM   = V/ss.itemHeight;
    start = ceil(abs(val*R/ss.itemHeight))+1;
    start = max(1, start);
    start = min(N, start);

    ss.startInd = start;
    ss.endInd   = min(start + NUM + 1, length(ss.symbols));

%-------------------------------------------%
% PEN API (wuensch: refactor this code out) %
%-------------------------------------------%

%-------------------------------------------------------------------
function pens = pens_flush_l(pens),
%
%
%
    pens.black.x  = [];
    pens.black.y  = [];

    pens.white.x  = [];
    pens.white.y  = [];

    pens.dark.x   = [];
    pens.dark.y   = [];

    pens.medium.x = [];
    pens.medium.y = [];

    pens.light.x  = [];
    pens.light.y  = [];

    pens.black.xdata  = [];
    pens.black.ydata  = [];

    pens.white.xdata  = [];
    pens.white.ydata  = [];

    pens.dark.xdata   = [];
    pens.dark.ydata   = [];

    pens.medium.xdata = [];
    pens.medium.ydata = [];

    pens.light.xdata  = [];
    pens.light.ydata  = [];

    penHs = [pens.black.h pens.white.h pens.dark.h pens.medium.h pens.light.h];
    set(penHs, 'xdata', [], 'ydata', []);


%-------------------------------------------------------------------
function pens = pens_draw_bevel_in_l(pens, pos),
%
%
%
    x = pos(1);
    y = pos(2);
    w = pos(3);
    h = pos(4);

    pens.dark = pen_move_to_l(pens.dark, [x y+h]);
    pens.dark = pen_line_to_l(pens.dark, [x y]);
    pens.dark = pen_line_to_l(pens.dark, [x+w y]);

    x = x+1;
    y = y+1;
    pens.black = pen_move_to_l(pens.black, [x y+h-2]);
    pens.black = pen_line_to_l(pens.black, [x y]);
    pens.black = pen_line_to_l(pens.black, [x+w-2 y]);

    x = x-1;
    y = y-1;
    pens.light = pen_move_to_l(pens.light, [x+w y]);
    pens.light = pen_line_to_l(pens.light, [x+w y+h]);
    pens.light = pen_line_to_l(pens.light, [x   y+h]);

    x = x+1;
    y = y+1;
    w = w-1;
    h = h-1;
    pens.medium = pen_move_to_l(pens.medium, [x+w y]);
    pens.medium = pen_line_to_l(pens.medium, [x+w y+h]);
    pens.medium = pen_line_to_l(pens.medium, [x   y+h]);


%-------------------------------------------------------------------
function pens = pens_draw_bevel_out_l(pens, pos),
%
%
%
    x = pos(1);
    y = pos(2);
    w = pos(3);
    h = pos(4);

    h = h-1;
    w = w-1;
    pens.light = pen_move_to_l(pens.light, [x   y+h]);
    pens.light = pen_line_to_l(pens.light, [x   y]);
    pens.light = pen_line_to_l(pens.light, [x+w y]);

    h = h+1;
    pens.black = pen_move_to_l(pens.black, [x   y+h]);
    pens.black = pen_line_to_l(pens.black, [x+w y+h]);
    pens.black = pen_line_to_l(pens.black, [x+w y-1]);

    x = x+1;
    h = h-1;
    w = w-2;
    pens.dark = pen_move_to_l(pens.dark, [x   y+h]);
    pens.dark = pen_line_to_l(pens.dark, [x+w y+h]);
    pens.dark = pen_line_to_l(pens.dark, [x+w y]);


%-------------------------------------------------------------------
function pen = pen_move_to_l(pen, xy),
%
%
%
   pen.x = xy(1);
   pen.y = xy(2);

   pen.xdata = [pen.xdata nan];
   pen.ydata = [pen.ydata nan];


%-------------------------------------------------------------------
function pen = pen_line_to_l(pen, xy),
%
%
%
   if isnan(pen.xdata(end)),
    pen.xdata = [pen.xdata pen.x xy(1)];
    pen.ydata = [pen.ydata pen.y xy(2)];
   else,
    pen.xdata = [pen.xdata xy(1)];
    pen.ydata = [pen.ydata xy(2)];
   end;

   pen.x = xy(1);
   pen.y = xy(2);


%-------------------------------------------------------------------
function pens_render_l(pens),
%
%
%
	penHs = [pens.black.h pens.white.h pens.dark.h pens.medium.h pens.light.h];

	props = {'xdata', 'xdata', 'xdata', 'xdata', 'xdata', 'ydata', 'ydata', 'ydata', 'ydata', 'ydata'};
    data = {...
             pens.black.xdata,  ...
             pens.white.xdata,  ...
             pens.dark.xdata,   ...
             pens.medium.xdata, ...
             pens.light.xdata,  ...
             pens.black.ydata,  ...
             pens.white.ydata,  ...
             pens.dark.ydata,   ...
             pens.medium.ydata, ...
             pens.light.ydata
          };

    %
    % vectorized sets --WHY DOESN'T THIS WORK?!
    %
 %   h = penHs;
 %   h = [h,h];
 %   set(h, props, data);
    pen_render_l(pens.black);
    pen_render_l(pens.white);
    pen_render_l(pens.dark);
    pen_render_l(pens.medium);
    pen_render_l(pens.light);

    set(penHs, 'vis','on');


%-------------------------------------------------------------------
function pen_render_l(pen),
%
%
%
    set(pen.h, 'xdata', pen.xdata, 'ydata', pen.ydata);





function ss = alert_dialog_l(ss)


  bgclr = get (0, 'defaultuicontrolbackground');


  dialogTag = 'sf_swizard_alert';
  foundVal = findall (0, 'type', 'figure', 'Tag', dialogTag);
  if (~isempty(foundVal))
    figure(foundVal);     % Force to front
    return;
  end

  boxHandle=figure(                                            ...
                  'Name'            ,'Stateflow Symbol Wizard Alert'     ...
                  ,'Pointer'         ,'arrow'                 ...
                  ,'Units'           ,'points'                ...
                  ,'WindowStyle'     ,'normal'             ...
                  ,'Toolbar'         ,'none'                  ...
                  ,'Tag'             ,dialogTag                      ...
                  , 'menubar'       , 'none' ...
                  , 'numbertitle'   , 'off' ...
                  , 'units'         , 'points' ...
                  , 'visible'       , 'off' ...
                  , 'Color'         , bgclr ...
                  );



    % Before filling in the dialog with "real" stuff, we're going to throw in a few
    % dummy uiwidgets to get a "handle" on the sizing of this thing (nice pun 'eh?)


    % First, let's figure out how big the text box needs to be
    % We decree that the longest item in the list shall not be wrapped!
    % We have also determinined, via ad-hoc empirical testing that, when
    % setting the entire text widget to "just fit" this line, the rest
    % of the text wraps such that we get 16 lines of text.

    % So, we find the width of the line and the height of 16 lines, then
    % Combine 'em to set the total area of the text widget
    longestLine = [9, '1) Review the list in the Symbol Wizard.', 9];
    height = ['a', 10,'a', 10,'a', 10,'a', 10,'a', 10,'a', 10,'a', 10,'a', 10,...
              'a', 10,'a', 10,'a', 10,'a', 10,'a', 10,'a', 10,'a'];

    llui = uicontrol( 'style', 'text', 'parent', boxHandle, 'visible', 'off', 'string', longestLine, 'units', 'points' );
    htui = uicontrol( 'style', 'text', 'parent', boxHandle, 'visible', 'on', 'string', height, 'units', 'points');
    wd = get (llui, 'extent') * 1.4;
    ht = get (htui, 'extent') * 1.1;
    set (htui, 'position', ht);
    textBoxExtent = [0 0 wd(3) ht(4)];



    % Temporarily set figure to be this big (but retain screen position)
    origPos = get(boxHandle, 'position');
    tempPos = [origPos(1:2) textBoxExtent(3:4)];
    set(boxHandle, 'position', tempPos);





    % Now, set up room for image on the side
    ICON_WIDTH = 64;
    set(boxHandle, 'units', 'pixels');
    tempPos = get(boxHandle, 'position');
    tempPos(3) = tempPos(3) + ICON_WIDTH + 20;     % Leave 10 pixels on each side
    set(boxHandle, 'position', tempPos, 'units', 'points');





    % Finally, let's make room for the bottom OK/Cancel buttons
    canui = uicontrol( ...
                  'style', 'pushbutton'         ...
                , 'string', 'Cancel'            ...
                , 'parent', boxHandle           ...
                );
    canExt = get(canui, 'extent');
    buttonExtent = canExt * 1.2;   % Leave 10% space on each side
    buttonPanelHeight = buttonExtent(4) * 1.5;   % Button takes up 2/3 of the height


    % And, now, make room along the bottom for the button panel
    tempPos = get(boxHandle, 'position');
    tempPos(4) = tempPos(4) + 2 * buttonPanelHeight;        % same height for checkbox
    set(boxHandle, 'position', tempPos);



    % Now, get rid of the temporary stuff
    delete(canui);
    delete(llui);
    delete(htui);




    % And, now add the "real" stuff in, in reverse order



    % First, the OK and Cancel buttons

    % Leave only 1/3 button space on right
    % 1/4 button height on bottom
    % Use computed width and height
    cancelButtonLoc = [ ...
        (tempPos(3) - (buttonExtent(3) * 4 / 3))    ...
        (buttonExtent(4) * 0.25)                    ...
        buttonExtent(3:4)                           ...
    ];

% UNCOMMENT HERE AND BELOW TO ADD A CANCEL BUTTON
%    cancelHandle = uicontrol( ...
%                  'style', 'pushbutton'         ...
%                , 'string', 'Cancel'            ...
%                , 'parent', boxHandle           ...
%                , 'units', 'points'             ...
%                , 'position', cancelButtonLoc   ...
%                );


    okButtonLoc = cancelButtonLoc;
% UNCOMMENT FOR CANCEL BUTTON
%    okButtonLoc(1) = cancelButtonLoc(1) - (cancelButtonLoc(3) * 6 / 5);

    okHandle =    uicontrol( ...
                  'style', 'pushbutton'         ...
                , 'string', 'OK'                ...
                , 'parent', boxHandle           ...
                , 'units', 'points'             ...
                , 'callback', ['sf(''Private'', ''symbol_wiz'', ''OK'',',sf_scalar2str(ss.machine),' );']        ...
                , 'position', okButtonLoc       ...
                );



    % Now the icon
    set(okHandle, 'units', 'pixels');
    set(boxHandle, 'units', 'pixels');
    okp = get(okHandle, 'position');
    bxp = get(boxHandle, 'position');
    boundingBox = [     0       ...
        okp(4) * 1.5            ...
        ICON_WIDTH + 20         ...
        bxp(4) - (okp(4) * 1.5) ...
        ];
    iconPos = [  10,                          ...
        boundingBox(2) + (boundingBox(4) - ICON_WIDTH) / 2,   ...
        (ICON_WIDTH +1),                         ...
        (ICON_WIDTH +1)                         ...
        ];


    bigIconData= [...
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 1 1 1 1 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 1 1 1 1 1 1 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 1 1 1 1 1 1 1 1 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 1 1 1 1 1 1 1 1 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2;
    2 2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2 2;
    2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2;
    2 2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2 2;
    2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2;
    2 2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2 2;
    2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2;
    2 2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2 2;
    2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2;
    2 2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2 2;
    2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2;
    2 2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2 2;
    2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2;
    2 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1 2;
    1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1;
    1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 1 1 1 1 1;
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;
    2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2;
    2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2];


    blk = [0 0 0] / 255;
    ylw = [255 255 0] / 255;
    iconCMap = [blk;bgclr;ylw];


    iconAxesHandle = axes(...
                   'units', 'pixels' ...
                 , 'parent', boxHandle ...
                 , 'visible', 'off'...
                 , 'position', iconPos ...
                 , 'ydir', 'reverse' ...
                 , 'xlim', [0.5 ICON_WIDTH+0.5] ...
                 , 'ylim', [0.5 ICON_WIDTH+0.5] ...
                 );

    iconImageHandle = image( ...
                  'cdata', bigIconData   ...
                , 'visible', 'on' ...
                , 'parent', iconAxesHandle ...
                );

    set (boxHandle, 'Colormap', iconCMap);



    % Now, the checkbox
    checkPos = [ boundingBox(3) (okp(4) * 1.5) ...
        (bxp(3) - boundingBox(2)) ...
        (okp(4) * 1.5) ];

    checkStr = 'In the future, don''t show this alert';

    checkHandle = uicontrol( ...
                  'style', 'checkbox'           ...
                , 'string', checkStr            ...
                , 'parent', boxHandle           ...
                , 'position', checkPos  ...
                , 'tag',  'SF_SYM_WIZ_ALERT_TAG' ...
                , 'backgroundColor', bgclr      ...
                );



    % Finally, take care of the main blurb
    blurbPos = [ boundingBox(3) (okp(4) * 3) ...
        (bxp(3) - boundingBox(3)) ...
        (bxp(4) - (okp(4) * 3)) ];


    titleStr = 'Parse errors occured due to unresolved symbols in your diagram(s).';
    blurbStr = [titleStr, 10, 10, ...%, 10, ...
            'These types of errors occur when appropriate data/event objects have not ' ...%,       10, ...
            'been added to the Stateflow Explorer before parsing.  A "best guess" ' ...%,       10, ...
            'has been made for you.  Please do the following:', 10, 10, ...
            9, '1) Review the list in the Symbol Wizard.', 10, ...
            9, '2) Check the items you wish to add.', 10, ...
            9, '3) Click the ''Create'' button.', 10, 10, ...
            'This will automatically create data/event objects in the ', ...
            'Stateflow Explorer which correspond to these unresolved symbols.'
           ];



    blurbHandle = uicontrol(                          ...
                     'position', blurbPos        ...
                    , 'parent', boxHandle                   ...
                    , 'BackGroundColor', bgclr              ...
                    , 'style', 'text'                        ...
                    , 'string', blurbStr                    ...
                    , 'horizontalalign', 'left'             ...
                    );

    screenUnits = 'pixels';
    set(0, 'units', screenUnits);
    screenSize = get(0, 'screensize');
    set (boxHandle, 'units', screenUnits);
    dialogSize = get(boxHandle, 'position');


    % Be smart about where we put this on the screen (next to the symbol wizard

    % Get size of symbol wizard
    set (ss.fig, 'units', screenUnits);
    swSize = get(ss.fig, 'position');
    swSize(3) = 0.8 * (swSize(3));      % Fudge factor.  Shift stuff relatively down the screen

    % Calc position of bounding box around both windows
    bigBoxSize = [0 0 (swSize(3)+dialogSize(3)+10) max(swSize(4),dialogSize(4))];
    bigBoxPos = [...
        ((screenSize(3) - bigBoxSize(3)) / 2) ...
        ((screenSize(4) - bigBoxSize(4)) / 2)  ...
        bigBoxSize(3:4) ...
        ];

    % Recalc positions of each window
    dialogPos = [...
        bigBoxPos(1)  ...
        (bigBoxPos(2) + (bigBoxPos(4) - dialogSize(4))) ...
        dialogSize(3:4) ...
        ];
    swPos = [...
        (bigBoxPos(1) + dialogSize(3) + 10) ...
        (bigBoxPos(2) + (bigBoxPos(4) - swSize(4))) ...
        swSize(3:4) ...
        ];

    % If screen isn't wide enough, then overlap them
    if (screenSize(3) <= bigBoxSize(3))
        dialogPos(1) = 1;
        swPos(1) = screenSize(3) - swSize(3);
    end


    % Reposition and show
    set (boxHandle, 'position', dialogPos);
    set (ss.fig, 'position', swPos);
    set(boxHandle, 'visible', 'on');



function ss = kill_alert_dialog_l(ss)

    dialogTag = 'sf_swizard_alert';
    foundVal = findall (0, 'type', 'figure', 'Tag', dialogTag);
    delete(foundVal);


