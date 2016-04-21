function varargout = commblkpoissrc(block, action)
%COMMBLKPOISSRC Mask dynamic dialog function for Poisson Integer Generator.
%
%   Syntax:
%     [eStr, lenmax, lambda, seed] = commblkpoissrc(gcb, 'init')
%            - initialization callback     
%     commblkpoissrc(gcb, 'cbFrameBased') - callback for frame based outputs
%     commblkpoissrc(gcb, 'cbOrient')     - callback for 1D oriented outputs

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/29 03:15:11 $

% --- Exit code and error message definitions
eStr.ecode = 0;
eStr.emsg  = '';

% --- Field data
Vals  = get_param(block, 'maskvalues');

% --- Set Field index numbers and mask variable data
setallfieldvalues(block);

vLen = [length(maskLambda) length(maskSeed)];
vSize = {size(maskLambda) size(maskSeed)};

lenmax = max(vLen);      % Larger of the two parameter lengths

switch action
case {'init'}
%*********************************************************************
% Function:			initialize
% Description:		Set the dialogs up based on the parameter values.
%					MaskEnables/MaskVisibles are not save in reference 
%					blocks.
% Inputs:			current block
% Return Values:	eStr, lenmax, lambda, seed, orientSBvec
%********************************************************************
        
    cbFrameBased(block);
    cbOrient(block);

    seed = maskSeed;
    lambda = maskLambda;
    orientSBVec = 1; % default, implies output is SB row vector, [1xN]

    % Set up returns in case of early exit
    varargout = {eStr, lenmax, lambda, seed, orientSBVec};

    % --- If the simulation status is 'stopped', then the function is being called
    %     because of an OK or apply and so the parameters do not need to be valid
    %     and hence, need not be evaluated
    simStatus = lower(get_param(bdroot(gcb),'SimulationStatus'));
    if (strcmp(simStatus,'stopped'))
        % Quiet exit
        eStr.ecode = 3;  varargout{1} = eStr; return;
    end;  
        
    % Check for consistency among vector parameter lengths
    if ~isequal(lenmax,1)   % if there exist vector parameters
        
        vSizeLambda = vSize{idxLambda};
        vSizeSeed   = vSize{idxSeed};
        
        % Set up the output row/col dimension for SB vector case
        if (vSizeLambda(1) > 1 | vSizeSeed(1) > 1)
            orientSBVec = 0; % implies output is column vector (Nx1) in SB mode
        end
        
        % Check for same vector lengths 
        if any(find(vLen(find(vLen~=1))~=lenmax)),
            eStr.emsg  = ['Lambda and Initial seed must be either all scalars,',...
                 ' or if more than one of them is a vector, their vector',...
                 ' sizes should agree.'];
            eStr.ecode = 1;  varargout{1} = eStr; return;
            
        % If dimensions are to be preserved, check if they agree
        elseif (strcmp(Vals{idxOrient},'off') & strcmp(Vals{idxFrameBased},'off') & ...
               ~isequal(vSizeLambda(1), vSizeSeed(1)) & ...
               ~isequal(vSizeLambda(2), vSizeSeed(2)) & ...
               ~isequal(vSize{idxLambda}, vSize{idxSeed}) )
            eStr.emsg  = ['Dimensions of parameter values in ', block, ' are inconsistent.'];
            eStr.ecode = 1;  varargout{1} = eStr; return;
        end
        
        % Scalar expand lambda variable only, seed expansion is done in the
        % Sfunction using the DSP createSeed function.
        if (length(maskLambda)==1 & length(maskSeed) >1)
            lambda = maskLambda * ones(1,lenmax);
        end      
    end     

    % Return validated parameters        
    varargout = {eStr, lenmax, lambda, seed, orientSBVec};

case {'cbFrameBased'}
    cbFrameBased(block);

case {'cbOrient'}
    cbOrient(block);

end


%----------------------------------------------------------------------
%	Dynamic dialog specific field functions
%----------------------------------------------------------------------
%----------------------------------------------------------------------
% Function Name:	'cbFrameBased'
%  - Callback function for 'frameBased' parameter
%----------------------------------------------------------------------
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

if ~strcmp(oldEnSamp, En{5}) | ~strcmp(oldEnOrient, En{6})
    set_param(block,'MaskEnables',En);
end

%----------------------------------------------------------------------
% Function Name:	'cbOrient'
%  - Callback function for 'orient' parameter
%----------------------------------------------------------------------
function cbOrient(block)

Vals  = get_param(block, 'maskvalues');
En    = get_param(block, 'maskenables');
oldEnFrame = En{4};

if(strcmp(Vals{6},'on'))  % Interpret as 1-D
    En{4}  = 'off';
else
    En{4}  = 'on';
end;

if ~strcmp(oldEnFrame, En{4})
    set_param(block,'MaskEnables',En);
end

% [EOF]
