function varargout = commblkmap(block, varargin)
% COMMBLKMAP Mask dynamic dialog function for data mapping block

% Author: Trefor Delve
% Copyright 1996-2002 The MathWorks, Inc.
% $Date: 2003/01/26 18:44:35 $ $Revision: 1.1.6.1 $

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
%		varargin{2} = 0					- Dynamic Dialog initiated callback
%						= 1					- Callback required to update fields only
%

% --- Field numbers

SetSizeField	= 1;
MapModeField 	= 2;
MapVecField		= 3;

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

		if((nvarargin > 1) & (isa(Args,'cell')))
		   M			= Args{SetSizeField};
		   MapMode	= Args{MapModeField};
		   MapVec	= Args{MapVecField};
		end;

end;

% --- Field data

Vals	= get_param(block, 'maskvalues');
Vis	= get_param(block, 'maskvisibilities');
En  	= get_param(block, 'maskenables');


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
   feval(mfilename,block,'UpdateBlocks',Args);
   [varargout{1:3}] = feval(mfilename,block,'UpdateWs',Args);
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

   % --- Common parameter checks
   if(MapMode ~= 1)
      if(~(all(size(M) == 1)))
         error('Symbol set size must be a scalar');
      end;

      if(M < 2)
         error('Symbol set size must be greater than two');
      end;

      if(M-floor(M) > 0)
         error('Symbol set size must be an integer');
      end;
   end;

	switch MapMode
		case 1		% Straight through mapping
			En = 0;
			IPValues	= 0:1;	% Dummy lookup values
			OPValues	= 0:1;
		case 2		% Gray code mapping
			En = 1;
			IPValues	= (0:M-1);
			OPValues	= bitxor(IPValues,floor(IPValues/2));
		case 3		% User defined mapping
			En = 1;
			IPValues	= (0:M-1);
			OPValues	= MapVec;

			% --- Check variables

			if(M ~= length(MapVec))
				error('Mapping vector should be the same length as the symbol set size.');
			end;
	end;

	varargout{1} = En;
	varargout{2} = IPValues;
	varargout{3} = OPValues;
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
	feval(mfilename,block,'MapMode',1);
end;




%----------------------------------------------------------------------
%
%	Dynamic dialog specific field functions
%
%----------------------------------------------------------------------


%*********************************************************************
% Function Name:	'MapMode'
%
% Description:		Deal with the mapping mode
%
% Inputs:			current block
%						Update mode: Args = 0, block update required
%										 Args = 1, no block update required
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'MapMode'))

   if(strmatch('User',Vals{MapModeField}))
		if(strcmp(En{MapVecField},'off'))
			En{MapVecField} = 'on';
			set_param(block,'MaskEnables',En);
			if(~Args)
				feval(mfilename,block,'UpdateBlocks');
			end;
		end;
	elseif(strcmp(En{MapVecField},'on'))
		En{MapVecField} = 'off';
		set_param(block,'MaskEnables',En);
		if(~Args)
			feval(mfilename,block,'UpdateBlocks');
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

	Cb{SetSizeField}	= '';
	Cb{MapModeField} = [mfilename '(gcb,''MapMode'');'];
	Cb{MapVecField}	= '';

	En{SetSizeField}	= 'on';
	En{MapModeField}	= 'on';
	En{MapVecField}	= 'off';

	Vis{SetSizeField}= 'on';
	Vis{MapModeField}= 'on';
	Vis{MapVecField}	= 'on';

	% --- Set Callbacks, enable status and visibilities
   set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis);

	% --- Set the startup values.  '' Indicates that the default saved will be used

	Vals{SetSizeField} 	= '8';
	Vals{MapModeField} 	= 'Straight';
	Vals{MapVecField}= '[0 1 3 2 7 6 4 5]';


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



%----------------------------------------------------------------------
%
%	Subfunctions
%
%----------------------------------------------------------------------






















