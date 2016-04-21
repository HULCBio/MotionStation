function dlg_call( dialog )
%DLGCALL Callback gateway for Stateflow property dialogs
%        DIALOG parameter is the name of the specific dialog
%        manager. (e.g. eventdlg)

%   E. Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.14.2.1 $  $Date: 2004/04/15 00:56:47 $

% obtain the callback object
persistent sfClass

% we need to extract the name of the mfile from fullpath
% otherwise, feval will choke. g68095
[dlgPath,dialog] = fileparts(dialog);

if isempty(sfClass)
	sfClass = cell(9,1);
	sfClass{sf('get','default','machine.isa')+1} = 'machine';
	sfClass{sf('get','default','data.isa')+1} = 'data';
	sfClass{sf('get','default','event.isa')+1} = 'event';
	sfClass{sf('get','default','chart.isa')+1} = 'chart';
	sfClass{sf('get','default','target.isa')+1} = 'target';
	sfClass{sf('get','default','instance.isa')+1} = 'instance';
	sfClass{sf('get','default','state.isa')+1} = 'state';
	sfClass{sf('get','default','junction.isa')+1} = 'junction';
	sfClass{sf('get','default','transition.isa')+1} = 'transition';
end
obj = gcbo;
if (isempty(obj)),
	obj = gco,
	if isempty(obj), obj = gcf; end;
end

switch get(obj,'Type')
case 'uicontrol'
   userData = get(obj,'UserData');
   if isempty(userData), return; end
   if ~isfield(userData,'callback'), return; end
   method = userData.callback;
   fig = get(obj,'Parent');
   objectId = object_id_of(fig);
   if isempty(objectId), return; end
   feval(dialog,method,objectId);
case 'figure',
   objectId = object_id_of(obj);
   if isempty(objectId), return; end
	% see if we are over a blue hyper-text uicontrol text object
	hyperUiText = findobj(get(obj,'CurrentObject'),'Type','uicontrol','Foreground',[0 0 1]);
	if isempty(hyperUiText)
	   feval(dialog,'buttondown',objectId);
		return;
	end
	% A potential hypertext link
%%	ui = findobj(obj,'Type','uicontrol','Tag','HYPERLINK');
%%	if isempty(ui), return; end
%%	set(ui,'Visible','off');
	userData = get(hyperUiText,'Userdata');
	if ~isfield(userData,'callback'), return; end
   method = userData.callback;
	if isempty(method), return; end
	% Are we exactly over the text?
	currentPoint = get(obj,'CurrentPoint');
	extent = get(hyperUiText,'Extent');
	position = get(hyperUiText,'Position');
	if any(currentPoint<position(1:2)), return; end
	if any(currentPoint>position(1:2)+extent(3:4)), return; end

	% Everything checks! lets call the hyperlink method for this text
	% But before that see if this 'ID#<id>', in which case export the
	% object to the workspace
	switch get(obj,'SelectionType')
	case 'normal'
	   feval(dialog,method,objectId);
	case 'open'
		if ~isempty(regexp(get(hyperUiText,'String'),'^ID#\s*\d+$','once'))
			disp(sprintf('Stateflow %s : data-dictionary object ID',sfClass{sf('get',objectId,'.isa')+1}));
			assignin('base','ans',objectId);
			evalin('base','ans');
		end
	end
case 'text'
	disp('text callback is TBD!');
case 'patch'
	disp('patch callback is TBD!');
case 'uimenu'
	disp('patch callback is TBD!');
	menuLabel = get(obj,'Label');
otherwise
	if nargin>0
		disp([upper(get(obj,'Type')),' callback ''',method, ''' is TBD!']);
	else
		disp([upper(get(obj,'Type')),' callback ''',method, ''' is TBD!']);
	end
end


function objectId = object_id_of( fig );
   userData = get(fig,'UserData');
   % Some simple checks on the integrity of the dialog userData
   if ~isstruct(userData) | ~isfield(userData,'objectId')
      warning('Bad object dialog UserData.');
      objectId = [];
      return;
   end
   objectId = userData.objectId;
   if ~sf('ishandle',objectId) | (sf('get',objectId,'.dialog')<=0)
      delete(fig);
      warning('Bad object dialog UserData.objectId.');
      objectId = [];
      return;
   end

