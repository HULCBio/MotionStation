function processBuildAction_TItarget(ccsObj, modelInfo)

% $RCSfile: processBuildAction_TItarget.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:08:12 $
% Copyright 2001-2003 The MathWorks, Inc.

% get retain-object-files flag
retainObj=str2num(parseRTWBuildArgs_DSPtarget(modelInfo.buildArgs, 'RETAIN_OBJ'));

% if BUILD_ACTION is not 'Create_CCS_Project' 
%     (i.e., "Build" or "Build_and_execute")
if isNotCreateProject(modelInfo.buildArgs),
    
    % compile and link the project
    buildProject_TItarget(ccsObj, modelInfo.name);
    
    % delete object files if specified
    if ~retainObj,
        deleteObjectFiles_TItarget(modelInfo);
    end
    
    if isBuildandExecute(modelInfo.buildArgs),
        % execute BUILD, RESET, LOAD, and RUN
        ccsObj.reset;
        % if DSK target, pause to let reset finish
        if strcmp(getTargetType_DSPtarget(modelInfo.name), 'C6711DSK'),
            pause(0.5);
        end
        loadProject_TItarget(ccsObj, modelInfo.name)
        ccsObj.run;
    end
end


%-------------------------------------------------------------------------------
function bool = isNotCreateProject(arg)
bool = isempty(findstr(arg,'BUILD_ACTION="Create_CCS_Project"'));

function bool = isBuildandExecute(arg)
bool = ~isempty(findstr(arg,'BUILD_ACTION="Build_and_execute"'));

% [EOF] processBuildAction_TItarget.m
