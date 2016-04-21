function varargout = commblkcpmdemod(block, action, varargin)
% COMMBLKCPMDEMOD Mask dynamic dialog function for CPM demodulator block

% Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $ $Date: 2004/04/12 23:02:49 $

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
    cbOutputType(block);
    cbPulseShape(block);

    % --- Exit code and error message definitions
    eStr.ecode = 0;
    eStr.emsg  = '';

    % --- Parameter structure definition
    params.g       = [];    % Frequency pulse
    params.q       = [];    % Integrated frequency pulse
    params.gMod    = [];    % Polyphase matrix version of frequency pulse
    params.m       = [];    % Modulation index numerator
    params.p       = [];    % Modulation index denomonator

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

    % --- Generate the pulse shapes
    switch Vals{idxPulseShape};
    case 'Raised Cosine'
        mode = 'LRC';
        modeParams = {};
    case {'Tamed FM'}
        mode = 'TFM';
        modeParams = {};
    case 'Spectral Raised Cosine'
        if(~isscalar(maskMainLobePulseLength) | ~isreal(maskMainLobePulseLength) | ...
           ~isinteger(maskMainLobePulseLength) | (maskMainLobePulseLength < 1))
            eStr.ecode = 1;
            eStr.emsg = 'Spectral Raised Cosine main lobe pulse length must be a positive real integer scalar.';
        end        
        if(~isscalar(maskRollOff) | ~isreal(maskRollOff) | (maskRollOff < 0) | (maskRollOff > 1) )
            eStr.ecode = 1;
            eStr.emsg  = 'Spectral Raised Cosine roll off must be a real scalar between 0 and 1 inclusive.';
        end;
        mode = 'LSRC';
        modeParams.mainLobePulseLength = maskMainLobePulseLength;
        modeParams.beta = maskRollOff;
    case 'Gaussian'
        if(~isscalar(maskBT) | ~isreal(maskBT) | (maskBT < 0) | (maskBT > 1))
            eStr.ecode = 1;
            eStr.emsg  = 'Gaussian BT product must be a real positive scalar.';
        end;
        mode = 'GMSK';
        modeParams.BT = maskBT;
    case 'Rectangular'
        mode = 'LREC';
        modeParams = {};
    otherwise
        eStr.ecode = 1;
        eStr.emsg  = 'Unrecognized pulse shape.';
    end;

    % --- In order to compute the pulse shapes, the pulse length and
    %     samples per symbol parameters must be valid
    if(~isscalar(maskPulseLength) | ~isreal(maskPulseLength) | ~isinteger(maskPulseLength) | (maskPulseLength < 1) )
        eStr.ecode = 1;
        eStr.emsg  = 'Pulse Length must be a positive real integer scalar.';
    end;
    if(~isscalar(maskSamplesPerSymbol) | ~isreal(maskSamplesPerSymbol) | ~isinteger(maskSamplesPerSymbol) | (maskSamplesPerSymbol < 1) )
        eStr.ecode = 1;
        eStr.emsg  = 'Samples per Symbol must be a positive real integer scalar.';
    end;
    % --- In order to compute the rational modulation index fraction, modIdx must be valid
    if(~isscalar(maskModIdx) | ~isreal(maskModIdx) |  (maskModIdx < 0) )
        eStr.ecode = 1;
        eStr.emsg  = 'Modulation index must be a positive real scalar.';
    end;

    % --- Return if there is an unrecognized mode or a parameter error
    varargout{1} = eStr;
    varargout{2} = params;

    if(eStr.ecode)
        return;
    end;

    % --- Compute the required sample times, widths and phase response functions
    [ecode, emsg, sfunParams] = cpmmodparams(mode, modeParams, maskPulseLength, maskSamplesPerSymbol);
    params.g = [sfunParams.g;0]*maskModIdx*2*pi;
    % --- Reshuffle the filter into phase order for use by the polyphase filter
    [params.gMod,str]= localUpFir2(params.g,maskSamplesPerSymbol);
    % --- Compute the rational modulation index fraction
    [params.m, params.p] = rat(maskModIdx);

	% --- Estimate the amount of memory required for the decoder
	
	L = maskPulseLength;
	N = maskSamplesPerSymbol;
	M = maskMnum;
	T = maskTraceBack;
	S = (mod(params.m,2)+1)*params.p;
	estMem = (M^L)*N*2*8*S + ((T+2)*8*S)*(M^(L-1));
	
    if (estMem > 8e6),
        ecode = 1;
        emsg  = 'Demodulator parameter settings exceed memory allocation limit.';
    end;
		
    % --- Output assignments
    eStr.ecode = ecode;
    eStr.emsg  = emsg;
    varargout{1} = eStr;
    varargout{2} = params;

% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------
case 'cbOutputType'
    cbOutputType(block);

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
    Cb{idxOutputType}           = [mfilename '(gcb,''cbOutputType'');'];
    Cb{idxMappingType}          = '';
    Cb{idxModIdx}               = '';
    Cb{idxPulseShape}           = [mfilename '(gcb,''cbPulseShape'');'];
    Cb{idxBT}                   = '';
    Cb{idxMainLobePulseLength}  = '';
    Cb{idxRollOff}              = '';
    Cb{idxPulseLength}          = '';
    Cb{idxPhaseOffset}          = '';
    Cb{idxSamplesPerSymbol}     = '';
    Cb{idxPreHistory}           = '';
    Cb{idxTraceBack}            = '';


    En{idxMnum}                 = 'on';
    En{idxOutputType}           = 'on';
    En{idxMappingType}          = 'off';
    En{idxModIdx}               = 'on';
    En{idxPulseShape}           = 'on';
    En{idxBT}                   = 'on';
    En{idxMainLobePulseLength}  = 'on';
    En{idxRollOff}              = 'on';
    En{idxPulseLength}          = 'on';
    En{idxPhaseOffset}          = 'on';
    En{idxSamplesPerSymbol}     = 'on';
    En{idxPreHistory}           = 'on';
    En{idxTraceBack}            = 'on';

    Vis{idxMnum}                = 'on';
    Vis{idxOutputType}          = 'on';
    Vis{idxMappingType}         = 'on';
    Vis{idxModIdx}              = 'on';
    Vis{idxPulseShape}          = 'on';
    Vis{idxBT}                  = 'off';
    Vis{idxMainLobePulseLength} = 'off';
    Vis{idxRollOff}             = 'off';
    Vis{idxPulseLength}         = 'on';
    Vis{idxPhaseOffset}         = 'on';
    Vis{idxSamplesPerSymbol}    = 'on';
    Vis{idxPreHistory}          = 'on';
    Vis{idxTraceBack}           = 'on';

    % --- Get the MaskTunableValues
    Tunable = get_param(block,'MaskTunableValues');
    Tunable{idxMnum}                = 'off';
    Tunable{idxOutputType}          = 'off';
    Tunable{idxMappingType}         = 'off';
    Tunable{idxModIdx}              = 'off';
    Tunable{idxPulseShape}          = 'off';
    Tunable{idxBT}                  = 'off';
    Tunable{idxMainLobePulseLength} = 'off';
    Tunable{idxRollOff}             = 'off';
    Tunable{idxPulseLength}         = 'off';
    Tunable{idxPhaseOffset}         = 'off';
    Tunable{idxSamplesPerSymbol}    = 'off';
    Tunable{idxPreHistory}          = 'off';
    Tunable{idxTraceBack}           = 'off';

    % --- Set Callbacks, enable status, visibilities and tunable values
    set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, 'MaskTunableValues', Tunable);

    % --- Set the startup values.  '' Indicates that the default saved will be used
    Vals{idxMnum}               = '4';
    Vals{idxOutputType}         = 'Integer';
    Vals{idxMappingType}        = 'Binary';
    Vals{idxModIdx}             = '0.5';
    Vals{idxPulseShape}         = 'Rectangular';
    Vals{idxBT}                 = '0.3';
    Vals{idxMainLobePulseLength}= '1';
    Vals{idxRollOff}            = '0.2';
    Vals{idxPulseLength}        = '1';
    Vals{idxPhaseOffset}        = '0';
    Vals{idxPreHistory}         = '1';
    Vals{idxSamplesPerSymbol}   = '8';
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
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Return Values:    Modified Value, Visibility and Enable cell arrays
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

%------------------------------------------------------------
function [gmod, str] = localUpFir2(h, L)

    if(isempty(L))
      str = '???';  % Default display
    else
        str=['x[n/' num2str(L) ']'];
    end

    [M,N] = size(h);
    if (M ~= 1 & N ~= 1)
        error('The filter coefficients must be a nonempty vector');
    end
    if (isempty(L) | L < 1 | fix(L) ~= L)
        error('Interpolation factor must be a positive integer');
    end

    if(~isempty(h) & ~isempty(L))

        % Need to reshuffle the coefficients into phase order
        len = length(h);
        if (rem(len, L) ~= 0)
            nzeros = L - rem(len, L);
            h = [h(:); zeros(nzeros,1)];
        end
        len = length(h);
        nrows = len / L;
        % Re-arrange the coefficient and gain-scale
        h = L * reshape(h, L, nrows).'; 
    end    
    
    gmod = h;

