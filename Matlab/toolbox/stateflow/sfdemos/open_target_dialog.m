function open_target_dialog(modelName, targetName)

% Copyright 2003 The MathWorks, Inc.

root = sfroot;
mach = root.find('-isa', 'Stateflow.Machine', '-and', 'Name', modelName);

switch(targetName)
case 'sfun'
	h = mach.find('-isa', 'Stateflow.Target', '-and', 'Name', 'sfun');
	DAStudio.Dialog(h);
case 'rtw'
	h = mach.find('-isa', 'Stateflow.Target', '-and', 'Name', 'rtw');
	DAStudio.Dialog(h);
end;