function ret = getIRInfo_C6713DSK(modelName, RTWSampleTimes,adcSampleTime,dacSampleTime)

% $RCSfile: getIRInfo_C6713DSK.m,v $
% $Revision: 1.1.6.1 $ 
% $Date: 2004/01/22 18:37:27 $
% Copyright 2001-2003 The MathWorks, Inc.

try
    
    % DSK has fixed CPU clock rate
    CPU_CLOCK_RATE = 225e6; 
    
    ADCblock = find_system(modelName,'FollowLinks','on','LookUnderMasks','on','MaskType','C6713DSK ADC');
    DACblock = find_system(modelName,'FollowLinks','on','LookUnderMasks','on','MaskType','C6713DSK DAC');
    ToRTDXblock = find_system(modelName,'FollowLinks','on','LookUnderMasks','on','MaskType','To RTDX');
    FromRTDXblock = find_system(modelName,'FollowLinks','on','LookUnderMasks','on','MaskType','From RTDX');
    
    if length(RTWSampleTimes)==1,
        AllSampleTimes = RTWSampleTimes.PeriodAndOffset(1);
    else
        % For multiple sample times, 
        % TLC-to-M gives us a cell array of structures
        for k = 1:length(RTWSampleTimes),
            AllSampleTimes(k) = RTWSampleTimes{k}.PeriodAndOffset(1);
        end
    end
    BaseSampleTime = AllSampleTimes(1);
    
    ret.RTDXIntNeeded = ~isempty(ToRTDXblock) || ~isempty(FromRTDXblock);
    
    if (isempty(ADCblock) && isempty(DACblock)),
        ret.DMAIntNeeded = 0; % DMA not used
        ret.DMAIntPeriod = 0;
        ret.timerIntNeeded = 1;
        ret.timerIntPeriod = floor (CPU_CLOCK_RATE * BaseSampleTime / 4);
        ret.timerStopCnt = 0; % Run timer forever
        ret.codecDataFormat = 0;
    else,
        if ~isempty(ADCblock),
            CODECblock = ADCblock;
            CODECsampleTime = adcSampleTime;
        else
            CODECblock = DACblock;
            CODECsampleTime = dacSampleTime;
        end
        
        ret.DMAIntNeeded = 1; % DMA used
        ret.DMAIntPeriod = floor (CPU_CLOCK_RATE * CODECsampleTime / 4);
        ret.timerIntNeeded = any (CODECsampleTime > AllSampleTimes); % needed only if codec rate not the fastest
        if (ret.timerIntNeeded),
            ret.timerIntPeriod = floor (CPU_CLOCK_RATE * BaseSampleTime / 4);
            ret.timerStopCnt = floor (ret.DMAIntPeriod / ret.timerIntPeriod) - 1;
        else,
            ret.timerIntPeriod = 0;
            ret.timerStopCnt = 0;
        end;
        % Get codec word length (data format) 
        % and convert e.g. "16-bit" to "16BIT"
        dataFormatParam = get_param(CODECblock,'CodecDataFormat');
        ret.codecDataFormat = upper(strrep(dataFormatParam,'-',''));
    end
    
    if ret.timerIntPeriod > 2^32-1, 
        error(['The base sample time of the model is too long ' ...
                'to fit in the 32-bit timer period register.  ']);
    end
    
catch
    
    disp(['Error executing m-file ' mfilename ' ...'])
    disp(lasterr)
    
end


% [EOF] getIRInfo_C6713DSK.m
