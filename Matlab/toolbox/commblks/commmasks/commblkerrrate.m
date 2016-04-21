function varargout = commblkerrrate(block, varargin)
% COMMBLKERRMETER Mask dynamic dialog function for error meter

% Author: Trefor Delve
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/03/24 02:00:28 $


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
Vis	= get_param(block, 'maskvisibilities');
En  	= get_param(block, 'maskenables');

% --- Field numbers

RxDelay  	= 1;
StDelay		= 2;
CpMode		= 3;
Subframe		= 4;
OutMode		= 5;
VarName		= 6;
RsPort		= 7;

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
   [varargout{1:1}] = feval(mfilename,block,'UpdateWs',Args);

end;
    
%----------------------------------------------------------------------
%
%	Block specific update functions
%
%----------------------------------------------------------------------

%*********************************************************************
% Function:        UpdateEnables
%
% Description:     Sets the blocks enables approprates
%
% Inputs:          current block
%
% Return values:   none
%
%*********************************************************************

if(strcmp(action,'UpdateEnables'))
    maskEnables = get_param(gcb,'MaskEnables');
    maskValues  = get_param(gcb,'MaskValues');
    if((strcmp(maskValues(8),'on')))
        maskEnables([9,10])  = {'on'};
    else
        maskEnables([9,10]) = {'off'};
    end
    set_param(gcb,'MaskEnables',maskEnables);
    
end




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
   
   if(strcmp(Vals{CpMode},'Select samples from port'))
      if(strcmp(Vals{RsPort},'on'))
         s.i1 = 1; s.i1s = 'Tx';
         s.i2 = 2; s.i2s = 'Rx';
         s.i3 = 3; s.i3s = 'Sel';
         s.i4 = 4; s.i4s = 'Rst';
      else
         s.i1 = 1; s.i1s = 'Tx';
         s.i2 = 2; s.i2s = 'Rx';
         s.i3 = 3; s.i3s = 'Sel';
         s.i4 = 3; s.i4s = '';
      end
   else
      if(strcmp(Vals{RsPort},'on'))
         s.i1 = 1; s.i1s = 'Tx';
         s.i2 = 2; s.i2s = 'Rx';
         s.i3 = 3; s.i3s = 'Rst';
         s.i4 = 3; s.i4s = '';
      else
         s.i1 = 1; s.i1s = 'Tx';
         s.i2 = 2; s.i2s = 'Rx';
         s.i3 = 2; s.i3s = '';
         s.i4 = 2; s.i4s = '';
      end
   end
         
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
	feval(mfilename,block,'CpMode',1);
	feval(mfilename,block,'OutMode',1);
end;

%----------------------------------------------------------------------
%
%	Dynamic dialog specific field functions
%
%----------------------------------------------------------------------

%*********************************************************************
% Function Name:	'OutMode'
%
% Description:		Deal with the output data mode
%
% Inputs:			current block
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'OutMode'))

   if(strcmp(Vals{OutMode},'Workspace'))
      if(strcmp(Vis{VarName},'off'))
         En{VarName}		= 'on';
         Vis{VarName}	= 'on';
         
         set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
			if(~Args)
            % --- Un-comment this if blocks are required to change
            %     when the dynamic dialog event occurs
				%feval(mfilename,block,'UpdateBlocks');
			end;
		end;
	elseif(strcmp(Vis{VarName},'on'))
		En{VarName}		= 'off';
      Vis{VarName}	= 'off';
      
		set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
		if(~Args)
         % --- Un-comment this if blocks are required to change
         %     when the dynamic dialog event occurs
			%feval(mfilename,block,'UpdateBlocks');
		end;
	end

end;

%*********************************************************************
% Function Name:	'CpMode'
%
% Description:		Deal with the subframe computation mode
%
% Inputs:			current block
%
% Return Values:	none
%
%********************************************************************

if(strcmp(action,'CpMode'))

   if(strcmp(Vals{CpMode},'Select samples from mask'))
      if(strcmp(Vis{Subframe},'off'))
         En{Subframe}		= 'on';
         Vis{Subframe}	= 'on';
         
         set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
			if(~Args)
            % --- Un-comment this if blocks are required to change
            %     when the dynamic dialog event occurs
				%feval(mfilename,block,'UpdateBlocks');
			end;
		end;
	elseif(strcmp(Vis{Subframe},'on'))
		En{Subframe}		= 'off';
      Vis{Subframe}	= 'off';
      
		set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
		if(~Args)
         % --- Un-comment this if blocks are required to change
         %     when the dynamic dialog event occurs
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

	Cb{RxDelay} 		= '';
	Cb{StDelay} 		= '';
	Cb{CpMode}			= [mfilename '(gcb,''CpMode'');'];
	Cb{Subframe}		= '';
	Cb{OutMode}			= [mfilename '(gcb,''OutMode'');'];
	Cb{VarName}			= '';
	Cb{RsPort}			= '';

	En{RxDelay}			= 'on';
	En{StDelay}			= 'on';
	En{CpMode}			= 'on';
	En{Subframe}		= 'off';
	En{OutMode}			= 'on';
	En{VarName}			= 'off';
	En{RsPort}			= 'on';

	Vis{RxDelay}		= 'on';
	Vis{StDelay}		= 'on';
	Vis{CpMode}			= 'on';
	Vis{Subframe}		= 'off';
	Vis{OutMode}		= 'on';
	Vis{VarName}		= 'off';
	Vis{RsPort}			= 'on';

   % --- Get the MaskTunableValues 
	Tunable = get_param(block,'MaskTunableValues');
	Tunable{RxDelay}	= 'off';
	Tunable{StDelay}	= 'off';
	Tunable{CpMode}	= 'off';
	Tunable{Subframe}	= 'off';
	Tunable{OutMode}	= 'off';
	Tunable{VarName}	= 'off';
	Tunable{RsPort}	= 'off';

	% --- Set Callbacks, enable status, visibilities and tunable values
	set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, 'MaskTunableValues', Tunable);

	% --- Set the startup values.  '' Indicates that the default saved will be used

	Vals{RxDelay}		= '0';
	Vals{StDelay}		= '0';
	Vals{CpMode}		= 'Entire frame';
	Vals{Subframe}		= '[]';
	Vals{OutMode}		= 'Workspace';
	Vals{VarName}		= 'ErrorVec';
	Vals{RsPort}		= 'off';
	
	MN = get_param(gcb,'MaskNames');
	for n=1:length(Vals)
		if(~isempty(Vals{n}))
			set_param(block,MN{n},Vals{n});
		end;
	end;

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

