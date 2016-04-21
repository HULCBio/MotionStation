function globVarNameEditBoxCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:01 $


blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');

selectedArgNum = get(handles.argChooserListboxTag,'value');
if selectedArgNum > UDATA.numArgs,
    error('This callback should not be reached for Return Value');
end
UDATA.args(selectedArgNum).globVarName = get(hObject,'string');

set_param(blk,'UserData',UDATA);
mdlName = HilBlkGetParentSystemName(blk);
set_param(mdlName,'Dirty','on');
