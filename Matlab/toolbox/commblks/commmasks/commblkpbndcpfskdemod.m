function varargout = commblkcpfskdemod(block, action, varargin)
% COMMBLKCPFSKDEMOD Mask dynamic dialog function for CPFSK demodulator block
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/03/24 01:59:54 $

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
    % --- Ensure that the mask and subsystem are correct
    maskpropupdate('CPM Demodulator Passband','mappingType');
    maskpropupdate('CPM Demodulator Passband','outputType');

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
case 'cbOutputType'
    cbOutputType(block);


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
    Cb{idxOutputType}           = [mfilename '(gcb,''cbOutputType'');'];
    Cb{idxMappingType}          = '';
    Cb{idxModIdx}               = '';
    Cb{idxPh}                   = '';
    Cb{idxNumSamp}              = '';
	Cb{idxFc}                   = '';
	Cb{idxInSamp}               = '';
	Cb{idxTd}                   = '';
    Cb{idxTraceBack}            = '';

    En{idxMnum}                 = 'on';
    En{idxOutputType}           = 'on';
    En{idxMappingType}          = 'off';
    En{idxModIdx}               = 'on';
    En{idxPh}                   = 'on';
    En{idxNumSamp}              = 'on';
	En{idxFc}                   = 'on';
	En{idxInSamp}               = 'on';
	En{idxTd}                   = 'on';
    En{idxTraceBack}            = 'on';

    Vis{idxMnum}                = 'on';
    Vis{idxOutputType}          = 'on';
    Vis{idxMappingType}         = 'on';
    Vis{idxModIdx}              = 'on';
    Vis{idxPh}                  = 'on';
    Vis{idxNumSamp}             = 'on';
	Vis{idxFc}                  = 'on';
	Vis{idxInSamp}              = 'on';
	Vis{idxTd}                  = 'on';
    Vis{idxTraceBack}           = 'on';

    % --- Get the MaskTunableValues
    Tunable = get_param(block,'MaskTunableValues');
    Tunable{idxMnum}            = 'off';
    Tunable{idxOutputType}      = 'off';
    Tunable{idxMappingType}     = 'off';
    Tunable{idxModIdx}          = 'off';
    Tunable{idxPh}              = 'off';
    Tunable{idxNumSamp}         = 'off';
	Tunable{idxFc}              = 'off';
	Tunable{idxInSamp}          = 'off';
	Tunable{idxTd}              = 'off';
    Tunable{idxTraceBack}       = 'off';


    % --- Set Callbacks, enable status, visibilities and tunable values
    set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, 'MaskTunableValues', Tunable);

    % --- Set the startup values.  '' Indicates that the default saved will be used

    Vals{idxMnum}               = '4';
    Vals{idxOutputType}         = 'Integer';
    Vals{idxMappingType}        = 'Binary';
    Vals{idxModIdx}             = '.5';
    Vals{idxPh}                 = '0';
    Vals{idxNumSamp}            = '8';
	Vals{idxFc}                 = '3000';
	Vals{idxInSamp}             = '1/8000';
	Vals{idxTd}                 = '1/100';
    Vals{idxTraceBack}          = '16';

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
% Function Name:    cbOutputType
% Description:      Deal with the different input modes
% Inputs:           current block
% Return Values:    None
%********************************************************************
function cbOutputType(block)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    En   = get_param(block, 'maskenables');

    % --- Set the field index numbers
    setfieldindexnumbers(block);

    prevEn = En{idxMappingType};

    switch Vals{idxOutputType}
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
