function storageOptionPopupCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2004/04/08 20:45:26 $


blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');

selectedArgNum = get(handles.argChooserListboxTag,'value');
if selectedArgNum > UDATA.numArgs,
    error('This callback should not be reached for Return Value');
end
storageOptionNum = get(hObject,'value');
strings = get(hObject,'string');
storageOption = strings{storageOptionNum};
if strcmp(storageOption,'Automatic'),
    uiwait(errordlg( ...
    'The automatic storage feature is not yet implemented.', ...
    'Error in HIL Function Call Block','modal'));
else
    UDATA.args(selectedArgNum).storageOption = storageOption;
    set_param(blk,'UserData',UDATA);
    mdlName = HilBlkGetParentSystemName(blk);
    set_param(mdlName,'Dirty','on');
    % Update gui
    arg = UDATA.args(selectedArgNum);
    setVisOnStorageOptionDependentParams(handles,arg,'on');
    setStorageOptionDependentParamValues(handles,arg);
end
