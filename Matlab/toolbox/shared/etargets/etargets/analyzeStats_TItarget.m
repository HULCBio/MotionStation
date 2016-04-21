function [S,P] = analyzeStats_TItarget(S,P)
% $Revision: 1.1.6.4 $ $Date: 2004/04/08 21:07:38 $
% Copyright 2001-2004 The MathWorks, Inc.

S.CpuClkSpeed = feval(['getCpuClockSpeed_' S.BoardType]);

% Time in seconds between interrupts, 
S.timeBetweenInterrupts = S.FundamentalStepSize;
S.cyclesBetweenInterrupts = S.timeBetweenInterrupts * S.CpuClkSpeed;

S.swi_P_index = [];

if ~S.isMultiTasking
    % Find the sts object corresponding to the software interrupt
    S.swiStsName = 'SWI_0';
    for m = 1:length(P.obj),
        if strcmp(S.swiStsName, P.obj(m).name),
            S.swi_P_index = m;
            break
        end
    end
    if isempty(S.swi_P_index)
        error(['STS object for ' S.swiStsName ' not found. ' ]);
    end
    S.swi_count = P.obj(S.swi_P_index).count;
end

% See if there is any data to report.
% If not, the user might need to be reminded
% that the application must execute for a while
% before (s)he asks for a report.
S.validData = false;
for k = 1:length(P.obj)
    if P.obj(k).count>0,
        S.validData = true;
        break;
    end
end

if S.validData,
    
    if S.isMultiTasking || isempty(S.swi_P_index),
        S.criticalHeadroom = [];
    else
        S.criticalHeadroom = (S.cyclesBetweenInterrupts ...
            - P.obj(S.swi_P_index).max)/S.CpuClkSpeed;
        S.overrun = (S.criticalHeadroom<0);
    end

    for k = 1:length(S.sys),
        
        % First, determine which elements in array P.obj correspond to this subsystem.
        for j = 1:length(S.sys(k).stsObj),
            % Find the P.obj(...) index corresponding to STS corresponding to S.sys(k)
            S.sys(k).stsObj(j).P_index = [];
            for m = 1:length(P.obj),
                if strcmp(S.sys(k).stsObj(j).name, P.obj(m).name),
                    S.sys(k).stsObj(j).P_index = m;  
                    break
                end
            end
            if isempty(S.sys(k).stsObj(j).P_index)
                error(['STS object ' S.sys(k).stsObj(j).name  ...
                        ' not found for subsystem ' S.sys(k).name]);
            end
        end
        
        % Shorthand for the P indices for this system.
        P_index_1 = S.sys(k).stsObj(1).P_index;
        if ~S.sys(k).OutputUpdateCombined,
            P_index_2 = S.sys(k).stsObj(2).P_index;
        end
        
        % Make sure there is a valid measurement for this system.
        S.sys(k).validData = ~( P.obj(P_index_1).count == 0 );
        
        if S.sys(k).validData,
            
            % Max amount of time (seconds) spent calculating this system.
            % No averaging is done here; we want the single iteration that
            % costs the most.
            % Note that CCS provides the statistics in 
            % units of CPU Clock Cycles.  The target stores stats
            % in High-res Timer Clicks.  CPU clock cycles happen 4
            % times faster (8 on a C64) than the high-res timer clicks.
            % But we don't have to worry about this, because when 
            % CCS pulls stats from the target, it applies an equation
            % on the host PC (configured in the STS Object properties) 
            % to convert the data into CPU Clock Cycles.  
            if S.sys(k).OutputUpdateCombined 
                S.sys(k).maxTime = P.obj(P_index_1).max / S.CpuClkSpeed;
            else
                if P.obj(P_index_2).max < 0,
                    S.sys(k).maxTime = P.obj(P_index_1).max / S.CpuClkSpeed;
                else
                    S.sys(k).maxTime = ( P.obj(P_index_1).max + ...
                        P.obj(P_index_2).max ) / S.CpuClkSpeed;
                end
            end
            
            % Max percentage of the interrupt interval that is spent on this subsystem.
            S.sys(k).maxPercentOfInterruptTime = (S.sys(k).maxTime) / ...
                S.timeBetweenInterrupts; %   [ * 100 ]
            
        else  % if system has invalid data:
            
            S.sys(k).maxTime = 0;
            S.sys(k).maxPercentOfInterruptTime = 0;
            
        end    
        
    end
    
end

% EOF  analyzeStats_TItarget.m
