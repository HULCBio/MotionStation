function varargout = commblkuniformsrc(block, varargin)
% COMMBLKUNIFORMSRC Mask dynamic dialog function for uniform source block

% Author: Trefor Delve
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/01/26 18:44:44 $


% --- Modes of operation
%		varargin{1} = action =	'init' - Indicates that the block initialization
%													function is calling the code.
%													The code should call the functions to update
%													visibilities/enables etc. and based on these
%													settings, make any changes to the
%													simulink block.
%
%						= CallbackName		-	Indicates that a dialog field callback
%													is executing.
%
%		varargin{2} = 0					- Dynamic dialog initiated callback
%						= 1					- Callback required to update fields only
%

% --- Field numbers

NoiseLower	= 1;
NoiseUpper 	= 2;
Seed		   = 3;
SampleTime  = 4;

nvarargin = nargin - 1;

switch nvarargin
	case 0
		action = '';
	case 1
		action = varargin{1};
		Args = {};
	otherwise
		action = varargin{1};
		Args = varargin{2:end};

      if(~strcmp(lower(action),'backprop'))
         % --- Breakout the arguments if required
         if((nvarargin > 1) & (isa(Args,'cell')))
         end;
      end;
end;

% --- Field data

Vals  = get_param(block, 'maskvalues');
Vis   = get_param(block, 'maskvisibilities');
En    = get_param(block, 'maskenables');

%*********************************************************************
% Function:			initialize
%
% Description:		Set the dialogs up based on the parameter values.
%						MaskEnables/MaskVisibles are not save in reference 
%						blocks.
%
% Inputs:			current block
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'init'))

%  feval(mfilename,block,'UpdateFields');
%	feval(mfilename,block,'UpdateBlocks',Args);
%	[varargout{1:3}] = feval(mfilename,block,'UpdateWs',Args);

end;



%----------------------------------------------------------------------
%
%	Block specific update functions
%
%----------------------------------------------------------------------

%*********************************************************************
% Function:			UpDateBlocks
%
% Description:		Set the simulink blocks as required
%
% Inputs:			current block
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'UpdateBlocks'))
end;

%*********************************************************************
% Function:			UpdateWs
%
% Description:		Set the simulink blocks as required
%
% Inputs:			current block
%
% Return Values:	values to be set in the workspace
%
%********************************************************************

if(strcmp(action,'UpdateWs'))
end;


%*********************************************************************
% Function:			UpdateFields
%
% Description:		Update the dialog fields.
%						Indicate that block updates are not required
%
% Inputs:			current block
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'UpdateFields'))
end;




%----------------------------------------------------------------------
%
%	Dynamic dialog specific field functions
%
%----------------------------------------------------------------------



%----------------------------------------------------------------------
%
%	Setup/Utility functions
%
%----------------------------------------------------------------------


%*********************************************************************
% Function Name:	'default'
%
% Description:		Set the block defaults (development use only)
%
% Inputs:			current block
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'default'))

	Cb{NoiseLower}   = '';
	Cb{NoiseUpper}   = '';
	Cb{Seed}         = '';
	Cb{SampleTime}   = '';

	En{NoiseLower}   = 'on';
	En{NoiseUpper}   = 'on';
	En{Seed}         = 'on';
	En{SampleTime}   = 'on';

	Vis{NoiseLower}   = 'on';
	Vis{NoiseUpper}   = 'on';
	Vis{Seed}         = 'on';
	Vis{SampleTime}   = 'on';

	% --- Set Callbacks, enable status and visibilities
   set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis);

	% --- Set the startup values.  '' Indicates that the default saved will be used

	Vals{NoiseLower}   = '[0 1]';
	Vals{NoiseUpper}   = '[1 2]';
	Vals{Seed}         = '[12345 54321]';
	Vals{SampleTime}   = '1';

	MN = get_param(gcb,'MaskNames');
	for n=1:length(Vals)
		if(~isempty(Vals{n}))
			set_param(block,MN{n},Vals{n});
		end;
	end;

	% --- Update the Vals field with the actual values

	Vals	= get_param(block, 'maskvalues');

   % --- Set the copy function
	set_param(block,'CopyFcn','');

	% --- Ensure that the block operates correctly from a library
	set_param(block,'MaskSelfModifiable','on');

end;


%*********************************************************************
% Function Name:	show all
%
% Description:		Show all of the widgets
%
% Inputs:			current block
%
% Return Values:	none
%
% Notes:				This function is for development use only and allows
%						All fields to be displayed
%
%********************************************************************

if(strcmp(action,'showall'))

	Vis	= get_param(block, 'maskvisibilities');
	En  	= get_param(block, 'maskenables');

	Cb = {};
	for n=1:length(Vis)
		Vis{n} = 'on';
		En{n} = 'on';
		Cb{n} = '';
	end;

   set_param(block,'MaskVisibilities',Vis,'MaskEnables',En,'MaskCallbacks',Cb);

end;



%----------------------------------------------------------------------
%
%	Subfunctions
%
%----------------------------------------------------------------------















