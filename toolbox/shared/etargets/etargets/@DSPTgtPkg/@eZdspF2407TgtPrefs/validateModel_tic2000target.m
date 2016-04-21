function errormsg = validateModel_tic2000target (h, modelInfo)

% $RCSfile: validateModel_tic2000target.m,v $
% $Revision: 1.1.6.4 $ 
% $Date: 2004/04/08 21:07:21 $
% Copyright 2003-2004 The MathWorks, Inc.



IOPORTS = [{'IOPA'},{'IOPB'},{'IOPC'},{'IOPD'},{'IOPE'},{'IOPF'}];
ISIOPORTUSED = zeros(1,6);
ISIOPORTPINUSED = zeros(6,8);

% get internal model info
IRmodelInfo  = getIRInfo_C2000DSP (modelInfo.name);

% for now, there cannot be more than one of c2000 Target Preferences blocks
% (we do not care about the instances below the top level)
tgtprefblocks = find_system (gcs,'FollowLinks','on','LookUnderMasks','on', 'MaskType','c2000 Target Preferences');
if ( length(tgtprefblocks)~=1 )
    error ('The model may not contain more than one target preference block.'); 
    return;
end

% check which timer is being used to drive the main program scheduler
userdata = get_param(tgtprefblocks{1},'userdata');
tgtprefs = userdata.tic2000TgtPrefs;
schedulertimer = tgtprefs.CodeGeneration.Scheduler.Timer;

% make sure multiple ADC blocks do not attempt to use the same resource (module)
if ( IRmodelInfo.numADCs == 2)
    if ( strcmp (IRmodelInfo.ADC{1}.useModule, IRmodelInfo.ADC{2}.useModule) || ...     
         strcmp (IRmodelInfo.ADC{1}.useModule, 'A and B') || strcmp (IRmodelInfo.ADC{2}.useModule, 'A and B') )        
        error ('Multiple ADC blocks cannot use the same module.');       
        return;        
    end
elseif ( IRmodelInfo.numADCs > 2)
    error ('No more than two ADC blocks are allowed in the model.'); 
    return;    
end

% make sure multiple PWM blocks do not attempt to use the same resource (module)
if ( IRmodelInfo.numPWMs == 2)
    if ( strcmp (IRmodelInfo.PWM{1}.useModule, IRmodelInfo.PWM{2}.useModule) )        
        error ('Multiple PWM blocks cannot use the same module.');       
        return;        
    end
elseif ( IRmodelInfo.numPWMs > 2)
    error ('No more than two PWM blocks are allowed in the model.'); 
    return;    
end

% for each PWM block, mark used pins so that the other peripherals can't use it
for i=1:IRmodelInfo.numPWMs
    if (strcmp (IRmodelInfo.PWM{i}.useModule, 'A'))      
        if (IRmodelInfo.PWM{i}.unitStatus{1})          
            ISIOPORTPINUSED(1,7) = 1;
            ISIOPORTPINUSED(1,8) = 1;                
        end
        if (IRmodelInfo.PWM{i}.unitStatus{2})          
            ISIOPORTPINUSED(2,1) = 1;
            ISIOPORTPINUSED(2,2) = 1;                
        end
        if (IRmodelInfo.PWM{i}.unitStatus{3})          
            ISIOPORTPINUSED(2,3) = 1;
            ISIOPORTPINUSED(2,4) = 1;                
        end
    elseif (strcmp (IRmodelInfo.PWM{i}.useModule, 'B'))      
        if (IRmodelInfo.PWM{i}.unitStatus{1})          
            ISIOPORTPINUSED(5,2) = 1;
            ISIOPORTPINUSED(5,3) = 1;                
        end
        if (IRmodelInfo.PWM{i}.unitStatus{2})          
            ISIOPORTPINUSED(5,4) = 1;
            ISIOPORTPINUSED(5,5) = 1;                
        end
        if (IRmodelInfo.PWM{i}.unitStatus{3})          
            ISIOPORTPINUSED(5,6) = 1;
            ISIOPORTPINUSED(5,7) = 1;                
        end
    end
end

% make sure multiple QEP blocks do not attempt to use the same resource (module)
if ( IRmodelInfo.numQEPs == 2)
    if ( strcmp (IRmodelInfo.QEP{1}.useModule, IRmodelInfo.QEP{2}.useModule) )        
        error ('Multiple QEP blocks cannot use the same module.');       
        return;        
    end
elseif ( IRmodelInfo.numQEPs > 2)
    error ('No more than two QEP blocks are allowed in the model.'); 
    return;    
end

% for each QEP block, mark used pins so that the other peripherals can't use it
for i=1:IRmodelInfo.numQEPs
    if (strcmp (IRmodelInfo.QEP{i}.useModule, 'A'))
        ISIOPORTPINUSED(1,4) = 1;
        ISIOPORTPINUSED(1,5) = 1;
    else
        ISIOPORTPINUSED(5,8) = 1;
        ISIOPORTPINUSED(6,1) = 1;
    end
end

%check for timer resource use conflicts
errorStr = checkTimerUseConflicts (IRmodelInfo, schedulertimer);
if (~isempty (errorStr)),
    error (errorStr);
    return;        
end


% the upper bound of the mailbox number is 5
ubound = 5;
% make sure that only the mailboxes 0 - 5 are used in the model
% also, make sure that multiple eCAN blocks do not refer to the same mailbox
if ( IRmodelInfo.numCANs > 0 )
    mailboxesUsed = zeros(1,ubound+1);
    for i=1:IRmodelInfo.numCANs,
        mBoxNo = IRmodelInfo.CAN{i}.mailboxNo;
        if ( mBoxNo<0 || mBoxNo>ubound ) || ...
           ( mBoxNo - double (uint8 (mBoxNo)) ) % check if integer number
            error (['Mailbox number ' num2str(mBoxNo) ' is illegal. '...
                    'CAN allows only integer numbers between 0 and ' num2str(ubound) '.']);
            return;            
        end    
        if ( mailboxesUsed (mBoxNo+1) )        
            error ('Multiple CAN blocks cannot refer to the same mailbox number.');
            return;
        else
            mailboxesUsed (mBoxNo+1) = 1;
        end 
    end
end

% if a CAN block is found, mark CAN pins as used so that the other peripherals can't use it
if ( IRmodelInfo.numCANs > 0 )
    ISIOPORTPINUSED(3,7) = 1;
    ISIOPORTPINUSED(3,8) = 1;
end

% Check solver options:  fixed-step, discrete
slvr = get_param (modelInfo.name, 'solver');
if ~strcmp (slvr,'FixedStepDiscrete'),
    error (['Fixed Step / Discrete solver is required for use with TI C2000.'])
end

% make sure multiple GPIO blocks do not attempt to use the same resource (IOports and pins)
for i=1:IRmodelInfo.numGPIOs
    idx = find (ismember (IOPORTS,IRmodelInfo.GPIO{i}.useIOPort));
    if (ISIOPORTUSED(idx)==1)
        error ('Multiple GPIO blocks cannot use the same IO port.');
        return;
    else
        ISIOPORTUSED(idx) = 1;
        for j=1:8
            if (IRmodelInfo.GPIO{i}.useBit{j})
                if (ISIOPORTPINUSED(idx,j))
                    open('PinsAssignmentManual_c2407.html');                    
                    error (['A GPIO block is trying to use ' IRmodelInfo.GPIO{i}.useIOPort ' pin ' num2str(j-1) '.' ...
                        ' This pin is already in use by another peripheral block. Select another pin' ...
                        ' or remove the peripheral block that shares ' IRmodelInfo.GPIO{i}.useIOPort ' pin ' num2str(j-1) ...
                        ' with the GPIO block.']);
                else
                    ISIOPORTPINUSED(idx,j) = 1;
                end
            end
        end
    end
end


%-------------------------------------------------------------------------------
function errorStr = checkTimerUseConflicts (IRmodelInfo, schedulertimer)

errorStr = '';
timers = {'EVA_timer1','EVA_timer2','EVB_timer3','EVB_timer4'};
timerUsedFlag = zeros (1,length(timers));

idx = find (strcmp(timers,schedulertimer));
if ~isempty (idx) 
    if timerUsedFlag(idx)
        errorStr = ['The scheduler is attempting to use the ' timers{idx} ' which is already in use.']; return;
    else
        timerUsedFlag(idx) = 1;
    end
end

for i=1:IRmodelInfo.numPWMs,
    idx = find (strcmp(timers,IRmodelInfo.PWM{i}.useTimer));
    if ~isempty (idx) 
        if timerUsedFlag(idx)
            errorStr = ['A PWM block is attempting to use the ' timers{idx} ' which is already in use.']; return;
        else
            timerUsedFlag(idx) = 1;
        end
    end
end

for i=1:IRmodelInfo.numQEPs,
    idx = find (strcmp(timers,IRmodelInfo.QEP{i}.useTimer));
    if ~isempty (idx) 
        if timerUsedFlag(idx)
            errorStr = ['A QEP block is attempting to use the ' timers{idx} ' which is already in use.']; return;
        else
            timerUsedFlag(idx) = 1;
        end
    end
end

% EOF validateModel_tic2000target.m
