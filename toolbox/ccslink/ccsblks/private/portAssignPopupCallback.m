function portAssignPopupCallback(hObject, eventdata, handles)
% Pass new choice into UserData
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:08 $

blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');

selectedArgNum = get(handles.argChooserListboxTag,'value');
portAssignNum = get(hObject,'value');
strings = get(hObject,'string');
if selectedArgNum > UDATA.numArgs,
    UDATA.retval.portAssign = 'Output port';
else
    UDATA.args(selectedArgNum).portAssign = strings{portAssignNum};
end
set_param(blk,'UserData',UDATA);
mdlName = HilBlkGetParentSystemName(blk);
set_param(mdlName,'Dirty','on');