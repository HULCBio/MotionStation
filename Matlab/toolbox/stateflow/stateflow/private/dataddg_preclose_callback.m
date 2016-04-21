function dataddg_preclose_callback(dlgH)

% Copyright 2003 The MathWorks, Inc.

if ~ishandle(dlgH)
    return;
end

h = dlgH.getDialogSource;
if ~isa(h, 'Stateflow.Data')
    return;
end

sf('SetDynamicDialog', h.Id, []);
if ~isempty(findstr(h.Tag, '_DDG_INTERMEDIATE_'))
    delete(h);
end
