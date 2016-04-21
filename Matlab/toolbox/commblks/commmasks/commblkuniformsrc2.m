function varargout = commblkuniformsrc2(block, varargin)
% COMMBLKUNIFORMSRC2 Mask dynamic dialog function for uniform source block

% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/03/24 02:02:13 $


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

NoiseLower   = 1;
NoiseUpper   = 2;
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

vLen = [];
for idx=1:3,
   % Length of each of the first 3 parameters
   vLen=[vLen length(str2num(Vals{idx}))];
   
   % Dimension of each of the first 3 parameters
   vSize{idx}=size(str2num(Vals{idx}));
end

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
   
   % Check for consistency among vector parameter lengths
   if ~isequal(lenmax,1)   % if there exist vector parameters
      
      % Check if vector lengths (if any) agree
      if any(find(vLen(find(vLen~=1))~=lenmax)),
         eStr.ecode = 1;
         eStr.emsg  = 'Noise lower bound, Noise upper bound and Initial seed must be either all scalars, or if more than one of them is a vector, their vector sizes should agree.';
         varargout{1}=eStr;
         return
      % If dimensions are to be preserved, check if they agree
      elseif strcmp(Vals{Orient},'off') & strcmp(Vals{FrameBased},'off')  
         for idx=[find(vLen~=1)]
            if ~isequal(vSize{idx},vSize{dimcomp})
               eStr.ecode = 1;
               eStr.emsg  = ['Dimensions of parameter values in ', block, ' are inconsistent.'];
            end
         end         
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
      set_param([block, '/Random Source'],'SampFrame','1');
      
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
      set_param([block, '/Random Source'],'SampFrame','sampPerFrame');
      set_param([block, '/Reshape'],'OutputDimensionality','Customize');
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

	Cb{NoiseLower}   = '';
	Cb{NoiseUpper}   = '';
	Cb{Seed}         = '';
	Cb{SampleTime}   = '';
	Cb{FrameBased}    = 'commblkuniformsrc2(gcb,''cbFrameBased'');';
	Cb{SampPerFrame}  = '';
	Cb{Orient}        = 'commblkuniformsrc2(gcb,''cbOrient'');';

	En{NoiseLower}   = 'on';
	En{NoiseUpper}   = 'on';
	En{Seed}         = 'on';
	En{SampleTime}   = 'on';
    En{FrameBased}    = 'on';
	En{SampPerFrame}  = 'off';
	En{Orient}        = 'on';

	Vis{NoiseLower}   = 'on';
	Vis{NoiseUpper}   = 'on';
	Vis{Seed}         = 'on';
	Vis{SampleTime}   = 'on';
    Vis{FrameBased}   = 'on';
	Vis{SampPerFrame} = 'on';
	Vis{Orient}       = 'on';

	% --- Set Callbacks, enable status and visibilities
   set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis);

	% --- Set the startup values.  '' Indicates that the default saved will be used

	Vals{NoiseLower}   = '[0 1]';
	Vals{NoiseUpper}   = '[1 2]';
	Vals{Seed}         = '[12345 54321]';
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

if strcmp(oldEnSamp, En{5}) == 0 | strcmp(oldEnOrient, En{5}) == 0
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

