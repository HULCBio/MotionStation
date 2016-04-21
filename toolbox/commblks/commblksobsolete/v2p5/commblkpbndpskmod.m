function varargout = commblkpbndpskmod(block, varargin)
% COMMBLKPBNDPSKMOD Mask dynamic dialog function for Passband M-PSK 
% and M-DPSK modulator blocks

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:02:32 $


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
%		varargin{2}     = 0					- Dynamic Dialog initiated callback
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
Vis		= get_param(block, 'maskvisibilities');
En  	= get_param(block, 'maskenables');

% --- Field numbers

M_ary              = 1;
InType             = 2;
Map                = 3;
InPer              = 4;
NumSamp			   = 5;
CarrFr             = 6;
CarrPh			   = 7;
OutPer             = 8;

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
   feval(mfilename,block,'InType',1);
end;


%----------------------------------------------------------------------
%
%	Dynamic Dialog specific field functions
%
%----------------------------------------------------------------------

%*********************************************************************
% Function Name:	'InType'
%
% Description:		Deal with the mode of the operation
%
% Inputs:			current block
%						Update encoding: Args = 0, block update required
%										     Args = 1, no block update required
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'InType'))

    Vis{Map} = 'on';
    if strcmp(Vals{InType},'Integer');
    	En{Map} = 'off';
    else
        En{Map} = 'on';
    end
         
	set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
end

%---------------------------------------------------------------------
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

   Cb{M_ary}				  = '';
   Cb{InType}				  = [mfilename '(gcb,''InType'');'];
   Cb{Map}   				  = '';
   Cb{InPer}		          = '';
   Cb{NumSamp}				  = '';
   Cb{CarrFr}		          = '';
   Cb{CarrPh}                 = '';
   Cb{OutPer}                 = '';
   
   En{M_ary}  		        = 'on';
   En{InType}				  = 'on';
   En{Map}                = 'on';
   En{NumSamp}            = 'on';
   En{InPer}		       = 'on';
   En{CarrFr}		       = 'on';
   En{CarrPh}              = 'on';
   En{OutPer}              = 'on';

   Vis{M_ary}    	        = 'on';
   Vis{InType}				  = 'on';
   Vis{Map}               = 'on';
   Vis{NumSamp}           = 'on';
   Vis{InPer}		       = 'on';
   Vis{CarrFr}		       = 'on';
   Vis{CarrPh}             = 'on';
   Vis{OutPer}             = 'on';
   
   % --- Get the MaskTunableValues 
   Tunable = get_param(block,'MaskTunableValues');
   Tunable{M_ary}			  = 'off';
   Tunable{InType}		  = 'off';
   Tunable{Map}           = 'off';
   Tunable{NumSamp}       = 'off';
   Tunable{InPer}		  = 'off';
   Tunable{CarrFr}		  = 'off';
   Tunable{CarrPh}        = 'off';
   Tunable{OutPer}        = 'off';
   
	% --- Set Callbacks, enable status, visibilities and tunable values
	set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, 'MaskTunableValues', Tunable);

	% --- Set the startup values.  '' Indicates that the default saved will be used

   Vals{M_ary}			    = '8';
   Vals{InType}			    = 'Integer';
   Vals{Map}                = 'Binary';
   Vals{InPer}		       = '1/100';
   Vals{NumSamp}   			= '1';
   Vals{CarrFr}		       = '3000';
   Vals{CarrPh}            = 'pi/8';
   Vals{OutPer}            = '1/8000';


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
