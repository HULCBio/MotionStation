function exportIDEobject_DSPtarget(IDEobj,modelName)
% Optionally exports the IDE object if the user has selected this option 
% from the simulation parameters dialog.

% $RCSfile: exportIDEobject_DSPtarget.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:07:49 $
% Copyright 2001-2003 The MathWorks, Inc.

args = get_param(modelName,'RTWBuildArgs');
chbx='EXPORT_OBJ';
name='CCS_OBJ';

% get 'EXPORT_OBJ' checkbox state
exportVar = str2num(parseRTWBuildArgs_DSPtarget(args,chbx));
if exportVar,
    % export IDE object to base workspace, naming it as specified by user
    variable_name = parseRTWBuildArgs_DSPtarget(args,name);
    assignin('base', variable_name, IDEobj);
end

% [EOF] exportIDEobject_DSPtarget.m
