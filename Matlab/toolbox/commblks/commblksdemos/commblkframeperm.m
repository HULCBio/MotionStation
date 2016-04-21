function varargout = commblkframeperm(block, varargin)
% COMMBLKFRAMEPERM Mask dynamic dialog function for Frame Permuter block

% Author: Mike Mulligan
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/03/24 02:04:12 $


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

FrameLen  = 1;
PermType  = 2;
Mrows     = 3;
Ncols     = 4;
Seed      = 5;
PermVec	 = 6;

%*********************************************************************
% Function:			Initialize
%
% Description:		Set the dialogs up based on the parameter values.
%						MaskEnables/MaskVisibles are not saved in reference 
%						blocks.
%
% Inputs:			current block
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'init'))
	feval(mfilename,block,'UpdateFields');
	varargout{1} = feval(mfilename,block,'UpdateWs',Args);
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

   if(strcmp(Vals{PermType},'Matrix transpose'))
      if (Args{1} ~= Args{2}*Args{3})
         error('Frame size not equal to matrix size');
      end;
      perm_mat = reshape(1:Args{1},Args{2},Args{3})';
	   varargout{1} = reshape(perm_mat,1,Args{1});
	elseif(strcmp(Vals{PermType},'Random permutation'))
      rand('state',Args{4});
      [ignore,p] = sort(rand(1,Args{1}));
      varargout{1} = p;
   elseif(strcmp(Vals{PermType},'User defined permutation'))
		varargout{1} = Args{5};
	elseif(strcmp(Vals{PermType},'No permutation'))
	   varargout{1} = 1:Args{1};      
   else
      error('Unrecognized mode');
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
	feval(mfilename,block,'Mode',1);
end;




%----------------------------------------------------------------------
%
%	Dynamic Dialog specific field functions
%
%----------------------------------------------------------------------

%*********************************************************************
% Function Name:	'Mode'
%
% Description:		Deal with the mode of the operation
%
% Inputs:			current block
%						Update mode: Args = 0, block update required
%										 Args = 1, no block update required
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'Mode'))

   if(strcmp(Vals{PermType},'Matrix transpose'))
      
      Vis{Mrows}     = 'on';
      Vis{Ncols}     = 'on';
      Vis{Seed}      = 'off';
      Vis{PermVec}   = 'off';
      
      En{Mrows}     = 'on';
      En{Ncols}     = 'on';
      En{Seed}		  = 'off';
      En{PermVec}   = 'off';
      
      set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
      
   elseif(strcmp(Vals{PermType},'Random permutation'))
      
      Vis{Mrows}     = 'off';
      Vis{Ncols}     = 'off';
      Vis{Seed}      = 'on';
      Vis{PermVec}   = 'off';
      
      En{Mrows}     = 'off';
      En{Ncols}     = 'off';
      En{Seed}		  = 'on';
      En{PermVec}   = 'off';
      
      set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
      
   elseif(strcmp(Vals{PermType},'User defined permutation'))
      
      Vis{Mrows}     = 'off';
      Vis{Ncols}     = 'off';
      Vis{Seed}      = 'off';
      Vis{PermVec}   = 'on';
      
      En{Mrows}     = 'off';
      En{Ncols}     = 'off';
      En{Seed}		  = 'off';
      En{PermVec}   = 'on';
      
      set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
      
   elseif(strcmp(Vals{PermType},'No permutation'))
      
      Vis{Mrows}     = 'off';
      Vis{Ncols}     = 'off';
      Vis{Seed}      = 'off';
      Vis{PermVec}   = 'off';
      
      En{Mrows}     = 'off';
      En{Ncols}     = 'off';
      En{Seed}		  = 'off';
      En{PermVec}   = 'off';
      
      set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
      
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

	Cb{FrameLen}  = '';
	Cb{PermType}  = [mfilename '(gcb,''Mode'');'];
   Cb{Mrows}     = '';
	Cb{Ncols}     = '';
	Cb{Seed}		  = '';
	Cb{PermVec}   = '';

	En{FrameLen}  = 'on';
	En{PermType}  = 'on';
   En{Mrows}     = 'on';
	En{Ncols}     = 'on';
	En{Seed}		  = 'off';
   En{PermVec}   = 'off';
   
	Vis{FrameLen}  = 'on';
	Vis{PermType}  = 'on';
   Vis{Mrows}     = 'on';
	Vis{Ncols}     = 'on';
	Vis{Seed}		= 'off';
   Vis{PermVec}   = 'off';
   
   % --- Get the MaskTunableValues 
   Tunable = get_param(block,'MaskTunableValues');
	Tunable{FrameLen}  = 'off';
	Tunable{PermType}  = 'off';
   Tunable{Mrows}     = 'off';
	Tunable{Ncols}     = 'off';
	Tunable{Seed}		 = 'off';
   Tunable{PermVec}   = 'off';
   
	% --- Set Callbacks, enable status, visibilities and tunable values
	set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, 'MaskTunableValues', Tunable);

	% --- Set the startup values.  '' Indicates that the default saved will be used

	Vals{FrameLen}  = '256';
	Vals{PermType}  = 'Matrix transpose';
   Vals{Mrows}     = '8';
	Vals{Ncols}     = '32';
	Vals{Seed}		 = '1234';
   Vals{PermVec}   = 'P';
   
	MN = get_param(gcb,'MaskNames');
	for n=1:length(Vals)
		if(~isempty(Vals{n}))
			set_param(block,MN{n},Vals{n});
		end;
	end;

	% --- Update the Vals field with the actual values

	Vals	= get_param(block, 'maskvalues');

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
