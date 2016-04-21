function sfcall( command, ignore )
% Stateflow Callback dispatcher

%	E. Mehran Mestchian
%	Jay R. Torgerson
%   Copyright 1995-2004 The MathWorks, Inc.
%  $Revision: 1.75.4.6 $  $Date: 2004/04/15 00:59:56 $
if nargin>1, return; end

if nargin == 1,
	disp(command);
end;

obj = safe_gcbo_l;

%
% Resolve machine from chart and the active instnace
%
chart=get(safe_gcbf_l, 'UserData');
fig = sf('get', chart, '.hg.figure');

machine = actual_machine_referred_by(chart);

ted_the_editors(machine);
GET = sf('method','get');

if isempty(chart), return; end
if length(chart)~=1, error('Bad userdata in SFCHART'); end

status = findobj(fig,'type','uicontrol','style','text');

% Let all handles be visible for the switch below
shh = get(0, 'ShowHiddenHandles');
set(0, 'ShowHiddenHandles', 'On');

try
    switch get(obj,'Type')
        case 'figure',
            switch command
                otherwise
                    if nargin>0
                        set(status,'String',['FIGURE callback ''',command, ''' is TBD!']);
                    else
                        disp(['FIGURE callback is TBD!']);
                    end
            end
        case 'text'
            set(status,'String','text callback is TBD!');
        case 'patch'
            set(status,'String','patch callback is TBD!');
        case 'uicontrol'
            switch obj
                case findobj(fig,'Type','uicontrol','Style','popupmenu')
                    zoom_size( chart, obj );
                case findobj(fig,'Type','uicontrol','Style','slider')
                case sf(GET,chart,'.hg.vertSlide')
                    vertical_slide( chart, obj );
                case findobj(fig,'Type','uicontrol','Style','slider')
                case sf(GET,chart,'.hg.horzSlide')
                    horizontal_slide( chart, obj );
                otherwise
                    set(status,'String',['UICONTROL ''',get(obj,'Tag'),''' callback is TBD!']);
            end;
        case 'uimenu'
            menuLabelStr = get(obj,'Label');
            menuLabelStr( find(menuLabelStr=='&') ) = [];
            switch menuLabelStr
                case 'New Model',               sfnew;
                case 'Open Model...',           sfopen;
                case 'Save Model',              sfsave(machine, ...
                                                                   [], 1);
                case 'Save Model As...',        sfsave(machine, ...
                                                       sf('get',machine,'.name'), 1);
                case 'Get Latest Version...' % PC only command
                    rcs_get_latest_version(machine);
                case 'Check Out...' 	% PC only command
                    rcs_check_out(machine);
                case 'Check In...' % On PC and Unix
                    rcs_check_in(machine);
                case 'Undo Check-Out...' % PC only command
                    rcs_undo_check_out(machine);
                case 'Add to Source Control...' % PC only command
                    rcs_add_to_source_control(machine);
                case 'Remove from Source Control...' % PC only command
                    rcs_remove_from_source_control(machine);
                case 'History...' % PC only command
                    rcs_history(machine);
                case 'Differences...' % PC only command
                    rcs_differences(machine);
                case 'Properties...' % PC only command
                    rcs_properties(machine);
                case 'Start Source Control System...' % PC only command
                    rcs_start_source_control_system;
                case 'Check Out',               cmdispatch('CHECKOUT', actual_machine_referred_by(chart));
                case 'Undo Check-Out',          cmdispatch('UNDOCHECKOUT', actual_machine_referred_by(chart));
                case 'Close',                   sfclose(chart);
                case 'Close All Charts',        sfclose(sf('get',machine,'.charts'));
                case 'Chart Properties',        dlg_open(chart);
                case 'Machine Properties',      dlg_open(machine);
                case 'Exit MATLAB',             matlab_exit;
                case 'Cut',                     sf('Cut', chart);
                case 'Copy',                    sf('Copy', chart);
                case 'Paste',                   sf('Paste', chart);
                case 'Undo',					sf('Undo', chart);
                case 'Redo',					sf('Redo', chart);
                case 'Print Book...',           rg(chart,'ps');
                case 'Print Details...',        rptgen_sl.slbook('-showdialog',sf('get', chart,'chart.viewObj'));
                case 'To Printer',              sfprint(chart, 'default', 'printer', 1, 1);
                case 'PostScript',              sfprint(chart, 'ps',   'promptForFile',1);
                case 'Color PostScript',        sfprint(chart, 'psc',  'promptForFile',1);
                case 'Encapsulated PostScript', sfprint(chart, 'eps',  'promptForFile',1);
                case 'Tiff',                    sfprint(chart, 'tiff', 'promptForFile',1);
                case 'Jpeg',                    sfprint(chart, 'jpg',  'promptForFile',1);
                case 'Png',                     sfprint(chart, 'png',  'promptForFile',1);
                case 'To Figure',               sfprint(chart, 'hg',   'figure', 1);
                case 'Print...',                sf_hier_print(chart);
                case 'Print Setup...',          sfprint(chart, 'setup');
                case 'Meta',                    sfprint(chart, 'meta',   'clipboard',1);
                case 'Bitmap',                  sfprint(chart, 'bitmap', 'clipboard',1);
                case 'Explore',                 view_in_explorer(chart);
                case 'Model Explorer',          view_in_explorer(chart);
                case 'Debug...',                goto_debugger(chart);
                case 'Find...',                 sfsrch('create', chart);
                case 'Search  Replace...',     sfsnr(chart);
                case 'Parse',                   parse_this(machine);
                case 'Parse Diagram',           parse_this(chart);
                case 'Help',
                case 'Editor',                  sfhelp;
                case 'Stateflow Help',          sfhelp('stateflow');
                case 'Help Desk',               sfhelp('helpdesk');
                case 'About Stateflow',         sfabout;
                case 'Documentation...',        sfhelp('doc');
                case 'Browser',                 sfprops(chart,sf('Lookup',chart));
                case 'Style...',                sfstyler(chart);
                case 'OR',                      sf('set',sf('SelectedObjectsIn',chart),'state.type','OR');
                case 'AND',                     sf('set',sf('SelectedObjectsIn',chart),'state.type','AND');
                case 'History',                 sf('set',sf('SelectedObjectsIn',chart),'junction.type','HISTORY');
                case 'Connective',              sf('set',sf('SelectedObjectsIn',chart),'junction.type','CONNECTIVE');
                case 'Plain',                   sf('set',sf('SelectedObjectsIn',chart),'junction.type','PLAIN');
                case 'Split',                   sf('set',sf('SelectedObjectsIn',chart),'junction.type','SPLIT');
                case 'Merge',                   sf('set',sf('SelectedObjectsIn',chart),'junction.type','MERGE');
                % data and events are differentiated by the space at the end of
                % the menu item for events.  (Barf)
                case 'Local... ',               id = new_event(chart, 'LOCAL'); sfdlg(id,1);
                case 'Input from Simulink... ', id = new_event(chart,'INPUT'); sfdlg(id,1);
                case 'Output to Simulink... ',  id = new_event(chart, 'OUTPUT');sfdlg(id,1);
                case 'Local...',                id = new_data(chart); sfdlg(id,1);
                case 'Input from Simulink...',  id = new_data(chart,'INPUT');  sfdlg(id,1);
                case 'Output to Simulink...',   id = new_data(chart,'OUTPUT');sfdlg(id,1);
                case 'Workspace',               id = new_data(chart,'WORKSPACE'); sfdlg(id,1);
                case 'Temporary...',               id = new_data(chart,'TEMPORARY'); sfdlg(id,1);
                case 'Constant...',                id = new_data(chart,'CONSTANT'); sfdlg(id,1);
                case 'Target...',                  id = new_target(machine); sfdlg(id,1);
                case 'Select All',              sf('SelectAll',chart);
                case 'Start',                   sfsim('start',machine);
                case 'Stop',                    stop_simulation(machine);
                case 'Pause',                   sfsim('pause',machine);
                case 'Continue',                sfsim('continue',machine);
                case 'Simulation',              sfsim('syncChart', chart);
                case 'Configuration Parameters...',
                if(sf('get',machine,'machine.isLibrary'))
                    return;
                    end
                    modelH = sf('get', machine, '.simulinkModel');
                    set_param(modelH, 'SimulationCommand', 'SimParamDialog');
                case 'Open Simulation Target', goto_target(machine,'sfun');
                case 'Open RTW Target', goto_target(machine,'rtw');
                case 'Open MEX Target', goto_target(machine,'mex');

                case 'View',
                    ch = get(gcbo, 'child');

                    toolbarUp = sf('get', chart,'.toolbarVis');
                    if toolbarUp, set(ch(1), 'checked', 'on');
                    else set(ch(1), 'checked', 'off');
                    end;

                case 'Toolbar',
                    switch(get(gcbo, 'checked')),
                        case 'on',  sf('set', chart, '.toolbarVis',0);
                        case 'off',	sf('set', chart, '.toolbarVis',1);
                    end;

                otherwise,
                    if ~isempty(regexp(menuLabelStr,'^Open \S+ Target$', 'once'))
                        %% handle custom targets added to menu at load time
                        name = sscanf(menuLabelStr,'Open %s');
                        goto_target(machine,name);
                    else
                    sizeValue = sscanf(menuLabelStr,'%d');
                    if ~isempty(sizeValue)
                        size_menu(chart,obj,sizeValue);
                        return;
                    end
             end
             end
          case 'uitoggletool',
             btnCmd = get(obj, 'Tag');
             switch(btnCmd),
                case 'Up',       sf('UpView', chart);
                case 'Back',     sf('BackView', chart);
                case 'Forward',  sf('ForwardView', chart);
                case 'New',   sfnew;
                case 'Open',  sfopen;
                case 'Save',  sfsave(machine, [], 1);
                case 'Print', sfprint(chart, 'default', 'printer', 1, 0);
                case 'Cut',   sf('Cut', chart);
                case 'Copy',  sf('Copy', chart);
                case 'Paste', sf('Paste', chart);
                case 'Undo',  sf('Undo', chart);
                case 'Redo',  sf('Redo', chart);
                case 'Parse',
                    parse_this(chart);
                case 'Build',
                try,
                   autobuild_driver('build',machine,'sfun','yes');
                catch,
                end
                case 'RebuildAll',
                try,
                   autobuild_driver('rebuildall',machine,'sfun','yes');
                catch,
                end
                case 'Start',
                   modelH = sf('get', machine, '.simulinkModel');
                   switch get_param(modelH, 'simulationStatus')
                        case {'stopped','terminating'}, sfsim('start', machine);
                        otherwise, sfsim('continue', machine);
                   end;
                case 'Stop',     stop_simulation(machine);
                case 'PauseBtn', sfsim('pause',machine);
                case 'Explore',  view_in_explorer(chart);
                case 'Debug',    goto_debugger(chart);
                case 'Find',     sfsrch('create', chart);
                case 'Search  Replace',     sfsnr(chart);
                case 'Target',   goto_target(machine,'sfun');
                case 'Simulink', simulink;
             end;


        otherwise
            if nargin>0
                disp(sprintf('%s callback ''%s'' is TBD!',upper(get(obj,'Type')),command));
            else
                disp(sprintf('%s callback ''%s'' is TBD!',upper(get(obj,'Type')),command));
            end
    end

    set(0, 'ShowHiddenHandles', shh);
catch
    disp(lasterr);
    set(0, 'ShowHiddenHandles', shh);
end

function size_menu( chart, obj, sizeValue )
	parent = get(obj,'Parent');
 	menuLabelStr = get(parent,'Label');
	menuLabelStr( find(menuLabelStr=='&') ) = [];
	switch menuLabelStr
		case 'Set Font Size'
			sf('set',sf('SelectedObjectsIn',chart),'state.fontSize',sizeValue,'transition.fontSize',sizeValue);
		case 'Junction Size'
			sf('set',sf('SelectedObjectsIn',chart),'junction.position.radius',sizeValue);
		case 'Arrowhead Size'
			sf('set',sf('SelectedObjectsIn',chart),'state.arrowSize',sizeValue);
			sf('set',sf('SelectedObjectsIn',chart),'junction.arrowSize',sizeValue);
		otherwise, error('Bad size menu.');
	end


function color_menu( chart, obj, rgb )
	if strcmp(get(obj,'Checked'),'on')
		return;
	end
	parent = get(obj,'Parent');
	set(get(parent,'Child'),'Checked','off');
	set(obj,'Checked','on');
	menuLabelStr = get(parent,'Label');
	menuLabelStr( find(menuLabelStr=='&') ) = [];
	switch menuLabelStr
		case 'State Color'
			sf('set',chart,'.stateColor',rgb);
		case 'State Label Color'
			sf('set',chart,'.stateLabelColor',rgb);
		case 'Transition Color'
			sf('set',chart,'.transitionColor',rgb);
		case 'Transition Label Color'
			sf('set',chart,'.transitionLabelColor',rgb);
		case 'Junction Color'
			sf('set',chart,'.junctionColor',rgb);
		case 'Selection Color'
			sf('set',chart,'.selectionColor',rgb);
		case 'Chart Color'
			sf('set',chart,'.chartColor',rgb);
		otherwise, error('Bad color menu.');
	end


function vertical_slide( chart, obj )
	fig = sf('get', chart, '.hg.figure');
	viewLimits = sf('get', chart, '.viewLimits');
	viewHeight = viewLimits(4) - viewLimits(3);
	viewLimits(3) = -get(obj, 'Value');
	viewLimits(4) = viewLimits(3) + viewHeight;

	sf('set', chart, '.viewLimits', viewLimits);
	figure(fig);	% to stop the scrollbars from stealing the focus.


function horizontal_slide(chart, obj)
	fig = sf('get', chart, '.hg.figure');
	viewLimits = sf('get', chart, '.viewLimits');
	viewWidth = viewLimits(2) - viewLimits(1);
	viewLimits(1) = get(obj, 'Value');
	viewLimits(2) = viewLimits(1) + viewWidth;

	sf('set', chart, '.viewLimits', viewLimits);
	figure(fig);	% to stop the scroll from stealing the focus.

function zoom_size( chart, obj )
	zoomIndex = get(obj,'Value');
	zoomFactors = sf('get',chart,'.zmFactors');
	sf('set',chart,'.zoomFactor',zoomFactors(zoomIndex));
	set(gcbo, 'vis','off');


function matlab_exit(),
	result = questdlg('Really close everything and exit MATLAB?','', 'Ok','Cancel','Cancel');
	switch result,
	  case 'Ok',

	    sfclose('all');
	    exit;
	end;

function goto_debugger(chart)
	machine = actual_machine_referred_by(chart);
	sfdebug('gui','init',machine);

%------------------------------------------------------------------------------------------
function sfunId = get_sfun_target_l(id),
%
%
%
   chartISA = sf('get','default','chart.isa');
   machineISA = sf('get','default','machine.isa');

   switch(sf('get', id, '.isa')),
		case chartISA,	 machineId = sf('get', id, '.machine');
		case machineISA, machineId = id;
		otherwise error('Bad id passed to get_sfun_target_l');
   end;

   targets = sf('find','all','target.machine',machineId);
   sfunId = sf('find',targets,'target.name','sfun');


%------------------------------------------------------------------------------------------
function id = view_in_explorer(chartId),
%
%
%
    sfexplr;
    selectionList = sf('SelectedObjectsIn',chartId);
    switch length(selectionList)
    case 1,
        id = selectionList;
    otherwise,
        viewObjId= sf('get',chartId,'chart.viewObj');
        if ~isempty(viewObjId) & isequal(viewObjId,chartId)
            id = chartId;
        else
            id = viewObjId;
        end
    end
    sf('Explr','VIEW',id);

%--------------------------------------------------------------------------
function rcs_get_latest_version(machine)
    modelHandle = sf('get',machine,'machine.simulinkModel');
	modelFile = get_param(modelHandle, 'FileName');
	if(isempty(modelFile))
        return;
	end
	try
        reload = verctrl('get', modelFile, 0);
		if (reload)
		    reloadsys(modelFile);
		end
	catch
        errordlg(lasterr, 'Error', 'modal');
	end
%--------------------------------------------------------------------------
function rcs_check_out(machine)
    modelHandle = sf('get',machine,'machine.simulinkModel');
	modelFile = get_param(modelHandle, 'FileName');
    if(isempty(modelFile))
	    return;
	end
    try
	    reload = verctrl('checkout', modelFile, 0);
		if (reload)
		    reloadsys(modelFile);
		end
	catch
	    errordlg(lasterr, 'Error', 'modal');
	end
%--------------------------------------------------------------------------
function rcs_check_in(machine)
    modelHandle = sf('get',machine,'machine.simulinkModel');
	if (isunix)
        cmdispatch('CHECKIN', machine);
	else
		isDirty     = get_param(modelHandle, 'dirty');
		if (isDirty)
		    sfsave(modelHandle);
		end
        % modelFile may have changed. re-get it
		modelFile = get_param(modelHandle, 'FileName');
		if(isempty(modelFile))
		    return; % Cancel a save must have occurred.  Just return (successfully).
		end
		try
		    reload = verctrl('checkin', modelFile, 0);
			if (reload)
			    reloadsys(modelFile);
			end
		catch
		  errordlg(lasterr, 'Error', 'modal');
		end
	end
%--------------------------------------------------------------------------
function rcs_undo_check_out(machine)
    modelHandle = sf('get',machine,'machine.simulinkModel');
	modelFile = get_param(modelHandle, 'FileName');
    if(isempty(modelFile))
	    return;
	end
    try
	    reload = verctrl('uncheckout', modelFile, 0);
		if (reload)
		    reloadsys(modelFile);
		end
	catch
	    errordlg(lasterr, 'Error', 'modal');
	end
%--------------------------------------------------------------------------
function rcs_add_to_source_control(machine)
	modelHandle = sf('get',machine,'machine.simulinkModel');
	isDirty     = get_param(modelHandle, 'dirty');
	if (isDirty)
       sfsave(modelHandle);
	end
	modelFile = get_param(modelHandle, 'FileName');
	if(isempty(modelFile))
       return; % Cancel a save must have occurred.  Just return (successfully).
	end
	try
       reload = verctrl('add', modelFile, 0);
       if (reload)
		    reloadsys(modelFile);
       end
	catch
       errordlg(lasterr, 'Error', 'modal');
	end
%--------------------------------------------------------------------------
function rcs_remove_from_source_control(machine)
    modelHandle = sf('get',machine,'machine.simulinkModel');
	modelFile = get_param(modelHandle, 'FileName');
    if(isempty(modelFile))
	    return;
	end
    try
	    verctrl('remove', modelFile, 0);
	catch
	    errordlg(lasterr, 'Error', 'modal');
	end
%--------------------------------------------------------------------------
function rcs_history(machine)
    modelHandle = sf('get',machine,'machine.simulinkModel');
	modelFile = get_param(modelHandle, 'FileName');
    if(isempty(modelFile))
	    return;
	end
    try
	    reload = verctrl('history', modelFile, 0);
		if (reload)
		    reloadsys(modelFile);
		end
	catch
	    errordlg(lasterr, 'Error', 'modal');
	end
%--------------------------------------------------------------------------
function rcs_differences(machine)
	modelHandle = sf('get',machine,'machine.simulinkModel');
	isDirty     = get_param(modelHandle, 'dirty');
	if (isDirty)
        sfsave(modelHandle);
	end
	modelFile = get_param(modelHandle, 'FileName');
	if(isempty(modelFile))
        return; % Cancel a save must have occurred.  Just return (successfully).
	end
	try
        verctrl('showdiff', modelFile, 0);
	catch
        errordlg(lasterr, 'Error', 'modal');
	end
%--------------------------------------------------------------------------
function rcs_properties(machine)
	modelHandle = sf('get',machine,'machine.simulinkModel');
	modelFile = get_param(modelHandle, 'FileName');
	if(isempty(modelFile))
        return;
	end
	try
        reload = verctrl('properties', modelFile, 0);
		if (reload)
		    reloadsys(modelFile);
		end
	catch
        errordlg(lasterr, 'Error', 'modal');
	end
%--------------------------------------------------------------------------
function rcs_start_source_control_system
	try
        verctrl('runscc', 0);
	catch
        errordlg(lasterr, 'Error', 'modal');
	end

   
    
%--------------------------------------------------------------------------
function obj = safe_gcbo_l
%
% Get the Callback Object independent of handle visibilities.
%
   shh = get(0, 'ShowHiddenHandles');
   set(0,'ShowHiddenHandles', 'on');
   obj = gcbo;
   if (isempty(obj)),
       obj = gco,
	   if isempty(obj), obj = gcf; end;
   end;
   set(0, 'ShowHiddenHandles', shh);

   
    
%--------------------------------------------------------------------------
function obj = safe_gcbf_l
%
% Get the Callback Figure independent of handle visibilities.
%
   shh = get(0, 'ShowHiddenHandles');
   set(0,'ShowHiddenHandles', 'on');
   obj = gcbf;
   set(0, 'ShowHiddenHandles', shh);

   
   
