function varargout = commblkmapdata(block, varargin)
% COMMBLKMAPDATA Mask dynamic dialog function for data mapping block

% Author: Trefor Delve
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/03/24 02:01:43 $

% --- Modes of operation
%		varargin{1} = action =	'init' - Indicates that the block initialization
%													function is calling the code.
%													The code should call the functions to update
%													visibilities/enables etc. and based on these
%													settings, make any changes to the
%													simulink block.
%
%						= CallbackName		 -	Indicates that a dialog field callback
%													is executing.
%
%		varargin{2} = 0					 - Dynamic Dialogue initiated callback
%						= 1					 - Callback required to update fields only
%

% --- Field numbers

MapModeField 	= 1;
SetSizeField	= 2;
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
		   MapMode	= Args{MapModeField};
		   M			= Args{SetSizeField};
		   MapVec	= Args{MapVecField};
		end;

end;

% --- Field data

Vals	= get_param(block, 'maskvalues');
Vis	= get_param(block, 'maskvisibilities');
En  	= get_param(block, 'maskenables');

%*********************************************************************
% Function:			initialise
%
% Description:		Set the dialogues up based on the parameter values.
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
   [varargout{1:4}] = feval(mfilename,block,'UpdateWs',Args);
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
   if(MapMode ~= 4)
      if(~(all(size(M) == 1)))
         error('Symbol set size must be a scalar');
      end;

      if(M < 2)
         error('Symbol set size must be greater than two');
      end;

      if(M-floor(M) > 0)
         error('Symbol set size must be an integer');
      end;

      if(abs(log2(M)-round(log2(M))) > 0)
         error('Symbol set size must be a power of two');
      end;
   end;

   % --- Set the lookup table as required
	switch MapMode

      case 1      % Binary to Gray
			EnFlag = 1;
			IPValues	= (0:M-1);
			OPValues	= bitxor(IPValues,floor(IPValues/2));
         SatValue = M-1;
      case 2      % Gray to binary
			EnFlag = 1;
			IPValues	= (0:M-1);

			[y,i]=sort(bitxor(IPValues,floor(IPValues/2)));
			OPValues	= i-1;
         SatValue = M-1;
		case 3		% User defined mapping
         if(M ~= length(MapVec))
      	  error('Mapping vector should be the same length as the symbol set size.');
      	end;

			EnFlag = 1;
			IPValues	= (0:M-1);
			OPValues	= MapVec;
         SatValue = M-1;
		case 4		% Straight through mapping
			EnFlag = 0;
			IPValues	= 0:1;	% Dummy lookup values
			OPValues	= 0:1;
         SatValue = 1;
	end;

   % --- Set the output variables
	varargout{1} = EnFlag;
	varargout{2} = IPValues;
	varargout{3} = OPValues;
	varargout{4} = SatValue;
end;


%*********************************************************************
% Function:			UpdateFields
%
% Description:		Update the dialogue fields.
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
%	Dynamic Dialog specific field functions
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

   if(~isempty(strmatch('User',Vals{MapModeField})) | ~isempty(strmatch('Gray',Vals{MapModeField}))  | ~isempty(strmatch('Binary',Vals{MapModeField})))
		if(strcmp(En{MapVecField},'off'))
			En{SetSizeField} = 'on';
         if(~isempty(strmatch('User',Vals{MapModeField})))
   			En{MapVecField} = 'on';
         end;
			set_param(block,'MaskEnables',En);
			if(~Args)
				feval(mfilename,block,'UpdateBlocks');
			end;
      elseif(~isempty(strmatch('Gray',Vals{MapModeField}))  | ~isempty(strmatch('Binary',Vals{MapModeField})))      
   			En{MapVecField} = 'off';
   			set_param(block,'MaskEnables',En);
		end;
	elseif(strcmp(En{SetSizeField},'on') | strcmp(En{MapVecField},'on'))
		En{SetSizeField} = 'off';
		En{MapVecField} = 'off';
		set_param(block,'MaskEnables',En);
		if(~Args)
			feval(mfilename,block,'UpdateBlocks');
		end;
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

	Cb{MapModeField} = [mfilename '(gcb,''MapMode'');'];
	Cb{SetSizeField}	= '';
	Cb{MapVecField}	= '';

	En{MapModeField}	= 'on';
	En{SetSizeField}	= 'off';
	En{MapVecField}	= 'off';

	Vis{MapModeField}= 'on';
	Vis{SetSizeField}= 'on';
	Vis{MapVecField}	= 'on';

   % --- Get the MaskTunableValues 
   Tunable = get_param(block,'MaskTunableValues');
	Tunable{MapModeField} = 'off';
	Tunable{SetSizeField} = 'off';
   Tunable{MapVecField}  = 'off';

	% --- Set Callbacks, enable status, visibilities and tunable values
	set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, 'MaskTunableValues', Tunable);

	% --- Set the startup values.  '' Indicates that the default saved will be used

	Vals{MapModeField} = 'Binary';
	Vals{SetSizeField} = '8';
	Vals{MapVecField}  = '[0 1 3 2 7 6 4 5]';

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






















