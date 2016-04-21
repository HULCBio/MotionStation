function funcNameEditBoxCallback(hObject, eventdata, handles)
% Pass new choice into UserData and wipe the dependent gui portions clean

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $  $Date: 2004/04/08 20:44:57 $

blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');

newFuncName = get(hObject,'string');

set(handles.statusTextTag,'string','');

if isempty(newFuncName),
    uiwait(errordlg(['Please enter the name of a function that exists ' ...
            'in memory on the target.'], ...
        'Error in HIL Function Call Block','modal'));
    return;
end
    
if ~strcmp(UDATA.funcName,newFuncName);
    % Clear UserData
    HilBlkClearUserData(blk);
    UDATA = get_param(blk,'UserData');
    UDATA.funcName = newFuncName;
    set_param(blk,'UserData',UDATA);
    mdlName = HilBlkGetParentSystemName(blk);
    set_param(mdlName,'Dirty','on');
    HilBlkPersistentData(blk,'clear');  
    % Invalidate stored function object
    PDATA = HilBlkPersistentData(blk,'get');
    PDATA.tgtFcnObjStale = true;
    HilBlkPersistentData(blk,'set',PDATA);
    % Update GUI
    updateGuiForFunctionInfo(handles,blk);
    setEnablesOnAllQueryDependentParams(handles, 'off');
end    
