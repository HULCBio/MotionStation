function [state,optnew,updateoptions]  = gatooloutput(optlast,state,flag)
%gatooloutput private to GA. 

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/09 16:15:38 $

%Initialize

updateoptions = false;
optnew = optlast;
drawnow;
STOP = 0;
RUN_RESUME = 1;
PAUSE = 2;
switch flag
    case 'init'
        gatoolGui = com.mathworks.toolbox.gads.GeneticAlgorithm.getGeneticAlgorithm;
        [msg,id] = lastwarn;
        if ~isempty(msg)
            gatoolGui.appendResults(['Warning: ',lastwarn]);
        end
        setappdata(0,'last_warning_id_for_gatool',id);
        %Set up for the GUI.
        return; %Nothing to do now
    case 'iter'
        gatoolGui = com.mathworks.toolbox.gads.GeneticAlgorithm.getGeneticAlgorithm;
        if isempty(gatoolGui)
            state.StopFlag = 'Abnormal termination';
            return;
        end
        [msg,id] = lastwarn;
        if ~isempty(msg) && ~strcmp(id,getappdata(0,'last_warning_id_for_gatool'))
            gatoolGui.appendResults(['Warning: ',lastwarn]);
            lastwarn('');
        end
        gatoolGui.setIteration(value2RHS(state.Generation));
        %Action based on run mode of GUI
        RunMode = gatoolGui.getRunMode;
        switch RunMode
            case RUN_RESUME
                
            case STOP   %Stop
                state.StopFlag = 'Stop requested';
                return;
            case PAUSE  %Pause
                fprintf('%s\n%s\n','GATOOL is paused. MATLAB Command prompt will', ...
                    'not be accessible until the genetic algorithm solver is completed.');
                PauseTimeStart =cputime; 
                %If in pause state keeping looping here.
                while true
                    drawnow
                    if isempty(com.mathworks.toolbox.gads.GeneticAlgorithm.getGeneticAlgorithm)
                        state.StopFlag = 'Abnormal termination';
                        return;
                    end
                    mode = gatoolGui.getRunMode;
                    if mode == STOP
                        state.StopFlag = 'Stop requested';
                        return;
                    elseif mode == RUN_RESUME
                        break;
                    end
                end % End while 
                PauseTimeTotal  = (cputime - PauseTimeStart); %Total time the gui is paused
                %Pause state of the GUI is not included in stall tolerances.
                state.LastImprovementTime = state.LastImprovementTime + PauseTimeTotal;
                state.StartTime = state.StartTime + PauseTimeTotal;
            otherwise
                return;
        end
        
        if  gatoolGui.getChangedState
            h = gatoolGui.getChangedModelAndClear;
            [optnew,err] = gaguiReadHashTable(h);
            try 
                if ~isempty(err)
                    rethrow(lasterror);
                end
                %Argument list of FitnessFcn was removed; add it now
                FitnessFcn = {@unused};
                for i = 1:length(optlast.FitnessFcnArgs)
                    FitnessFcn{i+1} = optlast.FitnessFcnArgs{i};
                end
                [gl,ff,optnew] = validate(size(state.Population,2),FitnessFcn,optnew);
                updateoptions = true;
            catch 
                errordlg(lasterr,'GA run time error');    
                gatoolGui.setRunMode(2)  %Set GUI to pause.
                optnew = optlast;  %Don't change the options if it contains errors
            end
        else
            optnew = optlast;
        end
        
    case 'done'
        gatoolGui = com.mathworks.toolbox.gads.GeneticAlgorithm.getGeneticAlgorithm;
        gatoolGui.setIteration(value2RHS(state.Generation));
        %If using a hybrid function, give a message.
        if ~isempty(optlast.HybridFcn)
           gatoolGui.appendResults(sprintf('%s\n','Switching to hybrid function.'));
        end
        if isappdata(0,'last_warning_id_for_gatool')
            rmappdata(0,'last_warning_id_for_gatool');
        end
        warning on;
        return;
        
    otherwise
        return;
        
end 
