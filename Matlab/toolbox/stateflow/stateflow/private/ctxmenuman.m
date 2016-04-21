function varargout = ctxmenuman(varargin),
% [HANDLE] = CTXMENUMAN( CMDEVENT ... )
%
% Stateflow context menu manager
%

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.39.2.11 $  $Date: 2004/04/15 00:56:32 $

%
% Currently supported external cmdEvents are:
%
%    ctxH =	ctxmenuman('construct');				- constructs a context menu for a Stateflow session
%	 	      ctxmenuman('POP', ctxObject, ctxH);	- displays the context menu in the current editor
%			   ctxmenuman('SaveMenu', ctxH) 			- stores the menu in a safe place
%

switch(length(varargin)),
case 1,		cmdEvent = varargin{1};
case 2, 	cmdEvent = varargin{1};
case 3, 	cmdEvent = varargin{1};
otherwise, error('bad number of args passed to sfctxmenus!');
end;

%
% Process command
%
switch(cmdEvent),
case 'construct',
    sfDefaultFigure = varargin{2};
    h = constructor_method(sfDefaultFigure);
    varargout{1} = h;
case 'POP',
    ctxObj = varargin{2};
    ctxH = varargin{3};
    pop_method(ctxH, ctxObj);
case 'FIND', find_method;
case 'DEBUG', debug_method;
case 'EDIT_LIBRARY',
    chartId = sf('CtxEditorId');
    machineId = sf('get', chartId, '.machine');
    libraryH = sf('get',machineId, '.simulinkModel');
    set_param(libraryH, 'lock','off');
    sf('set', chartId, '.activeInstance', 0);
case 'CHECK_UNCHECK',
    myS = get(gcbo, 'userdata');
    checked = get(gcbo, 'checked');
    switch checked,
    case 'on',  if ~isempty(myS.checkedCallback),   eval(myS.checkedCallback);   end;
    case 'off', if ~isempty(myS.uncheckedCallback), eval(myS.uncheckedCallback); end;
    end;
case 'IS_LOCKED',
    chartId = sf('CtxEditorId');
    activeInstance = sf('get', chartId, '.activeInstance');
    switch activeInstance,
    case 0,
        machineId = sf('get', chartId, '.machine');
        if sf('get', machineId, '.locked')
            varargout{1} = sf('get', chartId, '.locked');
        else
            varargout{1} = 0;
        end;
        return;
    end;
    varargout{1} = 1;

case 'Set',
    classFields = varargin{2};
    value = varargin{3};
    set_method(classFields, value);
case 'Toggle',
    classFields = varargin{2};
    toggle_method(classFields);
case 'History', junct_types_to_history;
case 'Connective', junct_types_to_connective;
case 'SaveMenu', savemenu_method(varargin{2});
case 'cv_disable_display', cv_disable_display;
case 'cv_mouse_over', cv_mouse_over;
case 'cv_report', cv_report;
case 'cv_settings', cv_settings;
otherwise, error('bad cmd passed to sfctxmenus');
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = constructor_method(fig),

% Cache away existence of RMI
persistent rmiExists;
if isempty(rmiExists)
	rmiExists = license('test', 'SL_Verification_Validation') && (exist('rmi') == 2);
end

%
% Construct context menus
%

sh = get_safehouse;

%
% The context menu itself.
%
h = uicontextmenu('parent', sh, 'Tag', 'SF_CTX_MENU');

%
% Menu Structure, menuS, description:
%
% menuS.validTypes		    [ Data Dictionary class ids that are allowed (.isa) ]
% menuS.validModeFcn		name of a boolean returning function that indicates whether or
%                      	    not this menu item should be disabled
% menuS.validModeFcnArg     argument for validModeFcn
% menuS.visibleModeFcn		name of a boolean returning function that indicates whether or
%                      	    not this menu item should be visible
% menuS.visibleModeFcnArg   argument for validModeFcn
% menuS.type				possible types are:
%									Regular		  -item is disabled if the selection is empty
%									Persistent	  -item remains enabled regardless of the selection
%									VirtualScroll -same as Regular + has virtual scrollbar capability
% menuS.menuData			used to pass dd field names to update_menu_sizes()
% menuS.valueSizes		used to store the allowed valueSizes for fonts/arrowheads/junctions

%
% Back menu
%

types = get_type;

n = 1;
menuS.validTypes = [types.ALL];
menuS.type = 'Regular';
menuS.checkedFcn    = [];
menuS.checkedFcnArg = [];
menuS.checkedCallback = [];
menuS.uncheckedCallback = [];
menuS.validModeFcn = 'ctx_editor_is_subviewing';
menuS.validModeFcnArg = [];
menuS.visibleModeFcn = [];
menuS.visibleModeFcnArg = [];
mh(n) = uimenu('Label', 'Back',  'Callback','sf(''CtxBack'')',	'userdata', menuS); n=n+1;

%
% Add Note Menu
%
%

menuS.validTypes = [types.CHART, types.BLOCK];
menuS.type = 'Persistent';
menuS.validModeFcn = 'ctx_editor_is_not_iced';
menuS.validModeFcnArg = [];
mh(n) = uimenu('Label', 'Add Note',  'Callback','sf(''Private'',''ctx_add_note'');','Separator','on','userdata', menuS); n=n+1;

%
% Smart Menu
%
%
menuS.validTypes = [types.TRANS];
menuS.type = 'Regular';
menuS.validModeFcn = 'ctx_editor_is_not_iced';
menuS.validModeFcnArg = [];
menuS.checkedFcn = 'ctx_all_wires_are_smart';
mh(n) = uimenu('Label', 'Smart','Callback', 'sf(''Private'', ''ctx_toggle_smart'');', 'Separator','on','userdata', menuS); n=n+1;

menuS.checkedFcn = '';

%
% Cut
%

menuS.validTypes = [types.ALL];
menuS.type = 'Regular';
menuS.validModeFcn = 'ctx_editor_has_a_selection_but_is_not_iced';
menuS.validModeFcnArg = [];
mh(n) = uimenu('Label', 'Cut',  'Callback','sf(''CtxCut'')', 'Separator', 'on',	'userdata', menuS); n=n+1;

%
% Copy
%

menuS.validTypes = [types.ALL];
menuS.type = 'Regular';
menuS.validModeFcn = 'ctx_editor_has_a_selection';
menuS.validModeFcnArg = [];
mh(n) = uimenu('Label', 'Copy', 'Callback','sf(''CtxCopy'')',	'userdata', menuS); n=n+1;

%
% Paste
%

menuS.validTypes = [types.ALL];
menuS.type = 'Regular';
menuS.validModeFcn = 'clipboard_not_empty';
menuS.validModeFcnArg = [];
mh(n) = uimenu('Label', 'Paste','Callback','sf(''CtxPaste'')','userdata', menuS);  n=n+1;

%
% Coverage
%

% Main coverage menu
menuS.validTypes      = [types.ALL];
menuS.type            = 'Regular';
menuS.validModeFcn    = [];
menuS.validModeFcnArg = [];
menuS.visibleModeFcn  = 'cv_display_active';
mh(n) = uimenu('Label',     'Coverage',...
               'Separator', 'on',...
               'userdata',  menuS);

% Report
menuS.validTypes      = [types.STATE types.TRANS];
menuS.type            = 'Regular';
menuS.validModeFcn    = [];
menuS.validModeFcnArg = [];
menuS.visibleModeFcn  = 'cv_report_exists';
uimenu('Label',     'Report',...
       'Separator', 'off',...
       'Callback',  'sf(''Private'', ''ctxmenuman'', ''cv_report'');',...
       'userdata',  menuS,...
       'parent',    mh(n));

% Display details on mouse-over
menuS.validTypes      = [types.ALL];
menuS.type            = 'Regular';
menuS.validModeFcn    = [];
menuS.validModeFcnArg = [];
menuS.visibleModeFcn  = 'cv_display_active';
menuS.checkedFcn      = 'cv_mouse_over_checked';
uimenu('Label',    'Coverage display on mouse-over', ...
       'Callback', 'sf(''Private'', ''ctxmenuman'', ''cv_mouse_over'');',...
       'Separator', 'on',...
       'userdata',  menuS,...
       'parent',    mh(n));
menuS.checkedFcn = [];

% Display details on mouse click
menuS.validTypes      = [types.ALL];
menuS.type            = 'Regular';
menuS.validModeFcn    = [];
menuS.validModeFcnArg = [];
menuS.visibleModeFcn  = 'cv_display_active';
menuS.checkedFcn      = 'cv_mouse_click_checked';
uimenu('Label',    'Display details on mouse click', ...
       'Callback', 'sf(''Private'', ''ctxmenuman'', ''cv_mouse_over'');',...
       'userdata',  menuS,...
       'parent',    mh(n));
menuS.checkedFcn = [];

% Remove information
menuS.validTypes      = [types.ALL];
menuS.type            = 'Regular';
menuS.validModeFcn    = [];
menuS.validModeFcnArg = [];
menuS.visibleModeFcn  = 'cv_display_active';
uimenu('Label',    'Remove information', ...
       'Callback', 'sf(''Private'', ''ctxmenuman'', ''cv_disable_display'');',...
       'Separator', 'on',...
       'userdata',  menuS,...
       'parent',    mh(n));

% Coverage settings
menuS.validTypes      = [types.ALL];
menuS.type            = 'Regular';
menuS.validModeFcn    = [];
menuS.validModeFcnArg = [];
menuS.visibleModeFcn  = 'cv_display_active';
uimenu('Label',    'Coverage settings...', ...
       'Callback', 'sf(''Private'', ''ctxmenuman'', ''cv_settings'');',...
       'Separator', 'on',...
       'userdata',  menuS,...
       'parent',    mh(n));
menuS.visibleModeFcn = [];
menuS.visibleModeFcnArg = [];

n=n+1;

%
% Requirements
%
if rmi_enabled
    menuS.type            = 'Persistent';
    menuS.validTypes      = [types.CHART types.STATE types.TRANS, types.TRUTHTABLE, types.BOX, types.FUNCTION];
    menuS.validModeFcn    = [];
    menuS.validModeFcnArg = [];
    menuS.visibleModeFcn  = [];
    mh(n) = uimenu('Label',     'Requirements',...
                   'userdata',  menuS,...
                   'Separator', 'on',...
                   'Visible',   Bool2OnOff(rmiExists),...
                   'Tag',       rmiTag);
    n=n+1;
end

%%%%%
theSizes = [2 4 6 8 9 10 12 14 16 20 24 32 40 48 50];
menuS.sizeValues = theSizes;

%
% Font Size
%
menuS.validTypes = [types.CHART types.BLOCK types.TRANS];
menuS.type = 'VirtualScroll';
menuS.validModeFcn = 'update_size_menu';
mh(n) = uimenu('Label', 'Font Size', 'Separator', 'on');
menuS.validModeFcnArg = mh(n);
menuS.menuData = '.fontSize';

for f = theSizes(:)',
    numStr = sf_scalar2str(f);
    callbackStr = ['sf(''CtxSetFontSize'',', numStr,');'];
%    callbackStr = ['sf(''Private'', ''ctxmenuman'', ''Set'', {''state.fontSize'', ''transition.fontSize''},',numStr,')'];
    uimenu('Label', numStr, 'Callback', callbackStr, 'parent', mh(n));
end;
set(mh(n), 'userdata', menuS);
n=n+1;

%
% Junction Size
%
menuS.validTypes = [types.JUNCT];
mh(n) = uimenu('Label', 'Junction Size','Separator', 'on');
menuS.validModeFcnArg = mh(n);
menuS.menuData = '.position.radius';
for f = theSizes(:)',
    numStr = sf_scalar2str(f);
    callbackStr = ['sf(''CtxSetJunctionSize'',', numStr,');'];
   % callbackStr = ['sf(''Private'', ''ctxmenuman'', ''Set'', {''junction.position.radius''},',numStr,')'];
    uimenu('Label', numStr, 'Callback', callbackStr, 'parent', mh(n));
end;
set(mh(n), 'userdata', menuS);
n=n+1;

%
% Arrowhead Size (STATE)
%
menuS.validTypes = [types.STATE];
mh(n) = uimenu('Label', 'Arrowhead Size');
menuS.validModeFcnArg = mh(n);
menuS.menuData = '.arrowSize';
for f = theSizes(:)',
    numStr = sf_scalar2str(f);
    callbackStr = ['sf(''CtxSetArrowSize'',', numStr,');'];
    uimenu('Label', numStr, 'Callback', callbackStr, 'parent', mh(n));
end;
set(mh(n), 'userdata', menuS);
n=n+1;

%
% Arrowhead Size (JUNCT)
%
menuS.validTypes = [types.JUNCT];
mh(n) = uimenu('Label', 'Arrowhead Size');
menuS.validModeFcnArg = mh(n);
for f = theSizes(:)',
    numStr = sf_scalar2str(f);
    callbackStr = ['sf(''CtxSetArrowSize'',', numStr,');'];
%    callbackStr = ['sf(''Private'', ''ctxmenuman'', ''Set'', {''junction.arrowSize''},',numStr,')'];
    uimenu('Label', numStr, 'Callback', callbackStr, 'parent', mh(n));
end;
set(mh(n), 'userdata', menuS);
n=n+1;

%
% Arrowhead Size (TRANS)
%
menuS.validTypes = [types.TRANS];
mh(n) = uimenu('Label', 'Arrowhead Size');
menuS.validModeFcnArg = mh(n);
for f = theSizes(:)',
    numStr = sf_scalar2str(f);
    callbackStr = ['sf(''CtxSetArrowSize'',', numStr,');'];
%    callbackStr = ['sf(''Private'', ''ctxmenuman'', ''Set'', {''transition.arrowSize''},',numStr,')'];
    uimenu('Label', numStr, 'Callback', callbackStr, 'parent', mh(n));
end;
set(mh(n), 'userdata', menuS);
n=n+1;


%
% Arrowhead Size (CHART ==> STATE + JUNCT)
%
menuS.validTypes = [types.CHART];
mh(n) = uimenu('Label', 'Arrowhead Size');
menuS.validModeFcnArg = mh(n);
for f = theSizes(:)',
    numStr = sf_scalar2str(f);
    callbackStr = ['sf(''CtxSetArrowSize'',', numStr,');'];
%    callbackStr = ['sf(''Private'', ''ctxmenuman'', ''Set'', {''state.arrowSize'', ''junction.arrowSize''},',numStr,')'];
    uimenu('Label', numStr, 'Callback', callbackStr, 'parent', mh(n));
end;
set(mh(n), 'userdata', menuS);
n=n+1;

menuS.valueSizes = [];	% no need to store this everywhere!
menuS.validModeFcn = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Text Format
%
menuS.type = 'Regular';
menuS.validTypes = [types.NOTE];
menuS.validModeFcn = 'ctx_editor_is_not_iced';
menuS.validModeFcnArg = [];
mh(n) = uimenu('Label', 'Text Format', 'userdata', menuS);

menuS.validModeFcn      = '';
menuS.checkedFcn        = 'ctx_all_notes_bold';
uimenu('Parent', mh(n), 'Label', 'Bold', 'Callback', ['sf(''Private'', ''ctxmenuman'', ''Toggle'', {''state.noteBox.bold''});'], 'userdata', menuS);

menuS.validModeFcn      = '';
menuS.checkedFcn        = 'ctx_all_notes_italic';
uimenu('Parent', mh(n), 'Label', 'Italic', 'Callback', ['sf(''Private'', ''ctxmenuman'', ''Toggle'', {''state.noteBox.italic''});'], 'userdata', menuS);

menuS.validModeFcn      = '';
menuS.checkedFcn        = 'ctx_all_notes_in_tex';
uimenu('Parent', mh(n), 'Label', 'TeX instructions', 'Callback', ['sf(''Private'', ''ctxmenuman'', ''Toggle'', {''state.noteBox.interp''});'], 'userdata', menuS);

n=n+1;

menuS.validModeFcn = '';
menuS.checkedFcn   = '';
menuS.checkedCallback = '';
menuS.uncheckedCallback = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Text Alignment
%
menuS.type = 'Regular';
menuS.validTypes = [types.NOTE];
menuS.validModeFcn = 'ctx_editor_is_not_iced';
menuS.validModeFcnArg = [];
mh(n) = uimenu('Label', 'Text Alignment', 'userdata', menuS);

menuS.validModeFcn      = '';
menuS.checkedFcn        = 'ctx_all_notes_left';
uimenu('Parent', mh(n), 'Label', 'Left',   'Callback', ['sf(''Private'', ''ctxmenuman'', ''Set'', {''state.noteBox.horzAlignment''},''LEFT'');'], 'userdata', menuS);

menuS.validModeFcn      = '';
menuS.checkedFcn        = 'ctx_all_notes_center';
uimenu('Parent', mh(n), 'Label', 'Center',   'Callback', ['sf(''Private'', ''ctxmenuman'', ''Set'', {''state.noteBox.horzAlignment''},''CENTER'');'], 'userdata', menuS);

menuS.validModeFcn      = '';
menuS.checkedFcn        = 'ctx_all_notes_right';
uimenu('Parent', mh(n), 'Label', 'Right',   'Callback', ['sf(''Private'', ''ctxmenuman'', ''Set'', {''state.noteBox.horzAlignment''},''RIGHT'');'], 'userdata', menuS);

n=n+1;

menuS.validModeFcn = '';
menuS.checkedFcn   = '';
menuS.checkedCallback = '';
menuS.uncheckedCallback = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Type (JUNCT)
%
menuS.type = 'Regular';
menuS.validTypes = [types.JUNCT];
menuS.validModeFcn = 'ctx_editor_is_not_iced';
mh(n) = uimenu('Label', 'Type', 'userdata', menuS, 'Separator','on');
uimenu('Parent', mh(n), 'Label', 'History', 'Callback', 'sf(''Private'',''ctxmenuman'',''History'');');
uimenu('Parent', mh(n), 'Label', 'Connective', 'Callback', 'sf(''Private'',''ctxmenuman'',''Connective'');');
n=n+1;

%
% Decomposition (STATE)
%
tempMenu = menuS;  %start copy of menuS

menuS.type = 'Regular';
menuS.validTypes = [types.STATE];
menuS.validModeFcn = 'ctx_editor_is_not_iced';
menuS.validModeFcnArg = [];

mh(n) = uimenu('Label', 'Decomposition', 'userdata', menuS, 'Separator', 'on');
uimenu('Parent', mh(n), 'Label', 'Exclusive (OR)', 'Callback', 'sf(''CtxAndDecomp'');');
uimenu('Parent', mh(n), 'Label', 'Parallel (AND)', 'Callback', 'sf(''CtxOrDecomp'');');
n=n+1;



%
% Decomposition (CHART)
%
menuS.type = 'Persistent';
menuS.validTypes = [types.CHART];
menuS.validModeFcn = 'ctx_editor_is_not_iced';
menuS.validModeFcnArg = [];
mh(n) = uimenu('Label', 'Decomposition', 'userdata', menuS, 'Separator', 'on');
uimenu('Parent', mh(n), 'Label', 'Exclusive (OR)', 'Callback', 'sf(''CtxAndChartDecomp'');');
uimenu('Parent', mh(n), 'Label', 'Parallel (AND)', 'Callback', 'sf(''CtxOrChartDecomp'');');
n=n+1;

menuS = tempMenu;  %end copy of menuS

%
% Type (STATE)
%
menuS.type = 'Regular';
menuS.validTypes = [types.STATE types.BOX];
menuS.validModeFcn = 'ctx_editor_is_not_iced';
menuS.validModeFcnArg = [];
mh(n) = uimenu('Label', 'Type', 'userdata', menuS);                                                        

%menuS.validModeFcn = 'function_isnt_ttable_or_eml';
uimenu('Parent', mh(n), 'Label', 'State', 'Callback', 'sf(''CtxStateType'')', 'userdata', menuS);                          
uimenu('Parent', mh(n), 'Label', 'Box', 'Callback', 'sf(''CtxGroupType'')', 'userdata', menuS);
%uimenu('Parent', mh(n), 'Label', 'Function', 'Callback', 'sf(''CtxFunctionType'')', 'userdata', menuS);

n=n+1;                                                                                                     

%
% MAKE CONTENTS : Grouped, Subcharted,
%
menuS.checkedFcn = [];
menuS.type = 'Regular';
menuS.validTypes = [types.STATE_LIKE];
menuS.validModeFcn = 'ctx_editor_is_not_iced';
menuS.validModeFcnArg = [];
mh(n) = uimenu('Label', 'Make Contents', 'userdata', menuS);

menuS.validModeFcn      = 'ctx_no_outline_subcharts';
menuS.checkedFcn        = 'ctx_all_grouped';
menuS.checkedCallback   = 'sf(''CtxUnGroup'');';
menuS.uncheckedCallback = 'sf(''CtxGroup'');';
uimenu('Parent', mh(n), 'Label', 'Grouped',   'Callback', 'sf(''Private'', ''ctxmenuman'', ''CHECK_UNCHECK'');', 'userdata', menuS);

menuS.validModeFcn      = 'enable_subchart';
menuS.checkedFcn        = 'ctx_all_subcharted';
menuS.checkedCallback   = 'sf(''CtxUnSubchart'');';
menuS.uncheckedCallback = 'sf(''CtxSubchart'');';
uimenu('Parent', mh(n), 'Label', 'Subcharted',   'Callback', 'sf(''Private'', ''ctxmenuman'', ''CHECK_UNCHECK'');', 'userdata', menuS);

n=n+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Truth Table View Contents
%
menuS.type = 'Regular';
menuS.validTypes = [types.TRUTHTABLE];
menuS.checkedFcn = [];
menuS.checkedCallback = [];
menuS.uncheckedCallback = [];
menuS.validModeFcn = 'function_is_truth_table';
%mh(n) = uimenu('Label', 'Truth Table Editor', 'Callback', 'sf(''Private'', ''truth_table_man'', ''create_ui'',sf(''CtxObjectId''));', 'userdata', menuS, 'Separator', 'on');
mh(n) = uimenu('Label', 'View Contents', 'Callback', 'sf(''ViewContent'',sf(''CtxObjectId''));', 'userdata', menuS, 'Separator', 'on');
n = n + 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

menuS.validModeFcn = '';
menuS.checkedFcn   = '';
menuS.checkedCallback = '';
menuS.uncheckedCallback = '';

%
% FitToView
%
menuS.type = 'Regular';
menuS.validTypes = [types.ALL];
mh(n) = uimenu('Label', 'Fit To View', 'Callback', 'sf(''CtxFitToView'');', 'userdata', menuS, 'Separator', 'on'); n=n+1;

%
% SelectAll
% Explore
% Debug
% Find
%
menuS.type = 'Persistent';
menuS.validTypes = [types.ALL];
menuS.validModeFcn = 'ctx_editor_is_not_empty';
menuS.validModeFcnArg = [];
mh(n) = uimenu('Label', 'Select All', 'Callback', 'sf(''CtxSelectAll'');', 'userdata', menuS); n=n+1;
menuS.validModeFcn = [];
mh(n) = uimenu('Label', 'Explore', 'Tag',explorer_tag_l,'Callback', 'sfexplr; sf(''Explr'', ''VIEW'', sf(''CtxObjectId''));', 'userdata', menuS, 'Separator', 'on'); n=n+1;
mh(n) = uimenu('Label', 'Debug...', 'Callback', 'sf(''Private'', ''ctxmenuman'', ''DEBUG'');', 'userdata', menuS); n=n+1;
mh(n) = uimenu('Label', 'Find...', 'Callback', 'sf(''Private'', ''ctxmenuman'', ''FIND'');', 'userdata', menuS); n=n+1;

%
% Edit Library
%
%
menuS.type = 'Persistent';
menuS.validTypes = [types.ALL];
menuS.validModeFcn = 'ctxmenuman';
menuS.validModeFcnArg = 'IS_LOCKED';
mh(n) = uimenu('Label', 'Edit Library', 'Callback', 'sf(''Private'', ''ctxmenuman'', ''EDIT_LIBRARY'');', 'userdata', menuS); n=n+1;

%
% Get Handle
%
menuS.type = 'Persistent';
menuS.validTypes = [types.ALL];
menuS.validModeFcn    = [];
menuS.validModeFcnArg = [];
mh(n) = uimenu('Label', 'Send to Workspace', 'Callback', 'sf(''CtxGetHandle'');', 'userdata', menuS, 'Separator', 'off'); n=n+1;

%
% Properties
%
menuS.type = 'Persistent';
menuS.validTypes = [types.ALL];
menuS.validModeFcn    = [];
menuS.visibleModeFcn  = [];
menuS.validModeFcnArg = [];
mh(n) = uimenu('Label', 'Properties', 'Callback', 'sf(''CtxProperties'');', 'userdata', menuS, 'Separator', 'on');

set(mh, 'parent', h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pop_method(ctxH, ctxObj),
%
% Pop a context menu based on the ctxObj
%
types = get_type;
objType = get_type(ctxObj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configure menu based on context %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch(objType.isa)
case types.isaCHART, editorId = ctxObj;
case types.isaSTATE, editorId = sf('get', ctxObj, '.chart');
case types.isaTRANS,
    parentId = sf('get', ctxObj, '.linkNode.parent');
    switch(sf('get', parentId, '.isa')),
    case types.isaCHART, editorId = parentId;
    case types.isaSTATE, editorId = sf('get', parentId, '.chart');
    otherwise, error('fooey!');
    end;
case types.isaJUNCT,
    editorId = sf('get', ctxObj, '.chart');
otherwise,	error('fooey!');
end;

% remove for release
if (editorId ~= sf('CtxEditorId')) error('bad context editor Id'); end;

selectionList = sf('Selected', editorId);
% filter out autocreated objects
selectionList = sf('find',selectionList,'.autogen.isAutoCreated',0);
emptySelection = isempty(selectionList);

%
% Filter out menus that never apply and disable ones that we can't use.
%
children = findall(ctxH, 'type','uimenu');
for child = children(:)',
    menuS = get(child, 'userdata');
    if ~isempty(menuS),
        if isempty(find(menuS.validTypes == objType.type))
            set(child, 'vis', 'off');
        else,
            if emptySelection,
                switch(menuS.type),
                case 'Persistent', set(child, 'enable','on');
                otherwise, set(child, 'enable','off');
                end;
            else, set(child, 'enable','on');
            end;

            if ~isempty(menuS.visibleModeFcn)
                isVisible = feval(menuS.visibleModeFcn, menuS.visibleModeFcnArg);
            else
                isVisible = 1;
            end

            if isVisible
            % filter by validModeFcn
            if ~isempty(menuS.validModeFcn),
                validMode = feval(menuS.validModeFcn, menuS.validModeFcnArg);
                if ~validMode, set(child, 'enable','off');
                else, set(child, 'enable','on');
                end;
            end;

            %
            % update checked mode
            %
            if ~isempty(menuS.checkedFcn),
                checkedMode = feval(menuS.checkedFcn, menuS.checkedFcnArg);
                if ~checkedMode,
                    set(child, 'checked','off');
                    % set(child, 'callback', menuS.uncheckedCallback); NOT testomaticable! see CHECK_UNCHECK above
                else,
                    set(child, 'checked','on');
                    % set(child, 'callback', menuS.checkedCallback);   NOT testomaticalble!
                end;
            end;
            set(child,'vis','on');
            else
                set(child,'vis','off');
            end
        end;
    end;
end;

exploreCallbackStr = 'sfexplr; sf(''Explr'', ''VIEW'', sf(''CtxObjectId''));';
exploreMenu = findobj(children,'Tag',explorer_tag_l);
try,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% The following code to show resolved symbols for the
    %%% selected objects is in incubation and subject to
    %%% Jay's review and approval
    resolvedSymbols = sf('ResolvedSymbolsIn',ctxObj);
    resolvedSymbols = unique(resolvedSymbols);
    if(~isempty(exploreMenu))
        delete(get(exploreMenu, 'children'));
        if(isempty(resolvedSymbols))
            set(exploreMenu, 'Callback', exploreCallbackStr);
        else
            persistent sObjectTypeStrings
            if(isempty(sObjectTypeStrings))
                sObjectTypeStrings{sf('get','default','machine.isa')+1} = 'machine';
                sObjectTypeStrings{sf('get','default','chart.isa')+1} = 'chart';
                sObjectTypeStrings{sf('get','default','state.isa')+1} = 'state';
                sObjectTypeStrings{sf('get','default','data.isa')+1} = 'data';
                sObjectTypeStrings{sf('get','default','event.isa')+1} = 'event';
                sObjectTypeStrings{sf('get','default','transition.isa')+1} = 'transition';
                sObjectTypeStrings{sf('get','default','junction.isa')+1} = 'junction';
                sObjectTypeStrings{sf('get','default','target.isa')+1} = 'target';
            end
            set(exploreMenu,'Callback','');
            selectedObjStr = sprintf('Selected %s',sObjectTypeStrings{sf('get',ctxObj,'.isa')+1});
            uimenu('Label', selectedObjStr, 'Callback', exploreCallbackStr, 'parent', exploreMenu);
            symbolNames = {};
            for i=1:length(resolvedSymbols)
                [objType,objName] = sf('get',resolvedSymbols(i),'.isa','.name');
                if(~isempty(sf('find',resolvedSymbols(i),'state.type','FUNC_STATE')))
                    objTypeStr = 'function';
                else
                    objTypeStr = sObjectTypeStrings{objType+1};
                end
                symbolNames{end+1} = sprintf('(%s) %s',objTypeStr,objName);
            end
            [symbolNames,indices] = sort(symbolNames);
            resolvedSymbols = resolvedSymbols(indices);
            for i=1:length(resolvedSymbols)
                numstr = sf_scalar2str(resolvedSymbols(i));
                callbackStr = ['sf(''Explr'');sf(''Explr'',''VIEW'',',numstr,')'];
                uimenu('Label', symbolNames{i}, 'Callback', callbackStr, 'parent', exploreMenu);
            end
        end;
    end
    %%%%% End of incubation code %%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
catch,
    disp(lasterr);
    disp('Turning Explore Symbols feature off due to above errors');
    sf('Feature','Explore Symbols','off');
    set(exploreMenu, 'Callback', exploreCallbackStr);
    delete(get(exploreMenu, 'children'));
end

%
% BEGIN - Requirements
%
if rmi_enabled
    children = findall(ctxH, 'type','uimenu'); % Refresh, explore stuff makes previous list stale
    reqMenu = findobj(children, 'Tag', rmiTag);
    
    if(~isempty(reqMenu)) && strcmp(get(reqMenu, 'Visible'), 'on')
    	% Delete existing children
    	delete(get(reqMenu, 'children'));
    

        if is_multi_select
            if feature('RMIVectorMenus')
            	uimenu('Parent',    reqMenu, ...
            	       'Label',     'Add Links to All...',...
            	       'Callback',   @rmi_vector_add);
            	uimenu('Parent',    reqMenu,...
            	       'Label',     'Delete All',...
            	       'Callback',   @rmi_vector_delete);

            else
                set(reqMenu, 'Visible','off');
            end
        else
    	% Get all requirements
    	reqDescs = rmi('descriptions', ctxObj);
    	lenDescs = length(reqDescs);
    	for i = 1 : lenDescs
    		callback = ['rmi(''view'',sf(''CtxObjectId''),' num2str(i) ');'];
    		uimenu('Parent', reqMenu, 'Label', sprintf('%d.  %s', i, reqDescs{i}), 'Callback', callback);
        	end
    		
    	% Add "Edit/Add Links..."
    	uimenu('Parent',    reqMenu,...
    	       'Label',     'Edit/Add Links...',...
    	       'Separator', Bool2OnOff(lenDescs > 0),...
    	       'Callback',  'rmi(''edit'',sf(''CtxObjectId''));');
        end
    end
end
%
% END - Requirements
%

%
% Move ctx menu to the correct figure
%
fig = sf('get', editorId, '.hg.figure');
parent = get(ctxH, 'parent');
if (parent ~= fig), set(ctxH, 'parent', fig); end;

%
% Place it and make it visible
%
units = get(fig, 'units');
set(fig,'units','pixels');
p = get(fig, 'currentpoint');
p = p;
set(fig,'units', units);
set(ctxH, 'position', p);

if ~sf('Playback'), set(ctxH, 'vis','on'); end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function find_method
%
%
%
ctxEditor = sf('CtxEditorId');
sfsrch('create', ctxEditor);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function debug_method
%
%
%
ctxEditor = sf('CtxEditorId');
machine = actual_machine_referred_by(ctxEditor);
sfdebug('gui','init', machine);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = clipboard_not_empty(junk)
%
%
%

x = ~sf('ClipboardIsEmpty') & ctx_editor_is_not_iced(junk);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_editor_is_not_empty(junk)
%
%
%
x = 0;

ctxEditor = sf('CtxEditorId');
objs = sf('ObjectsIn', ctxEditor);
if ~isempty(objs),
    STATE = sf('get', 'default', 'state.isa');
    TRANS = sf('get', 'default', 'trans.isa');
    JUNCT = sf('get', 'default', 'junct.isa');

    states = sf('find', objs, '.isa', STATE);
    trans  = sf('find', objs, '.isa', TRANS);
    juncts = sf('find', objs, '.isa', JUNCT);

    objs = [states trans juncts];

    if ~isempty(objs) x = 1; end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_subchart_selected(junk),
%
% detect if there are any subcharts selected AND if they're ALL
% in OUTLINE mode.  (UnSubcharting a subchart from the inside is
% NOT allowed due to usability issues.
%
x = ~ctx_no_subcharts(junk);

% if there are subcharts, then check that they're all in OUTLINE mode.
if (x),
    ctxEditor = sf('CtxEditorId');
    selection = sf('SelectedObjectsIn', ctxEditor);
    subcharts = sf('find', selection, 'state.superState', 'SUBCHART');
    subchartsInOutlineMode = sf('find', subcharts, 'state.viewMode', 'OUTLINE');
    if ~isequal(subcharts, subchartsInOutlineMode) x = logical(0); end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_no_outline_subcharts(junk),
%
% See if there are NO subcharts in outline mode in the selection list
%
ctxEditor = sf('CtxEditorId');
selection = sf('SelectedObjectsIn', ctxEditor);
subchartsInOutlineMode = sf('find', selection, 'state.superState', 'SUBCHART', 'state.viewMode', 'OUTLINE');

if ~isempty(subchartsInOutlineMode),
    x=logical(0);
    return;
end;

states = sf('get', selection, 'state.id');

if ~isempty(states),
    x = logical(1);
else
    x = logical(0);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_no_subview_subcharts(junk),
%
% See if there are NO subcharts in subview mode in the selection list
%
ctxEditor = sf('CtxEditorId');
selection = sf('SelectedObjectsIn', ctxEditor);
subchartsInSubviewMode = sf('find', selection, 'state.superState', 'SUBCHART', 'state.viewMode', 1); % use number to get around core data dictionary bug!!

if isempty(subchartsInSubviewMode) x=logical(1); else x=logical(0); end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_all_grouped(junk),
%
% See if all selected items are grouped
%
ctxEditor = sf('CtxEditorId');
selection = sf('SelectedObjectsIn', ctxEditor);
states    = sf('get', selection, 'state.id');
groupedStates = sf('find', states, 'state.superState', 'GROUPED');

%
% special case for subviewing subcharts
%
if length(states) == 1 & isequal(states, sf('find', states, 'state.superState', 'SUBCHART', 'state.viewMode', 1, 'state.subgrouped', 1)),
    x = logical(1);
    return;
end;

if ~isempty(states) & isequal(states(:), groupedStates(:)), x = logical(1); else, x = logical(0); end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_all_subcharted(junk),
%
% See if all selected items are subcharted
%
ctxEditor = sf('CtxEditorId');
selection = sf('SelectedObjectsIn', ctxEditor);
states    = sf('get', selection, 'state.id');
subchartStates = sf('find', states, 'state.superState', 'SUBCHART');

if ~isempty(states) & isequal(states(:), subchartStates(:)), x = logical(1); else, x = logical(0); end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_no_subcharts(junk)
%
%
%
x = logical(1);

ctxEditor = sf('CtxEditorId');
selection = sf('SelectedObjectsIn', ctxEditor);

subcharts = sf('find', selection, 'state.superState', 'SUBCHART');

if ~isempty(subcharts) & ~isequal(subcharts, 0), x = logical(0); end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_all_notes_are( alignment ),
%
% See if all selected notes are in appropriate alignment mode
%
ctxEditor = sf('CtxEditorId');
selection = sf('SelectedObjectsIn', ctxEditor);
notes     = sf('find', selection, 'state.isNoteBox', 1);
texNotes  = sf('find', notes, 'state.noteBox.horzAlignment', alignment);
if ~isempty(texNotes) & isequal(notes(:), texNotes(:)), x = logical(1); else, x = logical(0); end;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_all_wires_are_smart(junk),
%
% See if all selected wires are smart
%
    ctxEditor  = sf('CtxEditorId');
    selection  = sf('SelectedObjectsIn', ctxEditor);
    types      = get_type;
    wires      = sf('find', selection, '.isa', types.isaTRANS);
    smartWires = sf('find', wires, 'trans.drawStyle', 1);
    if ~isempty(smartWires) & isequal(wires(:), smartWires(:)),
        x = logical(1);
    else,
        x = logical(0);
    end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_all_notes_bold(junk),
%
% See if all selected notes are in LaTex interperter mode
%
ctxEditor = sf('CtxEditorId');
selection = sf('SelectedObjectsIn', ctxEditor);
notes     = sf('find', selection, 'state.isNoteBox', 1);
boldNotes  = sf('find', notes, 'state.noteBox.bold', 1);
if ~isempty(boldNotes) & isequal(notes(:), boldNotes(:)), x = logical(1); else, x = logical(0); end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_all_notes_italic(junk),
%
% See if all selected notes are in LaTex interperter mode
%
ctxEditor = sf('CtxEditorId');
selection = sf('SelectedObjectsIn', ctxEditor);
notes     = sf('find', selection, 'state.isNoteBox', 1);
italicNotes  = sf('find', notes, 'state.noteBox.italic', 1);
if ~isempty(italicNotes) & isequal(notes(:), italicNotes(:)), x = logical(1); else, x = logical(0); end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x = ctx_all_notes_left(junk)
    x = ctx_all_notes_are('LEFT_NOTE');

function x = ctx_all_notes_center(junk),
    x = ctx_all_notes_are('CENTER_NOTE');

function x = ctx_all_notes_right(junk),
    x = ctx_all_notes_are('RIGHT_NOTE');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_all_notes_in_tex(junk),
%
% See if all selected notes are in LaTex interperter mode
%
ctxEditor = sf('CtxEditorId');
selection = sf('SelectedObjectsIn', ctxEditor);
notes     = sf('find', selection, 'state.isNoteBox', 1);
texNotes  = sf('find', notes, 'state.noteBox.interp', 'TEX_NOTE');
if ~isempty(texNotes) & isequal(notes(:), texNotes(:)), x = logical(1); else, x = logical(0); end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_no_notes_in_tex(junk)
%
%
%
x = logical(1);

ctxEditor = sf('CtxEditorId');
selection = sf('SelectedObjectsIn', ctxEditor);
texNotes  = sf('find', selection, 'state.isNoteBox', 1, 'state.noteBox.interp', 'TEX_NOTE');

if ~isempty(texNotes) & ~isequal(texNotes, 0), x = logical(0); end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_editor_is_not_iced(junk)
%
%
%
ctxEditor = sf('CtxEditorId');
x = 0;  %test case

if ~sf('IsChartEditorIced',ctxEditor)
    x = 1;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_editor_has_a_selection_but_is_not_iced(junk)
x=0;
ctxEditor = sf('CtxEditorId');
selectionList = sf('Selected', ctxEditor);
% filter out autocreated objects
selectionList = sf('find',selectionList,'.autogen.isAutoCreated',0);
if ~isempty(selectionList) & ~sf('IsChartEditorIced',ctxEditor)
    x = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = function_is_truth_table(junk)
%
funcId = sf('CtxObjectId');
if isempty(sf('find',funcId,'state.type','FUNC_STATE'))
    x = 0;
else
    x = sf('get',funcId,'state.truthTable.isTruthTable');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = function_is_eml(junk)
%
funcId = sf('CtxObjectId');
if isempty(sf('find',funcId,'state.type','FUNC_STATE'))
    x = 0;
else
    x = sf('get',funcId,'state.eml.isEML');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = function_isnt_ttable_or_eml(junk)
%
x = ~function_is_truth_table & ~function_is_eml;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = enable_subchart(junk)
%
x = ctx_no_subview_subcharts & function_isnt_ttable_or_eml;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_method(classFields, value)
%
%
%
editor = sf('CtxEditorId');
objs = sf('SelectedObjectsIn', editor);

for i=1:length(classFields),
    sf('set',objs,classFields{i}, value);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function toggle_method(classFields)
%
%
%
editor = sf('CtxEditorId');
objs = sf('SelectedObjectsIn', editor);

for i=1:length(classFields),
    value = sf('get',objs,classFields{i});
    value = ~value;
    if any(value)
        sf('set',objs,classFields{i}, 1);
    else
        sf('set',objs,classFields{i}, 0);
    end
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_editor_has_a_selection(junk)
x=0;
ctxEditor = sf('CtxEditorId');
selectionList = sf('Selected', ctxEditor);
% filter out autocreated objects
selectionList = sf('find',selectionList,'.autogen.isAutoCreated',0);
if ~isempty(selectionList)
    x = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = update_size_menu(parentMenuH),
% This is not actually a validModeFcn but an update function that gets
% called from pop_method() via the validModeFcn callback.
% If the parentMenu is disabled, then just return as there's nothing to update.
% Otherwise, if there is only one selection, find out what the current value is
% for the size parameter and make the appropriate numerical submenu checked.

if ~ctx_editor_is_not_iced
    x=0;
    return;
end

switch(get(parentMenuH, 'enable')),
case 'on', x = 1;
otherwise, x = 0; return;
end;

editor = sf('CtxEditorId');
objs = sf('SelectedObjectsIn', editor);
menuS = get(parentMenuH, 'userdata');
children = get(parentMenuH, 'children');
set(children,'checked', 'off');

if length(objs)==1,
    obj = sf('CtxObjectId');

    if obj~=editor,
        currentSize = sf('get', obj, menuS.menuData);
        delta = abs(currentSize - menuS.sizeValues);
        minDelta = min(delta);
        ind = find(minDelta==delta);
        ind = ind(1);
        children = flipud(children);
        set(children(ind),'checked','on');	% checks the closest match to the current size.
    end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function junct_types_to_history
%
%
%
editor = sf('CtxEditorId');
objs = sf('SelectedObjectsIn', editor);
sf('CtxPushJunctionTypeForUndo', editor);
sf('set', objs, 'junction.type', 'HISTORY_JUNCTION');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function junct_types_to_connective
%
%
%
editor = sf('CtxEditorId');
objs = sf('SelectedObjectsIn', editor);
sf('CtxPushJunctionTypeForUndo', editor);
sf('set', objs, 'junction.type', 'CONNECTIVE_JUNCTION');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function safeHouse = get_safehouse
%
%
%
showHHState = get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on');
safeHouse = findobj('type','figure','tag','SF_SAFEHOUSE');
set(0,'showhiddenhandles', showHHState);

if isempty(safeHouse),
    safeHouse = sf_figure('vis','off','numbertitle','off','pos',[-1000 1000 100 100],'handlevis','off','tag','SF_SAFEHOUSE','CloseRequestFcn','','IntegerHandle','off');
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function savemenu_method(ctxMenuH),
%
%
%
safeHouse = get_safehouse;

% Goto the safeHouse.
set(ctxMenuH, 'parent', safeHouse);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = ctx_editor_is_subviewing(junk),
%
% See if current editor is subviewing
%
ctxEditor = sf('CtxEditorId');
viewObj = sf('get', ctxEditor, '.viewObj');

if isequal(ctxEditor, viewObj), x = logical(0); else x = logical(1); end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = explorer_tag_l
%
%
%
str = 'EXPLORE_TAG';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = get_type( objectId )
%
%
%
persistent types
if isempty(types)
    n=0;
    n=n+1;     types.CHART = n;
    n=n+1;  types.OR_STATE = n;
    n=n+1; types.AND_STATE = n;
    n=n+1;       types.BOX = n;
    n=n+1;  types.TRUTHTABLE = n;
    n=n+1;       types.EML = n;
    n=n+1;  types.FUNCTION = n;
    n=n+1;      types.NOTE = n;
    n=n+1;     types.TRANS = n;
    n=n+1;     types.JUNCT = n;

    types.BLOCK      = [types.OR_STATE : types.NOTE];
    types.STATE      = [types.OR_STATE , types.AND_STATE];
    types.STATE_LIKE = [types.OR_STATE : types.FUNCTION];
    types.ALL        = [1 : n];

    types.isaCHART = sf('get', 'default', 'chart.isa');
    types.isaSTATE = sf('get', 'default', 'state.isa');
    types.isaTRANS = sf('get', 'default', 'trans.isa');
    types.isaJUNCT = sf('get', 'default', 'junct.isa');
end

if nargin==0
    % return all the types
    t = types;
else
    switch (sf('get',objectId,'.isa'))
    case types.isaCHART
        t.isa = types.isaCHART;
        t.type = types.CHART;
    case types.isaSTATE
        t.isa = types.isaSTATE;
        if (sf('get',objectId,'state.isNoteBox'))
            t.type = types.NOTE;
        else
            switch sf('get',objectId,'state.type')
            case 0, t.type = types.OR_STATE;
            case 1, t.type = types.AND_STATE;
            case 2,
                if (sf('get', objectId, 'state.truthTable.isTruthTable'))
                    t.type = types.TRUTHTABLE;
                elseif (sf('get', objectId, 'state.eml.isEML'))
                    t.type = types.EML;
                else
                    t.type = types.FUNCTION;
                end
            case 3, t.type = types.BOX;
            otherwise
                error('Unknown Stateflow state/block type');
            end
        end
    case types.isaTRANS
        t.isa = types.isaTRANS;
        t.type = types.TRANS;
    case types.isaJUNCT
        t.isa = types.isaJUNCT;
        t.type = types.JUNCT;
    otherwise
        error('Unknown Stateflow object type');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions used to interface to the Requirements Management Interface
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = rmi_obj_has_req(junk)

	objID  = sf('CtxObjectId');
	result = rmi('count', objID) == 1;


function result = rmiTag

	result = 'rmitag';


function result = Bool2OnOff(bool)

	if bool
		result = 'on';
	else
		result = 'off';
	end;


function result = rmi_enabled

    persistent isEnabled;
    if isempty(isEnabled)
        isEnabled = (license('test','SL_Verification_Validation') && exist('rmi.m')==2);
    end
    result = isEnabled;

function out = is_multi_select
    selectList = sf('SelectedObjectsIn',sf('CtxEditorId'));
    out = length(selectList)>1;
    
    
function ids = selected_state_trans
    selectList = sf('SelectedObjectsIn',sf('CtxEditorId'));
    stateIsa = sf('get','default','state.isa');
    transIsa = sf('get','default','trans.isa');
    ids = [sf('find',selectList,'state.isa',stateIsa) sf('find',selectList,'trans.isa',transIsa)];
     

function rmi_vector_add(varargin)
    rmi('edit',selected_state_trans);

function rmi_vector_delete(varargin)
    rmi('clearAll',selected_state_trans);

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions used to interface to the Model Coverage Tool
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = cv_link_feature_on
    persistent  enabled;

    if isempty(enabled)
        enabled = 0;
        if exist('cv')==3
            [prevErrMsg, prevErrId] = lasterr;
            try
                if (feature('CoverageDiagramUI')==1)
                  enabled = 1;
                end
            catch
                lasterr(prevErrMsg, prevErrId);
            end
        end
    end
    out = enabled;

function out = cv_is_inmem
   [mFiles,mexFiles] = inmem;
   out = any(strcmp(mexFiles,'cv'));

% Determine if menus should be visible:
function out = cv_report_exists(junkArg)
    out = 0;
    if ~cv_link_feature_on || ~cv_is_inmem
        return;
    end

    sfId = sf('CtxObjectId');
    cvId = find_equiv_cv_id(sfId);
    if (cvId >0)
        out = cv('SlsfCheckCallback','reportLink',cvId);
    end

function out = cv_display_active(junkArg)
    out = 0;
    if ~cv_link_feature_on || ~cv_is_inmem
        return;
    end

    sfId = sf('CtxEditorId');
    cvId = find_equiv_cv_model_id(sfId);
    if (cvId >0)
        out = cv('SlsfCheckCallback','disableInfo',cvId);
    end

function out = cv_mouse_over_checked(junkArg)
    out = 0;
    if ~cv_link_feature_on || ~cv_is_inmem
        return;
    end

    sfId = sf('CtxEditorId');
    cvId = find_equiv_cv_model_id(sfId);
    if (cvId >0)
        out = cv('SlsfCheckCallback','mouseOverChecked',cvId);
	end

function result = cv_mouse_click_checked(junkArg)
	result = ~cv_mouse_over_checked(junkArg);

% Callbacks:
function cv_disable_display
    sfId = sf('CtxEditorId');
    cvId = find_equiv_cv_model_id(sfId);
    if (cvId >0)
        cv('SlsfCallback','disableInfo',cvId);
    end

function cv_mouse_over
    sfId = sf('CtxEditorId');
    cvId = find_equiv_cv_model_id(sfId);
    if (cvId >0)
        cv('SlsfCallback','mouseOverToggle',cvId);
    end


function cv_report
    sfId = sf('CtxObjectId');
    cvId = find_equiv_cv_id(sfId);
    if (cvId >0)
        cv('SlsfCallback','reportLink',cvId);
    end

function cv_settings

	chartId   = sf('CtxEditorId');
	machineId = sf('get', chartId, '.machine');
	modelH    = sf('get', machineId, '.simulinkModel');
	modelName = get_param(modelH, 'Name');
	scvdialog('create', modelName);

function cvId = find_equiv_cv_model_id(sfId)
    cvId = 0;
    blockH = chart2block(sfId);
    if length(blockH)>1
        blockH = sf('get',sfId,'.activeInstance');
    end

    cvId = get_param(bdroot(blockH),'CoverageId');

function cvId = find_equiv_cv_id(sfId)
    cvId = 0;
    chartId = sf('CtxEditorId');
    blockH = chart2block(chartId);
    if length(blockH)>1
        blockH = sf('get',sfId,'.activeInstance');
    end

    % Check that the stateflow block in SL has coverage
    chartCvId = get_param(blockH,'CoverageId');
    if (chartCvId>0)
        % Quick and dirty for now.
        allIds = cv('DecendentsOf',chartCvId);
        cvId = cv('find',allIds,'.handle',sfId);
    end


