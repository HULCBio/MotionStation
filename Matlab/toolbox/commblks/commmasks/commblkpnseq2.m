function varargout = commblkpnseq2(block, action)
% COMMBLKPNSEQ2 Mask dynamic dialog function for PN Sequence Generator block.
%
%   Usage:
%    [maskPoly, maskShift, rstPortLbl, eStr] = commblkpnseq2(gcb,'init')
%              - callback for initialization 
%    commblkkpnseq2(gcb,'cbFrameBased') - callback for frame based outputs

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.3 $  $Date: 2004/04/12 23:02:58 $

% Exit code and error message definitions
eStr.ecode = 0;
eStr.emsg  = '';

% Field data
Vals  = get_param(block, 'maskvalues');

% Set Field index numbers and mask variable data
setallfieldvalues(block);

switch(action)
case {'init'}
%*********************************************************************
% Function:         initialize
% Description:      Set the dialogs up based on the parameter values.
%                   MaskEnables/MaskVisibles are not save in reference 
%                   blocks.
% Inputs:           current block
% Return Values:    maskPoly, maskShift, rstPortLbl, eStr
%********************************************************************
    cbFrameBased(block);

    % Label for reset port (alongwith location in normalized units)
    rstPortLbl.str = ''; rstPortLbl.x = 0.0; rstPortLbl.y = 0.0;
    if (strcmp(Vals{idxReset},'on'))
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

    % Set up outputs in case of early return/error
    varargout = {maskPoly, maskShift, rstPortLbl, eStr};
    outLen = length(varargout);
                   
    % Check the generator polynomial parameters
    [maskPoly, eStr] = checkgenpoly_pn(maskPoly, eStr);
    if (eStr.ecode == 1),  varargout{outLen} = eStr; return; end;
    
    deg = length(maskPoly)-1; % degree of polynomial
    
    % Check the initial state parameters
    eStr = checkinistate(maskIni_sta, deg, eStr);    
    if (eStr.ecode == 1),  varargout{outLen} = eStr; return; end;
    
    % Check the shift (or mask) parameter - scalar, integer or binary vector
    if ~( ndims(maskShift)==2 & min(size(maskShift))==1 )
        eStr.emsg  = ['The shift (or mask) parameter must be a scalar',...
            ' or a vector of length equal to the degree of the generator ',...
            'polynomial parameter.'];
        eStr.ecode = 1; varargout{outLen} = eStr; return;
    end
    if length(maskShift)>1 % is a vector => mask
        if any(maskShift~=1 & maskShift~=0)
            eStr.emsg  = 'The mask parameter values must be binary.';
            eStr.ecode = 1; varargout{outLen} = eStr; return;
        end
        if (length(maskShift) ~= deg)
            eStr.emsg  = ['The mask parameter must be a vector of ',...
                'length equal to the degree of the generator polynomial ',...
                'parameter.'];
            eStr.ecode = 1; varargout{outLen} = eStr; return;
        end
    else % is a scalar
        if ( ~isnumeric(maskShift) | (floor(maskShift) ~= maskShift) )
            eStr.emsg  = 'The shift parameter must be an integer scalar.';
            eStr.ecode = 1; varargout{outLen} = eStr; return;
        end
        % modulo the period of the sequence
        maskShift = rem(maskShift, 2^deg - 1);
        if maskShift < 0
            maskShift = maskShift + 2^deg - 1;
        end
    end
    
    % Reset outputs with validated parameters            
    varargout = {maskPoly, maskShift, rstPortLbl, eStr};

case{'cbFrameBased'}
   cbFrameBased(block);

end

%----------------------------------------------------------------------
%   Dynamic dialog specific field functions
%----------------------------------------------------------------------
%*********************************************************************
% Function Name:    'cbFrameBased'
%       Callback function for 'frameBased' parameter
%********************************************************************
function cbFrameBased(block)

Vals  = get_param(block, 'maskvalues');
En    = get_param(block, 'maskenables');
oldEnSampPerFrames   = En{6};

if(strcmp(Vals{5},'off'))
    En{6}  = 'off';
else % 'Frame-based'
    En{6}  = 'on';
end;

if ( strcmp(oldEnSampPerFrames, En{6}) == 0 ) 
    set_param(block,'MaskEnables',En);
end

%----------------------------------------------------------------------
%          User-specified Parameter Validation functions
%----------------------------------------------------------------------
%----------------------------------------------------------------------
function [genPoly, eStr] = checkgenpoly_pn(genPoly, eStr)
% Checks for valid generator polynomial input and converts if needed 
% to a binary vector representation.
% Should be a binary vector with leading and trailing ones or a vector
% ending with 0 and indicating positive powers. 
%
% Also can be a vector with leading zero and negative powers (for
% backwards compatibility only).

emsg  = 'Invalid generator polynomial parameter values.';

% Check the polynomial parameter values - numeric vector only
if ~( isvector(genPoly) && ~isempty(genPoly) && ~isscalar(genPoly) )
    eStr.emsg  = emsg; eStr.ecode = 1; return;
end

if genPoly(1) == 0 % Negative powers case (for backwards compatibility only)
    if any(genPoly > 0)
        eStr.emsg  = emsg; eStr.ecode = 1; return;
    end
    % Check for repeated values
    if length(unique(genPoly)) ~= length(genPoly) 
        eStr.emsg  = emsg; eStr.ecode = 1; return;
    end
    % Check for sorted descending order
    if any(fliplr(sort(genPoly))~=genPoly)
        eStr.emsg  = emsg; eStr.ecode = 1; return;
    end
    % Convert to binary vector representation
    tmp = zeros(1, abs(min(genPoly))+1);
    tmp(abs(genPoly)+1) = 1;
    genPoly = tmp;
 
elseif genPoly(end) == 0  % Positive powers case
    % Check for repeated values
    if length(unique(genPoly)) ~= length(genPoly) 
        eStr.emsg  = emsg; eStr.ecode = 1; return;
    end
    % Check for sorted descending order
    if any(fliplr(sort(genPoly))~=genPoly)
        eStr.emsg  = emsg; eStr.ecode = 1; return;
    end
    % Convert to binary vector representation
    len = max(genPoly)+1;
    tmp = zeros(1, len);
    tmp(len-genPoly) = 1;
    genPoly = tmp;
end

% Now genPoly is in the binary vector representation
% Should have leading and trailing ones
if ((genPoly(1) == 0) | (genPoly(end) == 0)),
    eStr.emsg  = emsg; eStr.ecode = 1; return;
end

% Only 1's and 0's allowed
if any(genPoly~=1 & genPoly~=0)
    eStr.emsg  = emsg; eStr.ecode = 1; return;
end

% [EOF]
