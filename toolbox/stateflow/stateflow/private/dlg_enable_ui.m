function dlg_enable_ui( ui, onOff )
%DLG_ENABLE_UI( UI, ONOFF )

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:56:52 $
	switch onOff
		case 'on'
			dlg_set( ui, 'Enable', 'on');
			dlg_set( ...
			   [findobj(ui,'Style','popupmenu') ...
			   ,findobj(ui,'Style','edit') ...
			   ,findobj(ui,'Style','checkbox')] ...
			   ,'Background', 'white');
		case 'off'
			fig = get(ui(1),'Parent');
			dlg_set( ui, 'Enable', 'off');
         color = get(fig,'Color');
			dlg_set( ...
			   [findobj(ui,'Style','popupmenu') ...
			   ,findobj(ui,'Style','edit') ...
			   ,findobj(ui,'Style','checkbox')] ...
			   ,'Background', color);
		otherwise, warning(['bad onOff: ' onOff '.']);
	end


