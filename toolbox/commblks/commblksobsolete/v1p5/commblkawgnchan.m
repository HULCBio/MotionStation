function varargout = commblkawgnchan(block, varargin)
% COMMBLKAWGNCHAN Mask dynamic dialog function AWGN Channel block
% Copyright 1996-2002 The MathWorks, Inc.


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

Seed               = 1;
Mode               = 2;
EsNodB             = 3;
SNRdB					 = 4;
InputSamplePower   = 5;
SymbolPeriod       = 6;
Variance			    = 7;
FrameBased         = 8;
NoOfChannels       = 9;

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
   if(strcmp(Vals{Mode},'Signal to noise ratio  (Es/No)'))
      RemovePorts(block);
   elseif(strcmp(Vals{Mode},'Signal to noise ratio  (SNR)'))
      % --- The required mode is signal to noise, so no additional ports are required
      RemovePorts(block);
   elseif(strcmp(Vals{Mode},'Variance from mask'))
      RemovePorts(block);
   elseif(strcmp(Vals{Mode},'Variance from port'))
      AddPorts(block);
   else
      error('Unrecognized mode');
   end;

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

   
   if(strcmp(Vals{Mode},'Signal to noise ratio  (Es/No)'))
      s.i1 = 1; s.i1s = ''; 
      s.i2 = 1; s.i2s = '';
      s.o1 = 1; s.o1s = '';

      varargout{1} = 1; % Mode = 1
      varargout{2} = s;
	
	elseif(strcmp(Vals{Mode},'Signal to noise ratio  (SNR)'))
      s.i1 = 1; s.i1s = ''; 
      s.i2 = 1; s.i2s = '';
      s.o1 = 1; s.o1s = '';

      varargout{1} = 2; % Mode = 2
      varargout{2} = s;

	elseif(strcmp(Vals{Mode},'Variance from mask'))
      s.i1 = 1; s.i1s = ''; 
      s.i2 = 1; s.i2s = '';
      s.o1 = 1; s.o1s = '';

      varargout{1} = 3; % Mode = 3
      varargout{2} = s;
	elseif(strcmp(Vals{Mode},'Variance from port'))
      s.i1 = 1; s.i1s = 'In'; 
      s.i2 = 2; s.i2s = 'Var';
      s.o1 = 1; s.o1s = '';

      varargout{1} = 4; % Mode = 4
      varargout{2} = s;
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
   feval(mfilename,block,'FrameBased',1);
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

   if(strcmp(Vals{Mode},'Signal to noise ratio  (Es/No)'))
		if(strcmp(Vis{EsNodB},'off'))

         % --- The Es/No (dB) mode is selected and the InputSymbolPower
         %     field is not visible so this is a call requiring a change

         % --- Switch on the Es/No related fields
			Vis{EsNodB}            = 'on';
			Vis{InputSamplePower}  = 'on';
			Vis{SymbolPeriod}      = 'on';

			En{EsNodB}             = 'on';
			En{InputSamplePower}   = 'on';
			En{SymbolPeriod}       = 'on';

         % --- Switch off the other fields
         En{SNRdB}              = 'off';
   		En{Variance}		     = 'off';
   		         
			Vis{SNRdB}				  = 'off';
   		Vis{Variance}		     = 'off';
   		
			
			set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
			if(~Args)
            % --- If update of the block is required when the dynamic dialog
            %     changes, the uncomment the following
				%feval(mfilename,block,'UpdateBlocks');
			end;
      end;
    elseif(strcmp(Vals{Mode},'Signal to noise ratio  (SNR)'))
		if(strcmp(Vis{SNRdB},'off'))

         % --- The Signal to noise ratio (dB) mode is selected and the InputSamplePower
         %     field is not visible so this is a call requiring a change

         % --- Switch off the Es/No & variance related fields
			Vis{EsNodB}            = 'off';
         Vis{SymbolPeriod}      = 'off';
         Vis{Variance}		     = 'off';
         
			En{EsNodB}             = 'off';
         En{SymbolPeriod}       = 'off';
         En{Variance}		     = 'off';
         
         % --- Switch on SNRdB and on or off the other fields
         En{SNRdB}              = 'on';
	   	En{InputSamplePower}   = 'on';
                  
			Vis{SNRdB}				  = 'on';
		   Vis{InputSamplePower}  = 'on';
			
			set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
			if(~Args)
            % --- If update of the block is required when the dynamic dialog
            %     changes, the uncomment the following
				%feval(mfilename,block,'UpdateBlocks');
			end;
      end;
	elseif(strcmp(Vals{Mode},'Variance from mask'))
      if(strcmp(Vis{Variance},'off'))
         % --- The Variance from mask mode is selected and the variance field is not visible
         %     so this is a call requiring a change
         
         % --- Switch off the Es/No & SNR related fields
         Vis{EsNodB}            = 'off';
         Vis{SymbolPeriod}      = 'off';
         Vis{SNRdB}				  = 'off';
         Vis{InputSamplePower}  = 'off';
         
			En{EsNodB}             = 'off';
         En{SymbolPeriod}       = 'off';
         En{SNRdB}              = 'off';
	   	En{InputSamplePower}   = 'off';

         % --- Switch on the variance 			         
         Vis{Variance}          = 'on';
         En{Variance}           = 'on';
           
         % --- Set the parameters
			set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
         
         if(~Args)
            % --- If update of the block is required when the dynamic dialog
            %     changes, the uncomment the following
            %feval(mfilename,block,'UpdateBlocks');
         end;
      end;
   elseif(strcmp(Vals{Mode},'Variance from port'))
      if(any([strcmp(Vis{Variance},'on') strcmp(Vis{InputSamplePower},'on')]))      
         Vis{EsNodB}             = 'off';
         Vis{SymbolPeriod}       = 'off';
         Vis{SNRdB}				   = 'off';
         Vis{InputSamplePower}   = 'off';
         Vis{Variance}           = 'off';
   	
			En{EsNodB}              = 'off';
         En{SymbolPeriod}        = 'off';
         En{SNRdB}				   = 'off';
         En{InputSamplePower}    = 'off';
         En{Variance}            = 'off';
         % --- Set the parameters
			set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
         
         if(~Args)
            % --- If update of the block is required when the dynamic dialog
            %     changes, the uncomment the following
            %feval(mfilename,block,'UpdateBlocks');
         end
      end
   else
      error('Unrecognized mode');
   end;
end;



%----------------------------------------------------------------------
%
%	Dynamic Dialog specific field functions
%
%----------------------------------------------------------------------

%*********************************************************************
% Function Name:	'FrameBased'
%
% Description:		Deal with the Frame-based of the operation
%
% Inputs:			current block
%						Update NoOfChannels: Args = 0, block update required
%										          Args = 1, no block update required
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'FrameBased'))
   
   if(strcmp(Vals{FrameBased},'off'))
      if(strcmp(En{NoOfChannels},'on'))
         
         %Disable NoOfChannels Parameter
         En{NoOfChannels}          = 'off';
            % --- Set the parameters
			set_param(block,'MaskEnables',En);
      end;
   else
      if(strcmp(En{NoOfChannels},'off'))
         
         %Enable NoOfChannels parameter
         En{NoOfChannels}			  = 'on';
            % --- Set the parameters
			set_param(block,'MaskEnables',En);
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

	Cb{Seed}				     = '';
	Cb{Mode}				     = [mfilename '(gcb,''Mode'');'];
   Cb{EsNodB}             = '';
   Cb{SymbolPeriod}       = '';
   Cb{SNRdB}              = '';
	Cb{InputSamplePower}   = '';
   Cb{Variance}		     = '';
   Cb{FrameBased}         = [mfilename '(gcb,''FrameBased'');'];
   Cb{NoOfChannels}       = '';

	En{Seed}				     = 'on';
	En{Mode}				     = 'on';
   En{EsNodB}             = 'on';
   En{SymbolPeriod}		  = 'on';
   En{SNRdB}              = 'off';
   En{InputSamplePower}   = 'on';
   En{Variance}		     = 'off';
   En{FrameBased}         = 'on';
   En{NoOfChannels}       = 'off';

	Vis{Seed}			     = 'on';
	Vis{Mode}			     = 'on';
   Vis{EsNodB}            = 'on';
   Vis{SymbolPeriod}		  = 'on';
   Vis{SNRdB}				  = 'off';
   Vis{InputSamplePower}  = 'on';
   Vis{Variance}		     = 'off';
   Vis{FrameBased}        = 'on';
   Vis{NoOfChannels}      = 'on';

   % --- Get the MaskTunableValues 
   Tunable = get_param(block,'MaskTunableValues');
	Tunable{Seed}             = 'off';
	Tunable{Mode}             = 'off';
   Tunable{EsNodB}           = 'on';
   Tunable{SymbolPeriod}     = 'off';
   Tunable{SNRdB}            = 'on';
   Tunable{InputSamplePower} = 'on';
   Tunable{Variance}         = 'on';
   Tunable{FrameBased}       = 'off';
   Tunable{NoOfChannels}     = 'off';

	% --- Set Callbacks, enable status, visibilities and tunable values
	set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, 'MaskTunableValues', Tunable);

	% --- Set the startup values.  '' Indicates that the default saved will be used

	Vals{Seed}			       = '123456';
	Vals{Mode}			       = 'Signal to noise ratio  (Es/No)';
   Vals{EsNodB}             = '10';
   Vals{SymbolPeriod}	    = '1';
   Vals{SNRdB}              = '10';
   Vals{InputSamplePower}   = '1';
   Vals{Variance}		       = '1';
   Vals{FrameBased}         = 'off';
   Vals{NoOfChannels}       = '1';

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

   RemovePorts(block);

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

%*********************************************************************
% Function Name:	RemovePorts
%
% Description:		
%
% Inputs:			current block
%
%*********************************************************************

function ECode = RemovePorts(Parent)

if(~strcmp(get_param([Parent '/Variance'],'BlockType'),'Ground'))
   

		% -----------------
		% --- Variance port
		% -----------------

      % --- Delete the line
      delete_line(Parent,'Variance/1','Dynamic AWGN/3');
      
      % --- Get the position of the blocks
      blockPos = get_param([Parent '/Variance'],'Position');
      
      % --- Delete the block
      delete_block([Parent '/Variance']);
      
      % --- Add the new block
      add_block('built-in/Ground',[Parent '/Variance'],'Position',blockPos);
      
      % --- Add the new line
      add_line(Parent,'Variance/1','Dynamic AWGN/3');

		ECode = 1;


	else
		ECode = 0;
	end;

return;




%*********************************************************************
% Function Name:	AddPorts
%
% Description:		Remove the ground block and replace with a port
%
% Inputs:			current block
%
%*********************************************************************

function ECode = AddPorts(Parent)

	if(~strcmp(get_param([Parent '/Variance'],'BlockType'),'Inport'))
   
		% -----------------
		% --- Variance port
		% -----------------

      % --- Delete the line
      delete_line(Parent,'Variance/1','Dynamic AWGN/3');
      
      % --- Get the position of the blocks
      blockPos = get_param([Parent '/Variance'],'Position');
      
      % --- Delete the block
      delete_block([Parent '/Variance']);
      
      % --- Add the new block
      add_block('built-in/Inport',[Parent '/Variance'],'Position',blockPos);
      
      % --- Add the new line
      add_line(Parent,'Variance/1','Dynamic AWGN/3');


		ECode = 1;
      
   else
		ECode = 0;
	end;

return;

