function syncDlgStopTimes(system)

% Copyright 2003 The MathWorks, Inc.

root   = DAStudio.ToolRoot;
dlgH   = root.getOpenDialogs;

ind = strfind(system, filesep);
for i = 1:length(dlgH)
    source = dlgH(i).getDialogSource;
    if isa(source, 'Simulink.ConfigSet')
        mdl = get(source.getParent, 'Name');
    elseif isa(source, 'Simulink.SolverCC')
        mdl = get(source.getParent.getParent, 'Name');
    else
        continue;
    end
    
    if (isempty(ind))
        if (strcmp(system, mdl))
            dlgH(i).refresh;
        end
    else
        if (strcmp(system(ind(end):end), mdl))
            dlgH(i).refresh;
        end
    end
end