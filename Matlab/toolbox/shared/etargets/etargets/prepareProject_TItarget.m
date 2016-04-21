function [projectFiles,buildOptions] = prepareProject_TItarget...
                                (target_state,modelInfo)

% $RCSfile: prepareProject_TItarget.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:37:42 $
% Copyright 2001-2003 The MathWorks, Inc.


% create array of model project files (full names with path)
projectFiles = getSourceList_TItarget(target_state, modelInfo, []);

% get model build options
buildOptions = getBuildOptionsList_TItarget(modelInfo);


% [EOF] prepareProject_TItarget.m
