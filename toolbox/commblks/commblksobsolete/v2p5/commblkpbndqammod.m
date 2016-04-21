function varargout = commblkpbndqammod(block, varargin)
% COMMBLKPBNDQAMMOD Mask dynamic dialog function for Passband M-QAM modulator block
% Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:02:33 $


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
PowType			   = 4;
MinDist			   = 5;
AvgPow			   = 6;
PeakPow			   = 7;
InPer              = 8;
NumSamp			   = 9;
CarrFr             = 10;
CarrPh			   = 11;
OutPer             = 12;

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
   feval(mfilename,block,'Powtype',1);
end;


%----------------------------------------------------------------------
%
%	Dynamic Dialog specific field functions
%
%----------------------------------------------------------------------

%*********************************************************************
% Function Name:	'InType'
%
% Description:		Deal with Input type parameter
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


%*********************************************************************
% Function Name:	'PowType'
%
% Description:		Deal with the Normalization method parameter
%
% Inputs:			current block
%						Update encoding: Args = 0, block update required
%										     Args = 1, no block update required
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'PowType'))

   if(strcmp(Vals{PowType},'Min. distance between symbols'))
		if(strcmp(Vis{MinDist},'off'))

         % --- The Minimum distance between symbols method is selected and the 
         %	   Minimum distance field is not visible so this is a call requiring a change

         % --- Switch on the Minimum distance field
		 Vis{MinDist}             = 'on';
         En{MinDist}	          = 'on';
         
         Vis{AvgPow}              = 'off';
         En{AvgPow}	              = 'off';
         
         Vis{PeakPow}             = 'off';
         En{PeakPow}	          = 'off';
         
			set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
			if(~Args)
            % --- If update of the block is required when the dynamic dialog
            %     changes, the uncomment the following
				%feval(mfilename,block,'UpdateBlocks');
			end;
      end;
    elseif(strcmp(Vals{PowType},'Average Power'))
		if(strcmp(Vis{AvgPow},'off'))

         % --- The Average Power method is selected and the Average Power 
         %	   field is not visible so this is a call requiring a change

         % --- Switch on the Average Power field
         Vis{MinDist}             = 'off';
         En{MinDist}	          = 'off';
         
         Vis{AvgPow}              = 'on';
         En{AvgPow}	              = 'on';
         
         Vis{PeakPow}             = 'off';
         En{PeakPow}	          = 'off';
         
         set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
			if(~Args)
            % --- If update of the block is required when the dynamic dialog
            %     changes, the uncomment the following
				%feval(mfilename,block,'UpdateBlocks');
			end;
      end;
       elseif(strcmp(Vals{PowType},'Peak Power'))
		if(strcmp(Vis{PeakPow},'off'))

         % --- The Peak Power method is selected and the Peak Power 
         %	   field is not visible so this is a call requiring a change

         % --- Switch on the Peak Power field
         Vis{MinDist}             = 'off';
         En{MinDist}	          = 'off';
         
         Vis{AvgPow}              = 'off';
         En{AvgPow}	              = 'off';
         
         Vis{PeakPow}             = 'on';
         En{PeakPow}	          = 'on';
         
         set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
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
   Cb{PowType}   			  = [mfilename '(gcb,''PowType'');'];
   Cb{MinDist}   			  = '';
   Cb{AvgPow}   			  = '';
   Cb{PeakPow}   			  = '';
   Cb{NumSamp}				  = '';
   Cb{InPer}		        = '';
   Cb{CarrFr}		       = '';
   Cb{CarrPh}              = '';
   Cb{OutPer}              = '';
   
   En{M_ary}  		        = 'on';
   En{InType}				  = 'on';
   En{Map}                = 'off';
   En{PowType}		           = 'on';
   En{MinDist}		           = 'on';
   En{AvgPow}		           = 'on';
   En{PeakPow}		           = 'on';
   En{NumSamp}            = 'on';
   En{InPer}		       = 'on';
   En{CarrFr}		       = 'on';
   En{CarrPh}              = 'on';
   En{OutPer}              = 'on';

   Vis{M_ary}    	        = 'on';
   Vis{InType}				  = 'on';
   Vis{Map}               = 'on';
   Vis{PowType}		           = 'on';
   Vis{MinDist}		           = 'on';
   Vis{AvgPow}		           = 'off';
   Vis{PeakPow}		           = 'off';
   Vis{NumSamp}           = 'on';
   Vis{InPer}		       = 'on';
   Vis{CarrFr}		       = 'on';
   Vis{CarrPh}             = 'on';
   Vis{OutPer}             = 'on';
   
   % --- Get the MaskTunableValues 
   Tunable = get_param(block,'MaskTunableValues');
   Tunable{M_ary}		  = 'off';
   Tunable{InType}		  = 'off';
   Tunable{Map}           = 'off';
   Tunable{PowType}		  = 'off';
   Tunable{MinDist}		  = 'off';
   Tunable{AvgPow}		  = 'off';
   Tunable{PeakPow}		  = 'off';
   Tunable{NumSamp}       = 'off';
   Tunable{InPer}		  = 'off';
   Tunable{CarrFr}		  = 'off';
   Tunable{CarrPh}        = 'off';
   Tunable{OutPer}        = 'off';
   
	% --- Set Callbacks, enable status, visibilities and tunable values
	set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, 'MaskTunableValues', Tunable);

	% --- Set the startup values.  '' Indicates that the default saved will be used

   Vals{M_ary}			   = '16';
   Vals{InType}			   = 'Integer';
   Vals{Map}               = 'Binary';
   Vals{PowType}	       = 'Min. distance between symbols';
   Vals{MinDist}	       = '2';
   Vals{AvgPow}	           = '1';
   Vals{PeakPow}	       = '1';
   Vals{NumSamp}   		   = '1';
   Vals{InPer}		       = '1/100';
   Vals{CarrFr}		       = '3000';
   Vals{CarrPh}            = '0';
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
