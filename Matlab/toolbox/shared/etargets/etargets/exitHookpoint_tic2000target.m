function cout = exitHookpoint_tic2000target (target_state, modelInfo)

% $RCSfile: exitHookpoint_tic2000target.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:07:48 $
% Copyright 2003-2004 The MathWorks, Inc.

% obtain handle to the target preference object associated with the model
[h, errmsg] = getTargetPreferences_tic2000;
error (errmsg);

% unless 'Generate_code_only' is selected, create, build, load and run CCS project
if ~isequal (h.getBuildOptions.getRunTimeOptions.getBuildAction, 'Generate_code_only'),  
    % unless 'Create_CCS_Project' is selected, continue 
    if ~isequal (h.getBuildOptions.getRunTimeOptions.getBuildAction, 'Create_CCS_Project'),        
        % compile and link the project
        h.getCCSLink.buildCCSProject (target_state.ccsObj, modelInfo.name);
        % delete object files if specified
        if isequal (h.getBuildOptions.getLinkerOptions.getKeepOBJFiles, 'off'),
            h.getCCSLink.deleteObjectFiles(modelInfo);
        end
        if isequal (h.getBuildOptions.getRunTimeOptions.getBuildAction, 'Build_and_execute'),
            if isequal (h.getDSPBoard.getDSPChip.getDSPChipLabel, 'TI TMS320C2812') || ...
                isequal (h.getDSPBoard.getDSPChip.getDSPChipLabel, 'TI TMS320C2810'),
                % execute: RESET, LOAD, and RUN
                target_state.ccsObj.reset;
                h.getCCSLink.loadCCSProject (target_state.ccsObj, modelInfo.name)
                target_state.ccsObj.run;
            elseif isequal (h.getDSPBoard.getDSPChip.getDSPChipLabel, 'TI TMS320C2407')
                % execute: RESET, LOAD, RESET, and RUN
                % this order ensures that disable WD is executed (called from reset ISV)  
                target_state.ccsObj.reset;                
                h.getCCSLink.loadCCSProject (target_state.ccsObj, modelInfo.name)
                target_state.ccsObj.reset;
                target_state.ccsObj.run;
            else
                error(['Unrecognized DSP chip label.' ]);
            end
        end
    end   
else    
    % 'Generate_code_only' is selected: create batch file containing cl28x command line
    % createBatFile_TItarget(modelInfo);    
end

% Clean up the persistent state
% Note: this will (intentionally) clear our copy of the ccsObj now
%       The user may have their own copy of this, depending on generation options
cout=[];

% Clean up persistent storage in ti_RTWdefines
ti_RTWdefines('clear');

% [EOF] exitHookpoint_tic2000target.m
