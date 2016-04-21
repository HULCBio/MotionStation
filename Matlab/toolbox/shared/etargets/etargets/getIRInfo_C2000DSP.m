function ret = getIRInfo_C2000DSP (modelName,RTWSampleTimes)

% $RCSfile: getIRInfo_C2000DSP.m,v $
% $Revision: 1.1.6.3 $ 
% $Date: 2004/04/08 21:07:59 $
% Copyright 2003-2004 The MathWorks, Inc.

try
    ret = [];

    % Get user Target Preferences and set attributes according to the chip used
    tgtPrefs = getTargetPreferences_tic2000;
    sysinfo.tgtPrefs = tgtPrefs;

    % Find the base sample time and set the timer period variable accordingly
    if (nargin==2), % perform this task only if sample times array is passed in
        if length(RTWSampleTimes)==1,
            AllSampleTimes = RTWSampleTimes.PeriodAndOffset(1);
        else
            % For multiple sample times,
            % TLC-to-M gives us a cell array of structures
            for k = 1:length(RTWSampleTimes),
                AllSampleTimes(k) = RTWSampleTimes{k}.PeriodAndOffset(1);
            end
        end
        ret.timerIntPeriod = AllSampleTimes(1); % Base sample time
    end

    % Set the masktype string for the system search according to the chip used
    switch lower(tgtPrefs.getDSPBoard.getDSPChip.getDSPChipLabel)
        case {'ti tmc320c2401', 'ti tms320c2407'}
            sysinfo.ADCblocktypes = {'C24x ADC'};
            sysinfo.PWMblocktypes = {'C24x PWM'};
            sysinfo.CANblocktypes = {'C24x CAN Receive', 'C24x CAN Transmit'};
            sysinfo.QEPblocktypes = {'C24x QEP'};
            sysinfo.GPIOblocktypes = {'C24x GPIO Digital Input', 'C24x GPIO Digital Output'};
            sysinfo.numGPIOpins = 8;            
        case {'ti tms320c2810', 'ti tms320c2812'}
            sysinfo.ADCblocktypes = {'C28x ADC'};
            sysinfo.PWMblocktypes = {'C28x PWM'};
            sysinfo.CANblocktypes = {'C28x eCAN Receive', 'C28x eCAN Transmit'};
            sysinfo.QEPblocktypes = {'C28x QEP'};
            sysinfo.GPIOblocktypes = {'C28x GPIO Digital Input', 'C28x GPIO Digital Output'};            
            sysinfo.numGPIOpins = 16;  
        otherwise
            error ('Unknown DSP chip label');
    end

    % Set the current DSP chip label obtained from the Target Preference block
    ret.DSPchipLabel = lower(tgtPrefs.getDSPBoard.getDSPChip.getDSPChipLabel);

    % Process all system blocks according to the search criteria set earlier
    [ret,ADCblocks] = processADCblocks (ret, modelName, sysinfo);
    [ret,PWMblocks] = processPWMblocks (ret, modelName, sysinfo);
    ret = processCANblocks (ret, modelName, sysinfo);
    ret = processQEPblocks (ret, modelName, sysinfo);
    ret = processRTDXblocks (ret, modelName, sysinfo);
    ret = processGPIOblocks (ret, modelName, sysinfo);
catch
    disp (lasterr)
end

%-------------------------------------------------------------------------------
function [ret,ADCblocks] = processADCblocks (ret, modelName, sysinfo)
ADCblocks = [];
ADCblocks = find_system(modelName,'FollowLinks','on','LookUnderMasks','on','MaskType',sysinfo.ADCblocktypes{1});

%process all ADC blocks
if (~isempty(ADCblocks)),
    ret.numADCs = length (ADCblocks);
    for i=1:length (ADCblocks),
        ret.ADC{i}.useModule = get_param (ADCblocks{i},'useModule');
    end
else
    ret.numADCs = 0;
end

ret.numChannels = findNumChannels (ADCblocks);


%-------------------------------------------------------------------------------
function [ret,PWMblocks] = processPWMblocks (ret, modelName, sysinfo)

PWMblocks = [];
PWMblocks = find_system(modelName,'FollowLinks','on','LookUnderMasks','on','MaskType',sysinfo.PWMblocktypes{1});

% process all PWM blocks
if (~isempty(PWMblocks)),
    ret.numPWMs = length (PWMblocks);
    for i=1:length (PWMblocks),
        ret.PWM{i}.useModule = get_param (PWMblocks{i},'useModule');      
        if (ret.PWM{i}.useModule == 'A'), ret.PWM{i}.useTimer = 'EVA_timer1'; end
        if (ret.PWM{i}.useModule == 'B'), ret.PWM{i}.useTimer = 'EVB_timer3'; end                
        ret.PWM{i}.adcstartEvent = get_param (PWMblocks{i},'adcstartEvent');
        for j=1:3
            ret.PWM{i}.unitStatus{j} = strcmpi(get_param (PWMblocks{i}, ['unit' num2str(j) 'Status']), 'on');
        end               
    end
else
    ret.numPWMs = 0;
end


%-------------------------------------------------------------------------------
function ret = processCANblocks (ret, modelName, sysinfo)

CANblocks  = [];
CANblocks1 = find_system(modelName,'FollowLinks','on','LookUnderMasks','on','MaskType',sysinfo.CANblocktypes{1});
CANblocks2 = find_system(modelName,'FollowLinks','on','LookUnderMasks','on','MaskType',sysinfo.CANblocktypes{2});
CANblocks  = [CANblocks1; CANblocks2];

% process all CAN blocks
if (~isempty(CANblocks)),
    ret.numCANs = length (CANblocks); 
    for i=1:length (CANblocks),
        mboxNo = str2num (get_param (CANblocks{i},'mailboxNo'));
        if isempty (mboxNo),
            mboxname = get_param (CANblocks{i},'name');
            error (['The entry for the mailbox number of the block ''' mboxname ''' is invalid.']);
            return;   
        else
            ret.CAN{i}.mailboxNo = mboxNo; 
        end
    end    
else
    ret.numCANs = 0;
end

switch lower(sysinfo.tgtPrefs.getDSPBoard.getDSPChip.getDSPChipLabel)
    case {'ti tmc320c2810', 'ti tms320c2812'}
        ret.eCANMode = sysinfo.tgtPrefs.DSPBoard.DSPChip.eCAN.EnhancedCANMode;
    otherwise
end


%-------------------------------------------------------------------------------
function ret = processQEPblocks (ret, modelName, sysinfo)
QEPblocks = [];
QEPblocks = find_system(modelName,'FollowLinks','on','LookUnderMasks','on','MaskType',sysinfo.QEPblocktypes{1});

%process all QEP blocks
if (~isempty(QEPblocks)),
    ret.numQEPs = length (QEPblocks);
    for i=1:length (QEPblocks),
        ret.QEP{i}.useModule = get_param (QEPblocks{i},'useModule');
        if (ret.QEP{i}.useModule == 'A'), ret.QEP{i}.useTimer = 'EVA_timer2'; end
        if (ret.QEP{i}.useModule == 'B'), ret.QEP{i}.useTimer = 'EVB_timer4'; end
    end    
else
    ret.numQEPs = 0;
end


%-------------------------------------------------------------------------------
function ret = processGPIOblocks (ret, modelName, sysinfo)

GPIOblocks  = [];
GPIOblocks1 = find_system(modelName,'FollowLinks','on','LookUnderMasks','on','MaskType',sysinfo.GPIOblocktypes{1});
GPIOblocks2 = find_system(modelName,'FollowLinks','on','LookUnderMasks','on','MaskType',sysinfo.GPIOblocktypes{2});
GPIOblocks  = [GPIOblocks1; GPIOblocks2];

% process all GPIO blocks
if (~isempty(GPIOblocks)),
    ret.numGPIOs = length (GPIOblocks); 
    for i=1:length (GPIOblocks),
        ret.GPIO{i}.useIOPort = get_param (GPIOblocks{i},'useIOPort');
        for j=1:sysinfo.numGPIOpins
            ret.GPIO{i}.useBit{j} = strcmpi(get_param (GPIOblocks{i},['GPIO_Bit' num2str(j-1)]), 'on');
        end            
    end    
else
    ret.numGPIOs = 0;
end
    

%-------------------------------------------------------------------------------
function ret = processRTDXblocks (ret, modelName, sysinfo)

RTDXblocks = [];
FromRTDXblocks = find_system(modelName,'FollowLinks','on','LookUnderMasks','on','MaskType','From RTDX');
ToRTDXblocks = find_system(modelName,'FollowLinks','on','LookUnderMasks','on','MaskType','To RTDX');
RTDXblocks  = [FromRTDXblocks; ToRTDXblocks];

% process all RTDX blocks
ret.numRTDXs = length(RTDXblocks);


%-------------------------------------------------------------------------------
function numChannels = findNumChannels (ADCblocks)
numChannels = 0;
for i=1:length (ADCblocks),
    module = get_param (ADCblocks{i},'useModule');
    if (strcmp(module,'A') || strcmp(module,'A and B'))
        for j=0:7,
            chStatus = strcmp (get_param (ADCblocks{i},[ 'A' num2str(j)]), 'on'); 
            numChannels = numChannels + chStatus;  
        end            
    end;
    if (strcmp(module,'B') || strcmp(module,'A and B'))
        for j=0:7,
            chStatus = strcmp (get_param (ADCblocks{i},[ 'B' num2str(j)]), 'on'); 
            numChannels = numChannels + chStatus;   
        end            
    end;        
end

% [EOF] getIRInfo_C2000DSP.m
