function varargout = commblkgmskmod(block, action, varargin)
% COMMBLKGMSKMOD Mask dynamic dialog function for GMSK modulator block
% Copyright 1996-2002 The MathWorks, Inc.

if(nargin == 2)
    if(ishandle(block))
        varargout{1} = errorhandler(block, action);
        return;
    end;
end;


%*********************************************************************
% --- Action switch -- Determines which of the callback functions is called
%*********************************************************************

switch(action)
    
%*********************************************************************
% Function Name:     init
% Description:       Main initialization code
% Inputs:            current block and any parameters from the mask 
%                    required for parameter calculation.
% Return Values:     params - Parameter structure
%********************************************************************
case 'init'
    % --- Ensure the CPM subsystem is correctly setup
    maskpropupdate('CPM Modulator Baseband','inputType');

    % --- Exit code and error message definitions
    eStr.ecode = 0;
    eStr.emsg  = '';
    
    % --- Output assignments
    varargout{1} = eStr;
    varargout{2} = {};

% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------

%----------------------------------------------------------------------
%   Setup/Utility functions
%----------------------------------------------------------------------

%*********************************************************************
% Function Name:    'default'
% Description:      Set the block defaults (development use only)
% Inputs:           current block
% Return Values:    none
%*********************************************************************
case 'default'
    % --- Set Field index numbers and mask variable data
    setallfieldvalues(block);
    
    Cb{idxInputType}             = '';
    Cb{idxBT}                    = '';
    Cb{idxPulseLength}           = '';
    Cb{idxPhaseOffset}           = '';
    Cb{idxSamplesPerSymbol}      = '';
    Cb{idxPreHistory}            = '';
                                 
    En{idxInputType}             = 'on';
    En{idxBT}                    = 'on';
    En{idxPulseLength}           = 'on';
    En{idxPhaseOffset}           = 'on';
    En{idxSamplesPerSymbol}      = 'on';
    En{idxPreHistory}            = 'on';
                                 
    Vis{idxInputType}            = 'on';
    Vis{idxBT}                   = 'on';
    Vis{idxPulseLength}          = 'on';
    Vis{idxPhaseOffset}          = 'on';
    Vis{idxSamplesPerSymbol}     = 'on';
    Vis{idxPreHistory}           = 'on';

    % --- Get the MaskTunableValues 
    Tunable = get_param(block,'MaskTunableValues');
    Tunable{idxInputType}        = 'on';
    Tunable{idxBT}               = 'on';
    Tunable{idxPulseLength}      = 'on';
    Tunable{idxPhaseOffset}      = 'on';
    Tunable{idxSamplesPerSymbol} = 'on';
    Tunable{idxPreHistory}       = 'on';

    % --- Set Callbacks, enable status, visibilities and tunable values
    set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, 'MaskTunableValues', Tunable);

    % --- Set the startup values.  '' Indicates that the default saved will be used

    Vals{idxInputType}           = 'Integer';
    Vals{idxBT}                  = '.3';
    Vals{idxPulseLength}         = '4';
    Vals{idxPhaseOffset}         = '0';
    Vals{idxSamplesPerSymbol}    = '8';
    Vals{idxPreHistory}          = '1';

    % --- update Vals
    MN = get_param(block,'MaskNames');
    for n=1:length(Vals)
        if(~isempty(Vals{n}))
            set_param(block,MN{n},Vals{n});
        end;
    end;

    % --- Update the Vals field with the actual values
    Vals = get_param(block, 'maskvalues');

    % --- Ensure that the block operates correctly from a library
    set_param(block,'MaskSelfModifiable','on');

% --- End of case 'default'

%*********************************************************************
% Function Name:    show all
% Description:      Show all of the widgets
% Inputs:           current block
% Return Values:    none
% Notes:            This function is for development use only and allows
%                   All fields to be displayed
%********************************************************************
case 'showall'

    Vis = get_param(block, 'maskvisibilities');
    En  = get_param(block, 'maskenables');

    Cb = {};
    for n=1:length(Vis)
        Vis{n} = 'on';
        En{n} = 'on';
        Cb{n} = '';
    end;

    set_param(block,'MaskVisibilities',Vis,'MaskEnables',En,'MaskCallbacks',Cb);

end; % End of switch(action)

% ----------------
% --- Subfunctions
% ----------------
%*********************************************************************
% Function Name:    errorhandler
% Description:      Deal with errors in the block
% Inputs:           block handle and ID
% Return Values:    New message
%*********************************************************************
function newMsg = errorhandler(block,ID)
   
    lastErr = sllasterror;
    emsg    = lastErr.Message;
    
    newMsg = '';
% --- Error parsing
%    if(findstr(emsg,'Check Signal Attributes'))
%        newMsg = 'The input must be a complex scalar or column vector';
%    elseif(findstr(emsg,'Port complexity propagation error'))
%        newMsg = 'The input must be a complex scalar or column vector';
%    end;
    
    if(isempty(newMsg))
        key = 'MATLAB error message:';
        idx = min(findstr(emsg, key));

        if(isempty(idx))
            key = ':';
            idx = min(findstr(emsg, key));
        end;

        if(isempty(idx))
            newMsg = emsg;
        else
            newMsg = emsg(idx+length(key):end);
        end;

    end;

return;
