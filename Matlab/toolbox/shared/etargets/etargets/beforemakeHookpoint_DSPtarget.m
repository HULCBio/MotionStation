function target_state = beforemakeHookpoint_DSPtarget(target_state, modelInfo)

% $RCSfile: beforemakeHookpoint_DSPtarget.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/01 16:17:34 $
% Copyright 2001-2004 The MathWorks, Inc.

isMultiTasking = isMultiTasking_DSPtarget(modelInfo.buildOpts.solverMode);

% copy static source files to working directory
copyStaticSources_TItarget(isMultiTasking);

% Error if there are any non-inlined s-functions 
% (i.e., blocks without tlc files)
nisf = modelInfo.buildOpts.noninlinedSFcns;
if ~isempty(nisf) && ~isequal(nisf,{''}),
    % Exclude s-function builder blocks.
    foundNonSFB = false;
    nisf2 = {};  k2 = 0;
    for k = 1:length(nisf),
        if isempty(findstr(nisf{k},'_wrapper')),
            foundNonSFB = true;
            k2 = k2+1;
            nisf2{k2} = nisf{k};
        end
    end
    if foundNonSFB,
        msg = sprintf([...
                'The model contains non-inlined s-function blocks, which cannot be used with \n' ...
                'the Target for C6000.  Please remove the following blocks from the model: \n' ]);
        for k = 1:length(nisf2),
            msg = [msg nisf2{k} ' ' ];
        end
        error(msg);
    end
end

if isNotGenerateCodeOnly_DSPtarget(modelInfo.buildArgs),
    
    % build runtime libraries as necessary, get list of project files,
    %    build options, include paths, etc.
    [projectFiles, buildOptions] = prepareProject_TItarget...
        (target_state,modelInfo);
    
    createProject_TItarget(target_state,modelInfo,projectFiles,buildOptions);
    
    useDSPBIOS = isUsingDSPBIOS_TItarget(modelInfo);
    
    if (useDSPBIOS),
        % make sure the optimization level is not higher than -o1 for 
        modelfilename = [modelInfo.name '.c'];
        cur_boptstr = target_state.ccsObj.getbuildopt(modelfilename);            
        new_boptstr = strrep (cur_boptstr, '-o3', '-o1'); % reduce to -o1       
        new_boptstr = strrep (cur_boptstr, '-o2', '-o1'); % reduce to -o1
        callSwitchyard(target_state.ccsObj.ccsversion,[55 target_state.ccsObj.boardnum target_state.ccsObj.procnum 0 0],modelfilename,new_boptstr);
    end 
    
end

% [EOF] beforemakeHookpoint_DSPtarget.m