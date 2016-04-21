function varargout = commblkwcgen(block, action)
%COMMBLKWCGEN Mask dialog function for Walsh Code Generator block.
%
%   Usage:
%    [wCode, sampPerFrame, eStr] = commblkwcgen(gcb,'init')         
%           - callback for initialization 
%    commblkwcgen(gcb,'cbFrameBased') - callback for frame based outputs

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/18 23:08:01 $

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
% Return Values:    wCode, sampPerFrame, eStr
%*********************************************************************
    % Initial value
    wCode = [1];

    sampPerFrame = cbFrameBased(block);

    % Return values in case of early exit
    varargout = {wCode, sampPerFrame, eStr};
    outLen = length(varargout);
    
    % Check the code length parameter - scalar, integer, power of 2
    if ( ~isscalar(maskLength) | ~isinteger(log2(maskLength)) )
        eStr.emsg = 'The code length parameter must be a scalar integer power of 2.'; 
        eStr.ecode = 1;  varargout{outLen} = eStr; return;
    end
    
    % Check the code index parameter - scalar, positive integer, <= maskLength-1
    % The code index specifies the number of zero crossings in the code for the
    % walsh codes.
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
    nBits = log2(maskLength);
    % Get the corresponding H code index from the Walsh code index 
    bits = de2bi(maskIndex, nBits, 'left-msb');
    for j = 1:size(bits, 1)
        idxBits(j, nBits) = bits(j, 1); 
        for i = 2:nBits
            idxBits(j, nBits-i+1) = xor(bits(j, i-1), bits(j, i));
        end
    end
    hIndx = bi2de(idxBits, 'left-msb');
    wCode = H(hIndx+1,:);    

    % Set outputs with validated parameters            
    varargout = {wCode, sampPerFrame, eStr};

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
