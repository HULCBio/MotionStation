function varargout = commblkpoissonsrc2(block, varargin)
% COMMBLKPOISSONSRC2 Mask dynamic dialog function for Poisson source block

% Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:02:20 $


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

Lambda       = 1;
Seed         = 2;
SampleTime   = 3;
FrameBased   = 4;
SampPerFrame = 5;
Orient       = 6;

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

vLen = [length(maskLambda) length(maskSeed)];
vSize = {size(maskLambda) size(maskSeed)};

lenmax = max(vLen);            % Largest of all the parameter lengths
dimcomp = min(find(vLen~=1));  % Index of the first vector parameter
                               %    used for comparison with dimensions of other parameters

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
   eStr.ecode = 0;
   eStr.emsg  = '';
   
    % --- If the simulation status is 'stopped', then the function is being called
    %     because of an OK or apply and so the parameters do not need to be valid
    %     and hence, need not be evaluated
    simStatus = lower(get_param(bdroot(gcb),'SimulationStatus'));
    if(strcmp(simStatus,'stopped'))
        eStr.ecode = 3;  % Quiet exit
        varargout{1} = eStr;
        return;
    end;  
       
   % Check for consistency among vector parameter lenghts
   if ~isequal(lenmax,1)   % if there exist vector parameters
      
      vSizeLambda = vSize{idxLambda};
      vSizeSeed   = vSize{idxSeed};
      
      if any(find(vLen(find(vLen~=1))~=lenmax)),
         eStr.ecode = 1;
         eStr.emsg  = 'Lambda and Initial seed must be either all scalars, or if more than one of them is a vector, their vector sizes should agree.';
         
      % If dimensions are to be preserved, check if they agree
      elseif strcmp(Vals{Orient},'off') & strcmp(Vals{FrameBased},'off') ...
             & ~isequal(vSizeLambda(1),vSizeSeed(1)) & ~isequal(vSizeLambda(2),vSizeSeed(2)) ...
             & ~isequal(vSize{Lambda},vSize{Seed})
         eStr.ecode = 1;
         eStr.emsg  = ['Dimensions of parameter values in ', block, ' are inconsistent.'];
      end
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
   
   % Sample-based case
   if(strcmp(Vals{FrameBased},'off'))
      set_param([block, '/Frame Status Conversion'],'outframe','Sample-based');   
      set_param([block, '/Buffer'],'ic','0');
      
      % Interpret as 1-D; OR scalar output
      if(strcmp(Vals{Orient},'on')) | ~any(vLen-1)
          set_param([block, '/Reshape'],'OutputDimensionality','1-D array');
       
      % 2-D vector output    
       else
          vec = vSize{dimcomp};
          
          % Column vector
          if vec(1) > vec(2)
             set_param([block, '/Reshape'],'OutputDimensionality','Column vector');
          % Row vector   
          else  
             set_param([block, '/Reshape'],'OutputDimensionality','Row vector');
          end            
       end
      
   % Frame-based case
   else
      set_param([block, '/Frame Status Conversion'],'outframe','Frame-based');   

      set_param([block, '/Reshape'],'OutputDimensionality','Customize');       
      set_param([block, '/Reshape'],'OutputDimensions',['[sampPerFrame,' num2str(lenmax) ']']);
 
      if(maskSampPerFrame > 1)
         set_param([block, '/Buffer'],'ic','buffic');
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

if(strcmp(action,'UpdateIc'))
   lam = maskLambda;
   seed = maskSeed;
   rand('state',seed(1));
   k = [];
   
   for idx = 1:lenmax*maskSampPerFrame,
      
      while_flag = 1;
      kk = 0;
      p = 0;
      
      while (while_flag)
         p = p-log(rand);
         if (p > lam)
            while_flag = 0;
         else
            kk = kk+1;
         end
      end
      
      k = [k kk];
   end
   varargout{1} = k;
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
	Cb{Lambda}       = '';
	Cb{Seed}         = '';
	Cb{SampleTime}   = '';
	Cb{FrameBased}    = 'commblkpoissonsrc2(gcb,''cbFrameBased'');';
    Cb{SampPerFrame}  = '';
    Cb{Orient}        = 'commblkpoissonsrc2(gcb,''cbOrient'');';
    
    En{Lambda}       = 'on';
    En{Seed}         = 'on';
    En{SampleTime}   = 'on';
    En{FrameBased}    = 'on';
    En{SampPerFrame}  = 'off';
    En{Orient}        = 'on';
    
    Vis{Lambda}      = 'on';
    Vis{Seed}        = 'on';
    Vis{SampleTime}  = 'on';
    Vis{FrameBased}   = 'on';
    Vis{SampPerFrame} = 'on';
    Vis{Orient}       = 'on';
    
	% --- Set Callbacks, enable status and visibilities
    set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis);
    
	% --- Set the startup values.  '' Indicates that the default saved will be used

	Vals{Lambda}       = '[0.1 3]';
	Vals{Seed}         = '[1 2]';
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
oldEnSamp   = En{5};
oldEnOrient = En{6};

if(strcmp(Vals{4},'off'))
    En{5}  = 'off';
    En{6}  = 'on';
else % 'Frame-based'
    En{5}  = 'on';
    En{6}  = 'off';
end;

if strcmp(oldEnSamp, En{5}) == 0 | strcmp(oldEnOrient, En{6}) == 0
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
oldEnFrame = En{4};

if(strcmp(Vals{6},'on'))  % Interpret as 1-D
    En{4}  = 'off';
else
    En{4}  = 'on';
end;

if strcmp(oldEnFrame, En{4}) == 0
    set_param(block,'MaskEnables',En);
end

