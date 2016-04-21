function varargout = commblkpbndcpmmod(block, action, varargin)
% COMMBLKPBNDCPMMOD Mask dynamic dialog function for CPM modulator block
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 16:27:47 $

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
    % --- Set Field index numbers and mask variable data
    setallfieldvalues(block);

    % --- Ensure that the mask is correct
    maskpropupdate('CPM Modulator Baseband','inputType');
    maskpropupdate('CPM Modulator Baseband','mappingType');
    maskpropupdate('CPM Modulator Baseband','pulseShape');

    % --- Exit code and error message definitions
    eStr.ecode = 0;
    eStr.emsg  = '';

    % --- Parameter structure definition
    params.g       = [];    % Frequency pulse
    params.q       = [];    % Integrated frequency pulse
    params.gMod    = [];    % Polyphase matrix version of frequency pulse

    % --- Field data
    Vals = get_param(block, 'maskvalues');

    % --- If the simulation status is 'stopped', then the function is being called
    %     because of an OK or apply and so the parameters do not need to be valid
    %     and hence, need not be evaluated
    simStatus = lower(get_param(bdroot(gcb),'SimulationStatus'));
    if(strcmp(simStatus,'stopped'))
        eStr.ecode = 3;  % Quiet exit
        varargout{1} = eStr;
        varargout{2} = params;
        return;
    end;

    varargout{1} = eStr;
    varargout{2} = params;

% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------
case 'cbInputType'
    cbInputType(block);

case 'cbPulseShape'
    cbPulseShape(block);

case 'cbOutputMode'
    cbOutputMode(block);

case 'cbOutputRateSpec'
    cbOutputRateSpec(block);



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

    Cb{idxMnum}                 = '';
    Cb{idxInputType}            = [mfilename '(gcb,''cbInputType'');'];
    Cb{idxMappingType}          = '';
    Cb{idxModIdx}               = '';
    Cb{idxPulseShape}           = [mfilename '(gcb,''cbPulseShape'');'];
    Cb{idxBT}                   = '';
    Cb{idxMainLobePulseLength}  = '';
    Cb{idxRollOff}              = '';
    Cb{idxPulseLength}          = '';
    Cb{idxNumSamp}              = '';
    Cb{idxPreHistory}           = '';
    Cb{idxFc}                   = '';
    Cb{idxPh}                   = '';
    Cb{idxOutSamp}              = '';
    Cb{idxTd}                   = '';

    En{idxMnum}                 = 'on';
    En{idxInputType}            = 'on';
    En{idxMappingType}          = 'off';
    En{idxModIdx}               = 'on';
    En{idxPulseShape}           = 'on';
    En{idxBT}                   = 'on';
    En{idxMainLobePulseLength}  = 'on';
    En{idxRollOff}              = 'on';
    En{idxPulseLength}          = 'on';
    En{idxNumSamp}              = 'on';
    En{idxPreHistory}           = 'on';
    En{idxFc}                   = 'on';
    En{idxPh}                   = 'on';
    En{idxOutSamp}              = 'on';
    En{idxTd}                   = 'on';

    Vis{idxMnum}                = 'on';
    Vis{idxInputType}           = 'on';
    Vis{idxMappingType}         = 'on';
    Vis{idxModIdx}              = 'on';
    Vis{idxPulseShape}          = 'on';
    Vis{idxBT}                  = 'off';
    Vis{idxMainLobePulseLength} = 'off';
    Vis{idxRollOff}             = 'off';
    Vis{idxPulseLength}         = 'on';
    Vis{idxNumSamp}             = 'on';
    Vis{idxPreHistory}          = 'on';
    Vis{idxFc}                  = 'on';
    Vis{idxPh}                  = 'on';
    Vis{idxOutSamp}             = 'on';
    Vis{idxTd}                  = 'on';

    % --- Get the MaskTunableValues
    Tunable = get_param(block,'MaskTunableValues');
    Tunable{idxMnum}                = 'off';
    Tunable{idxInputType}           = 'off';
    Tunable{idxMappingType}         = 'off';
    Tunable{idxModIdx}              = 'off';
    Tunable{idxPulseShape}          = 'off';
    Tunable{idxBT}                  = 'off';
    Tunable{idxMainLobePulseLength} = 'off';
    Tunable{idxRollOff}             = 'off';
    Tunable{idxPulseLength}         = 'off';
    Tunable{idxNumSamp}             = 'off';
    Tunable{idxPreHistory}          = 'off';
    Tunable{idxFc}                  = 'off';
    Tunable{idxPh}                  = 'off';
    Tunable{idxOutSamp}             = 'off';
    Tunable{idxTd}                  = 'off';


    % --- Set Callbacks, enable status, visibilities and tunable values
    set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, 'MaskTunableValues', Tunable);

    % --- Set the startup values.  '' Indicates that the default saved will be used
    Vals{idxMnum}               = '4';
    Vals{idxInputType}          = 'Integer';
    Vals{idxMappingType}        = 'Binary';
    Vals{idxModIdx}             = '0.5';
    Vals{idxPulseShape}         = 'Rectangular';
    Vals{idxBT}                 = '0.3';
    Vals{idxMainLobePulseLength}= '1';
    Vals{idxRollOff}            = '0.2';
    Vals{idxPulseLength}        = '1';
    Vals{idxPreHistory}         = '1';
    Vals{idxNumSamp}            = '8';
    Vals{idxFc}                 = '3000';
    Vals{idxPh}                 = '0';
    Vals{idxOutSamp}            = '1/8000';
    Vals{idxTd}                 = '1/100';


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
% Function Name:    cbInputType
% Description:      Deal with the different input modes
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Return Values:    Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbInputType(block)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    En   = get_param(block, 'maskenables');

    % --- Set the field index numbers
    setfieldindexnumbers(block);

    prevEn = En{idxMappingType};

    switch Vals{idxInputType}
    case 'Integer'
        En{idxMappingType} = 'off';
    case 'Bit'
        En{idxMappingType} = 'on';
    otherwise
        error('Unknown input type.');
    end;

    if ( ~isequal(prevEn, En{idxMappingType}) )
        set_param(block,'MaskEnables',En);
    end

return;


%*********************************************************************
% Function Name:    cbPulseShape
% Description:      Deal with the different pulse shapes
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Return Values:    Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbPulseShape(block);
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis  = get_param(block, 'maskvisibilities');

    % --- Set the field index numbers
    setfieldindexnumbers(block);

    prevVis = Vis([idxBT idxMainLobePulseLength idxRollOff]);

    switch Vals{idxPulseShape}

    case {'Raised Cosine' 'Rectangular' 'Tamed FM'}
        Vis{idxBT}                  = 'off';
        Vis{idxMainLobePulseLength} = 'off';
        Vis{idxRollOff}             = 'off';

    case 'Spectral Raised Cosine'
        Vis{idxBT}                  = 'off';
        Vis{idxMainLobePulseLength} = 'on';
        Vis{idxRollOff}             = 'on';

    case 'Gaussian'
        Vis{idxBT}                  = 'on';
        Vis{idxMainLobePulseLength} = 'off';
        Vis{idxRollOff}             = 'off';
    otherwise
         error('Unrecognized pulse shape.');
    end;

    if ( ~isequal(prevVis, Vis([idxBT idxMainLobePulseLength idxRollOff])) )
        set_param(block,'MaskVisibilities',Vis);
    end

return;


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
