function [stop,optnew,updateoptions] = psearchtooloutput(optimval,optlast,flag)
%psearchtooloutput private to PFMINLCON, PFMINBND, PFMINUNC. 

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/09 16:16:01 $

%Initialize
stop = false;
updateoptions = false;
optnew = optlast;
drawnow;
STOP = 0;
RUN_RESUME = 1;
PAUSE = 2;

switch flag
    case 'init'
        psearchtoolGui = com.mathworks.toolbox.gads.DirectSearch.getDirectSearch;
        [msg,id] = lastwarn;
        if ~isempty(msg)
            psearchtoolGui.appendResults(['Warning: ',lastwarn]);
        end
        setappdata(0,'last_warning_id_for_psearchtool',id);
        %Set up for the GUI.
        return; %Nothing to do now
    case 'iter'
        psearchtoolGui = com.mathworks.toolbox.gads.DirectSearch.getDirectSearch;
        if isempty(psearchtoolGui)
            stop = true;
            return;
        end
        [msg,id] = lastwarn;
        if ~isempty(msg) && ~strcmp(id,getappdata(0,'last_warning_id_for_psearchtool'))
            psearchtoolGui.appendResults(['Warning: ',lastwarn]);
            lastwarn('');
        end
        psearchtoolGui.setIteration(value2RHS(optimval.iteration));
        %Action based on run mode of GUI
        RunMode = psearchtoolGui.getRunMode;
        switch RunMode
            case RUN_RESUME
                
            case STOP   %Stop
                stop = true;
                return;
            case PAUSE  %Pause
                fprintf('%s\n%s\n','PSEARCHTOOL is paused. MATLAB Command prompt will', ...
                    'not be accessible until the pattern search solver is completed.');
                %If in pause state keeping looping here.
                while true
                    drawnow
                    if isempty(com.mathworks.toolbox.gads.DirectSearch.getDirectSearch)
                        stop = true;
                        return;
                    end
                    mode = psearchtoolGui.getRunMode;
                    if mode == STOP
                        stop = true;
                        return;
                    elseif mode == RUN_RESUME
                        break;
                    end
                end % End while 
            otherwise
                return;
        end
        
        if  psearchtoolGui.getChangedState
            h = psearchtoolGui.getChangedModelAndClear;
            [optnew,err] = psguiReadHashTable(h);
            try 
                if ~isempty(err)
                    rethrow(lasterror);
                end
                checkoptions(optnew,psoptimset(@patternsearch),length(optimval.x(:)));
                updateoptions = true;
            catch 
                errordlg(lasterr,'Pattern search run time error');    
                psearchtoolGui.setRunMode(2)  %Set GUI to pause.
                optnew = optlast;  %Don't change the options if it contains errors
            end
        else
            optnew = optlast;
        end
        
        
    case 'done'
        psearchtoolGui = com.mathworks.toolbox.gads.DirectSearch.getDirectSearch;
        psearchtoolGui.setIteration(value2RHS(optimval.iteration));
        if isappdata(0,'last_warning_id_for_psearchtool')
            rmappdata(0,'last_warning_id_for_psearchtool');
        end
        warning on;
        return;
        
    otherwise
        return;
        
end 
