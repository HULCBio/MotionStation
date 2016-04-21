function varargout = commblkdrpt2(block, varargin)
% COMMBLKDRPT2 Communications Blockset Derepeat block helper function.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.3 $ $Date: 2002/03/24 02:00:19 $

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
Drpt    = 1;
IC      = 2;
Mode    = 3;

%*********************************************************************
% Function:			initialize
%
% Description:		Set the dialogs up based on the parameter values.
%						MaskEnables/MaskVisibilities are not saved in reference 
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


%----------------------------------------------------------------------
%
%	Block specific update functions
%
%----------------------------------------------------------------------

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
   feval(mfilename,block,'cbMode',1);
end;

%----------------------------------------------------------------------
%
%	Dynamic dialog specific field functions
%
%----------------------------------------------------------------------
%*********************************************************************
% Function Name:	'cbMode'
%
% Description:		Deal with the frame based modes of operation
%
% Inputs:			current block
%						Update mode: Args = 0, block update required
%			         	          Args = 1, no block update required
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'cbMode'))
    if(strcmp(Vals{Mode},'Maintain input frame rate'))
        if(strcmp(En{IC},'on')) 
            En{IC} = 'off';
            set_param(block,'MaskEnables',En);
        end
    elseif(strcmp(Vals{Mode},'Maintain input frame size'))
        if(strcmp(En{IC},'off')) 
            En{IC} = 'on'; 
            set_param(block,'MaskEnables',En);
        end
    else
        error('Unrecognized mode');
    end
end

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
   
   Cb{Drpt}   	= '';
   Cb{IC} 	    = '';
   Cb{Mode}   	= [mfilename '(gcb,''cbMode'');'];
   
   En{Drpt}   	= 'on';
   En{IC}	    = 'on';
   En{Mode}   	= 'on';
   
   Vis{Drpt}   = 'on';
   Vis{IC}	   = 'on';
   Vis{Mode}   = 'on';
   
   % --- Get the MaskTunableValues 
   Tunable = get_param(block,'MaskTunableValues');
   Tunable{Drpt}     = 'off';
   Tunable{IC}       = 'off';
   Tunable{Mode}     = 'off';
   
   % --- Set Callbacks, enable status, visibilities and tunable values
   set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, 'MaskTunableValues', Tunable);
   
   % --- Set the startup values.  '' Indicates that the default saved will be used
   
   Vals{Drpt}    = '10';
   Vals{IC}      = '0';
   Vals{Mode}    = 'Maintain input frame size';
   
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

