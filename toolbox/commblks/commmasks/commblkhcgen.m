function varargout = commblkhcgen(block, action)
%COMMBLKHCGEN Mask dialog function for Hadamard Code Generator block.
%
%   Usage:
%    [hCode, sampPerFrame, eStr] = commblkhcgen(gcb,'init')
%             - callback for initialization 
%    commblkhcgen(gcb,'cbFrameBased') - callback for frame based outputs

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/18 23:07:59 $

% Exit code and error message definitions
eStr.ecode = 0;
eStr.emsg  = '';

% Set Field index numbers and mask variable data
setallfieldvalues(block);

switch(action)
case {'init'}
%*********************************************************************
% Function:         initialize
% Description:      Set the dialogs based on the parameter values.
% Inputs:           current block
% Return Values:    hCode, sampPerFrame, eStr
%*********************************************************************
    % Initial value
    hCode = [1];

    sampPerFrame = cbFrameBased(block);

    % Return values in case of early exit
    varargout = {hCode, sampPerFrame, eStr};
    outLen = length(varargout);
        
    % Check the code length parameter - scalar, integer, power of 2
    if ( ~isscalar(maskLength) | ~isinteger(log2(maskLength)) )
        eStr.emsg = 'The code length parameter must be a scalar integer power of 2.'; 
        eStr.ecode = 1;  varargout{outLen} = eStr; return;
    end
    
    % Check the code index parameter - scalar, positive integer, < maskLength
    if ( ~isscalar(maskIndex) | ~isinteger(maskIndex) | maskIndex < 0 | ...
        maskIndex >= maskLength )
        eStr.emsg = ['The code index parameter must be a nonnegative scalar '...
            'integer less than the code length parameter.']; 
        eStr.ecode = 1;  varargout{outLen} = eStr; return;
    end
    
    % Check the sample time parameter - scalar real > 0 
    if ( ~isscalar(maskTs) | ~isreal(maskTs) | maskTs <= 0 ) ...
        eStr.emsg  = 'The sample time parameter must be a real scalar greater than 0.';
        eStr.ecode = 1; varargout{outLen} = eStr; return;
    end

    % Check the samples per frame parameter - scalar integer > 0 
    if ( ~isscalar(sampPerFrame) | ~isinteger(sampPerFrame) | ...
         sampPerFrame <= 0 ) ...
         eStr.emsg  = 'The samples per frame parameter must be a scalar integer greater than 0.';
         eStr.ecode = 1; varargout{outLen} = eStr; return;
    end

    % Create the Hadamard code matrix from which to index off a row
    H = hadamard(maskLength);
    hCode = H(maskIndex+1,:);    

    % Set outputs with validated parameters            
    varargout = {hCode, sampPerFrame, eStr};

case {'cbFrameBased'}
    sampPerFrame = cbFrameBased(block);

end

%----------------------------------------------------------------------
%               Dynamic-dialog specific field functions
%----------------------------------------------------------------------
%----------------------------------------------------------------------
% Function Name:    'cbFrameBased'
%       Callback function for 'frameBased' checkbox parameter
%----------------------------------------------------------------------
function sampPerFrame = cbFrameBased(block)

setallfieldvalues(block);

Vals  = get_param(block, 'maskvalues');
En    = get_param(block, 'maskenables');
oldEnSampPerFrames   = En{idxSampPerFrame};

if(strcmp(Vals{idxFrameBased},'off')) % Sample-based
    En{idxSampPerFrame}  = 'off';
    sampPerFrame = 1;
    set_param([block '/Frame Status Conversion'], 'outframe', 'Sample-based');
    set_param([block '/Reshape'], 'OutputDimensionality', '1-D array');
else % Frame-based
    En{idxSampPerFrame}  = 'on';
    sampPerFrame = maskSampPerFrame;
    set_param([block '/Frame Status Conversion'],'outframe','Frame-based');
    set_param([block '/Reshape'], 'OutputDimensionality', 'Column vector');
end

if ( ~strcmp(oldEnSampPerFrames, En{idxSampPerFrame}) ) 
    set_param(block,'MaskEnables',En);
end

% [EOF]
