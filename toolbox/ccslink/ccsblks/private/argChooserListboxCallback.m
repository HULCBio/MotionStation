function argChooserListboxCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:44:53 $

% Pass new choice into UserData

blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');
selectedArgNum = get(hObject,'value');
if selectedArgNum > UDATA.numArgs,
    arg = UDATA.retval;
else
    arg = UDATA.args(selectedArgNum);
end
setVisOnPointerSpecificItems(handles,arg,'on');
setArgSpecificParamValues(handles,arg);
