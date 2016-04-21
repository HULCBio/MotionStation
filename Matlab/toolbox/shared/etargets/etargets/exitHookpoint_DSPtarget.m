function cout = exitHookpoint_DSPtarget(target_state, modelInfo)

% $RCSfile: exitHookpoint_DSPtarget.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:07:47 $
% Copyright 2001-2003 The MathWorks, Inc.

if isNotGenerateCodeOnly_DSPtarget(modelInfo.buildArgs),
    
    % call function to process BUILD_ACTION = "Build" or "Build_and_Execute"
    processBuildAction_TItarget(target_state.ccsObj,modelInfo);
    
else
    
    % Generate_code_only mode:  create batch file containing cl6x command line
    createBatFile_TItarget(modelInfo);
    
end

% Clean up the persistent state
% Note: this will (intentionally) clear our copy of the ccsObj now
%       The user may have their own copy of this, depending on generation options
cout=[];

% Clean up persistent storage in ti_RTWdefines
ti_RTWdefines('clear');

% [EOF] exitHookpoint_DSPtarget.m
