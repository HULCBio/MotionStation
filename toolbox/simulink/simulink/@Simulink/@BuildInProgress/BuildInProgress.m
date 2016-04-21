function h = BuildInProgress(mdl)
    % create the object

% Copyright 2004 The MathWorks, Inc.

    h = Simulink.BuildInProgress;
    h.ModelName = mdl;

    % set the BuildInProgress flag on
    if ~isempty(find(slroot,'-isa','Simulink.BlockDiagram','Name',h.ModelName))
        set_param(h.ModelName, 'BuildInProgress', 'on');
    end

    % add listener to reset BuildInProgress on object destruction
    h.Listener = handle.listener(h, 'ObjectBeingDestroyed', @reset);
end

function reset(h, event, varargin)
    % reset the BuildInProgress flag
    if ~isempty(find(slroot,'-isa','Simulink.BlockDiagram','Name',h.ModelName))
        set_param(h.ModelName, 'BuildInProgress', 'off');
    end 
end
