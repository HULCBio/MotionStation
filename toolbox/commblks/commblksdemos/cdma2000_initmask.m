function eStr = cdma2000_initmask(block, action)
% cdma2000_INITMASKPHLAYER Sets up workspace variables for the cdma2000_phlayer
% model.
%   Usage: 
%       eStr = cdma2000_initmask(gcb, action)
%       where action corresponds to the different parameter's callbacks.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:01:34 $

%**************************************************************************
% --- Action switch -- Determines which of the callback functions is called
%**************************************************************************

%-- Init variables
eStr.emsg = ''; % error message string

%-- Disable changes when the simulation is not stopped
if ~strcmp(get_param(bdroot(block),'simulationstatus'),'stopped')
    return;
end
    
switch(action)
    
    case 'cbDataRates'
        % Get index to Data Rate
        idx = strmatch(get_param(block,'dataRates'),...
            strvcat('1.5 Kbps','2.7 Kbps','4.8 Kbps','9.6 Kbps'));

        %-- Set numSamp, CRC size and tail bits
        numSamp = {'16','40','80','172'};
        fqiSize = {'6','6','8','12'};
        sGenPol = {'[6 5 2 1 0]','[6 5 2 1 0]','[8 7 4 3 1 0]','[12 11 10 9 8 4 1 0]'};
        repetV = {'8','4','2','1'};
        punctV ={'[1;1;1;1;0]','[1;1;1;1;1;1;1;1;0]','[1]','[1]'};

        % Source
        sSampTime = ['20e-3*' get_param(block,'nFrameMask') '/' numSamp{idx}];
        set_param([bdroot(block) '/Binary Data Source'],'sampPerFrame',numSamp{idx},...
            'Ts',sSampTime);

        %-- Add/Extract Frame Quality Indicator: 6,8,12 bits
        set_param([bdroot(block) '/Tx Channel Structure/Add FQI'],...
            'genPoly',sGenPol{idx});
        set_param([bdroot(block) '/Rx Channel Structure/Extract FQI'],...
            'genPoly',sGenPol{idx});

        %-- Encoder Tail bits
        numCol = [numSamp{idx} ' + ' fqiSize{idx} ' + 8'];
        set_param([bdroot(block) '/Tx Channel Structure/Encoder Tail Bits'],...
            'numOutRows',numCol);
        numCol = [numSamp{idx} ' + ' fqiSize{idx}];
        set_param([bdroot(block) '/Rx Channel Structure/Encoder Tail Bits'],...
            'numOutRows',numCol);

        %-- Repetition
        set_param([bdroot(block) '/Tx Channel Structure/Repeat'],'N',repetV{idx});
        set_param([bdroot(block) '/Rx Channel Structure/Derepeat'],'N',repetV{idx});

        %-- Puncture
        set_param([bdroot(block) '/Tx Channel Structure/Puncture'],...
            'punctureVector',punctV{idx});
        set_param([bdroot(block) '/Rx Channel Structure/DePuncture'],...
            'insertZeroVector',punctV{idx});

        % BER metrics
        sDelay = ['2*' numSamp{idx}];
        set_param([bdroot(block) '/Error Rate Calculation'],'N',sDelay);
        
    case 'cbNFramesMask'
        %-- Update parameters
        str1='/Tx Antenna/Long Code Scrambling Power Control and Signal Point Mapping';
        set_param([bdroot(block) str1],'nFrameMask',get_param(block,'nFrameMask'));

        str2 = '/Rx Antenna/Long Code DeScrambling Power Control Extracting';
        set_param([bdroot(block) str2],'nFrameMask',get_param(block,'nFrameMask'));

    case 'cbLongCScrMask'
        %-- Update parameters
        str1='/Tx Antenna/Long Code Scrambling Power Control and Signal Point Mapping';
        set_param([bdroot(block) str1],'longCScrMask',get_param(block,'longCScrMask'));

        str2 = '/Rx Antenna/Long Code DeScrambling Power Control Extracting';
        set_param([bdroot(block) str2],'longCScrMask',get_param(block,'longCScrMask'));
        
    case 'cbGateRateMask'
        %-- Update parameters
        str1='/Tx Antenna/Long Code Scrambling Power Control and Signal Point Mapping';
        set_param([bdroot(block) str1],'gateRateMask',get_param(block,'gateRateMask'));

        str2 = '/Rx Antenna/Long Code DeScrambling Power Control Extracting';
        set_param([bdroot(block) str2],'gateRateMask',get_param(block,'gateRateMask'));

    case 'cbTrChCode'
        %-- Update parameters
        set_param([bdroot(block) '/Rx Antenna/Rake Receiver'],...
            'trChCode',get_param(block,'trChCode'));
        set_param([bdroot(block) '/Tx Antenna/Spreading Non-TD Mode'],...
            'trChCode',get_param(block,'trChCode'));
        
    case 'cbPnOffset'
        %-- Update parameters
        set_param([bdroot(block) '/Rx Antenna/Rake Receiver'],...
            'pnOffset',get_param(block,'pnOffset'));
        set_param([bdroot(block) '/Tx Antenna/Spreading Non-TD Mode'],...
            'pnOffset',get_param(block,'pnOffset'));
        
    case 'cbQof_idx'
        %-- Update parameters
        set_param([bdroot(block) '/Rx Antenna/Rake Receiver'],...
            'qof_idx',get_param(block,'qof_idx'));
        set_param([bdroot(block) '/Tx Antenna/Spreading Non-TD Mode'],...
            'qof_idx',get_param(block,'qof_idx'));
        
    case 'cbTxDivMode'
       
        %-- Select scrambling repetition factor depending on Tranmist diversity
        % mode.
        if(strcmp(get_param(block,'TxDivMode'),'Non-TD'))
            scrBitRepetition = '1';
        else
            scrBitRepetition = '2';
        end

        %-- Scrambling Bit Repetition
        %assignin('base','scrBitRepetition',scrBitRepetition);

        %-- Update parameters
        str1='/Tx Antenna/Long Code Scrambling Power Control and Signal Point Mapping';
        set_param([bdroot(block) str1],'TxDivMode',get_param(block,'TxDivMode'));

        str2 = '/Rx Antenna/Long Code DeScrambling Power Control Extracting';
        set_param([bdroot(block) str2],'TxDivMode',get_param(block,'TxDivMode'));
        
    case 'cbChMode1'
        
        setfieldindexnumbers(block);
        en = get_param(gcb,'MaskEnables');
        vis = get_param(gcb,'MaskVisibilities');

        if(strcmp(get_param(block,'chMode1'),'No Channel'))
            en{idxEcN0} = 'off';
            [vis{[idxDopplerFreq idxDelayVector idxGainVector]}] = deal('off');
        elseif (strcmp(get_param(block,'chMode1'),'AWGN Channel'))
            en{idxEcN0} = 'on';
            [vis{[idxDopplerFreq idxDelayVector idxGainVector]}] = deal('off');
        else
            en{idxEcN0} = 'on';
            [vis{[idxDopplerFreq idxDelayVector idxGainVector]}] = deal('on');

        end

        set_param(block,'MaskEnables',en,'MaskVisibilities',vis );
        set_param([bdroot(block) '/Channel Model/Channel1'],...
            'BlockChoice',get_param(block,'chMode1'));
        
    case 'init'
        %-- Get mask values
        setallfieldvalues(block);
        
        %-- PLCM : Public Long Code Mask
        plcm_37 = randint(1,37,2); 
        plcm_37_str = ['[1 1 0 0 0 ' num2str(plcm_37) ']'];
        str1='/Tx Antenna/Long Code Scrambling Power Control and Signal Point Mapping';
        set_param([bdroot(block) str1],'plcMask', plcm_37_str);
        str2 = '/Rx Antenna/Long Code DeScrambling Power Control Extracting';
        set_param([bdroot(block) str2],'plcMask', plcm_37_str);

        %-- Generate Interleaver table
        numSampInt = 768;
        radConfig = 3;
        interTable = cdma2000_inttable(numSampInt, radConfig);
        assignin('base','interTable',interTable);

        %-- Set Channel Settings
        if maskChMode1 == 2,%AWGN channel
            str = '/Channel Model/Channel1/AWGN Channel';
            set_param([bdroot(block) str],'EsNodB', num2str(maskEcN0));
        elseif maskChMode1 == 3 % Fading Channel
            str = '/Channel Model/Channel1/Multipath Fading Channel';
            set_param([bdroot(block) str],'EcN0', num2str(maskEcN0), ...
                'dopplerFreq', num2str(maskDopplerFreq), ...
                'delayVector',['[' num2str(maskDelayVector) ']'], ...
                'gainVector',['[' num2str(maskGainVector) ']']);
        end
        
        %-- Rake receiver settings
        fingerEnables = length(maskDelayVector);
        fingerEnables = [ones(1,fingerEnables) zeros(1,4-fingerEnables)];
        fingerPhasesTicks = [maskDelayVector zeros(1,4-length(maskDelayVector))];
        fingerPhasesTicks = round(fingerPhasesTicks*1.2288e6*4);
        set_param([bdroot(block) '/Rx Antenna/Rake Receiver'], ...
            'fingerEnables', ['[' num2str(fingerEnables) ']'], ...
            'fingerPhases',['[' num2str(fingerPhasesTicks) ']']);

    case 'default'

        %-- to restore default values

        %-- Get variables from mask
        vals = get_param(block, 'maskValues');
        vis  = get_param(block, 'MaskVisibilities');
        Cb   = get_param(block, 'MaskCallbacks');
        en   = get_param(block, 'MaskEnables');

        setfieldindexnumbers(block);

        %-- Set default values
        vals{idxChType}         = 'Forward Fundamental';
        vals{idxRadConfig}      = 'Radio Configuration 3';
        vals{idxDataRates}      = '9.6 Kbps';
        vals{idxNFrameMask}     = '1';
        vals{idxLongCScrMask}   = 'On';
        vals{idxGateRateMask}   = '1/4';
        vals{idxTrChCode}       = '23';
        vals{idxPnOffset}       = '1';
        vals{idxQof_idx}        = '2';
        vals{idxTxDivMode}      = 'Non-TD';
        vals{idxChMode1}        = 'Multipath Fading Channel';
        vals{idxEcN0}           = '10';
        vals{idxDopplerFreq}    = '486';
        vals{idxDelayVector}    = '[0 260e-9 521e-9 781e-9]';
        vals{idxGainVector}     = '[0 -3 -6 -9]';
        
        %-- Set visibilities
        [vis{(1:length(vis))}]  = deal('on');
        
        %-- Set enables
        idxOff  = [idxChType idxRadConfig idxNFrameMask idxTxDivMode];
        [en{(1:length(vis))}]  = deal('on');
        [en{idxOff}]  = deal('off');
        
        %-- Set Callbacks
        sFile = mFilename;
        [Cb{(1:length(Cb))}] = deal('');
        Cb{idxDataRates}        = sprintf('%s(gcb,''cbDataRates'');',sFile);
        Cb{idxNFrameMask}       = sprintf('%s(gcb,''cbNFrameMask'');',sFile);
        Cb{idxLongCScrMask}     = sprintf('%s(gcb,''cbLongCScrMask'');',sFile);
        Cb{idxGateRateMask}     = sprintf('%s(gcb,''cbGateRateMask'');',sFile);
        Cb{idxTrChCode}         = sprintf('%s(gcb,''cbTrChCode'');',sFile);
        Cb{idxPnOffset}         = sprintf('%s(gcb,''cbPnOffset'');',sFile);
        Cb{idxQof_idx}          = sprintf('%s(gcb,''cbQof_idx'');',sFile);
        Cb{idxTxDivMode}        = sprintf('%s(gcb,''cbTxDivMode'');',sFile);
        Cb{idxChMode1}          = sprintf('%s(gcb,''cbChMode1'');',sFile);
        
        %-- Restore propierties
        set_param(block, 'MaskVisibilities',vis,'MaskValues',vals, ...
            'MaskCallbacks',Cb,'MaskEnables',en);
end
% end of cdma2000_initmask.m