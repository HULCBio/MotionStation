function report_tableexec_setup(varargin)
% TABLEEXEC_SETUP - Generate a global data structure 
% to support reporting for look-up table coverage.

% Copyright 2003 The MathWorks, Inc.

    global gtableExec;

    gtableExec.rawData = [];
    
    for i=1:length(varargin)
        if isempty(varargin{i}.metrics.tableExec)
            cv('set', varargin{i}.id, '.data.tableExec', zeros(length(gtableExec.rawData), 1));
        end; %if
        gtableExec.dataObjs{i} = varargin{i};
        gtableExec.rawData = [gtableExec.rawData varargin{i}.metrics.tableExec];
    end
    



