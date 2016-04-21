function varargout = commblkrician1src(block, varargin)
% COMMBLKRICIAN1SRC Mask dynamic dialog function for Rician source block

% Author: Trefor Delve
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/01/26 18:44:43 $


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

SpecMethod  = 1;
InPhase     = 2;
Quad        = 3;
KFactor     = 4;
Sigma	      = 5;
Seed	      = 6;
SampleTime  = 7;


nvarargin = nargin - 1;

switch nvarargin
	case 0
		action = '';
	case 1
		action = varargin{1};
		Args = '';
	otherwise
		action = varargin{1};
		Args = varargin{2:end};

      % --- Breakout the arguments if required
      if((nvarargin > 1) & (isa(Args,'cell')))
         Mask_iMean = Args{1};
         Mask_qMean = Args{2};
         Mask_K     = Args{3};
         Mask_s     = Args{4};
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

   feval(mfilename,block,'UpdateFields');
%   feval(mfilename,block,'UpdateBlocks',Args);
	[varargout{1:2}] = feval(mfilename,block,'UpdateWs',Args);

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
   
   if(strcmp(Vals{SpecMethod},'Quadrature components'))
      varargout{1} = Mask_iMean;
      varargout{2} = Mask_qMean;
   else
      
      K = Mask_K;
      s = Mask_s;
      m1 = sqrt(2*K(:)).*s;
      m2 = 0;
      varargout{1} = m1;
      varargout{2} = m2;
      
   end;
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
	feval(mfilename,block,'SpecMethod',1);
end;


%----------------------------------------------------------------------
%
%	Dynamic dialog specific field functions
%
%----------------------------------------------------------------------
%*********************************************************************
% Function Name:	'SpecMethod'
%
% Description:		Deal with the different specification methods
%
% Inputs:			current block
%						Update mode: Args = 0, block update required
%										 Args = 1, no block update required
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'SpecMethod'))

   if(strcmp(Vals{SpecMethod},'Quadrature components'))
		if(strcmp(Vis{KFactor},'on'))
			Vis{KFactor} = 'off';
			En{KFactor}  = 'off';

			Vis{InPhase} = 'on';
			Vis{Quad}    = 'on';
			En{InPhase}  = 'on';
			En{Quad}     = 'on';

			set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
			if(~Args)
            % --- If update of the block is required when the dynamic dialog
            %     changes, the uncomment the following
				%feval(mfilename,block,'UpdateBlocks');
			end;
		end;
	elseif(strcmp(Vis{KFactor},'off'))
		Vis{KFactor} = 'on';
		En{KFactor}  = 'on';

   	Vis{InPhase} = 'off';
		Vis{Quad}    = 'off';
   	En{InPhase}  = 'off';
		En{Quad}     = 'off';

      set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
		if(~Args)
         % --- If update of the block is required when the dynamic dialog
         %     changes, the uncomment the following
			%feval(mfilename,block,'UpdateBlocks');
		end;
	end

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

	Cb{SpecMethod}   = [mfilename '(gcb,''SpecMethod'');'];
	Cb{InPhase}      = '';
	Cb{Quad}         = '';
	Cb{KFactor}      = '';
	Cb{Sigma}        = '';
	Cb{Seed}         = '';
	Cb{SampleTime}   = '';

	En{SpecMethod}   = 'on';
	En{InPhase}      = 'off';
	En{Quad}         = 'off';
	En{KFactor}      = 'on';
	En{Sigma}        = 'on';
	En{Seed}         = 'on';
	En{SampleTime}   = 'on';

	Vis{SpecMethod}  = 'on';
	Vis{InPhase}     = 'off';
	Vis{Quad}        = 'off';
	Vis{KFactor}     = 'on';
	Vis{Sigma}       = 'on';
	Vis{Seed}        = 'on';
	Vis{SampleTime}  = 'on';

	% --- Set Callbacks, enable status and visibilities
   set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis);

	% --- Set the start up values.  '' Indicates that the default saved will be used

	Vals{SpecMethod}  = 'K-factor';
	Vals{InPhase}     = 'sqrt(2)';
	Vals{Quad}        = 'sqrt(2)';
	Vals{KFactor}     = '2';
	Vals{Sigma}       = '1';
	Vals{Seed}        = '12345';
	Vals{SampleTime}  = '1';

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

	% --- Set the Mask Modifiable flag as required
	set_param(block,'MaskSelfModifiable','off');

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


















