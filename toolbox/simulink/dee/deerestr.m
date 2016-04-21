function deerestr()

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8 $

figh = gcf;
controlhands = get(figh,'UserData');
se = controlhands(1);
so = controlhands(2);
st = controlhands(5);
linb = controlhands(13);

set(linb,'String','Linearize');
set(linb,'UserData',1);

set(st,'String','Status: Restoring system...');
drawnow;

seRestore = findobj(figh,'Tag','SE_Restore');
soRestore = findobj(figh,'Tag','SO_Restore');

seStr = get(seRestore,'String');
soStr = get(soRestore,'String');

set(se,'String',seStr);
set(so,'String',soStr);

deeupdat;
