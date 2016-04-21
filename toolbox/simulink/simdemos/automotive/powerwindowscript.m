function powerwindowscript(varargin)
%   Pieter J. Mosterman
%	Copyright 1990-2004 The MathWorks, Inc.
%	$Revision: 1.3.4.1 $  $Date: 2004/04/15 00:39:16 $

persistent POWERWINDOWDEMO_STEP
persistent POWERWINDOWDEMO_STEPS
persistent LICENSE
try % Wrap the whole thing in a try catch, in case the user doesn't go in order.
	
	ni=nargin;
	
	if ~ni,
		step = 'initialize';
	else 
		step = varargin{1};
	end
	
	% If it is the first time the demo is run, or if the model has been
    % closed, open the model and initialize the counter.
	if isempty(find_system('Name','powerwindow')) | ~ni
		powerwindow;
		POWERWINDOWDEMO_STEP=0;
		POWERWINDOWDEMO_STEPS = char('initialize', ...
                                    'powerwindow cv', ...
                                    'initial powerwindow', ...
                                    'delete output', ...
                                    'add continuous', ...
                                    'delete continuous', ...
                                    'add continuous subsystem', ...
                                    'delete input', ...
                                    'add input subsystems', ...
                                    'delete control', ...
                                    'add control subsystem', ...
                                    'context connect', ...
                                    'add data validation', ...
                                    'delete continuous subsystem', ...
                                    'add power', ...
                                    'delete position detection', ...
                                    'add current detection', ...
                                    'connect current', ... %18
                                    'add object switch', ...
                                    'add VR world', ...
                                    'delete realistic Ia', ...
                                    'realistic Ia', ...
                                    'fixed point processing', ...
                                    'delete DAQ subsystem', ...
                                    'add DAQ subsystem', ...
                                    'delete process', ...
                                    'add process', ...
                                    'delete direct input', ...
                                    'add CAN input', ...
                                    'add CAN output', ...
                                    'sample input', ... %31
                                    'add position detection', ...
                                    'delete control', ...
                                    'add control', ...
                                    'position control', ...
                                    'position switches', ...
                                    'position all');
        LICENSE = 1;
	end
	
	switch step
	case 'initialize',
		% Open the web browser with the html file
        ret = stepTo(POWERWINDOWDEMO_STEP,1,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;
        
		fullPathName=which('powerwindowscript');
		tok=filesep;
		indtok = findstr(fullPathName,tok);
		pathname = fullPathName(1:indtok(end));
		
    case 'open VR world',
        if license('test','Virtual_Reality_Toolbox')==0 
	        warndlg({'You do not have a VR toolbox license available.';
                '';
		        'The VR world is not loaded.'})
            return
        end 

        try
		    open_system('powerwindow/window_world');
        catch
	        warndlg({'Your VR toolbox license is unavailable.';
                '';
		        'The VR world is not loaded.'})
            return;
        end
        
    case 'open control',
		open_system('powerwindow/control','force');
        
    case 'open truth table',
		open_system('powerwindow/passenger neutral, up, down map','force');
        
    case 'subsystem passenger window up',
		if (get_param('powerwindow/passenger_switch/up control','sw') == '0')
            open_system('powerwindow/passenger_switch/up control');
        end
        
    case 'subsystem driver window down',
		if (get_param('powerwindow/driver_switch/down control','sw') == '0')
            open_system('powerwindow/driver_switch/down control');
        end
        
    case 'passenger window up',
		if (get_param('powerwindow/passenger up','sw') == '1')
            open_system('powerwindow/passenger up');
        end
        
    case 'passenger window up release',
		if (get_param('powerwindow/passenger up','sw') == '0')
            open_system('powerwindow/passenger up');
        end
        
    case 'subsystem passenger window up release',
		if (get_param('powerwindow/passenger_switch/up control','sw') == '1')
            open_system('powerwindow/passenger_switch/up control');
        end
        
    case 'subsystem driver window down release',
		if (get_param('powerwindow/driver_switch/down control','sw') == '1')
            open_system('powerwindow/driver_switch/down control');
        end
        
    case 'subsystem driver window up release',
		if (get_param('powerwindow/driver_switch/up control','sw') == '1')
            open_system('powerwindow/driver_switch/up control');
        end
        
    case 'passenger auto up',
        powerwindowscript('passenger window up release');
        pause(0.01);
        powerwindowscript('passenger window up');
        pause(0.1);
        powerwindowscript('passenger window up release');
		
    case 'passenger window down release',
		if (get_param('powerwindow/passenger down','sw') == '0')
		    open_system('powerwindow/passenger down');
        end
        
    case 'driver window down',
		if (get_param('powerwindow/driver down','sw') == '1')
		    open_system('powerwindow/driver down');
        end
        
    case 'driver window down release',
		if (get_param('powerwindow/driver down','sw') == '0')
		    open_system('powerwindow/driver down');
        end
        
    case 'driver window up',
		if (get_param('powerwindow/driver up','sw') == '1')
		    open_system('powerwindow/driver up');
        end

    case 'driver window up release',
		if (get_param('powerwindow/driver up','sw') == '0')
		    open_system('powerwindow/driver up');
        end

    case 'driver window neutral',
		open_system('powerwindow/driver neutral');
        
    case 'endstop',
		if (get_param('powerwindow/endstop','sw') == '1')
		    open_system('powerwindow/endstop');
        end
		
    case 'endstop release',
		if (get_param('powerwindow/endstop','sw') == '0')
		    open_system('powerwindow/endstop');
        end

    case 'obstacle',
		if (get_param('powerwindow/obstacle','sw') == '1')
		    open_system('powerwindow/obstacle');
        end

    case 'obstacle release',
		if (get_param('powerwindow/obstacle','sw') == '0')
		    open_system('powerwindow/obstacle');
        end

    case 'open position scope',
		open_system('powerwindow/position');
        
    case 'open Ia scope',
		open_system('powerwindow/Ia');
        
    case 'open armature current scope',
		open_system('powerwindow/armature_current');
        
    case 'open window force scope',
		open_system('powerwindow/force');

	case 'run',
		% Run the model
        set_param('powerwindow','SimulationCommand','start')
        
    case 'stop',
        set_param('powerwindow','SimulationCommand','stop') 
        
    case 'reset switches',
        powerwindowscript('passenger window up release');
        powerwindowscript('passenger window down release');
        powerwindowscript('driver window up release');
        powerwindowscript('driver window down release');
        if POWERWINDOWDEMO_STEP < 4
            powerwindowscript('endstop release');
            powerwindowscript('obstacle release');
        end

    case 'powerwindow cv',                
        ret = stepTo(POWERWINDOWDEMO_STEP,2,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        delete_line('powerwindow', 'Constant9/1', 'passenger up/1');
        delete_line('powerwindow', 'Constant10/1', 'passenger up/2');
        delete_line('powerwindow', 'Constant2/1', 'passenger down/1');
        delete_line('powerwindow', 'Constant1/1', 'passenger down/2');
        delete_line('powerwindow', 'Constant12/1', 'driver up/1');
        delete_line('powerwindow', 'Constant5/1', 'driver up/2');
        delete_line('powerwindow', 'Constant7/1', 'driver down/1');
        delete_line('powerwindow', 'Constant3/1', 'driver down/2');
        delete_block('powerwindow/Constant9');
        delete_block('powerwindow/Constant10');
        delete_block('powerwindow/Constant2');
        delete_block('powerwindow/Constant1');
        delete_block('powerwindow/Constant12');
        delete_block('powerwindow/Constant5');
        delete_block('powerwindow/Constant7');
        delete_block('powerwindow/Constant3');
        delete_block('powerwindow/passenger up');
        delete_block('powerwindow/passenger down');
        delete_block('powerwindow/driver up');
        delete_block('powerwindow/driver down');

        add_block('simulink/Sources/Repeating Sequence','powerwindow/passenger up', ...
        'position', '[45 61 95 79]');
        set_param('powerwindow/passenger up', 'rep_seq_t','[0 1 2 3 4 5 6]');
        set_param('powerwindow/passenger up', 'rep_seq_y','[0 0 0 0 0 0 0]');

        add_block('simulink/Sources/Repeating Sequence','powerwindow/passenger down', ...
        'position', '[45 116 95 134]');
        set_param('powerwindow/passenger down', 'rep_seq_t','[0 1 2 3 4 5 6]');
        set_param('powerwindow/passenger down', 'rep_seq_y','[0 0 0 1 0 1 1]');

        add_block('simulink/Sources/Repeating Sequence','powerwindow/driver up', ...
        'position', '[45 186 95 204]');
        set_param('powerwindow/driver up', 'rep_seq_t','[0 1 2 3 4 5 6]');
        set_param('powerwindow/driver up', 'rep_seq_y','[0 0 1 0 1 0 1]');

        add_block('simulink/Sources/Repeating Sequence','powerwindow/driver down', ...
        'position', '[45 241 95 259]');
        set_param('powerwindow/driver down', 'rep_seq_t','[0 1 2 3 4 5 6]');
        set_param('powerwindow/driver down', 'rep_seq_y','[0 1 0 0 1 1 0]');

    case 'model coverage',     
        if license('test','SL_Verification_Validation')==0 
	        warndlg({'You do not have a license to perform coverage analysis available.';
                '';
		        'The coverage analysis is not performed.'})
            LICENSE = 0; %set flag to abort sequence of build actions
            return;
        end 
%        simin = [0     0     0     0     0;
%                 1     0     0     0     1;
%                 2     0     0     1     0;
%                 3     0     1     0     0;
%                 4     0     0     1     1;
%                 5     0     1     0     1;
%                 6     0     1     1     0];
             
        feature('InsureSingleRateEnableTriggerSignal',0);

        testObj1 = cvtest('powerwindow', 'first_test');
        [dataObj1, T, X, Y] = cvsim(testObj1, [0 7]);
        cvhtml('powerwindow report',dataObj1);

    case 'initial powerwindow',
        ret = stepTo(POWERWINDOWDEMO_STEP,3,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        delete_line('powerwindow', 'passenger up/1', 'Mux4/1');
        delete_line('powerwindow', 'passenger down/1', 'Mux4/2');
        delete_line('powerwindow', 'driver up/1', 'Mux1/1');
        delete_line('powerwindow', 'driver down/1', 'Mux1/2');
        
        delete_block('powerwindow/passenger up');
        delete_block('powerwindow/passenger down');
        delete_block('powerwindow/driver up');
        delete_block('powerwindow/driver down');

        add_block('simulink/Sources/Constant','powerwindow/Constant9', ...
        'position', '[15 51 35 69]','showName','off');
        add_block('simulink/Sources/Constant','powerwindow/Constant10', ...
        'position', '[15 71 35 89]','showName','off');
        add_block('simulink/Sources/Constant','powerwindow/Constant2', ...
        'position', '[15 106 35 124]','showName','off');
        add_block('simulink/Sources/Constant','powerwindow/Constant1', ...
        'position', '[15 126 35 144]','showName','off');
        add_block('simulink/Sources/Constant','powerwindow/Constant12', ...
        'position', '[15 176 35 194]','showName','off');
        add_block('simulink/Sources/Constant','powerwindow/Constant5', ...
        'position', '[15 196 35 214]','showName','off');
        add_block('simulink/Sources/Constant','powerwindow/Constant7', ...
        'position', '[15 231 35 249]','showName','off');
        add_block('simulink/Sources/Constant','powerwindow/Constant3', ...
        'position', '[15 251 35 269]','showName','off');
    
        set_param('powerwindow/Constant9', 'Value','0');
        set_param('powerwindow/Constant2', 'Value','0');
        set_param('powerwindow/Constant12', 'Value','0');
        set_param('powerwindow/Constant7', 'Value','0');

        add_block(sprintf('simulink/Signal\nRouting/Manual Switch'),'powerwindow/passenger up', ...
            'Position',[60 52 90 88]);
        add_block(sprintf('simulink/Signal\nRouting/Manual Switch'),'powerwindow/passenger down', ...
            'Position',[60 107 90 143]);
        add_block(sprintf('simulink/Signal\nRouting/Manual Switch'),'powerwindow/driver up', ...
            'Position',[60 177 90 213]);
        add_block(sprintf('simulink/Signal\nRouting/Manual Switch'),'powerwindow/driver down', ...
            'Position',[60 232 90 268]);

        add_line('powerwindow', 'Constant9/1', 'passenger up/1');
        add_line('powerwindow', 'Constant10/1', 'passenger up/2');
        add_line('powerwindow', 'Constant2/1', 'passenger down/1');
        add_line('powerwindow', 'Constant1/1', 'passenger down/2');
        add_line('powerwindow', 'Constant12/1', 'driver up/1');
        add_line('powerwindow', 'Constant5/1', 'driver up/2');
        add_line('powerwindow', 'Constant7/1', 'driver down/1');
        add_line('powerwindow', 'Constant3/1', 'driver down/2');
        
        add_line('powerwindow', 'passenger up/1', 'Mux4/1');
        add_line('powerwindow', 'passenger down/1', 'Mux4/2');
        add_line('powerwindow', 'driver up/1', 'Mux1/1');
        add_line('powerwindow', 'driver down/1', 'Mux1/2');

    case 'reset subsystem switches',
		if (get_param('powerwindow/passenger_switch/up control','sw') == '1')
            open_system('powerwindow/passenger_switch/up control');
        end
		if (get_param('powerwindow/passenger_switch/down control','sw') == '1')
            open_system('powerwindow/passenger_switch/down control');
        end
		if (get_param('powerwindow/driver_switch/up control','sw') == '1')
            open_system('powerwindow/driver_switch/up control');
        end
		if (get_param('powerwindow/driver_switch/down control','sw') == '1')
            open_system('powerwindow/driver_switch/down control');
        end
        
    case 'remove position detection'
        if POWERWINDOWDEMO_STEP == 15
            hilite_system('powerwindow/power_window_control_system/detect_obstacle_endstop','find');
		    pause(0.75)	
            hilite_system('powerwindow/power_window_control_system/detect_obstacle_endstop','none');
        end
        powerwindowscript('delete position detection');

    case 'remove output'
        if POWERWINDOWDEMO_STEP == 3
            powerwindowscript('highlight output');
        end
        powerwindowscript('delete output');

    case 'remove continuous'
        if POWERWINDOWDEMO_STEP == 5
            powerwindowscript('highlight continuous');
        end
        powerwindowscript('delete continuous');

    case 'remove continuous subsystem'
        if POWERWINDOWDEMO_STEP == 15
            hilite_system('powerwindow/window_system','find');
		    pause(0.75)	
            hilite_system('powerwindow/window_system','none');
        end
        powerwindowscript('delete continuous subsystem');

    case 'remove input'
        if POWERWINDOWDEMO_STEP == 7
            powerwindowscript('highlight input');
        end
        powerwindowscript('delete input');

    case 'delete output'
        ret = stepTo(POWERWINDOWDEMO_STEP,4,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        delete_line('powerwindow','outputMux/1','window command/1');
        delete_line('powerwindow','control/1','outputMux/1');
        delete_line('powerwindow','control/2','outputMux/2');
        delete_block('powerwindow/outputMux');
        delete_block('powerwindow/window command');

        delete_line('powerwindow','Constant13/1','endstop/1');
        delete_line('powerwindow','Constant14/1','endstop/2');
        delete_line('powerwindow','endstop/1','control/3');
        delete_block('powerwindow/Constant13');
        delete_block('powerwindow/Constant14');
        delete_block('powerwindow/endstop');

        delete_line('powerwindow','Constant15/1','obstacle/1');
        delete_line('powerwindow','Constant16/1','obstacle/2');
        delete_line('powerwindow','obstacle/1','control/4');
        delete_block('powerwindow/Constant15');
        delete_block('powerwindow/Constant16');
        delete_block('powerwindow/obstacle');

    case 'include data validation'
         if POWERWINDOWDEMO_STEP == 13
            hilite_system('powerwindow/power_window_control_system','find');
		    pause(0.75)	
            hilite_system('powerwindow/power_window_control_system','none');
		    open_system('powerwindow/power_window_control_system');            
		    pause(0.75)	
        end
        
        powerwindowscript('add data validation'); 
        
    case 'add data validation'
        ret = stepTo(POWERWINDOWDEMO_STEP,13,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;
        
        add_block('built-in/Reference','powerwindow/power_window_control_system/validate_driver', ...
            'Position',[210, 70, 330, 200],'SourceBlock','powerwindowlibsa/validate_state');
        set_param('powerwindow/power_window_control_system/validate_driver','LinkStatus','inactive')
        add_block('built-in/Reference','powerwindow/power_window_control_system/validate_passenger', ...
            'Position',[210, 225, 330, 355],'SourceBlock','powerwindowlibsa/validate_state');
        set_param('powerwindow/power_window_control_system/validate_passenger','LinkStatus','inactive')
        
        l = add_line('powerwindow/power_window_control_system','driver_neutral/1','validate_driver/1');
		set_param(l,'FontSize',9) % The default fontsize is 18, for some reason
        l = add_line('powerwindow/power_window_control_system','driver_up/1','validate_driver/2');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/power_window_control_system','driver_down/1','validate_driver/3');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/power_window_control_system','driver_reset/1','validate_driver/4');
		set_param(l,'FontSize',9) 

        l = add_line('powerwindow/power_window_control_system','passenger_neutral/1','validate_passenger/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/power_window_control_system','passenger_up/1','validate_passenger/2');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/power_window_control_system','passenger_down/1','validate_passenger/3');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/power_window_control_system','passenger_reset/1','validate_passenger/4');
		set_param(l,'FontSize',9) 

        l = add_line('powerwindow/power_window_control_system','validate_driver/1','control/3','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/power_window_control_system','validate_passenger/1','control/4','autorouting','on');
		set_param(l,'FontSize',9) 

    case 'add continuous'
        ret = stepTo(POWERWINDOWDEMO_STEP,5,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;
        
        % Add the block
		add_block('built-in/Switch',sprintf('powerwindow/up signal\nconversion'), ...
			'Position',[470, 115, 500, 145],'threshold','0.5');
		add_block('built-in/Switch',sprintf('powerwindow/down signal\nconversion'), ...
			'Position',[465, 250, 495, 280],'threshold','0.5');
        
		add_block('built-in/Constant',sprintf('powerwindow/up\nrate'), ...
			'Position',[415, 105, 435, 125],'NamePlacement','alternate', ...
            'Value','1');
		add_block('built-in/Constant','powerwindow/c0', ...
			'Position',[415, 135, 435, 155],'showName','off', ...
            'Value','0');
		add_block('built-in/Constant',sprintf('powerwindow/down\nrate'), ...
			'Position',[415, 240, 435, 260],'NamePlacement','alternate', ...
            'Value','-1');
		add_block('built-in/Constant','powerwindow/c1', ...
			'Position',[415, 270, 435, 290],'showName','off', ...
            'Value','0');
        
        add_block('built-in/Sum','powerwindow/window input', ...
			'Position',[540, 185, 560, 205],'showName','off', ...
            'Inputs','|++-','IconShape','round');

        add_block('built-in/Gain','powerwindow/gain', ...
			'Position',[610, 180, 640, 210],'gain','50');
        add_block('built-in/Gain','powerwindow/friction', ...
			'Position',[620, 235, 650, 265],'gain','10','Orientation','left');
        
        add_block('built-in/Integrator','powerwindow/angular velocity', ...
			'Position',[685, 180, 715, 210]);
        add_block('built-in/Integrator','powerwindow/window position', ...
			'Position',[765, 180, 795, 210]);

        add_block('built-in/Scope','powerwindow/position', ...
			'Position',[875, 179, 905, 211],'Location',[6, 532, 329, 734], ...
            'YMin','-0.05','YMax','0.5', ...
            'ForegroundColor','gray','LimitDataPoints','off');

        add_block('built-in/Relational Operator','powerwindow/top', ...
			'Position',[510, 407, 540, 438],'Operator','>','Orientation','left','ForegroundColor','magenta');
        add_block('built-in/Relational Operator','powerwindow/obstacle', ...
			'Position',[510, 352, 540, 383],'Operator','>','Orientation','left','ForegroundColor','magenta');
        add_block('built-in/Constant','powerwindow/c101', ...
			'Position',[585, 418, 615, 442],'Value','0.4','Orientation','left','ForegroundColor','magenta');
        add_block('built-in/Constant','powerwindow/c102', ...
			'Position',[585, 363, 615, 387],'Value','0.3','Orientation','left','ForegroundColor','magenta');

        l = add_line('powerwindow','up rate/1','up signal conversion/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','c0/1','up signal conversion/3');
		set_param(l,'FontSize',9) 

        l = add_line('powerwindow','down rate/1','down signal conversion/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','c1/1','down signal conversion/3');
		set_param(l,'FontSize',9) 

        l = add_line('powerwindow','up signal conversion/1','window input/1');
		set_param(l,'FontSize',9) 

        l = add_line('powerwindow','down signal conversion/1','window input/2');
		set_param(l,'FontSize',9) 

        l = add_line('powerwindow','control/1','up signal conversion/2');
		set_param(l,'FontSize',9) 

        l = add_line('powerwindow','control/2','down signal conversion/2');
		set_param(l,'FontSize',9) 

        l = add_line('powerwindow','window input/1','gain/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','gain/1','angular velocity/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','angular velocity/1','window position/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow',[725 195; 725 250; 650 250]);
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','window position/1','position/1','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','friction/1','window input/3','autorouting','on');
		set_param(l,'FontSize',9) 

        l = add_line('powerwindow',[800 195; 800 415; 540 415]);
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow',[800 360; 540 360]);
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','c101/1','top/2');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','c102/1','obstacle/2');
		set_param(l,'FontSize',9) 
        
        l = add_line('powerwindow','top/1','control/3','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','obstacle/1','control/4','autorouting','on');
		set_param(l,'FontSize',9) 
        powerwindowscript('resize for continuous plant');        
        
    case 'ode23'
		set_param('powerwindow','Solver','ode23')
        
    case 'ode23s'
		set_param('powerwindow','Solver','ode23s')
        
    case 'ode23t'
		set_param('powerwindow','Solver','ode23t')
        set_param('powerwindow','reltol','1e-2')
        
    case 'ode23tb'
		set_param('powerwindow','Solver','ode23tb')
        
    case 'show sample rates'
        powerwindowscript('ode23s'); 

		set_param('powerwindow','SampleTimeColors','on')
        powerwindow( [ ], [ ], [ ], 'compile')
        powerwindow([ ], [ ], [ ], 'term')
        
    case 'RT'
		set_param('powerwindow','Solver','ode1')        
		set_param('powerwindow','FixedStep','0.005')        

    case 'delete continuous'
        ret = stepTo(POWERWINDOWDEMO_STEP,6,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        delete_line('powerwindow','control/1','up signal conversion/2');
        delete_line('powerwindow','control/2','down signal conversion/2');
        delete_line('powerwindow','up rate/1','up signal conversion/1');
        delete_line('powerwindow','c0/1','up signal conversion/3');
        delete_line('powerwindow','down rate/1','down signal conversion/1');
        delete_line('powerwindow','c1/1','down signal conversion/3');
        delete_line('powerwindow','up signal conversion/1','window input/1');
        delete_line('powerwindow','down signal conversion/1','window input/2');
        delete_line('powerwindow','friction/1','window input/3');
        delete_line('powerwindow','window input/1','gain/1');
        delete_line('powerwindow','gain/1','angular velocity/1');
        delete_line('powerwindow','angular velocity/1','friction/1');
        delete_line('powerwindow','angular velocity/1','window position/1');
        delete_line('powerwindow','window position/1','position/1');
        delete_line('powerwindow','window position/1','obstacle/1');
        delete_line('powerwindow','window position/1','top/1');
        
        delete_block('powerwindow/up rate');
        delete_block('powerwindow/c0');
        delete_block('powerwindow/down rate');
        delete_block('powerwindow/c1');
        delete_block('powerwindow/up signal conversion');
        delete_block('powerwindow/down signal conversion');
        delete_block('powerwindow/window input');
        delete_block('powerwindow/friction');
        delete_block('powerwindow/gain');
        delete_block('powerwindow/angular velocity');
        delete_block('powerwindow/window position');
        
    case 'delete position detection'
        ret = stepTo(POWERWINDOWDEMO_STEP,16,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        delete_block('powerwindow/power_window_control_system/detect_obstacle_endstop');
        
    case 'include current detection'
         if POWERWINDOWDEMO_STEP == 16
            hilite_system('powerwindow/power_window_control_system','find');
		    pause(0.75)	
            hilite_system('powerwindow/power_window_control_system','none');
		    open_system('powerwindow/power_window_control_system');            
		    pause(0.75)	
        end
        
        powerwindowscript('add current detection'); 
        
    case 'add current detection'
        ret = stepTo(POWERWINDOWDEMO_STEP,17,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        add_block('built-in/Reference','powerwindow/power_window_control_system/detect_obstacle_endstop', ...
            'Position',[510, 24, 635, 96],'SourceBlock','powerwindowlibsa/verify_current');
        set_param('powerwindow/power_window_control_system/detect_obstacle_endstop','LinkStatus','inactive')
        set_param('powerwindow/power_window_control_system/detect_obstacle_endstop','Orientation','left')
        set_param('powerwindow/power_window_control_system/detect_obstacle_endstop','Position',[515, 24, 640, 96])

        set_param('powerwindow/power_window_control_system/position','Name','armature_current')
        
    case 'add object switch'
        ret = stepTo(POWERWINDOWDEMO_STEP,19,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        x_offset = 400;
        add_block('built-in/GoTo','powerwindow/Goto1', ...
            'Position',[x_offset+165, 265, x_offset+255, 285],'TagVisibility','global', ...
            'ShowName','off','GotoTag','object_present');
        add_block('built-in/Constant',sprintf('powerwindow/present'), ...
            'Position',[x_offset+35, 258, x_offset+60, 272],'NamePlacement','alternate', ...
            'Value','1');
        add_block('built-in/Constant','powerwindow/absent', ...
            'Position',[x_offset+35, 278, x_offset+60, 292], ...
            'Value','0');
        add_block('built-in/Reference','powerwindow/object', ...
            'Position',[x_offset+105, 255, x_offset+140, 295],'BackgroundColor','cyan', ...
            'SourceBlock','simulink3/Nonlinear/Manual Switch');
        %For some reason this has to be moved around to make the lines connect.
        set_param('powerwindow/object','NamePlacement','normal')

        l = add_line('powerwindow','present/1','object/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','absent/1','object/2');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','object/1','Goto1/1');
		set_param(l,'FontSize',9) 
 
    case 'add VR world'
        ret = stepTo(POWERWINDOWDEMO_STEP,20,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;
        
        if license('test','Virtual_Reality_Toolbox')==0 
	        warndlg({'You do not have a VR toolbox license available.';
                '';
		        'The VR world is not loaded.'})
            return
        end 
        
        add_block('built-in/Reference','powerwindow/window_world', ...
            'Position',[555, 185, 685, 215],'SourceBlock','powerwindowlibsa/window_world');
        set_param('powerwindow/window_world','LinkStatus','inactive')
        set_param('powerwindow/window_world','BackgroundColor','cyan')
        
        try
            add_block('built-in/Reference','powerwindow/window_world/VR Sink', ...
                'Position',[950, 131, 1060, 459],'SourceBlock','vrlib/VR Sink', ...
                'WorldFileName','pw_mech_window_world.wrl','WorldDescription','VR Power Window Model', ...
                'FieldsWritten','balloon.scale#glass.rotation#glass.translation#planetROT.rotation#plannet_connect.translation#support.translation#supportROT.rotation#support_connect.translation#worm.rotation');
        catch
	        warndlg({'Your VR toolbox license is unavailable.';
                '';
		        'The VR world is not loaded.'})
            return;
        end

        l = add_line('powerwindow/window_world','Product3/1','VR Sink/1','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_world','Mux1/1','VR Sink/2','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_world','Mux/1','VR Sink/3','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_world','Mux6/1','VR Sink/4','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_world','Mux3/1','VR Sink/5','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_world','Mux5/1','VR Sink/6','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_world','Mux4/1','VR Sink/7','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_world','Mux7/1','VR Sink/8','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_world','Mux2/1','VR Sink/9','autorouting','on');
		set_param(l,'FontSize',9) 

        l = add_line('powerwindow','window_system/4','window_world/1');
		set_param(l,'FontSize',9) 
 
    case 'connect current'
        ret = stepTo(POWERWINDOWDEMO_STEP,18,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        add_block('built-in/Scope','powerwindow/armature_current', ...
			'Position',[555, 54, 585, 76],'ForegroundColor','gray','LimitDataPoints','off');
        add_block('built-in/Scope','powerwindow/force', ...
			'Position',[555, 99, 585, 121],'ForegroundColor','gray','LimitDataPoints','off');
		set_param('powerwindow/position','Position',[555, 144, 585, 166]) 

        l = add_line('powerwindow','window_system/1','armature_current/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','window_system/2','force/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','window_system/1','power_window_control_system/1','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','window_system/3','position/1');
		set_param(l,'FontSize',9) 
        
    case 'delete continuous subsystem'
        ret = stepTo(POWERWINDOWDEMO_STEP,14,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        delete_line('powerwindow','power_window_control_system/1','window_system/1');
        delete_line('powerwindow','power_window_control_system/2','window_system/2');
        delete_line('powerwindow','window_system/1','power_window_control_system/1');
        delete_line('powerwindow','window_system/1','position/1');
        
        delete_block('powerwindow/window_system');
        
    case 'context plant'
        powerwindowscript('remove continuous');
        powerwindowscript('add continuous subsystem');

     case 'add continuous subsystem'
        ret = stepTo(POWERWINDOWDEMO_STEP,7,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        add_block('built-in/Reference','powerwindow/window_system', ...
            'Position',[475, 43, 615, 227],'SourceBlock','powerwindowlibsa/2nd_order_window_system');
        set_param('powerwindow/window_system','LinkStatus','inactive')
        
    case 'context switches'
        powerwindowscript('remove input');
        powerwindowscript('add input subsystems');
        
    case 'add input subsystems'
        ret = stepTo(POWERWINDOWDEMO_STEP,9,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        add_block('built-in/Reference','powerwindow/driver_switch', ...
            'Position',[25, 81, 115, 139],'SourceBlock','powerwindowlibsa/switch');
        set_param('powerwindow/driver_switch','LinkStatus','inactive')
        add_block('built-in/Reference',sprintf('powerwindow/passenger_switch'), ...
            'Position',[25, 156, 115, 214],'SourceBlock','powerwindowlibsa/switch');
        set_param('powerwindow/passenger_switch','LinkStatus','inactive')
        
    case 'add power'
        ret = stepTo(POWERWINDOWDEMO_STEP,15,POWERWINDOWDEMO_STEPS);
        
        if license('test','SimMechanics')==0 
	        warndlg({'You do not have a SimMechanics license available.';
                '';
		        'The detailed plant model is not loaded.'})
            LICENSE = 0;
            return;
        end 
        if license('test','Power_System_Blocks')==0 
	        warndlg({'You do not have a SimPowerSystems license available.';
                '';
		        'The detailed plant model is not loaded.'})
            LICENSE = 0;
           return;
        end 
        
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        try
            add_block('built-in/Reference','powerwindow/window_system', ...
                'Position',[375, 40, 515, 220],'SourceBlock','powerwindowlibphys/detailed_window_system');
        catch
	        warndlg({'Your SimMechanics or SimPowerSystems license is unavailable.';
                '';
		        'The detailed plant model is not loaded.'})
            return;
        end
        
        set_param('powerwindow/window_system','LinkStatus','inactive')
        set_param('powerwindow/window_system/actuator','LinkStatus','inactive')
        set_param('powerwindow/window_system/plant','LinkStatus','inactive')
        set_param('powerwindow/window_system/plant/window','LinkStatus','inactive')
        
        l = add_line('powerwindow','power_window_control_system/1','window_system/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','power_window_control_system/2','window_system/2');
		set_param(l,'FontSize',9) 
        
    case 'zoom Ia'
		close_system('powerwindow/armature_current','force');
		set_param('powerwindow/armature_current','TimeRange','0.8','YMin','-8','YMax','8');
		open_system('powerwindow/armature_current','force');
        
    case 'resize for continuous plant'
        p = get_param('powerwindow', 'Location');
        p(3) = p(1) + 915;
        p(4) = p(2) + 465;

		set_param('powerwindow','Location',p);
        
    case 'resize for power'
        p = get_param('powerwindow', 'Location');
        p(3) = p(1) + 935;
        p(4) = p(2) + 465;

		set_param('powerwindow','Location',p);
        
    case 'resize for reorganize'
        p = get_param('powerwindow', 'Location');
        p(3) = p(1) + 815;
        p(4) = p(2) + 300;

		set_param('powerwindow','Location',p);
        
    case 'resize for context diagram'
        p = get_param('powerwindow', 'Location');
        p(3) = p(1) + 635;
        p(4) = p(2) + 265;

		set_param('powerwindow','Location',p);
        
    case 'resize for object switch'
        p = get_param('powerwindow', 'Location');
        p(3) = p(1) + 705;
        p(4) = p(2) + 305;

		set_param('powerwindow','Location',p);
        
   case 'prepare realistic Ia'
        if POWERWINDOWDEMO_STEP == 20
            hilite_system('powerwindow/window_system/decouple up','find');
            hilite_system('powerwindow/window_system/decouple down','find');
		    pause(0.75)	
            hilite_system('powerwindow/window_system/decouple up','none');
            hilite_system('powerwindow/window_system/decouple down','none');
        end
        powerwindowscript('delete realistic Ia'); 
        
   case 'delete realistic Ia'
        ret = stepTo(POWERWINDOWDEMO_STEP,21,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        delete_line('powerwindow/window_system','move_up/1','decouple up/1');
        delete_line('powerwindow/window_system','move_down/1','decouple down/1');

        delete_line('powerwindow/window_system','decouple up/1','amplification up/1');
        delete_line('powerwindow/window_system','decouple down/1','amplification down/1');
        delete_line('powerwindow/window_system','amplification up/RConn1','actuator/LConn2');
         
        delete_line('powerwindow/window_system','actuator/1','armature_current/1');
 
        delete_block('powerwindow/window_system/decouple up');
        delete_block('powerwindow/window_system/decouple down');

    case 'include realistic Ia'
         if POWERWINDOWDEMO_STEP == 21
		    open_system('powerwindow/window_system');            
		    pause(0.75)	
        end
        
        powerwindowscript('realistic Ia'); 
       
   case 'fixed point processing'    
        if POWERWINDOWDEMO_STEP == 22
            hilite_system('powerwindow/power_window_control_system/detect_obstacle_endstop','find');
		    pause(0.75)	
            hilite_system('powerwindow/power_window_control_system/detect_obstacle_endstop','none');
        end
        
        ret = stepTo(POWERWINDOWDEMO_STEP,23,POWERWINDOWDEMO_STEPS);
        
        if license('test','Fixed-Point_Blocks')==0 
	        warndlg({'You do not have a fixed point blocks license available.';
                '';
		        'The fixed point processing model part is not loaded.'})
            return;
        end 
        
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        delete_block('powerwindow/power_window_control_system/detect_obstacle_endstop');

        try
            add_block('built-in/Reference','powerwindow/power_window_control_system/detect_obstacle_endstop', ...
                'Position',[510, 24, 635, 96],'SourceBlock','powerwindowlibsa/fp_verify_current');
        catch
	        warndlg({'Your fixed point blocks license is unavailable.';
                '';
		        'The fixed point processing model part is not loaded.'})
            return;
        end
        
        set_param('powerwindow/power_window_control_system/detect_obstacle_endstop','LinkStatus','inactive')
        set_param('powerwindow/power_window_control_system/detect_obstacle_endstop','Orientation','left')
        set_param('powerwindow/power_window_control_system/detect_obstacle_endstop','Position',[515, 24, 640, 96])
            
        hilite_system('powerwindow/power_window_control_system/detect_obstacle_endstop/process_current','find');
		pause(0.75)	
        hilite_system('powerwindow/power_window_control_system/detect_obstacle_endstop/process_current','none');
              
    case 'realistic Ia'    
        ret = stepTo(POWERWINDOWDEMO_STEP,22,POWERWINDOWDEMO_STEPS);

        if license('test','Signal_Blocks')==0
	        warndlg({'You do not have a Signal Processing Blockset license available.';
                '';
		        'The detailed measurement model is not loaded.'})
            LICENSE = 0;
            return;
        end 

        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;
        
        add_block('built-in/ZeroOrderHold','powerwindow/window_system/DAC up', ...
            'Position',[85, 150, 115, 180],'SampleTime','0.01', ...
            'ForegroundColor','darkGreen','NamePlacement','alternate');
        add_block('built-in/ZeroOrderHold','powerwindow/window_system/DAC down', ...
            'Position',[85, 190, 115, 220],'SampleTime','0.01', ...
            'ForegroundColor','darkGreen');

        try
            load_system('powerwindowlibdsp');
            set_param(bdroot('powerwindowlibdsp'),'Lock','off');
            add_block(sprintf('powerwindowlibdsp/measurement\nconditioning'),sprintf('powerwindow/window_system/Ia measurement\nconditioning'), ...
                'Position',[260, 155, 300, 190], 'ForegroundColor','darkGreen');
        catch
	        warndlg({'Your DSP license is unavailable.';
                '';
		        'The detailed measurement model is not loaded.'})
            return;
        end
        
        add_block('powerwindowlibdsp/ADC','powerwindow/window_system/ADC Ia', ...
                'Position',[320, 13, 360, 47], 'ForegroundColor','darkGreen');
        
        set_param('powerwindow/window_system/armature_current','Position','[445   23   475   37]');

        l = add_line('powerwindow/window_system','move_up/1','DAC up/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_system','move_down/1','DAC down/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_system','DAC up/1','amplification up/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_system','DAC down/1','amplification down/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_system','amplification up/RConn1','Ia measurement conditioning/LConn1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_system','Ia measurement conditioning/RConn1','actuator/LConn2');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_system','Ia measurement conditioning/1','ADC Ia/1','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_system','ADC Ia/1','armature_current/1','autorouting','on');
		set_param(l,'FontSize',9) 
    
    case 'highlight input'
        powerwindowscript('highlight passenger and driver switches');
        powerwindowscript('highlight maps');
        
    case 'highlight passenger and driver switches'
        hilite_system('powerwindow/passenger up','find');
        hilite_system('powerwindow/passenger down','find');
        hilite_system('powerwindow/driver up','find');
        hilite_system('powerwindow/driver down','find');

		pause(0.75)	
        
        hilite_system('powerwindow/passenger up','none');
        hilite_system('powerwindow/passenger down','none');
        hilite_system('powerwindow/driver up','none');
        hilite_system('powerwindow/driver down','none');
        
    case 'highlight thresholds'
        hilite_system('powerwindow/c101','find');
        hilite_system('powerwindow/c102','find');

		pause(0.75)	
        
        hilite_system('powerwindow/c101','none');
        hilite_system('powerwindow/c102','none');
        
   case 'highlight output'
        hilite_system('powerwindow/outputMux','find');
        hilite_system('powerwindow/window command','find');

        hilite_system('powerwindow/Constant13','find');
        hilite_system('powerwindow/Constant14','find');
        hilite_system('powerwindow/endstop','find');

        hilite_system('powerwindow/Constant15','find');
        hilite_system('powerwindow/Constant16','find');
        hilite_system('powerwindow/obstacle','find');
        
		pause(0.75)	
        
        hilite_system('powerwindow/outputMux','none');
        hilite_system('powerwindow/window command','none');

        hilite_system('powerwindow/Constant13','none');
        hilite_system('powerwindow/Constant14','none');
        hilite_system('powerwindow/endstop','none');

        hilite_system('powerwindow/Constant15','none');
        hilite_system('powerwindow/Constant16','none');
        hilite_system('powerwindow/obstacle','none');

        
   case 'highlight continuous'
        hilite_system('powerwindow/up rate','find');
        hilite_system('powerwindow/c0','find');
        hilite_system('powerwindow/down rate','find');
        hilite_system('powerwindow/c1','find');
        hilite_system('powerwindow/up signal conversion','find');
        hilite_system('powerwindow/down signal conversion','find');
        hilite_system('powerwindow/window input','find');
        hilite_system('powerwindow/friction','find');
        hilite_system('powerwindow/gain','find');
        hilite_system('powerwindow/angular velocity','find');
        hilite_system('powerwindow/window position','find');
        
		pause(0.75)	
        
        hilite_system('powerwindow/up rate','none');
        hilite_system('powerwindow/c0','none');
        hilite_system('powerwindow/down rate','none');
        hilite_system('powerwindow/c1','none');
        hilite_system('powerwindow/up signal conversion','none');
        hilite_system('powerwindow/down signal conversion','none');
        hilite_system('powerwindow/window input','none');
        hilite_system('powerwindow/friction','none');
        hilite_system('powerwindow/gain','none');
        hilite_system('powerwindow/angular velocity','none');
        hilite_system('powerwindow/window position','none');
        
   case 'highlight continuous subsystem'
        hilite_system('powerwindow/window_system','find');
        
		pause(0.75)	
        
        hilite_system('powerwindow/window_system','none');
        
    case 'highlight DAQ subsystem'
        %set_param('powerwindow/amplification up','BackgroundColor','blue');
        
		hilite_system('powerwindow/window_system/DAC up','find')
		hilite_system('powerwindow/window_system/DAC down','find')
		hilite_system('powerwindow/window_system/amplification up','find')
		hilite_system('powerwindow/window_system/amplification down','find')
		hilite_system('powerwindow/window_system/Ia measurement conditioning','find')
		hilite_system('powerwindow/window_system/ADC Ia','find')

        pause(0.75)	
		
        hilite_system('powerwindow/window_system/DAC up','none')
		hilite_system('powerwindow/window_system/DAC down','none')
		hilite_system('powerwindow/window_system/amplification up','none')
		hilite_system('powerwindow/window_system/amplification down','none')
		hilite_system('powerwindow/window_system/Ia measurement conditioning','none')
		hilite_system('powerwindow/window_system/ADC Ia','none')
        
    case 'highlight process'
		hilite_system('powerwindow/window_system/actuator','find')
		hilite_system('powerwindow/window_system/plant','find')
        
		pause(0.75)	
        
        hilite_system('powerwindow/window_system/actuator','none')
		hilite_system('powerwindow/window_system/plant','none')

    case 'delete DAQ subsystem'
        ret = stepTo(POWERWINDOWDEMO_STEP,24,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        delete_line('powerwindow/window_system','move_up/1','DAC up/1');
        delete_line('powerwindow/window_system','move_down/1','DAC down/1');
        delete_line('powerwindow/window_system','DAC up/1','amplification up/1');
        delete_line('powerwindow/window_system','DAC down/1','amplification down/1');
        
        portHandles = get_param('powerwindow/window_system/Vbattery 12[V]','PortHandles');
        l1 = get_param(portHandles.RConn(1),'line');
        delete_line(l1);
        
        portHandles = get_param(sprintf('powerwindow/window_system/amplification\nup'),'PortHandles');
        l1 = get_param(portHandles.LConn(1),'line');
        l2 = get_param(portHandles.RConn(1),'line');
        delete_line(l1);
        delete_line(l2);

        portHandles = get_param(sprintf('powerwindow/window_system/amplification\ndown'),'PortHandles');
        l1 = get_param(portHandles.LConn(1),'line');
        l2 = get_param(portHandles.RConn(1),'line');
        delete_line(l1);
        delete_line(l2);

        portHandles = get_param(sprintf('powerwindow/window_system/Ia measurement\nconditioning'),'PortHandles');
        l1 = get_param(portHandles.RConn(1),'line');
        delete_line(l1);
        
        delete_line('powerwindow/window_system','Ia measurement conditioning/1','ADC Ia/1');
        delete_line('powerwindow/window_system','ADC Ia/1','armature_current/1');
        
        delete_block('powerwindow/window_system/DAC up');
        delete_block('powerwindow/window_system/DAC down');
        delete_block('powerwindow/window_system/amplification up');
        delete_block('powerwindow/window_system/amplification down');
		delete_block('powerwindow/window_system/Ia measurement conditioning')
		delete_block('powerwindow/window_system/ADC Ia')
        
    case 'add DAQ subsystem'
        ret = stepTo(POWERWINDOWDEMO_STEP,25,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        add_block(sprintf('powerwindowlibdsp/window\nDAQ'),sprintf('powerwindow/window_system/window DAQ'), ...
            'Position',[205, 114, 275, 226], 'ForegroundColor','darkGreen');

        l = add_line('powerwindow/window_system','move_up/1','window DAQ/1','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_system','move_down/1','window DAQ/2','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_system','window DAQ/1','armature_current/1','autorouting','on');
		set_param(l,'FontSize',9) 
        
        l = add_line('powerwindow/window_system','Vbattery 12[V]/Rconn1','window DAQ/LConn1','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_system','Vbattery 12[V]/Rconn1','actuator/LConn1','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_system','window DAQ/RConn1','actuator/LConn2','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_system','window DAQ/RConn2','actuator/LConn3','autorouting','on');
		set_param(l,'FontSize',9)
        
        set_param('powerwindow/window_system/window DAQ','Position',[205, 116, 280, 234]);
        set_param('powerwindow/window_system/move_up','Position',[25, 128, 55, 142]);
        set_param('powerwindow/window_system/move_down','Position',[25, 168, 55, 182]);
        
    case 'delete process'
        ret = stepTo(POWERWINDOWDEMO_STEP,26,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        delete_line('powerwindow/window_system','plant/1','actuator/1');
        delete_line('powerwindow/window_system','actuator/2','plant/1');
        delete_line('powerwindow/window_system','plant/2','window kinematics/1');
        delete_line('powerwindow/window_system','plant/3','gear angle/1');

        portHandles = get_param('powerwindow/window_system/actuator','PortHandles');
        l1 = get_param(portHandles.LConn(1),'line');
        l2 = get_param(portHandles.LConn(2),'line');
        l3 = get_param(portHandles.LConn(3),'line');
        delete_line(l1);
        delete_line(l2);
        delete_line(l3);
        
        delete_block('powerwindow/window_system/actuator');
        delete_block('powerwindow/window_system/plant');
        
    case 'add process'
        ret = stepTo(POWERWINDOWDEMO_STEP,27,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        add_block('powerwindowlibphys/process','powerwindow/window_system/process', ...
            'Position',[355, 114, 430, 236], 'ForegroundColor','red');
        
        set_param(sprintf('powerwindow/window_system/process'),'LinkStatus','inactive');
        set_param(sprintf('powerwindow/window_system/process/actuator'),'LinkStatus','inactive');
        set_param(sprintf('powerwindow/window_system/process/actuator/DC Machine'),'LinkStatus','inactive');
        
        l = add_line('powerwindow/window_system','process/1','window kinematics/1','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_system','process/2','gear angle/1','autorouting','on');
		set_param(l,'FontSize',9) 

        l = add_line('powerwindow/window_system','window DAQ/RConn1','process/LConn2');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_system','window DAQ/RConn2','process/LConn3');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow/window_system','Vbattery 12[V]/RConn1','process/LConn1','autorouting','on');
		set_param(l,'FontSize',9) 
        
    case 'delete input'
        ret = stepTo(POWERWINDOWDEMO_STEP,8,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        delete_line('powerwindow','Constant9/1','passenger up/1');
        delete_line('powerwindow','Constant10/1','passenger up/2');
        delete_line('powerwindow','Constant2/1','passenger down/1');
        delete_line('powerwindow','Constant1/1','passenger down/2');
        delete_line('powerwindow','Constant12/1','driver up/1');
        delete_line('powerwindow','Constant5/1','driver up/2');
        delete_line('powerwindow','Constant7/1','driver down/1');
        delete_line('powerwindow','Constant3/1','driver down/2');
        
        delete_line('powerwindow','passenger up/1','Mux4/1');
        delete_line('powerwindow','passenger down/1','Mux4/2');
        delete_line('powerwindow','driver up/1','Mux1/1');
        delete_line('powerwindow','driver down/1','Mux1/2');
        
        delete_line('powerwindow','Mux4/1','passenger neutral, up, down map/1');
        delete_line('powerwindow','Mux1/1','driver neutral, up, down map/1');
        delete_line('powerwindow','passenger neutral, up, down map/1','control/1');
        delete_line('powerwindow','driver neutral, up, down map/1','control/2');

        delete_block('powerwindow/Constant9');
        delete_block('powerwindow/Constant10');
        delete_block('powerwindow/Constant2');
        delete_block('powerwindow/Constant1');
        
        delete_block('powerwindow/Constant12');
        delete_block('powerwindow/Constant5');
        delete_block('powerwindow/Constant7');
        delete_block('powerwindow/Constant3');
        
        delete_block('powerwindow/passenger up');
        delete_block('powerwindow/passenger down');
        delete_block('powerwindow/driver up');
        delete_block('powerwindow/driver down');

        delete_block('powerwindow/Mux4');
        delete_block('powerwindow/Mux1');

        delete_block('powerwindow/passenger neutral, up, down map');
        delete_block('powerwindow/driver neutral, up, down map');
        
    case 'delete direct input'
        ret = stepTo(POWERWINDOWDEMO_STEP,28,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        delete_line('powerwindow','driver_switch/1','power_window_control_system/2');
        delete_line('powerwindow','driver_switch/2','power_window_control_system/3');
        delete_line('powerwindow','driver_switch/3','power_window_control_system/4');

        delete_line('powerwindow','passenger_switch/1','power_window_control_system/5');
        delete_line('powerwindow','passenger_switch/2','power_window_control_system/6');
        delete_line('powerwindow','passenger_switch/3','power_window_control_system/7');

        delete_block('powerwindow/driver_switch');
        delete_block('powerwindow/passenger_switch');

    case 'add CAN input'
        ret = stepTo(POWERWINDOWDEMO_STEP,29,POWERWINDOWDEMO_STEPS);

        if(~ispc)
	        warndlg({'You have to run the xPC Target toolbox on a PC.';
                '';
		        'The CAN model part is not loaded.'})
            return
        end 

        if license('test','XPC_Target')==0 
	        warndlg({'You do not have an xPC Target license available.';
                '';
		        'The CAN model part is not loaded.'})
            return;
        end 
        
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;
        
        try
            add_block('built-in/Reference',sprintf('powerwindow/passenger\nbit-unpacking'), ...
                'Position',[105, 149, 125, 221],'SourceBlock','xpclib/CAN/Utilities/CAN bit-unpacking ', ...
                'ForegroundColor','blue','bitpatterns','{ [0:0] [1:1] [2:2] }','dtypes','{ ''boolean'' ''boolean'' ''boolean'' }');
        catch
	        warndlg({'Your xPC Target license is unavailable.';
                '';
		        'The CAN model part is not loaded.'})
            return;
        end

        add_block('built-in/Reference',sprintf('powerwindow/driver\nbit-unpacking'), ...
            'Position',[105, 75, 125, 145],'SourceBlock','xpclib/CAN/Utilities/CAN bit-unpacking ', ...
            'ForegroundColor','blue','bitpatterns','{ [0:0] [1:1] [2:2] }','dtypes','{ ''boolean'' ''boolean'' ''boolean'' }', ...
            'NamePlacement','alternate');

        add_block('built-in/From',sprintf('powerwindow/passenger\naddress read'), ...
            'Position',[25, 176, 90, 194], ...
            'ForegroundColor','blue','GotoTag','passenger');
        add_block('built-in/From',sprintf('powerwindow/driver\naddress read'), ...
            'Position',[25, 100, 90, 120], ...
            'ForegroundColor','blue','GotoTag','driver');

        l = add_line('powerwindow','passenger address read/1','passenger bit-unpacking/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','driver address read/1','driver bit-unpacking/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','driver bit-unpacking/1','power_window_control_system/2');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','driver bit-unpacking/2','power_window_control_system/3');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','driver bit-unpacking/3','power_window_control_system/4');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','passenger bit-unpacking/1','power_window_control_system/5');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','passenger bit-unpacking/2','power_window_control_system/6');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','passenger bit-unpacking/3','power_window_control_system/7');
		set_param(l,'FontSize',9) 
        
    case 'add CAN output'
        ret = stepTo(POWERWINDOWDEMO_STEP,30,POWERWINDOWDEMO_STEPS);

        if(~ispc)
	        warndlg({'You have to run the xPC Target toolbox on a PC.';
                '';
		        'The CAN model part is not loaded.'})
            return
        end 

        if license('test','XPC_Target')==0 
	        warndlg({'You do not have an xPC Target license available.';
                '';
		        'The CAN model part is not loaded.'})
            return;
        end 
        
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;
        
        add_block('built-in/Goto',sprintf('powerwindow/passenger\naddress write'), ...
            'Position',[110, 345, 180, 365], ...
            'ForegroundColor','blue','GotoTag','passenger');
        add_block('built-in/Goto',sprintf('powerwindow/driver\naddress write'), ...
            'Position',[110, 295, 180, 315], ...
            'ForegroundColor','blue','GotoTag','driver','NamePlacement','alternate');

        try
            add_block(sprintf('powerwindowlibdsp/passenger window control\nswitch'),sprintf('powerwindow/passenger\nswitch'), ...
                'Position',[25, 335, 85, 375], 'NamePlacement','alternate');
            set_param(sprintf('powerwindow/passenger\nswitch'),'LinkStatus','inactive');
        catch
	        warndlg({'Your xPC Target license is unavailable.';
                '';
		        'The CAN model part is not loaded.'})
            return;
        end

        add_block(sprintf('powerwindowlibdsp/driver window control\nswitch'),sprintf('powerwindow/driver\nswitch'), ...
            'Position',[25, 285, 85, 325], 'NamePlacement','alternate');
        % For some reason, the name has to be moved around to recognize this block in the following statements
        set_param('powerwindow/passenger switch','NamePlacement','normal');
        set_param(sprintf('powerwindow/driver\nswitch'),'LinkStatus','inactive');

        l = add_line('powerwindow','passenger switch/1','passenger address write/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','driver switch/1','driver address write/1');
		set_param(l,'FontSize',9) 
        
    case 'set sample input'
         if POWERWINDOWDEMO_STEP == 30
             
            hilite_system('powerwindow/power_window_control_system/driver_neutral','find');
            hilite_system('powerwindow/power_window_control_system/driver_up','find');
            hilite_system('powerwindow/power_window_control_system/driver_down','find');
            hilite_system('powerwindow/power_window_control_system/passenger_neutral','find');
            hilite_system('powerwindow/power_window_control_system/passenger_up','find');
            hilite_system('powerwindow/power_window_control_system/passenger_down','find');
            
		    pause(0.75)	
            
            hilite_system('powerwindow/power_window_control_system/driver_neutral','none');
            hilite_system('powerwindow/power_window_control_system/driver_up','none');
            hilite_system('powerwindow/power_window_control_system/driver_down','none');
            hilite_system('powerwindow/power_window_control_system/passenger_neutral','none');
            hilite_system('powerwindow/power_window_control_system/passenger_up','none');
            hilite_system('powerwindow/power_window_control_system/passenger_down','none');
       end
        
        powerwindowscript('sample input'); 
        
    case 'sample input'
        ret = stepTo(POWERWINDOWDEMO_STEP,31,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;
        
        set_param('powerwindow/power_window_control_system/driver_neutral','SampleTime','10e-3')
        set_param('powerwindow/power_window_control_system/driver_up','SampleTime','10e-3')
        set_param('powerwindow/power_window_control_system/driver_down','SampleTime','10e-3')

        set_param('powerwindow/power_window_control_system/passenger_neutral','SampleTime','10e-3')
        set_param('powerwindow/power_window_control_system/passenger_up','SampleTime','10e-3')
        set_param('powerwindow/power_window_control_system/passenger_down','SampleTime','10e-3')

    case 'highlight control'
		hilite_system('powerwindow/10 ms','find')
		hilite_system('powerwindow/control','find')
		hilite_system('powerwindow/obstacle','find')
		hilite_system('powerwindow/top','find')
		hilite_system('powerwindow/c101','find')
		hilite_system('powerwindow/c102','find')
        
		pause(0.75);
        
 		hilite_system('powerwindow/10 ms','none')
		hilite_system('powerwindow/control','none')
		hilite_system('powerwindow/obstacle','none')
		hilite_system('powerwindow/top','none')
		hilite_system('powerwindow/c101','none')
		hilite_system('powerwindow/c102','none')
       
    case 'highlight window control'
		hilite_system('powerwindow/power_window_control_system','find')
        
		pause(0.75);
        
        hilite_system('powerwindow/power_window_control_system','none')
        
    case 'highlight statechart'
		hilite_system('powerwindow/control','find')
        
		pause(0.75);
        
 		hilite_system('powerwindow/control','none')
        
    case 'highlight sample rate'
		hilite_system('powerwindow/10 ms','find')
        
		pause(0.75);
        
 		hilite_system('powerwindow/10 ms','none')
       
    case 'highlight maps'
		hilite_system('powerwindow/passenger neutral, up, down map','find')
		hilite_system('powerwindow/driver neutral, up, down map','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/passenger neutral, up, down map','none')
		hilite_system('powerwindow/driver neutral, up, down map','none')

    case 'position detection'
		hilite_system('powerwindow/power_window_control_system/detect_obstacle_endstop','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/power_window_control_system/detect_obstacle_endstop','none')
        
    case 'highlight subsystem passenger up'
		hilite_system('powerwindow/passenger_switch/up control','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/passenger_switch/up control','none')
        
    case 'highlight passenger up'
		hilite_system('powerwindow/passenger up','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/passenger up','none')
        
    case 'highlight driver down'
		hilite_system('powerwindow/driver down','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/driver down','none')
        
    case 'highlight obstacle'
		hilite_system('powerwindow/obstacle','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/obstacle','none')

    case 'highlight electronics'
		hilite_system('powerwindow/window_system/amplification up','find')
		hilite_system('powerwindow/window_system/amplification down','find')
		hilite_system('powerwindow/window_system/actuator','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/window_system/amplification up','none')
		hilite_system('powerwindow/window_system/amplification down','none')
		hilite_system('powerwindow/window_system/actuator','none')
        
    case 'highlight multi-body'
		hilite_system('powerwindow/window_system/plant','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/window_system/plant','none')
        
    case 'highlight worm gear'
		hilite_system('powerwindow/window_system/plant/window/worm','find')
		hilite_system('powerwindow/window_system/plant/window/worm gear','find')
		hilite_system('powerwindow/window_system/plant/window/main gear','find')
		hilite_system('powerwindow/window_system/plant/window/door','find')
		hilite_system('powerwindow/window_system/plant/window/Revolute6','find')
		hilite_system('powerwindow/window_system/plant/window/Revolute8','find')
		hilite_system('powerwindow/window_system/plant/window/Revolute1','find')
		hilite_system('powerwindow/window_system/plant/window/GND2','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/window_system/plant/window/worm','none')
		hilite_system('powerwindow/window_system/plant/window/worm gear','none')
		hilite_system('powerwindow/window_system/plant/window/main gear','none')
		hilite_system('powerwindow/window_system/plant/window/door','none')
		hilite_system('powerwindow/window_system/plant/window/Revolute6','none')
		hilite_system('powerwindow/window_system/plant/window/Revolute8','none')
		hilite_system('powerwindow/window_system/plant/window/Revolute1','none')
		hilite_system('powerwindow/window_system/plant/window/GND2','none')
        
    case 'highlight lever'
		hilite_system('powerwindow/window_system/plant/window/rotate & slide','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/window_system/plant/window/rotate & slide','none')

    case 'highlight friction table'
		hilite_system('powerwindow/window_system/plant/window/friction/vehicle characteristic friction','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/window_system/plant/window/friction/vehicle characteristic friction','none')

    case 'highlight window'
		hilite_system('powerwindow/window_system/plant/window/window','find')
		hilite_system('powerwindow/window_system/plant/window/up & down','find')
		hilite_system('powerwindow/window_system/plant/window/GND','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/window_system/plant/window/window','none')
		hilite_system('powerwindow/window_system/plant/window/up & down','none')
		hilite_system('powerwindow/window_system/plant/window/GND','none')
        
    case 'delete control'
        ret = stepTo(POWERWINDOWDEMO_STEP,10,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        delete_line('powerwindow','top/1','control/3');
        delete_line('powerwindow','obstacle/1','control/4');
        delete_line('powerwindow','10 ms/1','control/trigger');

        delete_line('powerwindow','c102/1','obstacle/2');
        delete_line('powerwindow','c101/1','top/2');
        
		delete_block('powerwindow/10 ms')
		delete_block('powerwindow/control')
		delete_block('powerwindow/obstacle')
		delete_block('powerwindow/top')
		delete_block('powerwindow/c101')
		delete_block('powerwindow/c102')
        
    case 'add control subsystem'
        ret = stepTo(POWERWINDOWDEMO_STEP,11,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        add_block('built-in/Reference',sprintf('powerwindow/power_window_control_system'), ...
            'Position',[180, 45, 340, 225],'SourceBlock','powerwindowlibsa/power_window_control');        
        set_param('powerwindow/power_window_control_system','LinkStatus','inactive')
        
    case 'collapse DAQ subsystem'
        if POWERWINDOWDEMO_STEP == 23
            powerwindowscript('highlight DAQ subsystem');
        end
        powerwindowscript('delete DAQ subsystem');
        powerwindowscript('add DAQ subsystem');
        
    case 'collapse process'
        if POWERWINDOWDEMO_STEP == 25
            powerwindowscript('highlight process');
        end
        powerwindowscript('delete process');
        powerwindowscript('add process');
        
    case 'collapse control'
        if (POWERWINDOWDEMO_STEP == 15) | (POWERWINDOWDEMO_STEP == 16)
            powerwindowscript('highlight control');
        end
        powerwindowscript('delete control');
        powerwindowscript('add control');
        
    case 'context control'
        if (POWERWINDOWDEMO_STEP == 8)
            powerwindowscript('highlight control');
        end
        powerwindowscript('delete control');
        powerwindowscript('add control subsystem');
        
    case 'context connect'
        ret = stepTo(POWERWINDOWDEMO_STEP,12,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        set_param('powerwindow/window_system','Position',[375, 43, 515, 227]);
        set_param('powerwindow/position','Position',[580, 119, 610, 151]);
        
        l = add_line('powerwindow','driver_switch/1','power_window_control_system/2','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','driver_switch/2','power_window_control_system/3','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','driver_switch/3','power_window_control_system/4','autorouting','on');
		set_param(l,'FontSize',9) 

        l = add_line('powerwindow','passenger_switch/1','power_window_control_system/5','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','passenger_switch/2','power_window_control_system/6','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','passenger_switch/3','power_window_control_system/7','autorouting','on');
		set_param(l,'FontSize',9) 

        l = add_line('powerwindow','power_window_control_system/1','window_system/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','power_window_control_system/2','window_system/2');
		set_param(l,'FontSize',9) 

        l = add_line('powerwindow','window_system/1','position/1');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','window_system/1','power_window_control_system/1','autorouting','on');
		set_param(l,'FontSize',9) 

    case 'AD1'
		open_system('powerwindow/power_window_control_system','force');
        
    case 'position control'
        ret = stepTo(POWERWINDOWDEMO_STEP,19,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        delete_line('powerwindow','window DAQ/1','window control/1');
        delete_line('powerwindow','window control/1','window DAQ/2');
        delete_line('powerwindow','window control/2','window DAQ/3');
        
        set_param('powerwindow/passenger bit-unpacking', ...
            'Position',[305, 157, 325, 213]);
        set_param('powerwindow/passenger address read', ...
            'Position',[225, 175, 290, 195]);
        set_param('powerwindow/driver bit-unpacking', ...
            'Position',[305, 215, 325, 275]);
        set_param('powerwindow/driver address read', ...
            'Position',[225, 235, 290, 255]);
        set_param('powerwindow/window control', ...
            'Position',[370, 130, 490, 280]);

        set_param('powerwindow/window kinematics', ...
            'Position',[765, 137, 770, 203]);
        set_param('powerwindow/position', ...
            'Position',[800, 139, 830, 171]);
        set_param('powerwindow/Ia', ...
            'Position',[800, 54, 830, 86]);

        l = add_line('powerwindow','window DAQ/1','window control/1','autorouting','on');
		set_param(l,'FontSize',9) 
        
        l = add_line('powerwindow','window control/1','window DAQ/2','autorouting','on');
		set_param(l,'FontSize',9) 
        l = add_line('powerwindow','window control/2','window DAQ/3','autorouting','on');
		set_param(l,'FontSize',9) 

    case 'position switches'
        ret = stepTo(POWERWINDOWDEMO_STEP,20,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        delete_line('powerwindow','Vbattery 12[V]/1','passenger switch/1');
        delete_line('powerwindow','Vbattery 12[V]/1','driver switch/1');

        set_param('powerwindow/passenger switch', ...
            'Position',[60, 165, 120, 205]);
        set_param('powerwindow/passenger address write', ...
            'Position',[145, 175, 215, 195],'NamePlacement','normal');
        set_param('powerwindow/driver switch', ...
            'Position',[60, 225, 120, 265]);
        set_param('powerwindow/driver address write', ...
            'Position',[145, 235, 215, 255]);

        l = add_line('powerwindow',[515 70; 515 100; 40 100; 40 245; 60 245]);
 		set_param(l,'FontSize',9) 
        l = add_line('powerwindow',[40 185; 60 185]);
		set_param(l,'FontSize',9) 
        
    case 'position all'
        ret = stepTo(POWERWINDOWDEMO_STEP,21,POWERWINDOWDEMO_STEPS);
        if(ret < 0 | LICENSE == 0) return; end
        POWERWINDOWDEMO_STEP = ret;

        xoffset = -25;
        yoffset = -25;
        l = find_system('powerwindow', 'FindAll', 'on', 'SearchDepth', 1, 'type', 'line');
        
        sl = size(l);
        for i = 1:sl(1)
            p = get_param(l(i), 'Points');
            sp = size(p);
            for j = 1 : sp(1)
                p(j,1) = p(j,1) + xoffset;
                p(j,2) = p(j,2) + yoffset;
            end
        
            set_param(l(i),'Points',p);
        end
        
        l = find_system('powerwindow', 'FindAll', 'on', 'SearchDepth', 1, 'type', 'block');
        
        sl = size(l);
        for i = 1:sl(1)
            p = get_param(l(i), 'Position');
            sp = size(p);
            for j = 1 : 2 : sp(2)
                p(j) = p(j) + xoffset;
                p(j+1) = p(j+1) + yoffset;
            end
        
            set_param(l(i),'Position',p);
        end

    case 'reorganize'    
        powerwindowscript('position control');
        powerwindowscript('position switches');
        powerwindowscript('position all');
        
        powerwindowscript('resize for reorganize');        
       
    case 'atomic'
        set_param('powerwindow/window control','TreatAsAtomicUnit','on');
        
    case 's-function'
        rtwgen('powerwindow/window control');
        
    case 'open motor'
		hilite_system('powerwindow/window_system/actuator','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/window_system/actuator','none')
        
		open_system('powerwindow/window_system/actuator','force');
        
		hilite_system('powerwindow/window_system/actuator/DC Machine','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/window_system/actuator/DC Machine','none')
        
    case 'open amplification up'
		hilite_system('powerwindow/window_system/amplification up','find')
		hilite_system('powerwindow/window_system/amplification down','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/window_system/amplification up','none')
		hilite_system('powerwindow/window_system/amplification down','none')
        
		open_system('powerwindow/window_system/amplification up','force');
        
    case 'open multi-body window'
		hilite_system('powerwindow/window_system/plant','find')
        
		pause(0.75);
        
 		hilite_system('powerwindow/window_system/plant','none')
        
		open_system('powerwindow/window_system/plant','force');
        
		pause(0.75);
        
		hilite_system('powerwindow/window_system/plant/window','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/window_system/plant/window','none')

        open_system('powerwindow/window_system/plant/window','force');
        
    case 'open friction'
		hilite_system('powerwindow/window_system/plant/window/friction','find')
        
		pause(0.75);
        
		hilite_system('powerwindow/window_system/plant/window/friction','none')
        
		open_system('powerwindow/window_system/plant/window/friction','force');
        
    case 'open switch subsystem',
        if(~ispc)
	        warndlg({'You have to run the xPC Target toolbox on a PC.';
                '';
		        'The CAN model part is not loaded.'})
            return
        end 

		open_system('powerwindow/passenger switch','force');
        
    case 'highlight switch plant',
        if(~ispc)
	        warndlg({'You have to run the xPC Target toolbox on a PC.';
                '';
		        'The CAN model part is not loaded.'})
            return
        end 

		hilite_system('powerwindow/passenger switch/switch','find');
        
		pause(0.75);
        
		hilite_system('powerwindow/passenger switch/switch','none');
        
    case 'highlight switch DAQ',
        if(~ispc)
	        warndlg({'You have to run the xPC Target toolbox on a PC.';
                '';
		        'The CAN model part is not loaded.'})
            return
        end 

		hilite_system('powerwindow/passenger switch/DAQ','find');
        
		pause(0.75);
        
		hilite_system('powerwindow/passenger switch/DAQ','none');
        
    case 'highlight switch control',
        if(~ispc)
	        warndlg({'You have to run the xPC Target toolbox on a PC.';
                '';
		        'The CAN model part is not loaded.'})
            return
        end 

		hilite_system('powerwindow/passenger switch/control','find');
        
		pause(0.75);
        
		hilite_system('powerwindow/passenger switch/control','none');
        
    case 'highlight switch CAN module',
        if(~ispc)
	        warndlg({'You have to run the xPC Target toolbox on a PC.';
                '';
		        'The CAN model part is not loaded.'})
            return
        end 

		hilite_system('powerwindow/passenger switch/CAN module','find'); 
        
		pause(0.75);
        
		hilite_system('powerwindow/passenger switch/CAN module','none');   

    case 'edit report',
        setedit powerwindow.rpt; %This will open powerwindow.rpt

    case 'generate report',
        report powerwindow;

    case 'closemodel',
		close_system('powerwindow',0);
		
	otherwise
		warning('The requested action could not be taken.')
		
	end	 % switch action
catch
	warndlg({'There was an error executing the link you selected.';
		'Please, restart the demonstration by closing and NOT saving ';
        'the powerwindow model as additional links may be broken';
		'because of this problem.';
		'';
		'To avoid future errors, please run the links in the order ';
		'in which they occur in the demo.'})
end % Try/catch

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function currentStep = stepTo(currentStep,finalStep,POWERWINDOWDEMO_STEPS)
    if currentStep > finalStep
	    warndlg({'You have passed this stage in the demo sequence.';
                '';
		        'To review, restart the demonstration by closing ';
                'and NOT saving the powerwindow model.'})
        currentStep = -1;
    else
        if currentStep < finalStep - 1
            i = finalStep - 1;
            powerwindowscript(deblank(POWERWINDOWDEMO_STEPS(i,:)));
        end
        currentStep = finalStep;    
    end
