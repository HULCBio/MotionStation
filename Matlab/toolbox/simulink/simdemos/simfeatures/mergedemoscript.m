function mergedemoscript(varargin)
%MERGEDEMOSCRIPT Controls the Merge Block Demo HTML page
%   MERGEDEMOSCRIPT initializes the HTML-based Merge Block Simulink demo.
%   MERGEDEMOSCRIPT(action) executes the hyperlink callback associated with the 
%   the string action.
%
%   MERGEDEMOSCRIPT(action,blockName) is used for the hiliteblock action. blockName
%   contains the string name of the block to be highlighted using hilite_system.
%
%   The complete set of demo files is as follows.
%      1) mergedemo.mdl
%      2) mergedemo.htm
%      3) mergedemofig1.gif
%      4) mergedemoscript.m

%   Karen Gondoly
%	Copyright 1990-2002 The MathWorks, Inc.
%	$Revision: 1.4 $  $Date: 2002/05/11 17:52:09 $

persistent MERGEDEMO_STEP_COUNTER SIMULATION_PARAMETER_HANDLE

try % Wrap the whole thing in a try catch, in case the user doesn't go in order.
	
	ni=nargin;
	
	if ~ni,
		step = 'initialize';
	else 
		step = varargin{1};
	end
    
    % If the Close link was selected, immediately close the model and bail
    % out of the function
    if strcmp(step,'closemodel'),
		close_system('mergedemo',0);	
        return    
    end
    
	% If first time running the demo, or they closed the model
	INITFLAG=0;
	if isempty(find_system('Name','mergedemo')) | ~ni
		mergedemo;
		MERGEDEMO_STEP_COUNTER = [...
				0; % Make sure the Logical operator is set to NOT (1)
			0; % Turn on Show port data types (2)
			0; % Open the Simulation Parameter window (3)
			0; % Press the Advanced Tab (4)
			0; % Highlight Boolean logic signals (5)
			0; % Select the On radio button (6)
			0; % Turn on Boolean logic signals (7)
			0; % Add a Data Type Conversion block (8)
			0]; % Set the Data Type Conversion block to boolean (9)
		INITFLAG = 1;
	end
	
	switch step
	case 'initialize',
		% Open the web browser with the html file
		fullPathName=which('mergedemoscript');
		tok=filesep;
		indtok = findstr(fullPathName,tok);
		pathname = fullPathName(1:indtok(end));
		web([pathname,'mergedemo.htm']);
	
	case 'openmodel'
		% re-initialize the model by closing and reopening it, if necessary.
		if ~INITFLAG,
			close_system('mergedemo',0)
			mergedemo
		end
	case 'hilite_subsystems',
		% Temporarily highlight both conditionally executed subsystems
		hilite_system(['mergedemo/Subsystem'],'find')
		hilite_system(['mergedemo/Subsystem1'],'find')
		
		pause(2)
		%try
		% Wrap in a try catch in case the diagram is closed before this call is made
		hilite_system(['mergedemo/Subsystem'],'none')
		hilite_system(['mergedemo/Subsystem1'],'none')
		%end
	case 'openoperator',
		% Open the Logical Operator block
		MERGEDEMO_STEP_COUNTER(1) = 1;
		open_system(['mergedemo/Logical',char(10),'Operator'])
		hilite_system(['mergedemo/Logical',char(10),'Operator'],'find')
		
	case 'usenot',
		% Make sure the Logical Operator block is set to NOT
		close_system('mergedemo/Logical Operator');
		set_param('mergedemo/Logical Operator','Operator','NOT');
		
	case 'showdatatypes',
		% Turn on the display for port data types
		MERGEDEMO_STEP_COUNTER(2) = 1;
		
		% If they skipped ahead and turned on Boolean Logic Signals already, this will 
		% cause a data type mismatch that will get caught by the try catch
		set_param('mergedemo','ShowPortDataTypes','on')
		
		% Update, in case they have not run the simulation
		set_param('mergedemo','SimulationCommand','update'); 
		
	case 'opensimparam',
		% Open the Simulation Parameter window for mergedemo.m.
		% Store its handle in a persistent variable
		MERGEDEMO_STEP_COUNTER(3) = 1;
		SIMULATION_PARAMETER_HANDLE = simprm('create',get_param('mergedemo','Handle'));
		
	case 'gotoadvanced',
		% Emulate pressing the Advanced tab
		if ~MERGEDEMO_STEP_COUNTER(3)
			SIMULATION_PARAMETER_HANDLE = simprm('create',get_param('mergedemo','Handle'));
			MERGEDEMO_STEP_COUNTER(3) = 1;
		end
		MERGEDEMO_STEP_COUNTER(4) = 1;
		tabdlg('tabpress',SIMULATION_PARAMETER_HANDLE,'Advanced',4);
		
	case 'selectboolean',
		% Highlight "Boolean logic signals"
		if  ~MERGEDEMO_STEP_COUNTER(4),
			mergedemoscript('gotoadvanced')
		end
		MERGEDEMO_STEP_COUNTER(5) = 1;
		ud = get(SIMULATION_PARAMETER_HANDLE,'userdata');
		eventlist = ud.AdvancedPage.Children.EventsList;
		set(eventlist,'Value',2);
		set(ud.AdvancedPage.Children.OffRadio,'Value',1,'Enable','on')
		set(ud.AdvancedPage.Children.OnRadio,'Enable','on')
		
	case 'selecton',
		if  ~MERGEDEMO_STEP_COUNTER(5),
			mergedemoscript('selectboolean')
		end
		MERGEDEMO_STEP_COUNTER(6) = 1;
		% Turn the "Boolean logic signals" on
		ud = get(SIMULATION_PARAMETER_HANDLE,'userdata');
		set(ud.AdvancedPage.Children.OffRadio,'Value',0)
		set(ud.AdvancedPage.Children.OnRadio,'Value',1)
		
	case 'pressok',
		% Simulate pressing the OK button on the Simulation Parameter window
		if MERGEDEMO_STEP_COUNTER(3)
			delete(SIMULATION_PARAMETER_HANDLE)
		end
		
		% Regardless of what else might have been changed, only register the boolean signals
		MERGEDEMO_STEP_COUNTER(7) = 1;
		set_param('mergedemo','BooleanDataType','on');
		
	case 'addconversion',
		% Turn on Show Data types, if it is not already on
		if ~MERGEDEMO_STEP_COUNTER(2),
			set_param('mergedemo','ShowPortDataTypes','on')
			set_param('mergedemo','SimulationCommand','update'); 
		end
		
		% Note, this is not robust to blocks having been moved
		MERGEDEMO_STEP_COUNTER(8) = 1;
		
		% Add the block
		add_block('built-in/DataTypeConversion','mergedemo/Data Type Conversion', ...
			'Position',[85 121 145 149]);
		
		% Delete the old line
		B = get_param('mergedemo/Discrete Pulse Generator','PortHandles');
		l = get_param(B.Outport,'Line');
		delete_line(l);
		
		% Add the new line	
		l = add_line('mergedemo','Discrete Pulse Generator/1','Data Type Conversion/1');
		set_param(l,'FontSize',9) % The default fontsize is 18, for some reason
		l = add_line('mergedemo',[150 135; 190 135]);
		set_param(l,'FontSize',9)
		add_line('mergedemo',[190 135; 190 165]);
		add_line('mergedemo',[190 135; 190 99]);

	case 'opendialog',
		% Open the Data Type Conversion block
		open_system('mergedemo/Data Type Conversion')
		
	case 'changedatatype',
		% Change the DataType of the Data Type Conversion block to boolean
		% This is done after closing the block since close_system is not picking up
		% changes made with set_param while the dialog is open.
		if ~MERGEDEMO_STEP_COUNTER(8),
			mergedemoscript('addconversion')
		end
		MERGEDEMO_STEP_COUNTER(9) = 1;
		close_system('mergedemo/Data Type Conversion')
		set_param('mergedemo/Data Type Conversion','DataType','boolean');
		
	case 'openmerge',
		% Open the Merge block's Block Parameter dialog
		open_system('mergedemo/Merge')
		
	case 'setnuminputs'
		% Make sure there are two inputs to the Merge block
		set_param('mergedemo/Merge','Inputs','2');
		
	case 'initialoutput'
		% Make sure the initial output of the Merge block is left empty
		set_param('mergedemo/Merge','InitialOutput','[]');
		
	case 'closemerge',
		% Close the Merge block's Block Parameter dialog
		close_system('mergedemo/Merge')
		
		% Make sure the Initial Output is empty and the number of inputs is two.
		set_param('mergedemo/Merge','Inputs','2');
		set_param('mergedemo/Merge','InitialOutput','[]');
		
	case 'selectlines',
		PH=get_param({'mergedemo/Subsystem';'mergedemo/Subsystem1'},'PortHandles');
		PH=[PH{:}];
		Outs=[PH.Outport];
		hilite_system(Outs);
		pause(2)
		% Wrap in a try catch in case the diagram is closed before this call is made
		hilite_system(Outs,'none');
		
	case 'opensubsystem',
		% Open a Subsystem 
		open_system('mergedemo/Subsystem');
		
	case 'opensfcn',
		% Open the S-function in the MATLAB editor
		edit('mergefcn.m')
		
	case 'run',
		% Run the model
		set_param('mergedemo','SimulationCommand','start'); 
		
	case 'stoprun',
		% Stop the simulation
		set_param('mergedemo','SimulationCommand','stop')
		
	case 'hiliteblock'
		%---hilite appropriate blocks
		blockName = varargin{2};
		b=find_system('mergedemo','SearchDepth',1,'Type','block');
		
		% Hilite the specific block for 2 seconds
		hilite_system(['mergedemo/',blockName],'find')
		pause(2)
		% Wrap in a try catch in case the diagram is closed before this call is made
		hilite_system(['mergedemo/',blockName],'none')
		
    otherwise
		warning('The requested action could not be taken.')
		
	end	 % switch action
	
	
catch
	warndlg({'There was an error executing the link you selected.';
		'Please, restart the demonstration as additional links ';
		'may be broken due to this problem.';
		'';
		'To avoid future errors, please run the links in the order ';
		'in which they occur in the demo.'})
end % Try/catch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          Local functions                         %%

