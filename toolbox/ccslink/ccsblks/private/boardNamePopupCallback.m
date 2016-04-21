function boardNamePopupCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:44:54 $

% Pass new choice into UserData
% Update the proc list according to the chosen board.

blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');

boardIndex = get(hObject,'value');
c = ccsboardinfo;
UDATA.boardName = c(boardIndex).name;

procList = '';
for k = 1:length(c(boardIndex).proc)
    if k>1,
        procList = [procList '|'];
    end
    procList = [procList c(boardIndex).proc(k).name];
end
set(handles.procNamePopupTag,'string',procList);
% Default to first proc in list
procIndex = 1;
set(handles.procNamePopupTag,'value',procIndex);
procName = c(boardIndex).proc(procIndex).name;
UDATA.procName = procName;

set_param(blk,'UserData',UDATA);
mdlName = HilBlkGetParentSystemName(blk);
set_param(mdlName,'Dirty','on');

% Invalidate stored CCS Link objects
PDATA = HilBlkPersistentData(blk,'get');
PDATA.ccsObjStale = true;
PDATA.tgtFcnObjStale = true;
HilBlkPersistentData(blk,'set',PDATA);
