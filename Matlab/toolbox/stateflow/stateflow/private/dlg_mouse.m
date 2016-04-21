function dlg_mouse( dialogManager )
%DLG_MOUSE( DIALOGMANAGER )

%   E.Mehran Mestchian January 1997
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:57:03 $

%
%  Dialog mouse motion callback
%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Get userData and movements
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fig = gcf;
	if ~isequal(get(0,'PointerWindow'),fig)
		return;
	end
	userData = get(fig, 'UserData');

   % Some simple checks on the integrity of the dialog userData
   if ~isstruct(userData) | ~isfield(userData,'objectId')
      warning('Bad object dialog UserData.');
		delete(gcf);
   	return;
   end

   objectId = userData.objectId;
   if ~sf('ishandle',objectId) | sf('get',objectId,'.dialog')~=fig
      warning('Bad object dialog UserData.objectId.');
		delete(gcf);
		return;
   end

%%	ui = findobj(fig,'Type','uicontrol','Tag','HYPERLINK');

%%	if ~strcmp(get(fig,'SelectionType'),'normal')
%%		set(ui,'Visible','off');
%%	end

	hyperLinks= findobj(fig,'Type','uicontrol','Style','text','Foreground',[0 0 1]);
	if isempty(hyperLinks), return; end

	pt = get(fig, 'CurrentPoint');
	position = get(hyperLinks,'Position');
	extent = get(hyperLinks,'Extent');

	for i = 1:length(position)
		if all(pt>position{i}(1:2)) & all(pt<position{i}(1:2)+extent{i}(3:4))
%			set(fig,'Pointer','custom');
%			if isempty(ui)
%				ui = uicontrol('Style','text'...
%					,'Parent',fig...
%					,'Foreground','yellow'...
%					,'String',' goto '...
%					,'FontName','Times'...
%					,'FontSize',8 ...
%					,'FontWeight','normal'...
%					,'Tag','HYPERLINK'...
%					,'Visible','off'...
%					,'Clipping','off'...
%				);
%			end
%			pos = get(ui,'Extent');
%			pos(1:2) = pt+[3 -25];
%			set(ui,'Position',pos,'Visible','on');
%			drawnow
			return;
		end
	end
%	set(fig,'Pointer','arrow');
%	set(ui,'Visible','off');
%	drawnow


