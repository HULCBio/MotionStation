function varargout = commblktriggeredbuffer(block, varargin)
% COMMBLKTRIGGEREDBUFFER Mask dynamic dialog function for triggered buffer block

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/24 02:02:10 $
% --- Modes of operation
%		varargin{1} = action =	'init' - Indicates that the block initialization
%													function is calling the code.
%													The code should call the functions to update
%													visibilities/enables etc. and based on these
%													settings, make any changes to the
%													simulink block.
%
%						= action = 'update'-	Indicates that the code is being called
%													by the dynamic dialog update function.
%
%						= CallbackName		-	Indicates that a dialog field callback
%													is executing.
%
%		varargin{2} = 0					- Dynamic Dialog initiated callback
%						= 1					- Callback required to update fields only
%


nvarargin = nargin - 1;

switch nvarargin
	case 0
		action = '';
	case 1
		action = varargin{1};
		Args = 0;
	otherwise
		action = varargin{1};
		Args = varargin{2:end};
end;

% --- Field data
Vals	= get_param(block, 'maskvalues');
Vis	= get_param(block, 'maskvisibilities');
En  	= get_param(block, 'maskenables');

% --- Field numbers
StartSample    = 1;
NumChan        = 2;
InputWidthMode = 3;
InputWidth     = 4;
InputWidthMin  = 5;
InputWidthStep = 6;
InputWidthMax  = 7;

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
	feval(mfilename,block,'UpdateFields');
	%feval(mfilename,block,'UpdateBlocks',Args);
	[varargout{1}] = feval(mfilename,block,'UpdateWs',Args);
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
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'UpdateWs'))
   % --- Set the block display strings
   s.i1 = 1; s.i1s = ''; 
   s.o1 = 1; s.o1s = 'f()';
   s.o2 = 2; s.o2s = 'Out';
   % --- Assign output arguments
   varargout{1} = s;
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
	feval(mfilename,block,'InputWidthMode',1);
end;


%----------------------------------------------------------------------
%
%	Dynamic Dialog specific field functions
%
%----------------------------------------------------------------------

%*********************************************************************
% Function Name:	'InputWidthMode'
%
% Description:		Deal with the input width mode of the operation
%
% Inputs:			current block
%						Update mode: Args = 0, block update required
%										 Args = 1, no block update required
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'InputWidthMode'))

   if(strcmp(Vals{InputWidthMode},'Specify'))
		if(strcmp(Vis{InputWidth},'off'))

         % --- The Specify mode is selected, but the width field is invisible
         %     so this field requires a change

         % --- Switch on the Specify related field
			Vis{InputWidth} = 'on';
			En{InputWidth}  = 'on';

         % --- Switch off the Based on output related fields
			Vis{InputWidthMin}  = 'off';
			Vis{InputWidthStep} = 'off';
			Vis{InputWidthMax}  = 'off';
			En{InputWidthMin}   = 'off';
			En{InputWidthStep}  = 'off';
			En{InputWidthMax}   = 'off';

			set_param(block,'MaskEnables',En,'MaskVisibilities',Vis);
			if(~Args)
            % --- If update of the block is required when the dynamic dialog
            %     changes, the uncomment the following
				%feval(mfilename,block,'UpdateBlocks');
			end;
		end;
   elseif(strcmp(Vals{InputWidthMode},'Inherit'))
		if(strcmp(Vis{InputWidth},'on') | strcmp(Vis{InputWidthMin},'on'))

         % --- The Inherit mode is selected, but the width field is visible
         %     so this field requires a change

         % --- Switch off the Specify related field
			Vis{InputWidth} = 'off';
			En{InputWidth}  = 'off';

         % --- Switch off the Based on output related fields
			Vis{InputWidthMin}  = 'off';
			Vis{InputWidthStep} = 'off';
			Vis{InputWidthMax}  = 'off';
			En{InputWidthMin}   = 'off';
			En{InputWidthStep}  = 'off';
			En{InputWidthMax}   = 'off';

			set_param(block,'MaskEnables',En,'MaskVisibilities',Vis);
			if(~Args)
            % --- If update of the block is required when the dynamic dialog
            %     changes, the uncomment the following
				%feval(mfilename,block,'UpdateBlocks');
			end;
		end;
   elseif(strcmp(Vals{InputWidthMode},'Based on output width'))
		if(strcmp(Vis{InputWidthMin},'off'))

         % --- The 'Based on output width' mode is selected, but the minimum 
         %     width field is invisible so this field requires a change

         % --- Switch off the Specify related field
			Vis{InputWidth} = 'off';
			En{InputWidth}  = 'off';

         % --- Switch off the Based on output related fields
			Vis{InputWidthMin}  = 'on';
			Vis{InputWidthStep} = 'on';
			Vis{InputWidthMax}  = 'on';
			En{InputWidthMin}   = 'on';
			En{InputWidthStep}  = 'on';
			En{InputWidthMax}   = 'on';

			set_param(block,'MaskEnables',En,'MaskVisibilities',Vis);
			if(~Args)
            % --- If update of the block is required when the dynamic dialog
            %     changes, the uncomment the following
				%feval(mfilename,block,'UpdateBlocks');
			end;
		end;
   else
      error('Unrecognized mode');
	end;

end;


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
	Cb{StartSample}		= '';
	Cb{NumChan}				= '';
   Cb{InputWidthMode}   = [mfilename '(gcb,''InputWidthMode'');'];
	Cb{InputWidth}       = '';
	Cb{InputWidthMin}    = '';
	Cb{InputWidthStep}   = '';
	Cb{InputWidthMax}    = '';

	En{StartSample}		= 'on';
	En{NumChan}				= 'on';
   En{InputWidthMode}   = 'on';
	En{InputWidth}       = 'off';
	En{InputWidthMin}    = 'off';
	En{InputWidthStep}   = 'off';
	En{InputWidthMax}    = 'off';

	Vis{StartSample}		= 'on';
	Vis{NumChan}			= 'on';
   Vis{InputWidthMode}  = 'on';
	Vis{InputWidth}      = 'off';
	Vis{InputWidthMin}   = 'off';
	Vis{InputWidthStep}  = 'off';
	Vis{InputWidthMax}   = 'off';

   % --- Get the MaskTunableValues 
   Tunable = get_param(block,'MaskTunableValues');
	Tunable{StartSample}      = 'off';
	Tunable{NumChan}          = 'off';
   Tunable{InputWidthMode}   = 'off';
	Tunable{InputWidth}       = 'off';
	Tunable{InputWidthMin}    = 'off';
	Tunable{InputWidthStep}   = 'off';
	Tunable{InputWidthMax}    = 'off';

	% --- Set Callbacks, enable status, visibilities and tunable values
	set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, 'MaskTunableValues', Tunable);

	% --- Set the startup values.  '' Indicates that the default saved will be used

	Vals{StartSample}      = '0';
	Vals{NumChan}          = '1';
   Vals{InputWidthMode}   = 'Inherit';
	Vals{InputWidth}       = '1';
	Vals{InputWidthMin}    = '2';
	Vals{InputWidthStep}   = '2';
	Vals{InputWidthMax}    = '20';

	MN = get_param(gcb,'MaskNames');
	for n=1:length(Vals)
		if(~isempty(Vals{n}))
			set_param(block,MN{n},Vals{n});
		end;
	end;

	% --- Update the Vals field with the actual values

	Vals	= get_param(block, 'maskvalues');

	% --- Update the blocks as required (block workspace is not available)
	%
	%		If specific parameter values are required (as opposed to strings)
	%     blocks will have to be built here

	% --- Ensure that the block operates correctly from a library
	set_param(block,'MaskSelfModifiable','on');

end;
