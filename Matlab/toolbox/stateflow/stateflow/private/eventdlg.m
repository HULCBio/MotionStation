function varargout = eventdlg(varargin),
%EVENTDLG  Creates and manages the event dialog box

%   E.Mehran Mestchian
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.23.2.6 $  $Date: 2004/04/15 00:57:35 $

error(nargchk(0,1,nargout));

switch nargin
  case 0, % This is a callback method
    dlg_call(mfilename);
    return;
  case 1,
    method = varargin{1};
    switch method
      case 'dialogProperty',
	if nargout>0
	  varargout{1} = 'event.dialog';
	end
      otherwise, warning(['Bad method passed to eventdlg: ' method '.']); return;
    end
  case {2,3}
    %
    % Possiblities are:
    %   datadlg('construct',objectId,'deleteObjectOnCancel')
    %   datadlg('construct',objectId) implies do not deleteObjectOnCancel
    %   datadlg(method,objectId)
    %   datadlg(method,objectId,property)
    %
    method = varargin{1};
    objectId = varargin{2};
    if ~sf('ishandle',objectId) | sf('get',objectId,'.isa')~=sf('get','all','event.isa')
      warning('Bad event.');
      return;
    end

    if strcmp(method,'construct')
      constructor_method(varargin{2:end}); % => constructor_method(objectId [,deleteObjectOnCancel])
      return;
    else
      fig = sf('get',objectId,'.dialog');
      if (fig==0 | ~ishandle(fig))
	warning('Event does not have an open dialog!');
	return;
      end
    end

    if (nargin==2)
      switch method
   	case {'apply','OK'}
	  if ~sf('IsIced',objectId)
            apply_method(objectId);
	  else
            apply_method(objectId,'event_bp');
            refresh_method(objectId);
	  end
	  if strcmp(method,'OK')
            close_method(objectId);
	  end
	case 'cancel',
	  figData = get(fig,'UserData');
	  close_method(objectId);
	  if figData.deleteObjectOnCancel
	    sf('delete',objectId);
	  end
	case 'scope',
	  change_method(objectId,'scope');
	case 'buttondown',
	case 'refresh',
	  refresh_method(objectId);
	case 'resized'
	  refresh_method(objectId,'parent');
	case 'gotoParent'
	  dlg_goto_parent(objectId);
	case 'gotoStateflow'
	  sf('Explr', 'VIEW', objectId);
	case 'gotoDocument'
	  dlg_goto_document(objectId);
   	otherwise, warning(['Bad method passed to eventdlg: ' method '.']); return;
      end
    else % nargin==3
      property = varargin{3};
      switch method
	case 'refresh'
	  refresh_method(objectId,property);
	case 'apply'
	  apply_method(objectId,property);
   	otherwise, warning(['Bad method passed to eventdlg: ' method '.']); return;
      end
      refresh_method(objectId,property);
    end % if (nargin==2)
  otherwise
    error(nargchk(0,0,nargin));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function refresh_method( eventId, property )
if nargin<2
  % Refresh all variable properties in the dialog
  refresh_method( eventId, 'name');
  refresh_method( eventId, 'parent');
  refresh_method( eventId, 'description');
  refresh_method( eventId, 'scope');
  refresh_method( eventId, 'port');
  refresh_method( eventId, 'trigger');
  refresh_method( eventId, 'start breakpoint');
  refresh_method( eventId, 'end breakpoint');
  refresh_method( eventId, 'document');
  return;
end
fig = sf('get',eventId,'.dialog');
switch property
  case 'name'
    eventName = sf('get',eventId,'.name');
    set(fig,'Name', ['Event ',eventName]);
    ui = findobj(fig,'Type','uicontrol','Tag','NAME');
    set(ui,'String',eventName);
  case 'parent'
    parent = sf('get',eventId,'.linkNode.parent');
    ui = findobj(fig,'Type','uicontrol','Tag','PARENT');
    dlg_update_parent_ui( parent, ui );
  case 'description'
    s = sf('get',eventId,'.description');
    ui = findobj(fig,'Type','uicontrol','Tag','DESCRIPTION');
    set(ui,'String',s);
  case 'scope'
    scope = sf('get',eventId,'.scope');
    ui = findobj(fig,'Type','uicontrol','Tag','SCOPE','Style','popupmenu');
    scope = scope_of(eventId);
    set(ui,'String',scope.string,'Value',scope.value);
    refresh_method(eventId,'port');
    refresh_method(eventId,'trigger');
  case 'trigger'
    refresh_trigger(eventId,fig);
  case 'port'
    [enableVal, scope] = is_io_event(eventId);
    ui = findobj(fig,'Type','uicontrol','Tag','PORT');
    if scope==1 % INPUT EVENT
      set(findobj(ui,'Style','text'),'String','Index:');
    else % OTHER EVENTS
      set(findobj(ui,'Style','text'),'String','Port:');
    end
    if any(scope==[1,2]) % INPUT or OUTPUT
      chart = sf('get',eventId,'.linkNode.parent');
      if isempty(sf('get',chart,'chart.isa'))
	warning('Expected chart parent for input event.');
	enableVal = 'off';
      else
	[ios,index] = io_events_of(chart,scope);
	if isempty(ios)
	  str = ' ';
	else
	  str = sprintf('%d|',index);
	  str(end)='';
	end
	set(findobj(ui,'Style','popupmenu'),'String',str,'Value',find(eventId==ios));
      end
    end
    dlg_enable_ui(ui,enableVal);
  case 'start breakpoint'
    ui = findobj(fig,'Type','uicontrol','Tag','START BREAKPOINT');
    set(ui,'Value',sf('get',eventId,'event.debug.breakpoints.startBroadcast'));
  case 'end breakpoint'
    ui = findobj(fig,'Type','uicontrol','Tag','END BREAKPOINT');
    set(ui,'Value',sf('get',eventId,'event.debug.breakpoints.endBroadcast'));
  case 'event_bp'
    refresh_method(eventId,'start breakpoint');
    refresh_method(eventId,'end breakpoint')
  case 'document'
    s = sf('get',eventId,'.document');
    ui = findobj(fig,'Type','uicontrol','Tag','DOCUMENT');
    set(ui,'String',s);
  otherwise, warning(['Bad refresh property in eventdlg: ' property '.']); return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function refresh_trigger(eventId, fig)   
% get value of trigger field from data dictionary
ddval = sf('get',eventId,'.trigger')+1;

% choose the popup menu string based on scope
scope = sf('get',eventId,'.scope');
if scope==2 % OUTPUT EVENT
  popupstr = {'Either Edge','Function Call'};
else % INPUT EVENT; other cases are don't care
  popupstr = {'Either Edge','Rising Edge','Falling Edge','Function Call'};
end

% translate the trigger value into an appropriate menu index
ddstr = {'Either Edge','Rising Edge','Falling Edge','Function Call'};
popupval = map_string_indices(ddval, ddstr, popupstr);

% get the popupmenu itself and set its value and string
popup = findobj(fig,'Type','uicontrol','Style','popupmenu','Tag','TRIGGER');
set(popup,'Value',popupval,'String',popupstr);

% enable/disable the popupmenu 
uis = findobj(fig,'Type','uicontrol','Tag','TRIGGER');
dlg_enable_ui(uis,is_io_event(eventId));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = get_trigger_value(fig)   
popup = findobj(fig,'Type','uicontrol','Style','popupmenu','Tag','TRIGGER');
popupstr = get(popup,'String');
popupval = get(popup,'Value');
ddstr = {'Either Edge','Rising Edge','Falling Edge','Function Call'};
% map popupval index into data dictionary enum
val = map_string_indices(popupval, popupstr, ddstr)-1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function apply_trigger(eventId, fig)   
ddval = get_trigger_value(fig);
sf('set',eventId,'.trigger',ddval);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% translate index into one string array into an index into another string array
% goal is to keep the same string value if possible
function newindex = map_string_indices( oldindex, oldstr, newstr )
foo = oldstr{oldindex};								% fetch old string
newindex = strmatch(foo,newstr,'exact');		% search for string in new array
if isempty(newindex)									% default to 1 if not found
  newindex = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the string of a popup menu and adjust its value accordingly.
% goal is to keep the same string value if possible
function set_popup_string_and_adjust_value( popup, newstrings )
% get string for current value
val = get(popup,'Value');
oldstring = get(popup,'String');
newindex = map_string_indices(val, oldstring,newstrings);
% set new string and value
set(popup,'Value',newindex,'String',newstrings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function change_method( eventId, property )
error(nargchk(2,2,nargin));
fig = sf('get',eventId,'.dialog');
switch property
  case 'scope'
    ui = findobj(fig,'Type','uicontrol','Tag','SCOPE','Style','popupmenu');
    scope.string = get(ui,'String');
    scope.value = get(ui,'Value');
    if isempty(scope.string) | scope.value<1, return; end
    uis = [findobj(fig,'Type','uicontrol','Tag','PORT')
           findobj(fig,'Type','uicontrol','Tag','TRIGGER')];
    triggerPopUp = findobj(uis,'Tag','TRIGGER','Style','popupmenu');
    portLabelUi = findobj(uis,'Tag','PORT','Style','text');
    if strcmp(scope.string{scope.value},'Input from Simulink')
      newstrings = {'Either Edge','Rising Edge','Falling Edge','Function Call'};
      set_popup_string_and_adjust_value(triggerPopUp, newstrings);
      set(portLabelUi,'String','Index:');
      dlg_enable_ui(uis,'on');
    elseif strcmp(scope.string{scope.value},'Output to Simulink')
      newstrings = {'Either Edge','Function Call'};
      set_popup_string_and_adjust_value(triggerPopUp, newstrings);
      set(portLabelUi,'String','Port:');
      dlg_enable_ui(uis,'on');
    else
      set(portLabelUi,'String','Port:');
      dlg_enable_ui(uis,'off');
    end
  otherwise, warning(['Bad property ' property '.']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function apply_port(eventId,fig)
[enableVal, scope] = is_io_event(eventId);
ui = findobj(fig,'Type','uicontrol','Tag','PORT','Style','popupmenu');
%			userData = get(ui,'UserData');
%			userData.revertBuffer = [];
if any(scope==[1,2]) % INPUT or OUTPUT
  chart = sf('get',eventId,'.linkNode.parent');
  if isempty(sf('get',chart,'chart.isa'))
    warning('Expected chart parent for input/output event.');
    enableVal = 'off';
  else
    portVal = get(ui,'Value');
    if ~isempty(portVal)
      [ios,index] = io_events_of(chart,scope);
      oldPortVal = find(ios==eventId);
      if ~isequal(oldPortVal,portVal) & ~dlg_is_iced(eventId)
	%							if ~isempty(oldPortVal)
	%								userData.revertBuffer = oldPortVal(1);
	%							end
	portNo = index(portVal);
	sf('ChgPortIndTo',eventId,portNo);
	%			            dlg_revert('enable',fig);
      end
    end
  end
end
%         set(ui,'UserData',userData);
refresh_method(eventId,'port');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function apply_method( eventId, property )

ted_the_editors(sf('get',eventId,'event.machine'));

if nargin<2
  % Apply all editable properties in the dialog
  apply_method( eventId, 'scope');
  apply_method( eventId, 'trigger');
  apply_method( eventId, 'name');
  apply_method( eventId, 'port');
  apply_method( eventId, 'event_bp');
  apply_method( eventId, 'document');
  apply_method( eventId, 'description');
  return;
end

fig = sf('get',eventId,'.dialog');
switch property
  case 'name'
    dlg_edit_field( 'apply', eventId, 'event.name', 'NAME','',1);
  case 'description'
    dlg_edit_field( 'apply', eventId, 'event.description', 'DESCRIPTION','',1);
  case 'document'
    dlg_edit_field( 'apply', eventId, 'event.document', 'DOCUMENT','',1);
  case 'scope'
    ui = findobj(fig,'Type','uicontrol','Tag','SCOPE');
    userData = get(ui,'UserData');
    set(ui,'UserData',[]);
    newScope = get(ui,'Value');
    scope = scope_of(eventId);
    if newScope~=scope.value
      if ~dlg_is_iced(eventId)
	userData.revertBuffer = scope;
	set(ui,'UserData',userData);
	% because we refresh trigger and port whenever we apply scope,
	% we need to apply trigger and port simultaneously with scope.
   apply_port(eventId,fig);
	triggerval = get_trigger_value(fig);
	%% scope must be applied before trigger or else instance.c asserts
	%% because it doesn't have an appropriate event to attach
	%% the trigger to
   sf('set',eventId,'event.scope',scope.values(newScope));
   sf('set',eventId,'.trigger',triggerval);
    
   dlg_revert('enable',fig);
   %            	disp('applied scope');
      end
    else
      userData.revertBuffer = [];
    end
    set(ui,'UserData',userData);
  case 'port'
    apply_port(eventId,fig);
  case 'trigger'
    apply_trigger(eventId, fig);
  case 'event_bp'
    start_bp = findobj(fig,'Type','uicontrol','Tag','START BREAKPOINT');
    end_bp = findobj(fig,'Type','uicontrol','Tag','END BREAKPOINT');
    dlg_apply_ui_checkbox([start_bp,end_bp],eventId,'event.debug.breakpoints',0);
  case 'start breakpoint'
    apply_method(eventId,'event_bp');
  case 'end breakpoint'
    apply_method(eventId,'event_bp');
  otherwise, warning(['Bad refresh property in eventdlg: ' property '.']); return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function close_method( eventId )
fig = sf('get',eventId,'.dialog');
sf('set',eventId,'.dialog',0);
if fig~=0 & ishandle(fig)
  delete(fig);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function revert_method( eventId )
%
%ted_the_editors(sf('get',eventId,'event.machine'));
%
%fig = sf('get',eventId,'.dialog');
%
%% Revert name
%dlg_edit_field( 'revert', eventId, 'event.name', 'NAME', '',1);
%
%% Revert scope
%ui = findobj(fig,'Type','uicontrol','Tag','SCOPE');
%dlg_revert_property(ui,eventId,'event.scope',1);
%
%% Revert port
%ui = findobj(fig,'Type','uicontrol','Tag','PORT','Style','popupmenu');
%userData = get(ui,'UserData');
%if isfield(userData,'revertBuffer') & ~dlg_is_iced(eventId)
%  set(ui,'UserData',[]);
%  % there is stuff to revert
%  [enableVal, scope] = is_io_event(eventId);
%  if any(scope==[1,2]) % INPUT or OUTPUT
%    chart = sf('get',eventId,'.linkNode.parent');
%    if isempty(sf('get',chart,'chart.isa'))
%      warning('Expected chart parent for input/output event.');
%    else
%      oldPortVal = userData.revertBuffer;
%      if ~isempty(oldPortVal)
%	[ios,index] = io_events_of(chart,scope);
%	portVal = find(ios==eventId);
%	if ~isequal(portVal,oldPortVal)
%	  portNo = index(oldPortVal);
%	  sf('ChgPortIndTo',eventId,portNo);
%	end
%      end
%    end
%  end
%  %   	disp(['reverted event.port']);
%  userData = rmfield(userData,'revertBuffer');
%  set(ui,'UserData',userData);
%end
%
%% Revert trigger
%ui = findobj(fig,'Type','uicontrol','Tag','TRIGGER','Style','popupmenu');
%dlg_revert_property(ui,eventId,'event.trigger',1);
%
%% Revert start breakpoint
%ui = findobj(fig,'Type','uicontrol','Tag','START BREAKPOINT');
%dlg_revert_property(ui,eventId,'event.debug.breakpoints.startBroadcast',0);
%
%% Revert stop breakpoint
%ui = findobj(fig,'Type','uicontrol','Tag','END BREAKPOINT');
%dlg_revert_property(ui,eventId,'event.debug.breakpoints.endBroadcast',0);
%
%% Revert document
%dlg_edit_field( 'revert', eventId, 'event.document', 'DOCUMENT','',1);
%
%% Revert description
%dlg_edit_field( 'revert', eventId, 'event.description', 'DESCRIPTION','',1);
%
%refresh_method(eventId);
%
%dlg_revert('disable',fig);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function scope = scope_of( eventId )
%
% Obtains the scope of an event
%
parent = sf('get',eventId,'.linkNode.parent');
if ~sf('ishandle',parent)
  scope.string = '';
  scope.values = [];
  scope.value = 0;
  warning('Event has an invalid parent.');
  return;
end
eventScope = sf('get',eventId,'event.scope');
[MACHINE, CHART, STATE] = sf('get','default','machine.isa', 'chart.isa', 'state.isa');
switch sf('get',parent,'.isa')
  case MACHINE
    scope.string = {'Local','Exported','Imported'};
    scope.values = [0,4,3];
  case CHART
    scope.string = {'Local','Input from Simulink','Output to Simulink'};
    scope.values = [0,1,2];
  case STATE
    scope.string = {'Local'};
    scope.values = [0];
  otherwise
    scope.string = '';
    scope.values = [];
    scope.value = 0;
    warning('Parent of event has an invalid class.');
    return;
end
scope.value = find(eventScope==scope.values);
if isempty(scope.value)
  scope.string = '';
  scope.values = [];
  scope.value = 0;
  warning('Event has an invalid scope.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [result,scope] = is_io_event(eventId)
%
% Event trigger and port is only needed in the context of input/output events
%
scope = sf('get',eventId,'event.scope');
if isempty(scope)
  warning('Bad eventId');
  result = 'off';
elseif any(scope == [1,2])
  result = 'on';
else
  result = 'off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function constructor_method(eventId,deleteObjectOnCancel)
%
%  Create the event dialog.
%

if nargin<2
  deleteObjectOnCancel = 0;
end

   dynamic_dialog_l(eventId);

function [ios,index] = io_events_of(chart,scope)
switch scope
  case 1 % INPUT
    ios = sf('find',sf('EventsOf',chart),'event.scope',scope);
    index = [1:size(ios,2)];
  case 2 % OUTPUT
    dios = sf('find',sf('DataOf',chart),'data.scope',scope);
    ios = sf('find',sf('EventsOf',chart),'event.scope',scope);
    index = size(dios,2) + [1:size(ios,2)];
  otherwise
    error('Bad scope');
end


%--------------------------------------------------------------------------
%  ddg constructor
%--------------------------------------------------------------------------
function dynamic_dialog_l(eventId)
    
  h = find(sfroot, 'id', eventId);
  if ~isempty(h)
      d = DAStudio.Dialog(h, 'Event', 'DLG_STANDALONE');
      sf('SetDynamicDialog',eventId, d);
  end




