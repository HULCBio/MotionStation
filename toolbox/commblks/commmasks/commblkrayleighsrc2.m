function varargout = commblkrayleighsrc2(block, varargin)
%COMMBLKRAYLEIGHSRC2 Mask dynamic dialog function for Rayleigh source block.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 16:28:09 $

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
    Args = {};
otherwise
    action = varargin{1};
    Args = varargin{2:end};
    
    if(~strcmp(lower(action),'backprop'))
        % --- Breakout the arguments if required
        if((nvarargin > 1) & (isa(Args,'cell')))
            Mask_alpha = Args{1};
            Mask_seed  = Args{2};
        end;
    end;
end;

% --- Field data
Vals  = get_param(block, 'maskvalues');

% --- Set Field index numbers and mask variable data
setallfieldvalues(block);

vLen = [length(maskAlpha) length(maskSeed)];
vSize = {size(maskAlpha) size(maskSeed)};

lenmax = max(vLen);            % Largest of all the parameter lengths
dimcomp = min(find(vLen~=1));  % Index of the first vector parameter
                               % used for comparison with other parameters

%*********************************************************************
% Function:			initialize
% Description:		Set the dialogs up based on the parameter values.
%                   MaskEnables/MaskVisibles are not save in reference 
%                   blocks.
% Inputs:			current block
% Return Values:	none
%********************************************************************
if(strcmp(action,'init'))
    
    % --- Return in case of early exit
    varargout = {maskAlpha, maskSeed, eStr};
    
    % Check for sample time parameter
    if (~isscalar(maskTs) | maskTs <= 0)
        eStr.emsg = 'The sample time parameter must be a real scalar greater than 0.';
        eStr.ecode = 1; varargout{3} = eStr; return;
    end    
    
    % Check for consistency among vector parameter lenghts
    if ~isequal(lenmax,1)   % there exist vector parameters
        
        vSizeAlpha = vSize{1};
        vSizeSeed  = vSize{2};
        
        % Check if vector lengths (if any) agree
        if any(find(vLen(find(vLen~=1))~=lenmax)),
            eStr.emsg = ['Sigma and Initial seed must be either all scalars,',...
                    ' or if more than one of them is a vector, their',...
                    ' vector sizes should agree.'];
            eStr.ecode = 1; varargout{3} = eStr; return;
            
            % If dimensions are to be preserved, check if they agree
        elseif strcmp(Vals{idxOrient},'off') & strcmp(Vals{idxFrameBased},'off') ...
                & ~isequal(vSizeAlpha(1),vSizeSeed(1)) & ~isequal(vSizeAlpha(2),vSizeSeed(2)) ...
                & ~isequal(vSize{1},vSize{2})
            eStr.emsg = ['Dimensions of parameter values in ', block, ' are inconsistent.'];
            eStr.ecode = 1; varargout{3} = eStr; return;
        end
        
    end     
    
    [varargout{1:2}] = feval(mfilename, block, 'UpdateWs', Args);
    
    cbFrameBased(block);
    cbOrient(block);
    feval(mfilename, block, 'UpdateBlocks', lenmax);    % pass in length of output
    
    varargout{3} = eStr;
    
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
    
    % Length of seed computed by UpdateWs (length is doubled)
    len = varargin{2};
    
    % Sample-based case
    if(strcmp(Vals{idxFrameBased},'off'))  % Sample-based
        set_param([block, '/Frame Status Conversion'],'outframe','Sample-based');   
        set_param([block, '/Buffer'],'N','1');   % Do not buffer up
        set_param([block, '/Buffer'],'ic','0');
        
        % Interpret as 1-D; OR scalar output
        if(strcmp(Vals{idxOrient},'on')) | ~any(vLen-1)
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
        
        % Only need half the size of the seed, because size of seed has been doubled at this point
        set_param([block, '/Reshape'],'OutputDimensions',['[sampPerFrame, ',num2str(len), ']']);
        
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
if(strcmp(action,'UpdateWs'))
    
    alpha = Mask_alpha;
    seed  = Mask_seed;
    
    alpha=alpha.^2;
    seed=[seed(:);seed(:)+max(seed)];
    if length(alpha)>1
        alpha=[alpha(:);alpha(:)];
    end;
    
    varargout(1:2) = {alpha,seed};
end;

%*********************************************************************
% Function:			UpdateIc
% Description:		Set the initial frame for buffer
% Inputs:			current block
% Return Values:	values set in the workspace (buffic)
%********************************************************************
if(strcmp(action,'UpdateIc'))
    
    % Check for samples per frame parameter
    if (~isscalar(maskSampPerFrame) | ~isinteger(maskSampPerFrame) | ...
            maskSampPerFrame < 1 )
        error('The samples per frame parameter must be an integer scalar greater than 0.');         
    end    
    
    alpha = Mask_alpha(:)'.*ones(1,lenmax); 
    seed  = Mask_seed;
    sampnum = maskSampPerFrame;
    
    % Calculate initial frame for buffer
    varargout{1} = abs( complex( wgn( sampnum, lenmax, 1, 1, seed(1) ) ...
        .*(ones(sampnum,1)*alpha ), wgn( sampnum, lenmax, 1, 1, seed(1) ...
        + max(seed) ).*(ones(sampnum,1)*alpha) ) );
end;

%*********************************************************************
% Function Name:	'default'
% Description:		Set the block defaults (development use only)
% Inputs:			current block
% Return Values:	none
%********************************************************************
if(strcmp(action,'default'))
    
    Cb{idxAlpha}         = '';
    Cb{idxSeed}          = '';
    Cb{idxTs}            = '';
    Cb{idxFrameBased}    = 'commblkrayleighsrc2(gcb,''cbFrameBased'');';
    Cb{idxSampPerFrame}  = '';
    Cb{idxOrient}        = 'commblkrayleighsrc2(gcb,''cbOrient'');';
    
    En{idxAlpha}         = 'on';
    En{idxSeed}          = 'on';
    En{idxTs}            = 'on';
    En{idxFrameBased}    = 'on';
    En{idxSampPerFrame}  = 'off';
    En{idxOrient}        = 'on';
    
    Vis{idxAlpha}        = 'on';
    Vis{idxSeed}         = 'on';
    Vis{idxTs}           = 'on';
    Vis{idxFrameBased}   = 'on';
    Vis{idxSampPerFrame} = 'on';
    Vis{idxOrient}       = 'on';
    
    % --- Set Callbacks, enable status and visibilities
    set_param(block, 'MaskCallbacks', Cb, 'MaskEnables', En, 'MaskVisibilities', Vis);
    
    % --- Set the startup values.  '' Indicates that the default saved will be used    
    Vals{idxAlpha}        = '1';
    Vals{idxSeed}         = '47';
    Vals{idxTs}           = '1';
    Vals{idxFrameBased}   = 'off';
    Vals{idxSampPerFrame} = '1';
    Vals{idxOrient}       = 'off';
    
    MN = get_param(gcb,'MaskNames');
    for n=1:length(Vals)
        if(~isempty(Vals{n}))
            set_param(block, MN{n}, Vals{n});
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
% Function Name:	'cbFrameBased'
%  - Callback function for 'frameBased' parameter
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
%  - Callback function for 'orient' parameter
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

% [EOF]
