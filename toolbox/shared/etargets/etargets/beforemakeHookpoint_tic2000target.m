function target_state = beforemakeHookpoint_tic2000target (target_state, modelInfo)

% $RCSfile: beforemakeHookpoint_tic2000target.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:07:40 $
% Copyright 2003-2004 The MathWorks, Inc.

% obtain handle to the target preference object associated with the model
[h, errmsg] = getTargetPreferences_tic2000;
error (errmsg);

isMultiTasking = isequal (modelInfo.buildOpts.solverMode, 'MultiTasking');
isGRTTarget = isequal (modelInfo.buildOpts.sysTargetFile, 'ti_c2000_grt.tlc');

% copy static source files to working directory
h.getCCSLink.copyStaticSourceFiles (isMultiTasking, isGRTTarget);

% Error if there are any non-inlined s-functions 
% (i.e., blocks without tlc files)
nisf = modelInfo.buildOpts.noninlinedSFcns;
if ~isempty(nisf),
    msg = sprintf([...
            'The model contains non-inlined s-function blocks, which cannot be used with \n' ...
            'the Target for C2000.  Please remove the following blocks from the model: \n' ]);
    for k = 1:length(nisf),
        msg = [msg nisf{k} ' ' ];
    end
    error(msg);
end
   
if ~isequal (h.getBuildOptions.getRunTimeOptions.getBuildAction, 'Generate_code_only'),    
    modules = [];
    % get project file pathnames
    projectFiles = h.getCCSLink.getSourceList (target_state, modelInfo, h.getBuildOptions.getLinkerOptions, modules);
    % get model build options
    buildOptions = h.getBuildOptions.getBuildOptionsList (modelInfo);
    % create Code Composer Studio project
    h.getCCSLink.createCCSProject (target_state, modelInfo, projectFiles, buildOptions);    
end

% [EOF] beforemakeHookpoint_tic2000target.m
