function vnvcallback(method,modelH)
% Notification gateway called from Simulink

% Copyright 2003 The MathWorks, Inc.

    switch(method)
    case 'postLoad'
        if ~is_mathworks_lib(modelH)
            vnv_assert_mgr('mdlPostLoad',modelH);
        end
        
    case 'init' 
        vnv_assert_mgr('mdlInit',modelH);

    case 'start'
    case 'stop'
    case 'preSave'
        vnv_assert_mgr('mdlPreSave',modelH);

        % Remove coverage highlighting if present
        modelColorData = get_param(modelH,'covColorData');
        if ~isempty(modelColorData)
            cvslhighlight('revert',modelH);
        end

    case 'vnvDirty'
        vnv_assert_mgr('mdlVnvDirty',modelH);
        
    case 'unknown'
    otherwise
        error('Unexpected notification type');
    end


function out = is_mathworks_lib(modelH)
    out = 0;
    if strncmp(get_param(modelH,'Name'),'simulink',8)
        out = 1;
    end


