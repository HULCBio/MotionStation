function varargout = commblkbernoullisrc2(block, action)
%COMMBLKBERNOULLISRC2 Mask dynamic dialog function for Bernoulli source block.
%
%   Syntax:
%     [maskP, maskSeed, eStr] = commblkbernoullisrc2(gcb, 'init')
%              - initialization callback.
%     commblkbernoullisrc2(gcb, 'default') - default settings
%     commblkbernoullisrc2(gcb, 'cbFrameBased') - frame-based output callback
%     commblkbernoullisrc2(gcb, 'cbOrient') - 1D vector callback
  
%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 16:28:07 $

% --- Field data
Vals  = get_param(block, 'maskvalues');
Vis   = get_param(block, 'maskvisibilities');
En    = get_param(block, 'maskenables');

% --- Set Field index numbers and mask variable data
setallfieldvalues(block);

vLen = [length(maskP) length(maskSeed)];
vSize = {size(maskP) size(maskSeed)};

lenmax = max(vLen);            % Largest of all the parameter lengths
dimcomp = min(find(vLen~=1));  % Index of the first vector parameter
                               % used for comparison with other parameters
if ((vLen(1) == 1) & (lenmax > 1))
    maskP = maskP(ones(vSize{2})); % expansion
end

switch action
case {'init'}
%*********************************************************************
% Function:			initialize
% Description:		Set the dialogs up based on the parameter values.
%                   MaskEnables/MaskVisibles are not save in reference 
%                   blocks.
% Inputs:			current block
% Return Values:	maskP, maskSeed, eStr
%********************************************************************
    % --- Exit code and error message definitions
    eStr.ecode = 0;
    eStr.emsg  = '';

    % --- Return in case of early exit
    varargout = {maskP, maskSeed, eStr};

    % --- If the simulation status is 'stopped', then the function is being called
    %     because of an OK or apply and so the parameters do not need to be valid
    %     and hence, need not be evaluated
    simStatus = lower(get_param(bdroot(gcb),'SimulationStatus'));
    if(strcmp(simStatus,'stopped')) % Quiet exit
        eStr.ecode = 3; varargout{3} = eStr; return;
    end;
    
    % Check for sample time parameter
    if ~isscalar(maskTs) | maskTs <=0
            eStr.emsg  = 'The sample time parameter must be a real scalar greater than 0.';
            eStr.ecode = 1; varargout{3} = eStr; return;
    end    

    % Check for samples per frame parameter
    if (~isscalar(maskSampPerFrame) | ~isinteger(maskSampPerFrame) | ...
        maskSampPerFrame < 1 )
            eStr.emsg  = ['The samples per frame parameter must be an integer ',...
                'scalar greater than 0.'];
            eStr.ecode = 1; varargout{3} = eStr; return;
    end    
    
    % Check for consistency among vector parameter lenghts
    if ~isequal(lenmax,1)   % if there exist vector parameters
        
        vSizeZeroProb = vSize{idxP};
        vSizeSeed     = vSize{idxSeed};
        
        % Check if vector lengths (if any) agree
        if any(find(vLen(find(vLen~=1))~=lenmax)),
            eStr.emsg = ['The Probability of a zero and the Initial seed ',...
                         'parameters must be either all scalars, or if more than ',...
                         'one of them is a vector, their vector sizes should agree.'];
            eStr.ecode = 1; varargout{3} = eStr; return;
            
            % If dimensions are to be preserved, check if they agree
        elseif strcmp(Vals{idxOrient},'off') & strcmp(Vals{idxFrameBased},'off') ...
                & ~isequal(vSizeZeroProb(1),vSizeSeed(1)) ...
                & ~isequal(vSizeZeroProb(2),vSizeSeed(2)) ...
                & ~isequal(vSize{idxP},vSize{idxSeed})
            eStr.emsg  = ['Dimensions of parameter values in ', block,...
                          ' are inconsistent.'];
            eStr.ecode = 1; varargout{3} = eStr; return;
        end
    end     
    
    if any(maskP>1 | maskP<0)
        eStr.emsg  = ['Probabilities of zeroes in ', block,...
                      ' must be between 0 and 1.'];
        eStr.ecode = 1; varargout{3} = eStr; return;
    end   
    
    feval(mfilename,block,'UpdateBlocks');
    cbFrameBased(block);
    cbOrient(block);
    
    % Return validated parameters 
    varargout = {maskP, maskSeed, eStr};
    
case {'cbFrameBased'}
    cbFrameBased(block);
    
case {'cbOrient'}
    cbOrient(block);
    
case {'UpdateBlocks'}
%*********************************************************************
% Function:			UpDateBlocks
% Description:		Set the simulink blocks as required
% Inputs:			current block
% Return Values:	none
%********************************************************************
    % Sample-based case
    if (strcmp(Vals{idxFrameBased},'off'))
        
        set_param([block, '/Frame Status Conversion'],'outframe','Sample-based');   
        set_param([block, '/DSP Constant'],'FrameBasedOutput','off');
        set_param([block, '/DSP Constant'],'Ts','Ts');
        set_param([block, '/DSP Constant'],'Value','P');
        
        % Interpret as 1-D; OR scalar output
        if(strcmp(Vals{idxOrient}, 'on')) | ~any(vLen-1)
            set_param([block, '/Reshape'],'OutputDimensionality','1-D array');
            set_param([block, '/DSP Constant'],'InterpretAs1D','on');
            
        else % 2-D vector output    
            set_param([block, '/DSP Constant'],'InterpretAs1D','off');
            
            vec = vSize{dimcomp};
            % Column vector
            if vec(1) > vec(2)
                set_param([block, '/Reshape'],'OutputDimensionality','Column vector');
            else  % Row vector   
                set_param([block, '/Reshape'],'OutputDimensionality','Row vector');
            end            
        end
        
    else % Frame-based case
        set_param([block, '/DSP Constant'],'InterpretAs1D','off');
        set_param([block, '/DSP Constant'],'Ts','Ts*sampPerFrame');
        
        if maskSampPerFrame >1 % Need to expand P
            if size(maskP,2) > 1 % P is a row vector 
                set_param([block, '/DSP Constant'],'Value','P(ones(sampPerFrame, 1),:)');
            else % P is a column vector
                set_param([block, '/DSP Constant'],'Value','[P(:,ones(1,sampPerFrame))'']');
            end
        else % P is a scalar
            set_param([block, '/DSP Constant'],'Value','P');
        end
        
        set_param([block, '/DSP Constant'],'FrameBasedOutput','on');
        
        set_param([block, '/Random Source'],'Min','zeros(size(P))');
        set_param([block, '/Random Source'],'Max','ones(size(P))');
        
        set_param([block, '/Frame Status Conversion'],'outframe','Frame-based');  
        set_param([block, '/Reshape'],'OutputDimensionality','Customize');
    end;

case {'default'}    
%*********************************************************************
% Function Name:	'default'
% Description:		Set the block defaults (development use only)
% Inputs:			current block
% Return Values:	none
%********************************************************************
 	Cb{idxP}             = '';
	Cb{idxSeed}          = '';
	Cb{idxTs}            = '';
	Cb{idxFrameBased}    = 'commblkbernoullisrc2(gcb,''cbFrameBased'');';
	Cb{idxSampPerFrame}  = '';
	Cb{idxOrient}        = 'commblkbernoullisrc2(gcb,''cbOrient'');';

	En{idxP}             = 'on';
	En{idxSeed}          = 'on';
	En{idxTs}            = 'on';
    En{idxFrameBased}    = 'on';
    En{idxSampPerFrame}  = 'off';
    En{idxOrient}        = 'on';
    
    Vis{idxP}            = 'on';
    Vis{idxSeed}         = 'on';
    Vis{idxTs}           = 'on';
    Vis{idxFrameBased}   = 'on';
    Vis{idxSampPerFrame} = 'on';
    Vis{idxOrient}       = 'on';
    
    % --- Set Callbacks, enable status and visibilities
    set_param(block,'MaskCallbacks', Cb, 'MaskEnables', En,...
        'MaskVisibilities', Vis);
    
    % --- Set the startup values.  '' Indicates that the default saved will be used    
    Vals{idxP}            = '0.5';
    Vals{idxSeed}         = '61';
    Vals{idxTs}           = '1';
    Vals{idxFrameBased}   = 'off';
    Vals{idxSampPerFrame} = '1';
    Vals{idxOrient}       = 'off';
    
    MN = get_param(gcb,'MaskNames');
    for n=1:length(Vals)
       if(~isempty(Vals{n}))
          set_param(block,MN{n},Vals{n});
       end;
    end;

	% --- Update the Vals field with the actual values
	Vals	= get_param(block, 'maskvalues');

    % --- Set the copy function to force all lower block to execute their copy functions
	set_param(block,'CopyFcn','');

	% --- Ensure that the block operates correctly from a library
	set_param(block,'MaskSelfModifiable','on');

end;

%----------------------------------------------------------------------
%	Dynamic dialog specific field functions
%----------------------------------------------------------------------
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
