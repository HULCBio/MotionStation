function varargout = commblkgcgen(block, action)
%COMMBLKGCGEN Mask dialog function for Gold Code Sequence Generator block.
%
%   Usage:
%    [genPoly1, iniState1, genPoly2, iniState2, index, shift,...
%         rstPortLbl, eStr] = commblkgcgen(gcb,'init')         
%            - callback for initialization 
%    commblkgcgen(gcb,'cbFrameBased') - callback for frame based outputs
%    commblkgcgen(gcb,'cbReset')      - callback for reset port

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/12 23:02:54 $

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
% Return Values:    genPoly1, iniState1, genPoly2, iniState2, index,...
%                   shift, rstPortLbl, eStr.
%*********************************************************************
    cbFrameBased(block);
    cbReset(block);

    % Label for reset port (alongwith location in normalized units)
    rstPortLbl.str = ''; rstPortLbl.x = 0.0; rstPortLbl.y = 0.0;

    resetVal  = get_param(block, 'reset');
    if strcmp(resetVal, 'on')
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
    varargout = {maskGenPoly1, maskIniState1, maskGenPoly2, maskIniState2,...
                 maskIndex, maskShift, rstPortLbl, eStr};
    outLen = length(varargout);

    % Check the generator polynomial parameters
    [maskGenPoly1, eStr] = checkgenpoly(maskGenPoly1, eStr);
    if (eStr.ecode == 1),  varargout{outLen} = eStr; return; end;

    [maskGenPoly2, eStr] = checkgenpoly(maskGenPoly2, eStr);
    if (eStr.ecode == 1),  varargout{outLen} = eStr; return; end;
             
    deg1 = length(maskGenPoly1)-1; % degree of polynomial1
    deg2 = length(maskGenPoly2)-1; % degree of polynomial2

    if (deg1 ~= deg2)
        eStr.emsg  = 'The two preferred pair polynomials must have the same degree.';
        eStr.ecode = 1; varargout{outLen} = eStr; return;
    end
    % Check for preferred pair properties
    if (mod(deg1,4)==0)
        eStr.emsg  = 'The degree of the polynomials must not be divisible by 4.';
        eStr.ecode = 1; varargout{outLen} = eStr; return;
    end    
    
    % Check the initial state parameters
    eStr = checkinistate(maskIniState1, deg1, eStr);    
    if (eStr.ecode == 1),  varargout{outLen} = eStr; return; end;

    eStr = checkinistate(maskIniState2, deg2, eStr);   
    if (eStr.ecode == 1),  varargout{outLen} = eStr; return; end;

    % Check the index parameter - scalar integer, [-2, -1, 0,...,2^deg1-2] 
    if ( ~isscalar(maskIndex) | ~isnumeric(maskIndex) | ~isreal(maskIndex) | ...
         ~isinteger(maskIndex) | maskIndex<-2 | maskIndex>(2^deg1-2) )
        eStr.emsg  = ['The code index parameter must be an integer scalar',...  
                      ' between -2 and 2^(degree)-2.'];
        eStr.ecode = 1; varargout{outLen} = eStr; return;
    end

    % Handle the special case indices by setting states to [0] to get 
    % corresponding all-zero sequences to be xor'ed.
    if (maskIndex == -2)        % First PN sequence
        maskIniState2 = [0];
    elseif (maskIndex == -1)    % Second PN sequence
        maskIniState1 = [0];
        maskIndex = 0;
    end
    
    % Check the shift parameter - scalar integer 
    if ( ~isscalar(maskShift) | ~isnumeric(maskShift) | ~isreal(maskShift) | ...
         ~isinteger(maskShift) )
        eStr.emsg  = 'The shift parameter must be an integer scalar.';
        eStr.ecode = 1; varargout{outLen} = eStr; return;
    end

    % Revise the shift modulo the period of the sequence
    maskShift = rem(maskShift, 2^deg1 - 1);
    if maskShift < 0
        maskShift = maskShift + 2^deg1 - 1;
    end
    
    % Reset outputs with validated parameters            
    varargout = {maskGenPoly1, maskIniState1, maskGenPoly2, maskIniState2,...
                 maskIndex, maskShift, rstPortLbl, eStr};

case {'cbFrameBased'}
    cbFrameBased(block);

case {'cbReset'}
    cbReset(block);

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
En = get_param(block, 'maskenables');
oldEnSampPerFrames   = En{idxSampPerFrame};

temp1 = get_param([block '/PN Sequence Generator1'], 'frameBased'); 
temp2 = get_param([block '/PN Sequence Generator2'], 'frameBased'); 

if (strcmp(Vals{idxFrameBased}, 'off')) % Sample-based
    En{idxSampPerFrame}  = 'off';
    
    if strcmp(temp1, 'on') 
        set_param([block '/PN Sequence Generator1'], 'frameBased', 'off');
    end
    if strcmp(temp2, 'on') 
        set_param([block '/PN Sequence Generator2'], 'frameBased', 'off');
    end
else % Frame-based
    En{idxSampPerFrame}  = 'on';
    
    if strcmp(temp1, 'off') 
        set_param([block '/PN Sequence Generator1'], 'frameBased', 'on');
    end
    if strcmp(temp2, 'off') 
        set_param([block '/PN Sequence Generator2'], 'frameBased', 'on');
    end
end

if ( ~strcmp(oldEnSampPerFrames, En{idxSampPerFrame}) ) 
    set_param(block,'MaskEnables',En);
end

%----------------------------------------------------------------------
% Function Name:    'cbReset'
%       Callback function for 'reset' checkbox parameter
%----------------------------------------------------------------------
function cbReset(block)
% Sets up the reset inputs for the underlying PNseq blocks.

setfieldindexnumbers(block);
resetVal  = get_param(block, 'reset');

% Determine if the connections exist (only then we'll add/delete)
% If isInPort is empty => no InPort in system
isInPort = find_system(block, 'LookUnderMasks', 'all', 'FollowLinks', 'on', ...
    'SearchDepth', 1, 'BlockType', 'Inport');

% If isLine is empty or == -1, => it is not there/unconnected
p1 = get_param([block '/PN Sequence Generator1'], 'PortHandles');
isLine1 = get_param(p1.Inport, 'Line');

p2 = get_param([block '/PN Sequence Generator2'], 'PortHandles');
isLine2 = get_param(p2.Inport, 'Line');

temp1 = get_param([block '/PN Sequence Generator1'], 'reset');
temp2 = get_param([block '/PN Sequence Generator2'], 'reset');

if (strcmp(resetVal, 'off')) % Reset is checked off
    % Delete the connections in an order and only if needed
    if (~isempty(isLine1) & isLine1 ~= -1) 
        delete_line(block,'In/1','PN Sequence Generator1/1');
    end
    if (~isempty(isLine2) & isLine2 ~= -1) 
        delete_line(block,'In/1','PN Sequence Generator2/1');
    end
    if ~isempty(isInPort)
        delete_block([block '/In']);
    end
    
    % Set only if needed
    if strcmp(temp1, 'on')
        set_param([block '/PN Sequence Generator1'], 'reset', 'off');
    end
    if strcmp(temp2, 'on')
        set_param([block '/PN Sequence Generator2'], 'reset', 'off');
    end
    
else % Reset is checked on
    % In reverse order from 'off' case above
    % Set only if needed
    if strcmp(temp1, 'off')
        set_param([block '/PN Sequence Generator1'], 'reset', 'on');
    end
    if strcmp(temp2, 'off')
        set_param([block '/PN Sequence Generator2'], 'reset', 'on');
    end
    
    % if needed, add the connections
    if isempty(isInPort)
        add_block('built-in/Inport', [block '/In']);
    end
    if ( isempty(isLine1) | isequal(isLine1, -1) )
        add_line(block,'In/1','PN Sequence Generator1/1');
    end
    if ( isempty(isLine2) | isequal(isLine1, -1) )
        add_line(block,'In/1','PN Sequence Generator2/1');
    end
    
end;

% [EOF]
