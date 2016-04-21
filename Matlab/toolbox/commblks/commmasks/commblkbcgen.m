function varargout = commblkbcgen(block, action)
%COMMBLKBCGEN Mask dialog function for Barker Code Generator block.
%
%   Syntax:
%    [bCode, sampPerFrame, eStr] = commblkbcgen(gcb,'init')
%            - callback for initialization 
%    commblkbcgen(gcb,'cbFrameBased') 
%            - callback for frame based outputs

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/18 23:08:05 $

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
% Return Values:    bCode, sampPerFrame, eStr
%*********************************************************************
    % Initial value 
    bCode = [-1];

    sampPerFrame = cbFrameBased(block);

    % Return values in case of early exit
    varargout = {bCode, sampPerFrame, eStr};
    outLen = length(varargout);
                
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

    % Set up the codes
    switch(str2num(maskLength))
    case 1
        bCode = [-1];
    case 2
        bCode = [-1 1]; % or can be [-1 -1]
    case 3
        bCode = [-1 -1 1];
    case 4
        bCode = [-1 -1 1 -1]; % or can be [-1 -1 -1 1]
    case 5
        bCode = [-1 -1 -1 1 -1];
    case 7
        bCode = [-1 -1 -1 1 1 -1 1];
    case 11
        bCode = [-1 -1 -1 1 1 1 -1 1 1 -1 1];
    case 13
        bCode = [-1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1];
    otherwise
        eStr.emsg  = 'Invalid code length parameter.';
        eStr.ecode = 1; varargout{outLen} = eStr; return;
    end
    
    % Set outputs with validated parameters            
    varargout = {bCode, sampPerFrame, eStr};

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
