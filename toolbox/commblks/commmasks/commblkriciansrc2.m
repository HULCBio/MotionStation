function varargout = commblkriciansrc2(block, varargin)
%COMMBLKRICIANSRC2 Mask dynamic dialog function for Rician source block

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 16:28:11 $

% --- Exit code and error message definitions
eStr.ecode = 0;
eStr.emsg  = '';

% --- Parse inputs
nvarargin = nargin - 1;
switch nvarargin
case 0
    action = '';
case 1
    action = varargin{1};
    Args = '';
otherwise
    action = varargin{1};
    Args = varargin{2:end};
    
    if(strcmp(action,'UpdateBlocks'))
        output_size = Args;
    end
    
    % --- Breakout the arguments if required
    if((nvarargin > 1) & (isa(Args,'cell')))
        Mask_iMean = Args{1};
        Mask_qMean = Args{2};
        Mask_K     = Args{3};
        Mask_s     = Args{4};
    end;
end;

% --- Field data
Vals  = get_param(block, 'maskvalues');
Vis   = get_param(block, 'maskvisibilities');
En    = get_param(block, 'maskenables');

% --- Set Field index numbers and mask variable data
setallfieldvalues(block);

% Get size and lengths of required parameters
if (strcmp(Vals{idxSpecMethod}, 'K-factor'))   
    vLen = [length(maskK) length(maskS) length(maskSeed)];
    vSize = {size(maskK) size(maskS) size(maskSeed)};
else    % "Quadrature compoment" method
    vLen = [length(maskIMean) length(maskQMean) length(maskS) length(maskSeed)];
    vSize = {size(maskIMean) size(maskQMean) size(maskS) size(maskSeed)};
end

lenmax = max(vLen);            % Largest of all the parameter lengths
dimcomp = min(find(vLen~=1));  % Index of the first vector parameter 
                               % used for comparison with other parameters
if (lenmax > 1)
    if (length(maskIMean) == 1)
        Mask_iMean = maskIMean(ones(1, lenmax));
    end
    if (length(maskQMean) == 1)
        Mask_qMean = maskQMean(ones(1, lenmax));
    end
    if (length(maskK) == 1)
        Mask_K = maskK(ones(1, lenmax));
    end
    if (length(maskS) == 1)
        Mask_s = maskS(ones(1, lenmax));
    end
end

%*********************************************************************
% Function:			initialize
% Description:		Set the dialogs up based on the parameter values.
%                   MaskEnables/MaskVisibles are not save in reference 
%                   blocks.
% Inputs:			current block
% Return Values:	m1, m2, eStr
%********************************************************************
if(strcmp(action,'init'))
    
    % --- Return in case of early exit
    varargout = {maskK, maskS, eStr};
    
    % Check for sample time parameter
    if (~isscalar(maskTs) | maskTs <= 0)
        eStr.emsg = 'The sample time parameter must be a real scalar greater than 0.';
        eStr.ecode = 1; varargout{3} = eStr; return;
    end    
        
    % Check for consistency among vector parameter lenghts
    if ~isequal(lenmax,1)   % there exist vector parameters
        
        % Check if vector lengths (if any) agree
        if any(find(vLen(find(vLen~=1))~=lenmax)),
            eStr.emsg  = ['Parameters must be either all scalars, or if more'...
                    ' than one of them is a vector, their vector sizes should agree.'];
            eStr.ecode = 1; varargout{3} = eStr; return;
            
            % If dimensions are to be preserved, check if they agree
        elseif strcmp(Vals{idxOrient},'off') & strcmp(Vals{idxFrameBased},'off')  
            for idx=[find(vLen~=1)]
                if ~isequal(vSize{idx},vSize{dimcomp})
                    eStr.emsg  = ['Dimensions of parameter values in ', block, ' are inconsistent.'];
                    eStr.ecode = 1; varargout{3} = eStr; return;
                end
            end         
        end
    end
    
    feval(mfilename, block, 'UpdateFields');
    [varargout{1:2}, outputSize] = feval(mfilename, block, 'UpdateWs', Args);
    cbFrameBased(block);
    cbOrient(block);
    feval(mfilename, block, 'UpdateBlocks', outputSize);
    
    varargout{3}=eStr;
end;

if(strcmp(action,'cbFrameBased'))
    cbFrameBased(block);
end

if(strcmp(action,'cbOrient'))
    cbOrient(block);
end

%----------------------------------------------------------------------
%	Block specific update functions
%----------------------------------------------------------------------
%*********************************************************************
% Function:			UpDateBlocks
% Description:		Set the simulink blocks as required
% Inputs:			current block
% Return Values:	none
%********************************************************************
if(strcmp(action,'UpdateBlocks'))
    
    % Sample-based case
    if(strcmp(Vals{idxFrameBased},'off'))
        set_param([block, '/Frame Status Conversion'],'outframe','Sample-based');   
        set_param([block, '/Buffer'],'N','1');   % Do not buffer up
        set_param([block, '/Buffer'],'ic','0');
        
        % Interpret as 1-D; OR scalar output
        if(strcmp(Vals{idxOrient},'on')) | ~any(vLen-1)
            % Interpret as 1-D; OR scalar output
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
        set_param([block, '/Buffer'],'N','sampPerFrame');   % Buffer up
        set_param([block, '/Reshape'],'OutputDimensionality','Customize');
        
        set_param([block, '/Reshape'],'OutputDimensions',...
            ['[sampPerFrame, ',num2str(output_size), ']']);
        
        if str2num(Vals{idxSampPerFrame}) > 1
            set_param([block, '/Buffer'],'ic','buffic');
        else
            set_param([block, '/Buffer'],'ic','0'); 
        end
        
    end;
    
end;
 
%*********************************************************************
% Function:			UpdateWs
% Description:		Set the simulink blocks as required
% Inputs:			current block
% Return Values:	values to be set in the workspace
%********************************************************************
if (strcmp(action,'UpdateWs'))
    if (strcmp(Vals{idxSpecMethod}, 'Quadrature components'))
        varargout(1:2) = {Mask_iMean, Mask_qMean};
    else
        if (length(Mask_K) == length(Mask_s))
            varargout{1} = sqrt(2*Mask_K(:)) .* Mask_s(:);
        else
            varargout{1} = 0;
        end
        varargout{2} = 0;
    end;
    varargout{3} = lenmax;   % size of desired output
end;

%*********************************************************************
% Function:			UpdateFields
% Description:		Update the dialog fields.
%						Indicate that block updates are not required
% Inputs:			current block
% Return Values:	none
%********************************************************************
if (strcmp(action,'UpdateFields'))
    feval(mfilename,block,'SpecMethod',1);
end;

%*********************************************************************
% Function:			UpdateIc
% Description:		Set up the initial conditions for buffer
% Inputs:			current block
% Return Values:	output initial conditions (buffic)
%********************************************************************
if (strcmp(action,'UpdateIc'))

    % Check for samples per frame parameter
    if (~isscalar(maskSampPerFrame) | ~isinteger(maskSampPerFrame) | ...
            maskSampPerFrame < 1 )
        error('The samples per frame parameter must be an integer scalar greater than 0.');         
    end    

    sampnum = maskSampPerFrame;
    seed = maskSeed;
    s = Mask_s;
    
    if (strcmp(Vals{idxSpecMethod},'Quadrature components'))
        m1 = Mask_iMean;
        m2 = Mask_qMean;
    else
        K = Mask_K;
        if (length(K) == length(s))
            if isequal(size(K), size(s))
                m1 = sqrt(2*K) .* s;
            else % rowize them
                m1 = sqrt(2*K(:)') .* s(:)';
            end
        else
            m1 = 0;
        end
        m2 = zeros(1,lenmax);
    end;

    varargout{1} = abs( complex( wgn( sampnum, lenmax, 1, 1, seed(1) ) ...
        .*( ones(sampnum,1)*sqrt(s(:).') ) + ones(sampnum, 1)*(m1(:).') ,...
        wgn( sampnum, lenmax, 1, 1, seed(1)+max(seed) ) ...
        .*( ones(sampnum,1)*sqrt(s(:).') ) + ones(sampnum, 1)*(m2(:).') ) );
    
end;

%----------------------------------------------------------------------
%	Dynamic dialog specific field functions
%----------------------------------------------------------------------
%*********************************************************************
% Function Name:    'SpecMethod'
% Description:      Deal with the different specification methods
% Inputs:           current block
%                   Update mode: Args = 0, block update required
%                                Args = 1, no block update required
% Return Values:    none
%********************************************************************
if(strcmp(action,'SpecMethod'))
    
    if(strcmp(Vals{idxSpecMethod},'Quadrature components'))
        if(strcmp(Vis{idxK},'on'))
            Vis{idxK} = 'off';
            En{idxK}  = 'off';
            
            Vis{idxIMean} = 'on';
            Vis{idxQMean} = 'on';
            En{idxIMean}  = 'on';
            En{idxQMean}  = 'on';
            
            set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
        end;
    elseif(strcmp(Vis{idxK},'off'))
        Vis{idxK} = 'on';
        En{idxK}  = 'on';
        
        Vis{idxIMean} = 'off';
        Vis{idxQMean} = 'off';
        En{idxIMean}  = 'off';
        En{idxQMean}  = 'off';
        
        set_param(block,'MaskVisibilities',Vis,'MaskEnables',En);
    end
    
end;

%----------------------------------------------------------------------
%	Setup/Utility functions
%----------------------------------------------------------------------
%*********************************************************************
% Function Name:	'default'
% Description:		Set the block defaults (development use only)
% Inputs:			current block
% Return Values:	none
%********************************************************************
if(strcmp(action,'default'))

	Cb{idxSpecMethod}   = 'commblkriciansrc2(gcb,''SpecMethod'');';
	Cb{idxIMean}        = '';
	Cb{idxQMean}        = '';
	Cb{idxK}            = '';
	Cb{idxS}            = '';
	Cb{idxSeed}         = '';
	Cb{idxTs}           = '';
	Cb{idxFrameBased}   = 'commblkriciansrc2(gcb,''cbFrameBased'');';
	Cb{idxSampPerFrame} = '';
	Cb{idxOrient}       = 'commblkriciansrc2(gcb,''cbOrient'');';

	En{idxSpecMethod}   = 'on';
	En{idxIMean}        = 'off';
	En{idxQMean}        = 'off';
	En{idxK}            = 'on';
	En{idxS}            = 'on';
	En{idxSeed}         = 'on';
	En{idxTs}           = 'on';
    En{idxFrameBased}   = 'on';
    En{idxSampPerFrame} = 'off';
    En{idxOrient}       = 'on';
    
    Vis{idxSpecMethod}  = 'on';
    Vis{idxIMean}       = 'off';
    Vis{idxQMean}       = 'off';
    Vis{idxK}           = 'on';
    Vis{idxS}           = 'on';
    Vis{idxSeed}        = 'on';
    Vis{idxTs}          = 'on';
    Vis{idxFrameBased}  = 'on';
    Vis{idxSampPerFrame}= 'on';
    Vis{idxOrient}      = 'on';
    
    % --- Set Callbacks, enable status and visibilities
    set_param(block, 'MaskCallbacks', Cb, 'MaskEnables', En, ...
        'MaskVisibilities', Vis);
    
	% --- Set the start up values.
	Vals{idxSpecMethod}   = 'K-factor';
	Vals{idxIMean}        = 'sqrt(2)';
	Vals{idxQmean}        = 'sqrt(2)';
	Vals{idxK}            = '2';
	Vals{idxS}            = '1';
	Vals{idxSeed}         = '59';
    Vals{idxFrameBased}   = 'off';
    Vals{idxSampPerFrame} = '1';
	Vals{idxOrient}       = 'off';
	Vals{idxTs}           = '1';

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

	% --- Set the Mask Modifiable flag as required
	set_param(block,'MaskSelfModifiable','off');

end;

%----------------------------------------------------------------------
%	Callback functions
%----------------------------------------------------------------------
%*********************************************************************
% Function Name:	'cbFrameBased'
%  - Callback function for 'frameBased' parameter
%********************************************************************
function cbFrameBased(block)

Vals  = get_param(block, 'maskvalues');
En    = get_param(block, 'maskenables');
oldEnSamp   = En{9};
oldEnOrient = En{10};

if(strcmp(Vals{8},'off'))
    En{9}  = 'off';
    En{10}  = 'on';
else % 'Frame-based'
    En{9}  = 'on';
    En{10}  = 'off';
end;

if strcmp(oldEnSamp, En{9}) == 0 | strcmp(oldEnOrient, En{10}) == 0
    set_param(block,'MaskEnables',En);
end

%*********************************************************************
% Function Name:	'cbOrient'
%  - Callback function for 'orient' parameter
%********************************************************************
function cbOrient(block)

Vals  = get_param(block, 'maskvalues');
En    = get_param(block, 'maskenables');
oldEnFrame = En{8};

if(strcmp(Vals{10},'on'))  % Interpret as 1-D
    En{8}  = 'off';
else
    En{8}  = 'on';
end;

if strcmp(oldEnFrame, En{8}) == 0
    set_param(block,'MaskEnables',En);
end

% [EOF]
