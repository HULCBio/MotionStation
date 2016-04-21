function aero_guidancedemoscript(varargin)
%AERO_GUIDANCEDEMOSCRIPT Controls the 3DoF guidance Demo HTML page
%   AERO_GUIDANCEDEMOSCRIPT(action) executes the hyperlink callback associated with the 
%   the string action.
%
%
%   Jeremy Hodgson
%   Original : Karen Gondoly
%	Copyright 1990-2002 The MathWorks, Inc.
%	$Revision: 1.4 $  $Date: 2002/04/10 18:40:46 $

persistent GUIDANCEDEMO_STEP_COUNTER
try % Wrap the whole thing in a try catch, in case the user doesn't go in order.
	
	ni=nargin;
	
	if ~ni,
		step = 'initialize';
	else 
		step = varargin{1};
	end
	
	% If first time running the demo, or they closed the model
	% Open the model and initialize the counter
	if isempty(find_system('Name','aero_guidance')) | ~ni
		aero_guidance;
		GUIDANCEDEMO_STEP_COUNTER=zeros(1,12);
	end
	
	switch step
	case 'initialize',
		% Open the web browser with the html file
		fullPathName=which('aero_guidancedemoscript');
		tok=filesep;
		indtok = findstr(fullPathName,tok);
		pathname = fullPathName(1:indtok(end));
		web([pathname,'aero_guidancedemo.htm']);
		
	case 'step1',
		% Open the Simulink Library block model
		open_system('aerospace')
		GUIDANCEDEMO_STEP_COUNTER(1)=1;
		
	case 'step2',
		% Open Simulink airframe model
		open_system('aero_guidance_airframe');
		GUIDANCEDEMO_STEP_COUNTER(2)=1;
		if GUIDANCEDEMO_STEP_COUNTER(1)
			try 
				close_system('aerospace');
			end
		end
		
	case 'step3'
		 % Highlight and open the Atmosphere model
		 open_system('aero_guidance_airframe');
		 hilite_system('aero_guidance_airframe/Atmosphere model','default')
		 open_system('aero_guidance_airframe/Atmosphere model','force');
 		 GUIDANCEDEMO_STEP_COUNTER(3)=1;
		 if GUIDANCEDEMO_STEP_COUNTER(4)
			 hilite_system('aero_guidance_airframe/Aerodynamics & Equations of Motion','none')
			 try
 				 close_system('aero_guidance_airframe/Aerodynamics & Equations of Motion')
			 end
		 end
		 
	 case 'step4'
		 % Hilight the Equations of motion model
		 open_system('aero_guidance_airframe');
		 hilite_system('aero_guidance_airframe/Aerodynamics & Equations of Motion','default')
		 open_system('aero_guidance_airframe/Aerodynamics & Equations of Motion','force');
		 GUIDANCEDEMO_STEP_COUNTER(4)=1;
   		 if GUIDANCEDEMO_STEP_COUNTER(3)
	 		 hilite_system('aero_guidance_airframe/Atmosphere model','none')
			 try
				 close_system('aero_guidance_airframe/Atmosphere model');
			 end
		 end
		 
	 case 'step5'
		% Run the MATLAB trim and linearise demo
		if ~GUIDANCEDEMO_STEP_COUNTER(2)
			aero_guidancedemoscript('step2');
		end
		evalin('base','aero_lin_aero')
		GUIDANCEDEMO_STEP_COUNTER(5)=1;

	case 'step6'
		% Open the Guidance Simulation
		open_system('aero_guidance');
		GUIDANCEDEMO_STEP_COUNTER(6)=1;
		try
			close_system('aero_guidance_airframe');
		end

   case 'step7'
		 % Highlight the Guidance Model
		 open_system('aero_guidance')
		 hilite_system('aero_guidance/Guidance','default');
		 open_system('aero_guidance/Guidance','force');
		 GUIDANCEDEMO_STEP_COUNTER(7)=1;
   		 if GUIDANCEDEMO_STEP_COUNTER(9)
			 hilite_system('aero_guidance/Seeker//Tracker','none');
			 try
				 close_system('aero_guidance/Seeker//Tracker');
			 end
		 end

	case 'step8'
		% Highlight the PN Gain
		open_system('aero_guidance');
		open_system('aero_guidance/Guidance','force');
		hilite_system('aero_guidance/Guidance/Proportional Navigation Gain','default');
  	 	GUIDANCEDEMO_STEP_COUNTER(8)=1;
		if GUIDANCEDEMO_STEP_COUNTER(9)
			 hilite_system('aero_guidance/Seeker//Tracker','none');
			 try
				 close_system('aero_guidance/Seeker//Tracker');
			 end
		 end

		
	case 'step9'
		 % Highlight the Seeker Model
		 %open_system('aero_guidance');
		 hilite_system('aero_guidance/Seeker//Tracker','default');
		 open_system('aero_guidance/Seeker//Tracker/Tracker and Sightline Rate Estimator','force');
		 GUIDANCEDEMO_STEP_COUNTER(9)=1;
   		 if GUIDANCEDEMO_STEP_COUNTER(7)|GUIDANCEDEMO_STEP_COUNTER(8)
	 		 hilite_system('aero_guidance/Guidance','none')
			 try
				 close_system('aero_guidance/Guidance');
			 end
		 end

	case 'step10'
		 % Highlight the Radome Aberration block
		 %open_system('aero_guidance');
		 open_system('aero_guidance/Seeker//Tracker','force');
		 hilite_system('aero_guidance/Seeker//Tracker/Tracker and Sightline Rate Estimator/Radome  Aberration','default');
		 GUIDANCEDEMO_STEP_COUNTER(10)=1;
   		 if GUIDANCEDEMO_STEP_COUNTER(7)|GUIDANCEDEMO_STEP_COUNTER(8)
	 		 hilite_system('aero_guidance/Guidance','none')
			 try
				 close_system('aero_guidance/Guidance');
			 end
		 end
		 
	case 'step11'
		% Run the Guidance Simulation
        if ~GUIDANCEDEMO_STEP_COUNTER(4)
			aero_guidance;
		end
		evalin('base','sim(''aero_guidance'')');
		GUIDANCEDEMO_STEP_COUNTER(11)=1;
		
	case 'step12'
		% Open the 6DoF Model 
		open_system('aero_six_dof');
		GUIDANCEDEMO_STEP_COUNTER(12)=1;
		try
			close_system('aero_guidance');
		end

	otherwise
		warning('The requested action could not be taken.')
		
	end	 % switch action
catch
	disp(['What was last error ' lasterr])
	warndlg({'There was an error executing the link you selected.';
		'Please, restart the demonstration as additional links ';
		'may be broken due to this problem.';
		'';
		'To avoid future errors, please run the links in the order ';
		'in which they occur in the demo.'})
end % Try/catch

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function modArray = StripSelection(inArray)

modArray = strrep(inArray, '??? ', '');
