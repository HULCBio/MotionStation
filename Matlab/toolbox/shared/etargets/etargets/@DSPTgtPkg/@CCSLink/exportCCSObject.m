function exportCCSObject (h, IDEobj, modelName)
% Optionally exports the IDE object if the user has selected this option

% $RCSfile: exportCCSObject.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:06:32 $
% Copyright 2003-2004 The MathWorks, Inc.

if isequal (h.getExportCCSHandle, 'on'),
    % export IDE object to base workspace, naming it as specified by user
    variable_name = h.getCCSHandleName;
    assignin ('base', variable_name, IDEobj);
end

% [EOF] exportCCSObject.m
