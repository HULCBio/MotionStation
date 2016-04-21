function varargout = rf_link_mask(block, action, varargin)
% RF_LINK_MASK Sets up workspace variables for the RF Link Demo.
%

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.3.4.3 $  $Date: 2004/04/12 23:02:06 $

%**************************************************************************
% --- Action switch -- Determines which of the callback functions is called
%**************************************************************************
switch(action)

%*********************************************************************
% Function Name:     init
% Description:       Main initialization code
%********************************************************************
case 'init',

    % --- Initialize values
    eStr = setInitValues(block,struct('emsg','','wmsg',''));
    if (~isempty(eStr.emsg)),varargout{1} = eStr; return;  end
    
    eStr = updateHPA(block,eStr);
    if (~isempty(eStr.emsg)),varargout{1} = eStr; return;  end
    
    eStr = updateCorrPh(block,eStr);
    if (~isempty(eStr.emsg)),varargout{1} = eStr; return;  end
    
    eStr = updateAltitude(block,eStr);
    if (~isempty(eStr.emsg)),varargout{1} = eStr; return;  end

    eStr = updateFrequency(block,eStr);
    if (~isempty(eStr.emsg)),varargout{1} = eStr; return;  end

    eStr = updateAntGain(block,eStr);
    if (~isempty(eStr.emsg)),varargout{1} = eStr; return;  end

    eStr = updateTemp(block,eStr);
    if (~isempty(eStr.emsg)),varargout{1} = eStr; return;  end
    
    eStr = updateDoppler(block,eStr);
    if (~isempty(eStr.emsg)),varargout{1} = eStr; return;  end
    
    eStr = updateImbal(block,eStr);
    if (~isempty(eStr.emsg)),varargout{1} = eStr; return;  end
    
    eStr = updateNoPh(block,eStr);
    if (~isempty(eStr.emsg)),varargout{1} = eStr; return;  end
    
    eStr = updateAGC(block,eStr);
    if (~isempty(eStr.emsg)),varargout{1} = eStr; return;  end

    eStr = updateDcOffsetComp(block,eStr);
    if (~isempty(eStr.emsg)),varargout{1} = eStr; return;  end

    eStr = updateCorrPh(block,eStr);
    varargout{1} = eStr;

case 'cbLvlSat',
    eStr = updateHPA(block,struct('emsg','','wmsg',''));
    varargout{1} = eStr;

case 'cbDoppler',
    eStr = updateDoppler(block,struct('emsg','','wmsg',''));
    varargout{1} = eStr;

case 'cbImbal',
    eStr = updateImbal(block,struct('emsg','','wmsg',''));
    varargout{1} = eStr;

case 'cbNoPh',
    eStr = updateNoPh(block,struct('emsg','','wmsg',''));
    varargout{1} = eStr;
     
case 'cbSelAGC',
    eStr = updateAGC(block,struct('emsg','','wmsg',''));
    varargout{1} = eStr;
    
case 'cbCorrPh',
    eStr = updateCorrPh(block,struct('emsg','','wmsg',''));
    varargout{1} = eStr;
    
case 'cbDcOffset',
    eStr = updateDcOffsetComp(block,struct('emsg','','wmsg',''));
    varargout{1} = eStr;
    
case 'cbAltitude',
    eStr = updateAltitude(block,struct('emsg','','wmsg',''));
    varargout{1} = eStr;

case 'cbFrequency',
    eStr = updateFrequency(block,struct('emsg','','wmsg',''));
    varargout{1} = eStr;

case 'cbAntDiam',
    eStr = updateAntGain(block,struct('emsg','','wmsg',''));
    varargout{1} = eStr;

%*********************************************************************
% Function Name:     default
% Description:       Define visiblity, enable and values of variables 
%                    for default case.  
% Return Values:     None
%********************************************************************
case 'default'

    % --- Field data
    Vals = get_param(block, 'MaskValues');
    Vis  = get_param(block, 'MaskVisibilities');
    En   = get_param(block, 'MaskEnables');
    filename = 'rf_link_mask';

    % -- Set Index to Mask parameters
    setfieldindexnumbers(block);
    
    % -- Set Callbacks
    Cb{idxAltitude}   		= [filename '(gcb,''cbAltitude'');']; 
    Cb{idxFrequency}        = [filename '(gcb,''cbFrequency'');'];
    Cb{idxSelCorrPh}        = [filename '(gcb,''cbSelCorrPh'');'];
    Cb{idxSelDopper}        = [filename '(gcb,''cbSelDopper'');'];
    Cb{idxSelImbal}         = [filename '(gcb,''cbSelImbal'');'];
    Cb{idxSelLvlBO}         = [filename '(gcb,''cbSelLvlBO'');'];
    Cb{idxSelNoPh}          = [filename '(gcb,''cbSelNoPh'');'];
    Cb{idxSelTemp}          = [filename '(gcb,''cbSelTemp'');'];
    Cb{idxAntDiam}          = [filename '(gcb,''cbAntDiam'');'];
    Cb{idxSelDcOffset}      = [filename '(gcb,''cbDcOffset'');'];
    Cb{idxSelAGC}           = [filename '(gcb,''cbSelAGC'');'];

    % --- Set Callbacks, enable status, visibilities and tunable values
%    set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis, 'MaskTunableValues', Tunable);
    set_param(block,'MaskCallbacks',Cb);

    % --- Update the Vals field with the actual values
    MN = get_param(block,'MaskNames');
    for n=1:length(Vals)
        set_param(block,MN{n},Vals{n});
    end;

    % --- Ensure that the block operates correctly from a library
    set_param(block,'MaskSelfModifiable','on');

    % --- Set Init Values
    eStr = setInitValues(block,struct('emsg','','wmsg',''));

    % --- Return parameters
    varargout{1} = eStr;

end
%*********************************************************************
% Function Name:     setInitValues
% Description:       This function gets all the variables from the mask,
%                       computes intermediated variables and finally
%                       assigns them to the base Workspace
%********************************************************************
function eStr = setInitValues(block,eStr)

%*********************************************************************
% Function Name:     updateHPA
% Description:       update nonlinear amplifier input and output gains      
%********************************************************************
function eStr = updateHPA(block,eStr)

    % -- Update the saturation level parameters
    valsBO = [-30 -7 -1];       % values for backoff
    rrcComp = 20*log10(.38);    % compensation for RRC filter P2P power
    gainLin = 18;               % fixed HPA linear gain
    alpha = 20*log10(2.1587);   % difference between linear gain and
                                % small signal gain
    
    gainIP = cellstr(num2str([valsBO - rrcComp]'))';
    gainOP = cellstr(num2str([-valsBO + rrcComp - alpha + gainLin]'))';
    
    eStr = updateTgtParamFromPopup(block, [gcs '/High Power Amplifier'],  ...
        'GindB', gainIP, 'selLvlBO');
    eStr = updateTgtParamFromPopup(block, [gcs '/High Power Amplifier'],  ...
        'GoutdB', gainOP, 'selLvlBO');

%*********************************************************************
% Function Name:     updateTemp
% Description:       update receiver noise temperature       
%********************************************************************
function eStr = updateTemp(block,eStr)

    % -- Update the eceiver noise temperature parameter
    eStr = updateTgtParamFromPopup(block, [gcs '/Satellite Receiver System Temp'],  ...
        'ntemp', {'0','20','290'}, 'selTemp');

%*********************************************************************
% Function Name:     updateDoppler
% Description:       update doppler and doppler correction
%********************************************************************
function eStr = updateDoppler(block,eStr)

    % -- Update the doppler parameter
    nStr = updateTgtParamFromPopup(block, [gcs '/Doppler and Phase Error'],  ...
        'freqOffset', {'0','.7','3'}, 'selDopper');
    if (~isempty(nStr.emsg)), 
        return;  
    else
        eStr.wmsg = [eStr.wmsg char(10) char(10) nStr.wmsg];
    end

    % -- Update the doppler correction parameter
    nStr = updateTgtParamFromPopup(block, [gcs '/Doppler and Phase Compensation'],  ...
        'freqOffset', {'0','0','-3'}, 'selDopper');
    if (~isempty(nStr.emsg)), 
        return;  
    else
        eStr.wmsg = [eStr.wmsg char(10) char(10) nStr.wmsg];
    end

%*********************************************************************
% Function Name:     updateImbal
% Description:       update inphase and quadrature imbalances
%********************************************************************
function eStr = updateImbal(block,eStr)

    % -- Set common variables
    targetBlock = [gcs '/I//Q Imbalance'];
    param = 'selImbal';

    % -- Update Amplitude Imbalance
    nStr = updateTgtParamFromPopup(block, targetBlock,  ...
        'ampImbal', {'0','3','0','0','0'}, param);
    if (~isempty(nStr.emsg)), 
        return;  
    else
        eStr.wmsg = [eStr.wmsg char(10) char(10) nStr.wmsg];
    end

    % -- Update Phase Imbalance
    eStr = updateTgtParamFromPopup(block, targetBlock,  ...
        'phsImbal', {'0','0','20','0','0'}, param);
    if (~isempty(nStr.emsg)), 
        return;  
    else
        eStr.wmsg = [eStr.wmsg char(10) char(10) nStr.wmsg];
    end

    % -- Update Inphase DC Offset
    eStr = updateTgtParamFromPopup(block, targetBlock,  ...
        'Idc', {'0','0','0','2e-6','0'}, param);
    if (~isempty(nStr.emsg)), 
        return;  
    else
        eStr.wmsg = [eStr.wmsg char(10) char(10) nStr.wmsg];
    end

    % -- Update Quadrature DC Offset
    nStr = updateTgtParamFromPopup(block, targetBlock,  ...
        'Qdc', {'0','0','0','0','1e-5'}, param);
    if (~isempty(nStr.emsg)), 
        return;  
    else
        eStr.wmsg = [eStr.wmsg char(10) char(10) nStr.wmsg];
    end

%*********************************************************************
% Function Name:     updateNoPh
% Description:       update phase noise
%********************************************************************
function eStr = updateNoPh(block,eStr)

    % -- Update the phase noise parameter
    eStr = updateTgtParamFromPopup(block, [gcs '/Phase Noise'],  ...
        'PhNs', {'-100','-55','-48'}, 'selNoPh');

%*********************************************************************
% Function Name:     updateCorrPh
% Description:       update phase correction
%********************************************************************
function eStr = updateCorrPh(block,eStr)

    % -- Update the phase correction parameter
    eStr = updateTgtParamFromPopup(block, [gcs '/Doppler and Phase Compensation'],  ...
        'phaseOffset', {'0','-12','-16'}, 'selCorrPh');

%*********************************************************************
% Function Name:     updateDcOffsetComp
% Description:       update phase correction
%********************************************************************
function eStr = updateDcOffsetComp(block,eStr)

    % -- Update the DC offset parameter
    eStr = updateTgtParamFromPopup(block, [gcs '/DC Offset Comp./Gain'],  ...
        'Gain', {'0','1'}, 'selDcOffset');

%*********************************************************************
% Function Name:     updateAGC
% Description:       update phase correction
%********************************************************************
function eStr = updateAGC(block,eStr)

    % -- Update the AGC selection parameter
    eStr = updateTgtParamFromPopup(block, [gcs '/Select AGC'],  ...
        'swCase', {'Magnitude','I and Q'}, 'selAGC');

%*********************************************************************
% Function Name:     updateAltitude
% Description:       update satellite altitude 
%********************************************************************
function eStr = updateAltitude(block,eStr)

    % -- Update the satellite altitude parameter
    eStr = updateTgtParamFromEdit(block, [gcs '/Downlink Path'],  ...
        'd', 'altitude');

%*********************************************************************
% Function Name:     updateFrequency
% Description:       update carrier frequency
%********************************************************************
function eStr = updateFrequency(block,eStr)

    % -- Update the carrier frequency parameter
    eStr = updateTgtParamFromEdit(block, [gcs '/Downlink Path'],  ...
        'fc', 'frequency');

%*********************************************************************
% Function Name:     updateAntGain
% Description:       update antenna gain from antenna size
%********************************************************************
function eStr = updateAntGain(block,eStr)

    % -- Update the antenna gain parameters
    % -- Get variables from mask
    WsVar = get_param(block, 'MaskWsVariables');

    % -- Set Index to Mask parameters
    setfieldindexnumbers(block);

    % -- get selected value
	diameter = WsVar(idxAntDiam).Value;
    area = pi .* diameter .* diameter; 
    wavelength = 3e8 ./ (WsVar(idxFrequency).Value .* 1e6);
    gain = sqrt(0.55 .* area .* 4 .* pi) ./ wavelength;

    % --- assign in the saturation values
    param = 'Gain';
    try,
        targetBlock = [gcs '/Tx Dish Antenna Gain'];
        set_param(targetBlock, param, num2str(gain(1)));
        targetBlock = [gcs '/Rx Dish Antenna Gain'];
        set_param(targetBlock, param, num2str(gain(2)));
        eStr.wmsg = '';
    catch,
        eStr.wmsg = ['Could not find the ''' param ''' parameter in the ''' targetBlock ''' block.' char(10) char(10) ...
            'The block was either renamed or removed. Please replace the missing block or ' ...
             'rename the changed block back to the original block.'];
    end
    eStr.emsg = '';

%*********************************************************************
% Function Name:     updateTgtParamFromPopup
% Description:       upate target parameter in target block from 
%                    the popup control.
%********************************************************************
function eStr = updateTgtParamFromPopup(block, targetBlock, param, valList, popupName )

    % -- Get variables from mask
    WsVar = get_param(block, 'MaskWsVariables');

    % -- get selected value
	idx = strmatch(popupName,strvcat(WsVar.Name));
	valNew = valList{WsVar(idx).Value};
    
    % --- assign in the saturation values
    try,
        set_param(targetBlock,param,num2str(valNew));
        eStr.wmsg = '';
    catch,
        eStr.wmsg = ['Could not find the ''' param ''' parameter in the ''' targetBlock ''' block.' char(10) char(10) ...
            'The block was either renamed or removed. Please replace the missing block or ' ...
             'rename the changed block back to the original block.'];
    end
    eStr.emsg = '';

%*********************************************************************
% Function Name:     updateTgtParamFromEdit
% Description:       update target parameters in a target block 
%                    from an edit control.      
%********************************************************************
function eStr = updateTgtParamFromEdit(block, targetBlock, param, editName )

    % -- Get variables from mask
    WsVar = get_param(block, 'MaskWsVariables');

    % -- get selected value
	idx = strmatch(editName,strvcat(WsVar.Name));
	valNew = WsVar(idx).Value;
    
    % --- assign in the saturation values
    try,
        set_param(targetBlock,param,num2str(valNew));
        eStr.wmsg = '';
    catch,
        eStr.wmsg = ['Could not find the ''' param ''' parameter in the ''' targetBlock ''' block.' char(10) char(10) ...
            'The block was either renamed or removed. Please replace the missing block or ' ...
             'rename the changed block back to the original block.'];
    end
    eStr.emsg = '';

% end of rf_link_mask.m
