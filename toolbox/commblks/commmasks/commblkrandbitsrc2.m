function varargout = commblkrandbitsrc2(block, varargin)
% COMMBLKRANDBITSRC2 Mask dynamic dialog function for random bit source block

% Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/12 23:02:59 $


% --- Modes of operation
%		varargin{1} = action =	'init' - Indicates that the block initialization
%													function is calling the code.
%													The code should call the functions to update
%													visibilities/enables etc. and based on these
%													settings, make any changes to the
%													simulink block.
%
%					= CallbackName		-	Indicates that a dialog field callback
%													is executing.
%
%		varargin{2} = 0					- Dynamic dialog initiated callback
%					= 1					- Callback required to update fields only
%

% --- Field numbers

VecLen       = 1;
ProbVec      = 2;
Seed         = 3;
SampleTime   = 4;
FrameBased   = 5;
SampPerFrame = 6;
Orient       = 7;

nvarargin = nargin - 1;

switch nvarargin
	case 0
		action = '';
	case 1
		action = varargin{1};
		Args = {};
	otherwise
		action = varargin{1};
		Args = varargin{2:end};

      if(~strcmp(lower(action),'backprop'))
         % --- Breakout the arguments if required
   		if((nvarargin > 1) & (isa(Args,'cell')))
   		end;
      end;

end;

% --- Field data

Vals  = get_param(block, 'maskvalues');
Vis   = get_param(block, 'maskvisibilities');
En    = get_param(block, 'maskenables');

% --- Set Field index numbers and mask variable data
setallfieldvalues(block);

eStr.ecode1 = 0;
eStr.ecode2 = 0;
eStr.emsg1  = '';
eStr.emsg2  = '';

% Get 1st parameter, and lengths of 2nd and 3rd parameters
if ~isscalar(maskN) | ~isinteger(maskN) | maskN<=0
   eStr.ecode1 = 1;
   eStr.emsg1  = 'Binary vector length must be a positive integer scalar.';
   varargout{1} = eStr;
   return
end
vLen = [maskN length(maskProb) length(maskSeed)];

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

   % --- Exit code and error message definitions
%    eStr.ecode2 = 0;
%    eStr.emsg1  = '';
   eStr.emsg2  = '';
   
   % --- If the simulation status is 'stopped', then the function is being called
   %     because of an OK or apply and so the parameters do not need to be valid
   %     and hence, need not be evaluated
   simStatus = lower(get_param(bdroot(gcb),'SimulationStatus'));
   if(strcmp(simStatus,'stopped'))
      eStr.ecode = 3;  % Quiet exit
      varargout{1} = eStr;
      return;
   end;  
   
   % Check for consistency among vector parameter lengths
   if vLen(2) > vLen(1)
      eStr.ecode2 = 1;
      eStr.emsg2  = 'Length of Probability vector must be smaller or equal to the Binary vector length parameter.';
      
   end
   
   cbFrameBased(block);
   cbOrient(block);
   feval(mfilename,block,'UpdateBlocks',Args);
   varargout{1}=eStr;
   
end;

if(strcmp(action,'cbFrameBased'))
   cbFrameBased(block);
end

if(strcmp(action,'cbOrient'))
   cbOrient(block);
end

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
   if(strcmp(Vals{FrameBased},'off'))  % Sample-based
      set_param([block, '/Frame Status Conversion'],'outframe','Sample-based');   
      set_param([block, '/Buffer'],'ic','0');
      if(strcmp(Vals{Orient},'on')) | ~any(vLen-1)
          % Interpret as 1-D; OR scalar output
          set_param([block, '/Reshape'],'OutputDimensionality','1-D array');
      else  % 2-D vector
         vec = size(maskProb);
         if vec(1) > vec(2)   % column vector
            set_param([block, '/Reshape'],'OutputDimensionality','Column vector');
         else  % row vector
            set_param([block, '/Reshape'],'OutputDimensionality','Row vector');
         end            
      end
   else   % Frame-based
      set_param([block, '/Frame Status Conversion'],'outframe','Frame-based');   
      set_param([block, '/Reshape'],'OutputDimensionality','Customize');

      if (maskSampPerFrame>1)
         set_param([block, '/Buffer'],'ic','randerr(sampPerFrame,n,[0:length(prob);1-sum(prob) prob],seed)');   % First frame of buffer
      else
         set_param([block, '/Buffer'],'ic','0');         
      end
   end;
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
%    [varargout{1:2}]=srcsicon(5); % Mask icon
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
end;




%----------------------------------------------------------------------
%
%	Dynamic dialog specific field functions
%
%----------------------------------------------------------------------



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

	Cb{VecLen}        = '';
	Cb{ProbVec}       = '';
	Cb{Seed}          = '';
	Cb{SampleTime}    = '';
	Cb{FrameBased}    = 'commblkrandbitsrc2(gcb,''cbFrameBased'');';
	Cb{SampPerFrame}  = '';
	Cb{Orient}        = 'commblkrandbitsrc2(gcb,''cbOrient'');';

	En{VecLen}        = 'on';
	En{ProbVec}       = 'on';
	En{Seed}          = 'on';
	En{SampleTime}    = 'on';
    En{FrameBased}    = 'on';
    En{SampPerFrame}  = 'off';
    En{Orient}        = 'on';
    
    Vis{VecLen}       = 'on';
    Vis{ProbVec}      = 'on';
    Vis{Seed}         = 'on';
    Vis{SampleTime}   = 'on';
    Vis{FrameBased}   = 'on';
    Vis{SampPerFrame} = 'on';
    Vis{Orient}       = 'on';
    
    % --- Set Callbacks, enable status and visibilities
    set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis);
    
    % --- Set the startup values.  '' Indicates that the default saved will be used
    
    Vals{VecLen}       = '7';
    Vals{ProbVec}      = '0.5';
    Vals{Seed}         = '12345';
    Vals{SampleTime}   = '1';
    Vals{FrameBased}   = 'off';
    Vals{SampPerFrame} = '1';
    Vals{Orient}       = 'off';
    
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
% Function Name:	'cbFrameBased'
%
%  - Callback function for 'frameBased' parameter
%
%********************************************************************

function cbFrameBased(block)

Vals  = get_param(block, 'maskvalues');
En    = get_param(block, 'maskenables');
oldEnSamp   = En{6};
oldEnOrient = En{7};

if(strcmp(Vals{5},'off'))
    En{6}  = 'off';
    En{7}  = 'on';
else % 'Frame-based'
    En{6}  = 'on';
    En{7}  = 'off';
end;

if strcmp(oldEnSamp, En{6}) == 0 | strcmp(oldEnOrient, En{7}) == 0
    set_param(block,'MaskEnables',En);
end

%*********************************************************************
% Function Name:	'cbOrient'
%
%  - Callback function for 'orient' parameter
%
%********************************************************************

function cbOrient(block)

Vals  = get_param(block, 'maskvalues');
En    = get_param(block, 'maskenables');
oldEnFrame = En{5};

if(strcmp(Vals{7},'on'))  % Interpret as 1-D
    En{5}  = 'off';
else
    En{5}  = 'on';
end;

if strcmp(oldEnFrame, En{5}) == 0
    set_param(block,'MaskEnables',En);
end
