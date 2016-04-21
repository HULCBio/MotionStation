function procNamePopupCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:09 $


blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');
boardIndex = get(handles.boardNamePopupTag,'value');
c = ccsboardinfo;
procIndex = get(hObject,'value');
procName = c(boardIndex).proc(procIndex).name;
UDATA.procName = procName;
set_param(blk,'UserData',UDATA);
mdlName = HilBlkGetParentSystemName(blk);
set_param(mdlName,'Dirty','on');

PDATA = HilBlkPersistentData(blk,'get');
PDATA.ccsObjStale = true;
PDATA.tgtFcnObjStale = true;
HilBlkPersistentData(blk,'set',PDATA);
