function varargout = commblkksgen(block, action)
%COMMBLKKSGEN Mask dialog function for Kasami Sequence Generator block.
%
%   Usage:
%    [maskgenPoly, maskCodeIdx, maskShift, rstPortLbl,...
%         eStr] = commblkksgen(gcb,'init')
%             - callback for initialization 
%    commblkksgen(gcb,'cbFrameBased') - callback for frame based outputs

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:02:55 $

% Exit code and error message definitions
eStr.ecode = 0;
eStr.emsg  = '';

Vals  = get_param(block, 'maskvalues');

% Set Field index numbers and mask variable data
setallfieldvalues(block);

switch(action)
case {'init'}
%*********************************************************************
% Function:         initialize
% Description:      Set the dialogs based on the parameter values.
% Inputs:           current block
% Return Values:    maskgenPoly, maskCodeIdx, maskShift, rstPortLbl, eStr.
%*********************************************************************
    cbFrameBased(block);

    % Label for reset port (alongwith location in normalized units)
    rstPortLbl.str = ''; rstPortLbl.x = 0.0; rstPortLbl.y = 0.0;
    if strcmp(Vals{idxReset}, 'on')
        rstPortLbl.str = 'Rst';

        switch lower(get_param(block, 'orientation'))
            case 'right'
                rstPortLbl.x = 0.03;
                rstPortLbl.y = 0.5;
            case 'left'
                rstPortLbl.x = 0.82;
                rstPortLbl.y = 0.5;
            case 'up'
                rstPortLbl.x = 0.5;
                rstPortLbl.y = 0.05;
            case 'down'
                rstPortLbl.x = 0.5;
                rstPortLbl.y = 0.93;
            otherwise
                eStr.emsg = 'Unspecified orientation.';
                eStr.ecode = 1;
        end
    end

    % Set up outputs in case of early return due to an error
    varargout = {maskGenPoly, maskCodeIdx, maskShift, rstPortLbl, eStr};
    outLen = length(varargout);

    % Check the generator polynomial parameters
    [maskGenPoly, eStr] = checkgenpoly(maskGenPoly, eStr);
    if (eStr.ecode == 1),  varargout{outLen} = eStr; return; end;
             
    deg = length(maskGenPoly) - 1; % degree of polynomial

    if mod(deg, 2)
        eStr.emsg  = 'The generator polynomial parameter must be of even degree.';
        eStr.ecode = 1; varargout{outLen} = eStr; return;
    end

    % Check the initial state parameters
    eStr = checkinistate(maskIniState, deg, eStr);    
    if (eStr.ecode == 1),  varargout{outLen} = eStr; return; end;
    
    % Check for last value to be non-zero - else decimated sequence is all-zero
    if (~maskIniState(end))
        eStr.emsg  = 'The initial states parameter must have its last value to be nonzero.';
        eStr.ecode = 1; varargout{outLen} = eStr; return;
    end

    % Check the sequence index parameter
    [maskCodeIdx, eStr] = checkcodindex(maskCodeIdx, deg, eStr);
    if (eStr.ecode == 1),  varargout{outLen} = eStr; return; end;
    
    % Check the shift (offset) parameter - scalar integer 
    if ( ~isscalar(maskShift) | ~isnumeric(maskShift) | ~isreal(maskShift) | ...
         ~isinteger(maskShift) )
        eStr.emsg  = 'The shift parameter must be an integer scalar.';
        eStr.ecode = 1; varargout{outLen} = eStr; return;
    end

    % Revise the shift modulo the period of the sequence
    maskShift = rem(maskShift, 2^deg - 1);
    if maskShift < 0
        maskShift = maskShift + 2^deg - 1;
    end
    
    % Reset outputs with validated parameters            
    varargout = {maskGenPoly, maskCodeIdx, maskShift, rstPortLbl, eStr};

case {'cbFrameBased'}
    cbFrameBased(block);

end

%----------------------------------------------------------------------
%               Dynamic-dialog specific field functions
%----------------------------------------------------------------------
%----------------------------------------------------------------------
% Function Name:    'cbFrameBased'
%       Callback function for 'frameBased' checkbox parameter
%----------------------------------------------------------------------
function cbFrameBased(block)

setfieldindexnumbers(block);

Vals  = get_param(block, 'maskvalues');
En    = get_param(block, 'maskenables');
oldEnSampPerFrames   = En{idxSampPerFrame};

if (strcmp(Vals{idxFrameBased}, 'off')) % Sample-based
    En{idxSampPerFrame}  = 'off';
else % Frame-based
    En{idxSampPerFrame}  = 'on';
end

if ( ~strcmp(oldEnSampPerFrames, En{idxSampPerFrame}) ) 
    set_param(block,'MaskEnables',En);
end

%----------------------------------------------------------------------
%          User-specified Parameter Validation functions
%----------------------------------------------------------------------
%----------------------------------------------------------------------
function [index, eStr] = checkcodindex(index, deg, eStr)
% Checks for valid index parameter and returns the validated one which
% is passed onto the s-function for processing.
%
% Requirements:
%-----------------------------------------------------------------------------
%   Degree        Allowed User input           Sfunction Input   Comments
%-----------------------------------------------------------------------------
%  n mod4==2      [k m], k = [-2:1:2^n-2]        [k m]           Large Set
%                        m = [-1:1:2^(n/2)-2] 
%                 [m],   m = [-1:1:2^(n/2)-2]    [-2 m]          Small set
%
%  n mod4==0      [m],   m = [-1:1:2^(n/2)-2]    [-2 m]          Small set
%-----------------------------------------------------------------------------

emsg  = ['The sequence indexes parameter must be an integer between',...
         ' -1 and 2^(degree/2)-2.'];
         
% Checks for the code index parameter
if ( ~isnumeric(index) | any(floor(index) ~= index) )
    eStr.emsg  = 'The sequence indexes parameter must be integer valued.';
    eStr.ecode = 1; return;
end

if isscalar(index) % allowed for Small sets only 
    % Range checking
    if ( index < -1 | index > (2^(deg/2)-2) )
        eStr.emsg  = emsg; eStr.ecode = 1; return;
    end

    % Output value 
    index = [-2 index];
 
elseif ( isvector(index) & length(index) == 2 ) % allow 2-element vector

    % Only Small set is defined for nmod4 = 0.
    if mod(deg, 4) == 0
        eStr.emsg  = emsg; eStr.ecode = 1; return;
    end
    
    % Range checking
    if ( index(1) < -2 | index(1) > (2^(deg)-2) )
        eStr.emsg  = ['The first element of the sequence indexes parameter',...
                      ' must be an integer between -2 and 2^(degree)-2.'];
        eStr.ecode = 1; return;
    end
    if ( index(2) < -1 | index(2) > (2^(deg/2)-2) )
        eStr.emsg  = ['The second element of the sequence indexes parameter',...
                      ' must be an integer between -1 and 2^(degree/2)-2.'];
        eStr.ecode = 1; return;
    end

else     
    eStr.emsg  = ['The sequence indexes parameter must be a 2-element',...
                  ' vector or a scalar of integer values.'];
    eStr.ecode = 1; return;

end

% [EOF]
