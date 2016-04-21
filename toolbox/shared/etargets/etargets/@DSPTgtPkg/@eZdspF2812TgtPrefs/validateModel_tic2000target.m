function errormsg = validateModel_tic2000target (h, modelInfo)

% $RCSfile: validateModel_tic2000target.m,v $
% $Revision: 1.1.6.4 $ 
% $Date: 2004/04/08 21:07:28 $
% Copyright 2003-2004 The MathWorks, Inc.



IOPORTS = [{'GPIOA'},{'GPIOB'},{'GPIOD'},{'GPIOE'},{'GPIOF'},{'GPIOG'}];
ISIOPORTUSED = zeros(1,6);
ISIOPORTPINUSED = zeros(6,16);

% get internal model info
IRmodelInfo  = getIRInfo_C2000DSP (modelInfo.name);

% for now, there cannot be more than one of c2000 Target Preferences blocks
% (we do not care about the instances below the top level)
tgtprefblocks = find_system (gcs,'FollowLinks','on','LookUnderMasks','on', 'MaskType','c2000 Target Preferences');
if ( length(tgtprefblocks)~=1 )
    error ('The model may not contain more than one target preference block.'); 
    return;
end

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
    for j=1:3
        if (IRmodelInfo.PWM{i}.unitStatus{j})
            if (strcmp (IRmodelInfo.PWM{i}.useModule, 'A'))
                ISIOPORTPINUSED(1,j*2-1) = 1;
                ISIOPORTPINUSED(1,j*2) = 1;                
            else
                ISIOPORTPINUSED(2,j*2-1) = 1;
                ISIOPORTPINUSED(2,j*2) = 1;                
            end
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
        ISIOPORTPINUSED(1,9) = 1;
        ISIOPORTPINUSED(1,10) = 1;
    else
        ISIOPORTPINUSED(2,9) = 1;
        ISIOPORTPINUSED(2,10) = 1;
    end
end

% get the upper bound of the mailbox number depending on the CAN module mode
if strcmp (IRmodelInfo.eCANMode, 'off'), 
    ubound = 15;
    modestring = 'SCC';
else 
    ubound = 31; 
    modestring = 'HECC';    
end;
% make sure that in SCC mode only the mailboxes 0 - 15 are used in the model
% also, make sure that multiple eCAN blocks do not refer to the same mailbox
if ( IRmodelInfo.numCANs > 0 )
    mailboxesUsed = zeros(1,ubound+1);
    for i=1:IRmodelInfo.numCANs,
        mBoxNo = IRmodelInfo.CAN{i}.mailboxNo;
        if ( mBoxNo<0 || mBoxNo>ubound ) || ...
           ( mBoxNo - double (uint8 (mBoxNo)) ) % check if integer number
            error (['Mailbox number ' num2str(mBoxNo) ' is illegal. '...
                    modestring ' mode of the eCAN allows only integer numbers between 0 and ' num2str(ubound) '.']);
            return;            
        end    
        if ( mailboxesUsed (mBoxNo+1) )        
            error ('Multiple eCAN blocks cannot refer to the same mailbox number.');
            return;
        else
            mailboxesUsed (mBoxNo+1) = 1;
        end 
    end
end

% if a CAN block is found, mark CAN pins as used so that the other peripherals can't use it
if ( IRmodelInfo.numCANs > 0 )
    ISIOPORTPINUSED(5,7) = 1;
    ISIOPORTPINUSED(5,8) = 1;
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
        for j=1:16
            if (IRmodelInfo.GPIO{i}.useBit{j})
                if (ISIOPORTPINUSED(idx,j))
                    open('PinsAssignmentManual_c2812.html');                    
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

% EOF validateModel_tic2000target.m
