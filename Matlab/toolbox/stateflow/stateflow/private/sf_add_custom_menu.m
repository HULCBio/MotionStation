function sf_add_custom_menu(topMenuLabel, subMenuLabels, callbacks)
%SF_ADD_CUSTOM_MENU Adds custom menus to a all charts in a Stateflow session and to
%	all subsequently created charts.
%
%   SF_ADD_CUSTOM_MENU(TOPMENULABEL, SUBMENULABELS, CALLBACKS);
%
% 	INPUTS: 
%         topMenuLabel Custom menu label you will see on the menubar of 
%                      Stateflow Charts
%        subMenuLabels cell-array of the sub-menu labels you wish to 
%                      add under the top menu
%            callbacks the corresponding callbacks for these menu items
%                      (length must be the same as subMenuLabels!)
% 
%
%   To automate this add the appropriate calls to sf_add_custom_menu() in
%   your startup.m file where you load MATLAB
%
%   Note, to get rid of these menus, you'll need to exit Stateflow and re-load
%   WITHOUT calling this function.

%
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/04/15 00:59:19 $
%

	% force sf into memory
	charts = sf('get','all','chart.id');
	
	% Add new menus to the default editor
	defEditor = findall(0,'type','figure','tag', 'DEFAULT_SFCHART');
	switch length(defEditor),
	case 0, 
		error('could not default sf editor to add menu');
	case 1, 
	otherwise, 
		warning('more than one default editor found!');
		defEditor = defEditor(1);
	end;
	
	topMenu = uimenu(defEditor, 'label', topMenuLabel);
	
	for i = 1:length(subMenuLabels),
		label = subMenuLabels{i};
		callback = callbacks{i};
		menu = uimenu(topMenu, 'label', label, 'callback', callback);
	end;
	
	% Add new menus to open charts
	for chart = charts(:).',
		fig = sf('get', chart, '.hg.figure');
		if ~isequal(fig, 0) & ishandle(fig),
			copyobj(topMenu, fig);
		end;
	end;
	